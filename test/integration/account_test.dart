import 'dart:math';

// dart_pre_commit:ignore-library-import
import 'package:firebase_auth_rest/firebase_auth_rest.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';

import 'test_config_vm.dart' if (dart.library.js) 'test_config_js.dart';

Matcher isAfter(DateTime after) => predicate<DateTime>(
      (e) => e.isAfter(after),
      'is after $after',
    );

void main() {
  late final Client client;
  late final FirebaseAuth auth;

  String _generateRnd(int length) => List<String>.generate(
        length ~/ 2,
        (i) => Random.secure().nextInt(256).toRadixString(16),
      ).join();

  setUpAll(() {
    client = Client();
    auth = FirebaseAuth(client, TestConfig.apiKey);
  });

  tearDownAll(() {
    client.close();
  });

  group('anonymous', () {
    late FirebaseAccount account;
    late DateTime createdAt;
    var deleted = false;

    setUp(() async {
      createdAt = DateTime.now().toUtc().subtract(const Duration(seconds: 2));
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
        DateTime.fromMillisecondsSinceEpoch(
          int.parse(details.createdAt!),
          isUtc: true,
        ),
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
        photoUrl: ProfileUpdate.update(
          Uri.parse(
            'https://example.org/profile.png',
          ),
        ),
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
      final fakeMail = '${_generateRnd(32)}@example.org';
      final fakePassword = _generateRnd(64);

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
        contains(
          predicate<ProviderUserInfo>((p) => p.providerId == 'password'),
        ),
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
  });

  test('email', () async {
    final fakeMail = '${_generateRnd(32)}@example.org';
    final fakePassword = _generateRnd(64);

    FirebaseAccount? account1;
    FirebaseAccount? account2;
    try {
      // create the account
      account1 = await auth.signUpWithPassword(
        fakeMail,
        fakePassword,
        autoVerify: false,
        autoRefresh: false,
      );
      expect(account1.localId, isNotNull);
      expect(account1.idToken, isNotNull);
      expect(account1.refreshToken, isNotNull);
      expect(account1.expiresAt, isNotNull);

      // list providers
      final providers = await auth.fetchProviders(fakeMail);
      expect(providers, hasLength(2));
      expect(providers, contains('email'));
      expect(providers, contains('password'));

      // sign in
      account2 = await auth.signInWithPassword(
        fakeMail,
        fakePassword,
        autoRefresh: false,
      );
      expect(account2.localId, account1.localId);
      expect(account2.idToken, isNotNull);
      expect(account2.refreshToken, isNotNull);
      expect(account2.expiresAt, isAfter(account1.expiresAt));
    } finally {
      account1?.dispose();
      account2?.dispose();
    }
  });
}
