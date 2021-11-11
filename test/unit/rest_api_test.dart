// ignore_for_file: prefer_const_constructors
import 'dart:convert';

import 'package:firebase_auth_rest/src/models/auth_exception.dart';
import 'package:firebase_auth_rest/src/models/delete_request.dart';
import 'package:firebase_auth_rest/src/models/fetch_provider_request.dart';
import 'package:firebase_auth_rest/src/models/fetch_provider_response.dart';
import 'package:firebase_auth_rest/src/models/oob_code_request.dart';
import 'package:firebase_auth_rest/src/models/oob_code_response.dart';
import 'package:firebase_auth_rest/src/models/password_reset_request.dart';
import 'package:firebase_auth_rest/src/models/password_reset_response.dart';
import 'package:firebase_auth_rest/src/models/refresh_response.dart';
import 'package:firebase_auth_rest/src/models/signin_request.dart';
import 'package:firebase_auth_rest/src/models/signin_response.dart';
import 'package:firebase_auth_rest/src/models/update_request.dart';
import 'package:firebase_auth_rest/src/models/update_response.dart';
import 'package:firebase_auth_rest/src/models/userdata_request.dart';
import 'package:firebase_auth_rest/src/models/userdata_response.dart';
import 'package:firebase_auth_rest/src/rest_api.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'fakes.dart';

class MockClient extends Mock implements Client {}

extension FakeResponseX on When<Future<Response>> {
  void thenFake<T>(T model, [Map<String, dynamic>? overwrites]) =>
      thenAnswer((i) async => FakeResponse.forModel<T>(model, overwrites));
}

void main() {
  const apiKey = 'apiKey';
  final mockClient = MockClient();
  final api = RestApi(mockClient, apiKey);

  When<Future<Response>> whenPost() => when(
        () => mockClient.post(
          any(),
          body: any(named: 'body'),
          headers: any(named: 'headers'),
          encoding: any(named: 'encoding'),
        ),
      );

  void whenError() =>
      whenPost().thenAnswer((i) => Future.value(FakeResponse(statusCode: 400)));

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    reset(mockClient);
    whenPost().thenAnswer((i) async => FakeResponse());
  });

  test('Constructor initializes properties as expected', () {
    expect(api.client, mockClient);
    expect(api.apiKey, apiKey);
  });

  group('token', () {
    test('should send a post request with correct data', () async {
      whenPost().thenFake(
        const RefreshResponse(
          expires_in: '',
          token_type: '',
          refresh_token: '',
          id_token: '',
          user_id: '',
          project_id: '',
        ),
      );

      const token = 'token';
      await api.token(refresh_token: token);
      verify(
        () => mockClient.post(
          Uri.parse('https://securetoken.googleapis.com/v1/token?key=apiKey'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'refresh_token': token,
            'grant_type': 'refresh_token',
          },
        ),
      );
    });

    test('should throw AuthError on failure', () async {
      whenError();
      expect(
        () => api.token(refresh_token: 'token'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('signUpAnonymous', () {
    test('should send a post request with correct data', () async {
      whenPost().thenFake(
        AnonymousSignInResponse(
          idToken: '',
          refreshToken: '',
          expiresIn: '',
          localId: '',
        ),
      );

      await api.signUpAnonymous(AnonymousSignInRequest());
      verify(
        () => mockClient.post(
          Uri.parse(
            'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=apiKey',
          ),
          body: json.encode({
            'returnSecureToken': true,
          }),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
    });

    test('should throw AuthError on failure', () async {
      whenError();
      expect(
        () => api.signUpAnonymous(AnonymousSignInRequest()),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('signUpWithPassword', () {
    test('should send a post request with correct data', () async {
      whenPost().thenFake(
        const PasswordSignInResponse(
          idToken: '',
          refreshToken: '',
          expiresIn: '',
          localId: '',
        ),
      );

      await api.signUpWithPassword(
        PasswordSignInRequest(
          email: 'email',
          password: 'password',
        ),
      );
      verify(
        () => mockClient.post(
          Uri.parse(
            'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=apiKey',
          ),
          body: json.encode({
            'email': 'email',
            'password': 'password',
            'returnSecureToken': true,
          }),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
    });

    test('should throw AuthError on failure', () async {
      whenError();
      expect(
        () => api.signUpWithPassword(
          PasswordSignInRequest(
            email: '',
            password: '',
          ),
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('signInWithIdp', () {
    test('should send a post request with correct data', () async {
      whenPost().thenFake(
        const IdpSignInResponse(
          federatedId: '',
          providerId: '',
          localId: '',
          idToken: '',
          refreshToken: '',
          expiresIn: '',
        ),
      );

      await api.signInWithIdp(
        IdpSignInRequest(
          requestUri: Uri.parse('http://localhost'),
          postBody: 'postBody',
        ),
      );
      verify(
        () => mockClient.post(
          Uri.parse(
            'https://identitytoolkit.googleapis.com/v1/accounts:signInWithIdp?key=apiKey',
          ),
          body: json.encode({
            'requestUri': 'http://localhost',
            'postBody': 'postBody',
            'returnSecureToken': true,
            'returnIdpCredential': false,
          }),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
    });

    test('should throw AuthError on failure', () async {
      whenError();
      expect(
        () => api.signInWithIdp(
          IdpSignInRequest(
            requestUri: Uri(),
            postBody: 'postBody',
          ),
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('signInWithPassword', () {
    test('should send a post request with correct data', () async {
      whenPost().thenFake(
        const PasswordSignInResponse(
          idToken: '',
          refreshToken: '',
          expiresIn: '',
          localId: '',
        ),
      );

      await api.signInWithPassword(
        const PasswordSignInRequest(
          email: 'email',
          password: 'password',
        ),
      );
      verify(
        () => mockClient.post(
          Uri.parse(
            'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=apiKey',
          ),
          body: json.encode({
            'email': 'email',
            'password': 'password',
            'returnSecureToken': true,
          }),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
    });

    test('should throw AuthError on failure', () async {
      whenError();
      expect(
        () => api.signInWithPassword(
          const PasswordSignInRequest(
            email: '',
            password: '',
          ),
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('signInWithCustomToken', () {
    test('should send a post request with correct data', () async {
      whenPost().thenFake(
        const CustomTokenSignInResponse(
          idToken: '',
          refreshToken: '',
          expiresIn: '',
        ),
      );

      await api.signInWithCustomToken(
        const CustomTokenSignInRequest(token: 'token'),
      );
      verify(
        () => mockClient.post(
          Uri.parse(
            'https://identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=apiKey',
          ),
          body: json.encode({
            'token': 'token',
            'returnSecureToken': true,
          }),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
    });

    test('should throw AuthError on failure', () async {
      whenError();
      expect(
        () => api.signInWithCustomToken(
          const CustomTokenSignInRequest(token: 'token'),
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('getUserData', () {
    test('should send a post request with correct data', () async {
      whenPost().thenFake(const UserDataResponse());

      await api.getUserData(
        UserDataRequest(
          idToken: 'idToken',
        ),
      );
      verify(
        () => mockClient.post(
          Uri.parse(
            'https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=apiKey',
          ),
          body: json.encode({
            'idToken': 'idToken',
          }),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
    });

    test('should throw AuthError on failure', () async {
      whenError();
      expect(
        () => api.getUserData(
          UserDataRequest(
            idToken: 'idToken',
          ),
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('updateEmail', () {
    test('should send a post request with correct data', () async {
      whenPost().thenFake(const EmailUpdateResponse(localId: ''));

      await api.updateEmail(
        const EmailUpdateRequest(
          idToken: 'token',
          email: 'mail',
        ),
        'de-DE',
      );
      verify(
        () => mockClient.post(
          Uri.parse(
            'https://identitytoolkit.googleapis.com/v1/accounts:update?key=apiKey',
          ),
          body: json.encode({
            'idToken': 'token',
            'email': 'mail',
            'returnSecureToken': false,
          }),
          headers: {
            'X-Firebase-Locale': 'de-DE',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
    });

    test('should throw AuthError on failure', () async {
      whenError();
      expect(
        () => api.updateEmail(
          const EmailUpdateRequest(
            idToken: 'token',
            email: 'mail',
          ),
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('updatePassword', () {
    test('should send a post request with correct data', () async {
      whenPost().thenFake(const PasswordUpdateResponse(localId: ''));

      await api.updatePassword(
        const PasswordUpdateRequest(
          idToken: 'token',
          password: 'password',
        ),
      );
      verify(
        () => mockClient.post(
          Uri.parse(
            'https://identitytoolkit.googleapis.com/v1/accounts:update?key=apiKey',
          ),
          body: json.encode({
            'idToken': 'token',
            'password': 'password',
            'returnSecureToken': true,
          }),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
    });

    test('should throw AuthError on failure', () async {
      whenError();
      expect(
        () => api.updatePassword(
          const PasswordUpdateRequest(
            idToken: 'token',
            password: 'password',
          ),
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('updateProfile', () {
    test('should send a post request with correct data', () async {
      whenPost().thenFake(const ProfileUpdateResponse(localId: ''));

      await api.updateProfile(const ProfileUpdateRequest(idToken: 'token'));
      verify(
        () => mockClient.post(
          Uri.parse(
            'https://identitytoolkit.googleapis.com/v1/accounts:update?key=apiKey',
          ),
          body: json.encode({
            'idToken': 'token',
            'displayName': null,
            'photoUrl': null,
            'deleteAttribute': const <String>[],
            'returnSecureToken': false,
          }),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
    });

    test('should throw AuthError on failure', () async {
      whenError();
      expect(
        () => api.updateProfile(const ProfileUpdateRequest(idToken: 'token')),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('sendOobCode', () {
    group('verifyEmail', () {
      test('should send a post request with correct data', () async {
        whenPost().thenFake(const OobCodeResponse());

        await api.sendOobCode(
          const OobCodeRequest.verifyEmail(idToken: 'token'),
          'de-DE',
        );
        verify(
          () => mockClient.post(
            Uri.parse(
              'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=apiKey',
            ),
            body: json.encode({
              'idToken': 'token',
              'requestType': 'VERIFY_EMAIL',
            }),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'X-Firebase-Locale': 'de-DE',
            },
          ),
        );
      });

      test('should throw AuthError on failure', () async {
        whenError();

        expect(
          () => api.sendOobCode(
            const OobCodeRequest.verifyEmail(idToken: 'token'),
          ),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('passwordReset', () {
      test('should send a post request with correct data', () async {
        whenPost().thenFake(const OobCodeResponse());

        await api.sendOobCode(
          const OobCodeRequest.passwordReset(email: 'email'),
          'de-DE',
        );
        verify(
          () => mockClient.post(
            Uri.parse(
              'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=apiKey',
            ),
            body: json.encode({
              'email': 'email',
              'requestType': 'PASSWORD_RESET',
            }),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'X-Firebase-Locale': 'de-DE',
            },
          ),
        );
      });

      test('should throw AuthError on failure', () async {
        whenError();

        expect(
          () => api.sendOobCode(
            const OobCodeRequest.passwordReset(email: 'email'),
          ),
          throwsA(isA<AuthException>()),
        );
      });
    });
  });

  group('resetPassword', () {
    group('verify', () {
      test('should send a post request with correct data', () async {
        whenPost().thenFake(const PasswordResetResponse());

        await api.resetPassword(
          const PasswordResetRequest.verify(oobCode: 'code'),
        );
        verify(
          () => mockClient.post(
            Uri.parse(
              'https://identitytoolkit.googleapis.com/v1/accounts:resetPassword?key=apiKey',
            ),
            body: json.encode({
              'oobCode': 'code',
            }),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        );
      });

      test('should throw AuthError on failure', () async {
        whenError();

        expect(
          () => api.resetPassword(
            const PasswordResetRequest.verify(oobCode: 'code'),
          ),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('confirm', () {
      test('should send a post request with correct data', () async {
        whenPost().thenFake(const PasswordResetResponse());

        await api.resetPassword(
          const PasswordResetRequest.confirm(
            oobCode: 'code',
            newPassword: 'password',
          ),
        );
        verify(
          () => mockClient.post(
            Uri.parse(
              'https://identitytoolkit.googleapis.com/v1/accounts:resetPassword?key=apiKey',
            ),
            body: json.encode({
              'oobCode': 'code',
              'newPassword': 'password',
            }),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        );
      });

      test('should throw AuthError on failure', () async {
        whenError();

        expect(
          () => api.resetPassword(
            const PasswordResetRequest.confirm(
              oobCode: 'code',
              newPassword: 'password',
            ),
          ),
          throwsA(isA<AuthException>()),
        );
      });
    });
  });

  group('confirmEmail', () {
    test('should send a post request with correct data', () async {
      whenPost().thenFake(const ConfirmEmailResponse());

      await api.confirmEmail(const ConfirmEmailRequest(oobCode: 'code'));
      verify(
        () => mockClient.post(
          Uri.parse(
            'https://identitytoolkit.googleapis.com/v1/accounts:update?key=apiKey',
          ),
          body: json.encode({
            'oobCode': 'code',
          }),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
    });

    test('should throw AuthError on failure', () async {
      whenError();
      expect(
        () => api.confirmEmail(const ConfirmEmailRequest(oobCode: 'code')),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('fetchProviders', () {
    test('should send a post request with correct data', () async {
      whenPost().thenFake(const FetchProviderResponse());

      await api.fetchProviders(
        FetchProviderRequest(
          identifier: 'id',
          continueUri: Uri.parse('http://localhost:8080'),
        ),
      );
      verify(
        () => mockClient.post(
          Uri.parse(
            'https://identitytoolkit.googleapis.com/v1/accounts:createAuthUri?key=apiKey',
          ),
          body: json.encode({
            'identifier': 'id',
            'continueUri': 'http://localhost:8080',
          }),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
    });

    test('should throw AuthError on failure', () async {
      whenError();
      expect(
        () => api.fetchProviders(
          FetchProviderRequest(
            identifier: 'id',
            continueUri: Uri(),
          ),
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('linkEmail', () {
    test('should send a post request with correct data', () async {
      whenPost().thenFake(const LinkEmailResponse(localId: ''));

      await api.linkEmail(
        const LinkEmailRequest(
          idToken: 'token',
          email: 'mail',
          password: 'password',
        ),
      );
      verify(
        () => mockClient.post(
          Uri.parse(
            'https://identitytoolkit.googleapis.com/v1/accounts:update?key=apiKey',
          ),
          body: json.encode({
            'idToken': 'token',
            'email': 'mail',
            'password': 'password',
            'returnSecureToken': true,
          }),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
    });

    test('should throw AuthError on failure', () async {
      whenError();
      expect(
        () => api.linkEmail(
          const LinkEmailRequest(
            idToken: 'token',
            email: 'mail',
            password: 'password',
          ),
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('linkIdp', () {
    test('should send a post request with correct data', () async {
      whenPost().thenFake(
        const LinkIdpResponse(
          federatedId: '',
          providerId: '',
          localId: '',
          idToken: '',
          refreshToken: '',
          expiresIn: '',
        ),
      );

      await api.linkIdp(
        LinkIdpRequest(
          idToken: 'token',
          requestUri: Uri.parse('http://localhost'),
          postBody: 'post',
        ),
      );
      verify(
        () => mockClient.post(
          Uri.parse(
            'https://identitytoolkit.googleapis.com/v1/accounts:signInWithIdp?key=apiKey',
          ),
          body: json.encode({
            'idToken': 'token',
            'requestUri': 'http://localhost',
            'postBody': 'post',
            'returnSecureToken': true,
            'returnIdpCredential': false,
          }),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
    });

    test('should throw AuthError on failure', () async {
      whenError();
      expect(
        () => api.linkIdp(
          LinkIdpRequest(
            idToken: 'token',
            requestUri: Uri(),
            postBody: '',
          ),
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('unlinkProvider', () {
    test('should send a post request with correct data', () async {
      whenPost().thenFake(const UnlinkResponse(localId: ''));

      await api.unlinkProvider(
        const UnlinkRequest(
          idToken: 'token',
          deleteProvider: ['a', 'b', 'c'],
        ),
      );
      verify(
        () => mockClient.post(
          Uri.parse(
            'https://identitytoolkit.googleapis.com/v1/accounts:update?key=apiKey',
          ),
          body: json.encode({
            'idToken': 'token',
            'deleteProvider': ['a', 'b', 'c'],
          }),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
    });

    test('should throw AuthError on failure', () async {
      whenError();
      expect(
        () => api.unlinkProvider(
          const UnlinkRequest(
            idToken: 'token',
            deleteProvider: [],
          ),
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('delete', () {
    test('should send a post request with correct data', () async {
      await api.delete(const DeleteRequest(idToken: 'token'));
      verify(
        () => mockClient.post(
          Uri.parse(
            'https://identitytoolkit.googleapis.com/v1/accounts:delete?key=apiKey',
          ),
          body: json.encode({
            'idToken': 'token',
          }),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
    });

    test('should throw AuthError on failure', () async {
      whenError();
      expect(
        () => api.delete(const DeleteRequest(idToken: 'token')),
        throwsA(isA<AuthException>()),
      );
    });
  });
}
