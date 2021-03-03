import 'dart:math';

import 'package:firebase_auth_rest/firebase_auth_rest.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';

import 'test_config.dart';

Matcher isAfter(DateTime after) => predicate<DateTime>((e) => e.isAfter(after));

void main() {
  late final Client client;
  late final FirebaseAuth auth;

  setUpAll(() {
    client = Client();
    auth = FirebaseAuth(client, TestConfig.apiKey);
  });

  tearDownAll(() {
    client.close();
  });

  late FirebaseAccount account;
  late DateTime createdAt;
  var deleted = false;

  setUp(() async {
    createdAt = DateTime.now().toUtc();
    account = await auth.signUpAnonymous(autoRefresh: false);
  });

  tearDown(() async {
    if (!deleted) {
      await account.delete();
    }
    account.dispose();
  });

  test('setUp and tearDown work', () {
    expect(account.localId, isNotNull);
    expect(account.idToken, isNotNull);
    expect(account.refreshToken, isNotNull);
    expect(account.expiresAt, isNotNull);
  });

  test('refresh requests a new id token', () async {
    final oldId = account.localId;
    final oldExpires = account.expiresAt;

    final result = await account.refresh();

    expect(result, isNotNull);
    expect(account.idToken, result);
    expect(account.localId, oldId);
    expect(account.expiresAt, isAfter(oldExpires));
  });

  test('getDetails returns account details', () async {
    final details = await account.getDetails();
    printOnFailure(details.toString());

    expect(details, isNotNull);
    expect(details!.localId, account.localId);
    expect(details.email, isNull);
    expect(details.emailVerified, false);
    expect(details.displayName, isNull);
    expect(details.providerUserInfo, isEmpty);
    expect(details.photoUrl, isNull);
    expect(details.passwordHash, isNull);
    expect(details.passwordUpdatedAt, isNull);
    expect(details.validSince, isNull);
    expect(details.disabled, false);
    expect(details.createdAt, isNotNull);
    expect(
      DateTime.fromMillisecondsSinceEpoch(int.parse(details.createdAt!)),
      isAfter(createdAt),
    );
    expect(details.lastLoginAt, details.createdAt);
    expect(details.customAuth, false);
  });

  test('can update profile details', () async {
    var details = await account.getDetails();
    expect(details, isNotNull);
    expect(details!.displayName, isNull);
    expect(details.photoUrl, isNull);

    await account.updateProfile(
      displayName: const ProfileUpdate.update('testName'),
    );
    details = await account.getDetails();
    expect(details, isNotNull);
    expect(details!.displayName, 'testName');
    expect(details.photoUrl, isNull);

    await account.updateProfile(
      displayName: const ProfileUpdate.delete(),
      photoUrl: ProfileUpdate.update(Uri.parse(
        'https://example.org/profile.png',
      )),
    );
    details = await account.getDetails();
    expect(details, isNotNull);
    expect(details!.displayName, isNull);
    expect(details.photoUrl, Uri.parse('https://example.org/profile.png'));

    await account.updateProfile(
      photoUrl: const ProfileUpdate.delete(),
    );
    details = await account.getDetails();
    expect(details, isNotNull);
    expect(details!.displayName, isNull);
    expect(details.photoUrl, isNull);
  });

  test('can restore account from refresh token', () async {
    final restoredAccount = await FirebaseAccount.restore(
      client,
      account.api.apiKey,
      account.refreshToken,
    );
    try {
      expect(restoredAccount, isNotNull);
      expect(restoredAccount.refreshToken, account.refreshToken);

      expect(restoredAccount.getDetails(), completes);
    } finally {
      restoredAccount.dispose();
    }
  });

  test('account linking with fake email works', () async {
    String _generate(int length) => List<String>.generate(
          length ~/ 2,
          (i) => Random.secure().nextInt(256).toRadixString(16),
        ).join();

    final fakeMail = '${_generate(32)}@example.org';
    final fakePassword = _generate(64);

    final ok = await account.linkEmail(
      fakeMail,
      fakePassword,
      autoVerify: false,
    );
    expect(ok, false); // eMail is not verified.

    final details = await account.getDetails();
    expect(details, isNotNull);
    expect(details!.email, fakeMail);
    expect(details.emailVerified, false);
    expect(details.passwordHash, isNotNull);
    expect(details.providerUserInfo, hasLength(1));
    expect(
      details.providerUserInfo,
      contains(predicate<ProviderUserInfo>((p) => p.providerId == 'password')),
    );

    await account.updatePassword(fakePassword + fakePassword);
    final newDetails = await account.getDetails();
    expect(newDetails, isNotNull);
    expect(newDetails!.email, fakeMail);
    // expect(newDetails.passwordHash, isNot(details.passwordHash));
    expect(
      newDetails.passwordUpdatedAt,
      greaterThan(details.passwordUpdatedAt),
    );

    await account.unlinkProviders(['password']);
    final clearedDetails = await account.getDetails();
    expect(clearedDetails, isNotNull);
    expect(clearedDetails!.providerUserInfo, isEmpty);
  });

  test('requets fail after account was deleted', () async {
    await account.delete();
    deleted = true;

    expect(() => account.getDetails(), throwsA(isA<AuthException>()));
  });
}
