import 'package:test/test.dart';
import 'package:firebase_rest_auth/firebase_rest_auth.dart';
import 'package:mockito/mockito.dart';

import './mocks.dart';

void main() {
  const apiKey = "apiKey";
  final mockClient = MockClient();
  final api = RestApi(mockClient, apiKey);

  setUp(() {
    reset(mockClient);
    mockClient.setupMock();
  });

  group("token", () {
    test("should send a post request with correct data", () async {
      const token = "token";
      await api.token(refresh_token: token);
      verify(mockClient.post(
        Uri.parse("https://securetoken.googleapis.com/v1/token?key=apiKey"),
        body: {
          "refresh_token": token,
          "grant_type": "refresh_token",
        },
      ));
    });

    test("should throw AuthError on failure", () async {
      mockClient.setupError();

      expect(
          () => api.token(refresh_token: "token"), throwsA(isA<AuthError>()));
    });
  });

  group("signUpAnonymous", () {
    test("should send a post request with correct data", () async {
      await api.signUpAnonymous(const AnonymousSignInRequest());
      verify(mockClient.post(
        Uri.parse(
            "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=apiKey"),
        body: isA<String>(),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ));
    });

    test("should throw AuthError on failure", () async {
      mockClient.setupError();

      expect(() => api.signUpAnonymous(const AnonymousSignInRequest()),
          throwsA(isA<AuthError>()));
    });
  });

  group("signUpWithPassword", () {
    test("should send a post request with correct data", () async {
      await api.signUpWithPassword(const PasswordSignInRequest(
        email: "email",
        password: "password",
      ));
      verify(mockClient.post(
        Uri.parse(
            "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=apiKey"),
        body: isA<String>(),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ));
    });

    test("should throw AuthError on failure", () async {
      mockClient.setupError();

      expect(
          () => api.signUpWithPassword(const PasswordSignInRequest(
                email: "",
                password: "",
              )),
          throwsA(isA<AuthError>()));
    });
  });

  group("signInWithIdp", () {
    test("should send a post request with correct data", () async {
      await api.signInWithIdp(IdpSignInRequest(
        requestUri: Uri(),
        postBody: "postBody",
      ));
      verify(mockClient.post(
        Uri.parse(
            "https://identitytoolkit.googleapis.com/v1/accounts:signInWithIdp?key=apiKey"),
        body: isA<String>(),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ));
    });

    test("should throw AuthError on failure", () async {
      mockClient.setupError();

      expect(
          () => api.signInWithIdp(IdpSignInRequest(
                requestUri: Uri(),
                postBody: "postBody",
              )),
          throwsA(isA<AuthError>()));
    });
  });

  group("signInWithPassword", () {
    test("should send a post request with correct data", () async {
      await api.signInWithPassword(const PasswordSignInRequest(
        email: "email",
        password: "password",
      ));
      verify(mockClient.post(
        Uri.parse(
            "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=apiKey"),
        body: isA<String>(),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ));
    });

    test("should throw AuthError on failure", () async {
      mockClient.setupError();

      expect(
          () => api.signInWithPassword(const PasswordSignInRequest(
                email: "",
                password: "",
              )),
          throwsA(isA<AuthError>()));
    });
  });

  group("signInWithCustomToken", () {
    test("should send a post request with correct data", () async {
      await api.signInWithCustomToken(
          const CustomTokenSignInRequest(token: "token"));
      verify(mockClient.post(
        Uri.parse(
            "https://identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=apiKey"),
        body: isA<String>(),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ));
    });

    test("should throw AuthError on failure", () async {
      mockClient.setupError();

      expect(
          () => api.signInWithCustomToken(
              const CustomTokenSignInRequest(token: "token")),
          throwsA(isA<AuthError>()));
    });
  });

  group("fetchProviders", () {
    test("should send a post request with correct data", () async {
      await api.fetchProviders(FetchProviderRequest(
        identifier: "id",
        continueUri: Uri(),
      ));
      verify(mockClient.post(
        Uri.parse(
            "https://identitytoolkit.googleapis.com/v1/accounts:createAuthUri?key=apiKey"),
        body: isA<String>(),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ));
    });

    test("should throw AuthError on failure", () async {
      mockClient.setupError();

      expect(
          () => api.fetchProviders(FetchProviderRequest(
                identifier: "id",
                continueUri: Uri(),
              )),
          throwsA(isA<AuthError>()));
    });
  });

  group("sendOobCode", () {
    test("should send a post request with correct data", () async {
      await api.sendOobCode(
          const OobCodeRequest.verifyEmail(idToken: "token"), "de-DE");
      verify(mockClient.post(
        Uri.parse(
            "https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=apiKey"),
        body: isA<String>(),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "X-Firebase-Locale": "de-DE",
        },
      ));
    });

    test("should throw AuthError on failure", () async {
      mockClient.setupError();

      expect(
          () => api
              .sendOobCode(const OobCodeRequest.verifyEmail(idToken: "token")),
          throwsA(isA<AuthError>()));
    });
  });

  group("resetPassword", () {
    test("should send a post request with correct data", () async {
      await api
          .resetPassword(const PasswordResetRequest.verify(oobCode: "code"));
      verify(mockClient.post(
        Uri.parse(
            "https://identitytoolkit.googleapis.com/v1/accounts:resetPassword?key=apiKey"),
        body: isA<String>(),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ));
    });

    test("should throw AuthError on failure", () async {
      mockClient.setupError();

      expect(
          () => api.resetPassword(
              const PasswordResetRequest.verify(oobCode: "code")),
          throwsA(isA<AuthError>()));
    });
  });

  group("updateEmail", () {
    test("should send a post request with correct data", () async {
      await api.updateEmail(const EmailUpdateRequest(
        idToken: "token",
        email: "mail",
      ));
      verify(mockClient.post(
        Uri.parse(
            "https://identitytoolkit.googleapis.com/v1/accounts:update?key=apiKey"),
        body: isA<String>(),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ));
    });

    test("should throw AuthError on failure", () async {
      mockClient.setupError();

      expect(
          () => api.updateEmail(const EmailUpdateRequest(
                idToken: "token",
                email: "mail",
              )),
          throwsA(isA<AuthError>()));
    });
  });

  group("updatePassword", () {
    test("should send a post request with correct data", () async {
      await api.updatePassword(const PasswordUpdateRequest(
        idToken: "token",
        password: "password",
      ));
      verify(mockClient.post(
        Uri.parse(
            "https://identitytoolkit.googleapis.com/v1/accounts:update?key=apiKey"),
        body: isA<String>(),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ));
    });

    test("should throw AuthError on failure", () async {
      mockClient.setupError();

      expect(
          () => api.updatePassword(const PasswordUpdateRequest(
                idToken: "token",
                password: "password",
              )),
          throwsA(isA<AuthError>()));
    });
  });

  group("updateProfile", () {
    test("should send a post request with correct data", () async {
      await api.updateProfile(const ProfileUpdateRequest(idToken: "token"));
      verify(mockClient.post(
        Uri.parse(
            "https://identitytoolkit.googleapis.com/v1/accounts:update?key=apiKey"),
        body: isA<String>(),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ));
    });

    test("should throw AuthError on failure", () async {
      mockClient.setupError();

      expect(
          () => api.updateProfile(const ProfileUpdateRequest(idToken: "token")),
          throwsA(isA<AuthError>()));
    });
  });

  group("linkEmail", () {
    test("should send a post request with correct data", () async {
      await api.linkEmail(const LinkEmailRequest(
        idToken: "token",
        email: "mail",
        password: "password",
      ));
      verify(mockClient.post(
        Uri.parse(
            "https://identitytoolkit.googleapis.com/v1/accounts:update?key=apiKey"),
        body: isA<String>(),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ));
    });

    test("should throw AuthError on failure", () async {
      mockClient.setupError();

      expect(
          () => api.linkEmail(const LinkEmailRequest(
                idToken: "token",
                email: "mail",
                password: "password",
              )),
          throwsA(isA<AuthError>()));
    });
  });

  group("linkIdp", () {
    test("should send a post request with correct data", () async {
      await api.linkIdp(LinkIdpRequest(
        idToken: "token",
        requestUri: Uri(),
        postBody: "",
      ));
      verify(mockClient.post(
        Uri.parse(
            "https://identitytoolkit.googleapis.com/v1/accounts:signInWithIdp?key=apiKey"),
        body: isA<String>(),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ));
    });

    test("should throw AuthError on failure", () async {
      mockClient.setupError();

      expect(
          () => api.linkIdp(LinkIdpRequest(
                idToken: "token",
                requestUri: Uri(),
                postBody: "",
              )),
          throwsA(isA<AuthError>()));
    });
  });

  group("unlinkProvider", () {
    test("should send a post request with correct data", () async {
      await api.unlinkProvider(const UnlinkRequest(
        idToken: "token",
        deleteProvider: [],
      ));
      verify(mockClient.post(
        Uri.parse(
            "https://identitytoolkit.googleapis.com/v1/accounts:update?key=apiKey"),
        body: isA<String>(),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ));
    });

    test("should throw AuthError on failure", () async {
      mockClient.setupError();

      expect(
          () => api.unlinkProvider(const UnlinkRequest(
                idToken: "token",
                deleteProvider: [],
              )),
          throwsA(isA<AuthError>()));
    });
  });

  group("confirmEmail", () {
    test("should send a post request with correct data", () async {
      await api.confirmEmail(const ConfirmEmailRequest(oobCode: "code"));
      verify(mockClient.post(
        Uri.parse(
            "https://identitytoolkit.googleapis.com/v1/accounts:update?key=apiKey"),
        body: isA<String>(),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ));
    });

    test("should throw AuthError on failure", () async {
      mockClient.setupError();

      expect(() => api.confirmEmail(const ConfirmEmailRequest(oobCode: "code")),
          throwsA(isA<AuthError>()));
    });
  });

  group("delete", () {
    test("should send a post request with correct data", () async {
      await api.delete(const DeleteRequest(idToken: "token"));
      verify(mockClient.post(
        Uri.parse(
            "https://identitytoolkit.googleapis.com/v1/accounts:delete?key=apiKey"),
        body: isA<String>(),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ));
    });

    test("should throw AuthError on failure", () async {
      mockClient.setupError();

      expect(() => api.delete(const DeleteRequest(idToken: "token")),
          throwsA(isA<AuthError>()));
    });
  });
}
