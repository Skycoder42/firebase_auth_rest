// ignore_for_file: prefer_const_constructors
import 'dart:convert';

import 'package:firebase_auth_rest/rest.dart';
import 'package:firebase_auth_rest/src/firebase_account.dart';
import 'package:firebase_auth_rest/src/models/auth_exception.dart';
import 'package:firebase_auth_rest/src/models/delete_request.dart';
import 'package:firebase_auth_rest/src/models/idp_provider.dart';
import 'package:firebase_auth_rest/src/models/oob_code_request.dart';
import 'package:firebase_auth_rest/src/models/refresh_response.dart';
import 'package:firebase_auth_rest/src/models/signin_request.dart';
import 'package:firebase_auth_rest/src/models/signin_response.dart';
import 'package:firebase_auth_rest/src/models/update_request.dart';
import 'package:firebase_auth_rest/src/models/update_response.dart';
import 'package:firebase_auth_rest/src/models/userdata.dart';
import 'package:firebase_auth_rest/src/models/userdata_request.dart';
import 'package:firebase_auth_rest/src/models/userdata_response.dart';
import 'package:firebase_auth_rest/src/profile_update.dart';
import 'package:firebase_auth_rest/src/rest_api.dart';
import 'package:http/http.dart'; // ignore: import_of_legacy_library_into_null_safe
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'fakes.dart';
import 'firebase_account_test.mocks.dart';
import 'test_fixture.dart';

@GenerateMocks([
  Client,
  RestApi,
])
void main() {
  final mockApi = MockRestApi();
  const defaultSignInResponse = SignInResponse.anonymous(
    localId: 'localId',
    idToken: 'idToken',
    refreshToken: 'refreshToken',
    expiresIn: '5',
  );
  const defaultLinkEmailResponse = LinkEmailResponse(localId: 'localId');
  const defaultRefreshResponse = RefreshResponse(
    expires_in: '5',
    token_type: 'token_type',
    refresh_token: 'refresh_token',
    id_token: 'id_token',
    user_id: 'user_id',
    project_id: 'project_id',
  );
  const defaultLinkIdpResponse = LinkIdpResponse(
    federatedId: 'federatedId',
    providerId: 'providerId',
    localId: 'localId',
    idToken: 'idToken',
    refreshToken: 'refreshToken',
    expiresIn: '5',
  );
  const defaultUserData = UserData(localId: 'localId');

  late FirebaseAccount account;

  setUp(() {
    reset(mockApi);
  });

  tearDown(() {
    account.dispose();
  });

  group('create', () {
    final mockClient = MockClient();

    setUp(() {
      reset(mockClient);
    });

    test('apiCreate initializes account correctly', () {
      final expiresAt = DateTime.now().toUtc().add(Duration(seconds: 5));
      account = FirebaseAccount.apiCreate(
        mockApi,
        defaultSignInResponse,
        autoRefresh: false,
        locale: 'de-DE',
      );

      expect(account.api, mockApi);
      expect(account.localId, 'localId');
      expect(account.idToken, 'idToken');
      expect(account.refreshToken, 'refreshToken');
      expect(account.expiresAt.difference(expiresAt).inSeconds, 0);
      expect(account.autoRefresh, false);
      expect(account.locale, 'de-DE');
    });

    test('apiCreate starts refresh timer', () {
      final expiresAt = DateTime.now().toUtc().add(Duration(seconds: 5));
      account = FirebaseAccount.apiCreate(mockApi, defaultSignInResponse);

      expect(account.autoRefresh, true);
      expect(account.expiresAt.difference(expiresAt).inSeconds, 0);
    });

    test('create initializes api with correct client and key', () {
      const apiKey = 'API-KEY';
      account =
          FirebaseAccount.create(mockClient, apiKey, defaultSignInResponse);

      expect(account.api.client, mockClient);
      expect(account.api.apiKey, apiKey);
    });
  });

  group('restore', () {
    final mockClient = MockClient();

    setUp(() {
      reset(mockClient);

      when(mockApi.token(refresh_token: anyNamed('refresh_token')))
          .thenAnswer((i) async => defaultRefreshResponse);
    });

    test('apiRestore calls api.token with refreshToken', () async {
      const refreshToken = 'refreshToken';

      account = await FirebaseAccount.apiRestore(
        mockApi,
        refreshToken,
        autoRefresh: false,
      );

      verify(mockApi.token(refresh_token: refreshToken));
    });

    test('apiRestore initializes account correctly', () async {
      const refreshToken1 = 'refreshToken1';
      const refreshToken2 = 'refreshToken2';
      when(mockApi.token(refresh_token: refreshToken1))
          .thenAnswer((i) async => defaultRefreshResponse.copyWith(
                refresh_token: refreshToken2,
              ));

      final expiresAt = DateTime.now().toUtc().add(Duration(seconds: 5));
      account = await FirebaseAccount.apiRestore(
        mockApi,
        refreshToken1,
        autoRefresh: false,
        locale: 'de-DE',
      );

      expect(account.api, mockApi);
      expect(account.localId, defaultRefreshResponse.user_id);
      expect(account.idToken, defaultRefreshResponse.id_token);
      expect(account.refreshToken, refreshToken2);
      expect(account.expiresAt.difference(expiresAt).inSeconds, 0);
      expect(account.autoRefresh, false);
      expect(account.locale, 'de-DE');
    });

    test('apiRestore starts refresh timer', () async {
      final expiresAt = DateTime.now().toUtc().add(Duration(seconds: 5));
      account = await FirebaseAccount.apiRestore(mockApi, 'refreshToken');

      expect(account.autoRefresh, true);
      expect(account.expiresAt.difference(expiresAt).inSeconds, 0);
    });

    test('restore initializes api with correct client and key', () async {
      when(mockClient.post(
        any,
        body: anyNamed('body'),
        headers: anyNamed('headers'),
      )).thenAnswer((i) async => FakeResponse(
            body: json.encode(
              defaultRefreshResponse.copyWith(expires_in: '1').toJson(),
            ),
          ));

      const apiKey = 'API-KEY';
      account = await FirebaseAccount.restore(
        mockClient,
        apiKey,
        'refreshToken',
      );

      expect(account.api.client, mockClient);
      expect(account.api.apiKey, apiKey);
    });
  });

  group('autoRefresh', () {
    test('does nothing if disabled', () async {
      account = FirebaseAccount.apiCreate(
        mockApi,
        defaultSignInResponse.copyWith(expiresIn: '61'),
        autoRefresh: false,
      );

      await _wait(3);

      verifyZeroInteractions(mockApi);
    });

    test('sends token request one minute before timeout', () async {
      account = FirebaseAccount.apiCreate(
        mockApi,
        defaultSignInResponse.copyWith(expiresIn: '62'),
      );

      await _wait(3);

      verify(mockApi.token(refresh_token: 'refreshToken')).called(1);
    });

    test('sends token request again after timeout', () async {
      when(mockApi.token(refresh_token: anyNamed('refresh_token')))
          .thenAnswer((i) async => defaultRefreshResponse.copyWith(
                refresh_token: 'refreshToken2',
                expires_in: '62',
              ));

      account = FirebaseAccount.apiCreate(
        mockApi,
        defaultSignInResponse.copyWith(expiresIn: '62'),
      );

      await _wait(7);

      verify(mockApi.token(refresh_token: 'refreshToken')).called(1);
      verify(mockApi.token(refresh_token: 'refreshToken2')).called(2);
    });

    test('sends token request immediatly if timeout is below 60 seconds',
        () async {
      account = FirebaseAccount.apiCreate(
        mockApi,
        defaultSignInResponse,
      );

      await _wait(1);

      verify(mockApi.token(refresh_token: 'refreshToken')).called(1);
    });
  });

  group('methods', () {
    setUp(() {
      account = FirebaseAccount.apiCreate(
        mockApi,
        defaultSignInResponse,
        autoRefresh: false,
        locale: 'ab-CD',
      );
    });

    group('refresh', () {
      test('updates all properties', () async {
        const idToken = 'id';
        const refreshToken = 'refresh';
        when(mockApi.token(refresh_token: anyNamed('refresh_token')))
            .thenAnswer((i) async => defaultRefreshResponse.copyWith(
                  id_token: idToken,
                  refresh_token: refreshToken,
                  expires_in: '6000',
                ));

        final expiresAt = DateTime.now().toUtc().add(Duration(seconds: 6000));
        final token = await account.refresh();

        expect(token, idToken);
        expect(account.idToken, idToken);
        expect(account.refreshToken, refreshToken);
        expect(account.expiresAt.difference(expiresAt).inSeconds, 0);
      });

      test('forwards auth exceptions', () async {
        when(mockApi.token(refresh_token: anyNamed('refresh_token')))
            .thenThrow(AuthException(ErrorData()));

        expect(() => account.refresh(), throwsA(isA<AuthException>()));
      });

      test('token updates are streamed', () async {
        const idToken = 'nextId';
        when(mockApi.token(refresh_token: anyNamed('refresh_token')))
            .thenAnswer((i) async => defaultRefreshResponse.copyWith(
                  id_token: idToken,
                  expires_in: '5',
                ));

        expect(account.idTokenStream.isBroadcast, true);

        final firstElement = account.idTokenStream.first;
        await account.refresh();
        expect(await firstElement, idToken);
      });

      test('token update errors are streamed', () async {
        when(mockApi.token(refresh_token: anyNamed('refresh_token')))
            .thenThrow(AuthException(ErrorData()));

        final firstElement = account.idTokenStream.first;
        expect(() => account.refresh(), throwsA(isA<AuthException>()));
        expect(() => firstElement, throwsA(isA<AuthException>()));
      });
    });

    testWithData('requestEmailConfirmation sends oobCode request', const [
      Fixture('ee-EE', 'ee-EE'),
      Fixture(null, 'ab-CD'),
    ], (fixture) async {
      when(mockApi.sendOobCode(any, any))
          .thenAnswer((i) async => OobCodeResponse());

      await account.requestEmailConfirmation(locale: fixture.get0<String>());

      verify(mockApi.sendOobCode(
        OobCodeRequest.verifyEmail(
          idToken: 'idToken',
          requestType: OobCodeRequestType.VERIFY_EMAIL,
        ),
        fixture.get1<String>(),
      ));
    });

    test('confirmEmail sends confirm email request', () async {
      const code = 'code';
      when(mockApi.confirmEmail(any))
          .thenAnswer((i) async => ConfirmEmailResponse());

      await account.confirmEmail(code);

      verify(mockApi.confirmEmail(ConfirmEmailRequest(oobCode: code)));
    });

    group('getDetails', () {
      test('sends user data request', () async {
        when(mockApi.getUserData(any)).thenAnswer((i) async => UserDataResponse(
              users: [],
            ));

        final result = await account.getDetails();

        verify(mockApi.getUserData(UserDataRequest(idToken: 'idToken')));
        expect(result, null);
      });

      test('returns first user data element', () async {
        final userData = defaultUserData.copyWith(displayName: 'Max Muster');
        when(mockApi.getUserData(any)).thenAnswer((i) async => UserDataResponse(
              users: [
                userData,
                defaultUserData,
              ],
            ));

        final result = await account.getDetails();
        expect(result, userData);
      });
    });

    testWithData('updateEmail sends email update request', const [
      Fixture('ee-EE', 'ee-EE'),
      Fixture(null, 'ab-CD'),
    ], (fixture) async {
      const newEmail = 'new@mail.de';
      when(mockApi.updateEmail(any, any))
          .thenAnswer((i) async => EmailUpdateResponse(localId: ''));

      await account.updateEmail(newEmail, locale: fixture.get0<String>());

      verify(mockApi.updateEmail(
        EmailUpdateRequest(
          idToken: 'idToken',
          email: newEmail,
          returnSecureToken: false,
        ),
        fixture.get1<String>(),
      ));
    });

    test('updatePassword sends password update request', () async {
      const newPassword = 'pw';
      when(mockApi.updatePassword(any))
          .thenAnswer((i) async => PasswordUpdateResponse(localId: ''));

      await account.updatePassword(newPassword);

      verify(mockApi.updatePassword(PasswordUpdateRequest(
        idToken: 'idToken',
        password: newPassword,
        returnSecureToken: false,
      )));
    });

    testWithData('updateProfile sends profile update', [
      Fixture(
        null,
        null,
        null,
        null,
        const <DeleteAttribute>[],
      ),
      Fixture(
        null,
        ProfileUpdate<Uri>.update(Uri.parse('http://example.com/image.jpg')),
        null,
        Uri.parse('http://example.com/image.jpg'),
        const <DeleteAttribute>[],
      ),
      Fixture(
        null,
        ProfileUpdate<Uri>.delete(),
        null,
        null,
        const <DeleteAttribute>[DeleteAttribute.PHOTO_URL],
      ),
      Fixture(
        ProfileUpdate<String>.update('name'),
        null,
        'name',
        null,
        const <DeleteAttribute>[],
      ),
      Fixture(
        ProfileUpdate<String>.update('name'),
        ProfileUpdate<Uri>.update(Uri.parse('http://example.com/image.jpg')),
        'name',
        Uri.parse('http://example.com/image.jpg'),
        const <DeleteAttribute>[],
      ),
      Fixture(
        ProfileUpdate<String>.update('name'),
        ProfileUpdate<Uri>.delete(),
        'name',
        null,
        const <DeleteAttribute>[DeleteAttribute.PHOTO_URL],
      ),
      Fixture(
        ProfileUpdate<String>.delete(),
        null,
        null,
        null,
        const <DeleteAttribute>[DeleteAttribute.DISPLAY_NAME],
      ),
      Fixture(
        ProfileUpdate<String>.delete(),
        ProfileUpdate<Uri>.update(Uri.parse('http://example.com/image.jpg')),
        null,
        Uri.parse('http://example.com/image.jpg'),
        const <DeleteAttribute>[DeleteAttribute.DISPLAY_NAME],
      ),
      Fixture(
        ProfileUpdate<String>.delete(),
        ProfileUpdate<Uri>.delete(),
        null,
        null,
        const <DeleteAttribute>[
          DeleteAttribute.DISPLAY_NAME,
          DeleteAttribute.PHOTO_URL,
        ],
      ),
    ], (fixture) async {
      final nameUpdate = fixture.get0<ProfileUpdate<String>>();
      final photoUpdate = fixture.get1<ProfileUpdate<Uri>>();
      final nameData = fixture.get2<String>();
      final photoData = fixture.get3<Uri>();
      final deleteData = fixture.get4<List<DeleteAttribute>>()!;

      when(mockApi.updateProfile(any))
          .thenAnswer((i) async => ProfileUpdateResponse(localId: ''));

      await account.updateProfile(
        displayName: nameUpdate,
        photoUrl: photoUpdate,
      );

      verify(mockApi.updateProfile(ProfileUpdateRequest(
        idToken: 'idToken',
        displayName: nameData,
        photoUrl: photoData,
        deleteAttribute: deleteData,
        returnSecureToken: false,
      )));
    });

    group('linkEmail', () {
      test('sends link email request', () async {
        when(mockApi.linkEmail(any))
            .thenAnswer((i) async => defaultLinkEmailResponse);
        when(mockApi.sendOobCode(any, any))
            .thenAnswer((i) async => OobCodeResponse());

        const mail = 'mail';
        const password = 'password';
        final result = await account.linkEmail(
          mail,
          password,
          autoVerify: false,
        );

        verify(mockApi.linkEmail(LinkEmailRequest(
          idToken: 'idToken',
          email: mail,
          password: password,
          returnSecureToken: false,
        )));
        expect(result, false);
      });

      test('returns email verified as result', () async {
        when(mockApi.linkEmail(any))
            .thenAnswer((i) async => defaultLinkEmailResponse.copyWith(
                  emailVerified: true,
                ));

        final result = await account.linkEmail(
          'mail',
          'password',
          autoVerify: false,
        );

        expect(result, true);
      });

      testWithData(
          'requests email confirmation if not verified and enabled', const [
        Fixture('ee-EE', 'ee-EE'),
        Fixture(null, 'ab-CD'),
      ], (fixture) async {
        when(mockApi.linkEmail(any))
            .thenAnswer((i) async => defaultLinkEmailResponse);
        when(mockApi.sendOobCode(any, any))
            .thenAnswer((i) async => OobCodeResponse());

        final result = await account.linkEmail(
          'mail',
          'password',
          locale: fixture.get0<String>(),
        );
        expect(result, false);

        verify(mockApi.sendOobCode(
          OobCodeRequest.verifyEmail(
            idToken: 'idToken',
          ),
          fixture.get1<String>(),
        ));
      });

      test('does not request email confirmation if verified and enabled',
          () async {
        when(mockApi.linkEmail(any))
            .thenAnswer((i) async => defaultLinkEmailResponse.copyWith(
                  emailVerified: true,
                ));

        final result = await account.linkEmail(
          'mail',
          'password',
        );
        expect(result, true);

        verifyNever(mockApi.sendOobCode(any));
      });
    });

    test('linkIdp sends link idp request', () async {
      when(mockApi.linkIdp(any))
          .thenAnswer((i) async => defaultLinkIdpResponse);

      final provider = IdpProvider.google('token');
      final uri = Uri.parse('https://localhost:4242');
      await account.linkIdp(provider, uri);

      verify(mockApi.linkIdp(LinkIdpRequest(
        idToken: 'idToken',
        postBody: provider.postBody,
        requestUri: uri,
        returnIdpCredential: false,
        returnSecureToken: false,
      )));
    });

    test('unlinkProvider sends unlink request', () async {
      when(mockApi.unlinkProvider(any))
          .thenAnswer((i) async => UnlinkResponse(localId: ''));

      const providers = ['a', 'b'];
      await account.unlinkProviders(providers);

      verify(mockApi.unlinkProvider(UnlinkRequest(
        idToken: 'idToken',
        deleteProvider: providers,
      )));
    });

    group('delete', () {
      test('sends delete request', () async {
        when(mockApi.delete(any)).thenAnswer((i) async {});

        await account.delete();

        verify(mockApi.delete(DeleteRequest(
          idToken: 'idToken',
        )));
      });

      test('sends null to idToken stream', () async {
        when(mockApi.delete(any)).thenAnswer((i) async {});

        expect(account.idTokenStream.isEmpty, completion(true));
        await account.delete();
      });
    });

    test('dispose disables auto refresh and clears controller', () async {
      account
        ..autoRefresh = true
        ..dispose();

      expect(account.autoRefresh, false);
      expect(await account.idTokenStream.length, 0);
    });
  });
}

Future _wait(int seconds) => Future<void>.delayed(Duration(seconds: seconds));
