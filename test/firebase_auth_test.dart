// ignore_for_file: prefer_const_constructors
import 'package:firebase_auth_rest/src/firebase_account.dart';
import 'package:firebase_auth_rest/src/firebase_auth.dart';
import 'package:firebase_auth_rest/src/models/fetch_provider_request.dart';
import 'package:firebase_auth_rest/src/models/fetch_provider_response.dart';
import 'package:firebase_auth_rest/src/models/idp_provider.dart';
import 'package:firebase_auth_rest/src/models/oob_code_request.dart';
import 'package:firebase_auth_rest/src/models/password_reset_request.dart';
import 'package:firebase_auth_rest/src/models/signin_request.dart';
import 'package:firebase_auth_rest/src/models/signin_response.dart';
import 'package:firebase_auth_rest/src/rest_api.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'test_fixture.dart';

class MockRestApi extends Mock implements RestApi {}

class MockClient extends Mock implements Client {}

void main() {
  final mockApi = MockRestApi();

  setUp(() {
    reset(mockApi);
  });

  test("constructor sets api and locale correctly", () {
    final mockClient = MockClient();
    const apiKey = "key";
    const locale = "locale";

    final auth = FirebaseAuth(
      mockClient,
      apiKey,
      locale,
    );

    expect(auth.api, isNotNull);
    expect(auth.api.client, mockClient);
    expect(auth.api.apiKey, apiKey);
    expect(auth.locale, locale);
  });

  test("Api constructor sets api and locale correctly", () {
    const locale = "locale";
    final auth = FirebaseAuth.api(
      mockApi,
      locale,
    );

    expect(auth.api, mockApi);
    expect(auth.locale, locale);
  });

  group("methods:", () {
    const idToken = "id";
    const localId = "local";
    const expiresIn = "60";
    const refreshToken = "refresh";

    FirebaseAuth auth;
    FirebaseAccount account;

    setUp(() {
      auth = FirebaseAuth.api(mockApi, "ab-CD");
    });

    tearDown(() {
      account?.dispose();
      account = null;
    });

    group("fetchProviders", () {
      testWithData("sends fetch providers request", [
        Fixture(
          null,
          Uri.parse("http://localhost"),
        ),
        Fixture(
          Uri.parse("http://example.com"),
          Uri.parse("http://example.com"),
        ),
      ], (fixture) async {
        when(mockApi.fetchProviders(any))
            .thenAnswer((i) async => FetchProviderResponse(
                  registered: false,
                  allProviders: [],
                ));

        const mail = "mail";
        await auth.fetchProviders(mail, fixture.get0<Uri>());

        verify(mockApi.fetchProviders(FetchProviderRequest(
          identifier: mail,
          continueUri: fixture.get1<Uri>(),
        )));
      });

      testWithData("returns providers with mail", const [
        Fixture(false, ["a", "b", "c"]),
        Fixture(true, ["email", "a", "b", "c"]),
      ], (fixture) async {
        const providers = ["a", "b", "c"];
        when(mockApi.fetchProviders(any))
            .thenAnswer((i) async => FetchProviderResponse(
                  registered: fixture.get0<bool>(),
                  allProviders: providers,
                ));

        final result = await auth.fetchProviders("email");
        expect(result, fixture.get1<List<String>>());
      });
    });

    group("signUpAnonymous", () {
      test("sends anonymous sign up request", () async {
        when(mockApi.signUpAnonymous(any))
            .thenAnswer((i) async => AnonymousSignInResponse(
                  idToken: "",
                  localId: "",
                  expiresIn: "1",
                  refreshToken: "",
                ));

        account = await auth.signUpAnonymous();

        verify(mockApi.signUpAnonymous(AnonymousSignInRequest(
          returnSecureToken: true,
        )));
      });

      test("creates account from reply", () async {
        when(mockApi.signUpAnonymous(any))
            .thenAnswer((i) async => AnonymousSignInResponse(
                  idToken: idToken,
                  localId: localId,
                  expiresIn: expiresIn,
                  refreshToken: refreshToken,
                ));

        final expiresAt =
            DateTime.now().toUtc().add(const Duration(minutes: 1));
        account = await auth.signUpAnonymous(autoRefresh: false);

        expect(account.localId, localId);
        expect(account.idToken, idToken);
        expect(account.refreshToken, refreshToken);
        expect(account.autoRefresh, false);
        expect(account.expiresAt.difference(expiresAt).inSeconds, 0);
      });
    });

    group("signUpWithPassword", () {
      test("sends password sign up request", () async {
        const mail = "mail";
        const password = "password";
        when(mockApi.signUpWithPassword(any))
            .thenAnswer((i) async => PasswordSignInResponse(
                  idToken: "",
                  localId: "",
                  expiresIn: "1",
                  refreshToken: "",
                ));

        account = await auth.signUpWithPassword(
          mail,
          password,
          autoVerify: false,
        );

        verify(mockApi.signUpWithPassword(PasswordSignInRequest(
          email: mail,
          password: password,
          returnSecureToken: true,
        )));
        verifyNoMoreInteractions(mockApi);
      });

      testWithData("sends oob code request if enabled", const [
        Fixture("ee-EE", "ee-EE"),
        Fixture(null, "ab-CD"),
      ], (fixture) async {
        when(mockApi.signUpWithPassword(any))
            .thenAnswer((i) async => PasswordSignInResponse(
                  idToken: idToken,
                  localId: "",
                  expiresIn: "1",
                  refreshToken: "",
                ));

        account = await auth.signUpWithPassword(
          "email",
          "password",
          autoRefresh: false,
          locale: fixture.get0<String>(),
        );

        verify(mockApi.sendOobCode(
          OobCodeRequest.verifyEmail(
            idToken: idToken,
            requestType: OobCodeRequestType.VERIFY_EMAIL,
          ),
          fixture.get1<String>(),
        ));
      });

      test("creates account from reply", () async {
        when(mockApi.signUpWithPassword(any))
            .thenAnswer((i) async => PasswordSignInResponse(
                  idToken: idToken,
                  localId: localId,
                  expiresIn: expiresIn,
                  refreshToken: refreshToken,
                ));

        final expiresAt =
            DateTime.now().toUtc().add(const Duration(minutes: 1));
        account = await auth.signUpWithPassword(
          "email",
          "password",
          autoVerify: false,
          autoRefresh: false,
        );

        expect(account.localId, localId);
        expect(account.idToken, idToken);
        expect(account.refreshToken, refreshToken);
        expect(account.autoRefresh, false);
        expect(account.expiresAt.difference(expiresAt).inSeconds, 0);
      });
    });

    group("signInWithIdp", () {
      test("sends idp sign in request", () async {
        final provider = IdpProvider.google("token");
        final uri = Uri.parse("http://localhost");
        when(mockApi.signInWithIdp(any))
            .thenAnswer((i) async => IdpSignInResponse(
                  idToken: "",
                  localId: "",
                  expiresIn: "1",
                  refreshToken: "",
                ));

        account = await auth.signInWithIdp(provider, uri);

        verify(mockApi.signInWithIdp(IdpSignInRequest(
          postBody: provider.postBody,
          requestUri: uri,
          returnIdpCredential: false,
          returnSecureToken: true,
        )));
      });

      test("creates account from reply", () async {
        when(mockApi.signInWithIdp(any))
            .thenAnswer((i) async => IdpSignInResponse(
                  idToken: idToken,
                  localId: localId,
                  expiresIn: expiresIn,
                  refreshToken: refreshToken,
                ));

        final expiresAt =
            DateTime.now().toUtc().add(const Duration(minutes: 1));
        account = await auth.signInWithIdp(
          IdpProvider.google("idToken"),
          Uri(),
          autoRefresh: false,
        );

        expect(account.localId, localId);
        expect(account.idToken, idToken);
        expect(account.refreshToken, refreshToken);
        expect(account.autoRefresh, false);
        expect(account.expiresAt.difference(expiresAt).inSeconds, 0);
      });
    });

    group("signInWithPassword", () {
      test("sends password sign in request", () async {
        const mail = "mail";
        const password = "password";
        when(mockApi.signInWithPassword(any))
            .thenAnswer((i) async => PasswordSignInResponse(
                  idToken: "",
                  localId: "",
                  expiresIn: "1",
                  refreshToken: "",
                ));

        account = await auth.signInWithPassword(
          mail,
          password,
        );

        verify(mockApi.signInWithPassword(PasswordSignInRequest(
          email: mail,
          password: password,
          returnSecureToken: true,
        )));
        verifyNoMoreInteractions(mockApi);
      });

      test("creates account from reply", () async {
        when(mockApi.signInWithPassword(any))
            .thenAnswer((i) async => PasswordSignInResponse(
                  idToken: idToken,
                  localId: localId,
                  expiresIn: expiresIn,
                  refreshToken: refreshToken,
                ));

        final expiresAt =
            DateTime.now().toUtc().add(const Duration(minutes: 1));
        account = await auth.signInWithPassword(
          "email",
          "password",
          autoRefresh: false,
        );

        expect(account.localId, localId);
        expect(account.idToken, idToken);
        expect(account.refreshToken, refreshToken);
        expect(account.autoRefresh, false);
        expect(account.expiresAt.difference(expiresAt).inSeconds, 0);
      });
    });

    group("signInWithCustomToken", () {
      test("sends custom tken sign in request", () async {
        const token = "token";
        when(mockApi.signInWithCustomToken(any))
            .thenAnswer((i) async => CustomTokenSignInResponse(
                  idToken: "",
                  localId: "",
                  expiresIn: "1",
                  refreshToken: "",
                ));

        account = await auth.signInWithCustomToken(token);

        verify(mockApi.signInWithCustomToken(CustomTokenSignInRequest(
          token: token,
          returnSecureToken: true,
        )));
      });

      test("creates account from reply", () async {
        when(mockApi.signInWithCustomToken(any))
            .thenAnswer((i) async => CustomTokenSignInResponse(
                  idToken: idToken,
                  localId: localId,
                  expiresIn: expiresIn,
                  refreshToken: refreshToken,
                ));

        final expiresAt =
            DateTime.now().toUtc().add(const Duration(minutes: 1));
        account = await auth.signInWithCustomToken(
          "token",
          autoRefresh: false,
        );

        expect(account.localId, localId);
        expect(account.idToken, idToken);
        expect(account.refreshToken, refreshToken);
        expect(account.autoRefresh, false);
        expect(account.expiresAt.difference(expiresAt).inSeconds, 0);
      });
    });

    testWithData("requestPasswordReset sends oob code request", const [
      Fixture("ee-EE", "ee-EE"),
      Fixture(null, "ab-CD"),
    ], (fixture) async {
      const mail = "email";
      await auth.requestPasswordReset(
        mail,
        locale: fixture.get0<String>(),
      );

      verify(mockApi.sendOobCode(
        OobCodeRequest.passwordReset(
          email: mail,
        ),
        fixture.get1<String>(),
      ));
    });

    test("validatePasswordReset send reset password request", () async {
      const code = "oob-code";
      await auth.validatePasswordReset(code);

      verify(mockApi.resetPassword(PasswordResetRequest.verify(
        oobCode: code,
      )));
    });

    test("resetPassword send reset password request", () async {
      const code = "oob-code";
      const password = "password";
      await auth.resetPassword(code, password);

      verify(mockApi.resetPassword(PasswordResetRequest.confirm(
        oobCode: code,
        newPassword: password,
      )));
    });
  });
}
