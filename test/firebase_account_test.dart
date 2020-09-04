// ignore_for_file: prefer_const_constructors
import 'dart:convert';

import 'package:firebase_auth_rest/src/firebase_account.dart';
import 'package:firebase_auth_rest/src/models/auth_error.dart';
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
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'test_fixture.dart';

class MockResponse extends Mock implements Response {}

class MockClient extends Mock implements Client {}

class RestApiMock extends Mock implements RestApi {}

class MockSignInResponse extends Mock implements SignInResponse {}

void main() {
  final mockApi = RestApiMock();
  final mockResponse = MockSignInResponse();

  FirebaseAccount account;

  setUp(() {
    reset(mockApi);

    reset(mockResponse);
    when(mockResponse.localId).thenReturn("localId");
    when(mockResponse.idToken).thenReturn("idToken");
    when(mockResponse.refreshToken).thenReturn("refreshToken");
    when(mockResponse.expiresIn).thenReturn("5");
  });

  tearDown(() {
    account?.dispose();
    account = null;
  });

  group("create", () {
    final mockClient = MockClient();

    setUp(() {
      reset(mockClient);
    });

    test("apiCreate initializes account correctly", () {
      final expiresAt = DateTime.now().toUtc().add(Duration(seconds: 5));
      account = FirebaseAccount.apiCreate(
        mockApi,
        mockResponse,
        autoRefresh: false,
        locale: "de-DE",
      );

      expect(account.api, mockApi);
      expect(account.localId, "localId");
      expect(account.idToken, "idToken");
      expect(account.refreshToken, "refreshToken");
      expect(account.expiresAt.difference(expiresAt).inSeconds, 0);
      expect(account.autoRefresh, false);
      expect(account.locale, "de-DE");
    });

    test("apiCreate starts refresh timer", () {
      final expiresAt = DateTime.now().toUtc().add(Duration(seconds: 5));
      account = FirebaseAccount.apiCreate(mockApi, mockResponse);

      expect(account.autoRefresh, true);
      expect(account.expiresAt.difference(expiresAt).inSeconds, 0);
    });

    test("create initializes api with correct client and key", () {
      const apiKey = "API-KEY";
      account = FirebaseAccount.create(mockClient, apiKey, mockResponse);

      expect(account.api.client, mockClient);
      expect(account.api.apiKey, apiKey);
    });
  });

  group("restore", () {
    final mockClient = MockClient();

    setUp(() {
      reset(mockClient);

      when(mockApi.token(refresh_token: anyNamed("refresh_token")))
          .thenAnswer((i) async => RefreshResponse(expires_in: "5"));
    });

    test("apiRestore calls api.token with refreshToken", () async {
      const refreshToken = "refreshToken";

      account = await FirebaseAccount.apiRestore(
        mockApi,
        refreshToken,
        autoRefresh: false,
      );

      verify(mockApi.token(refresh_token: refreshToken));
    });

    test("apiRestore initializes account correctly", () async {
      const refreshToken1 = "refreshToken1";
      const refreshToken2 = "refreshToken2";
      const localId = "localId";
      const idToken = "idToken";
      when(mockApi.token(refresh_token: refreshToken1))
          .thenAnswer((i) async => RefreshResponse(
                user_id: localId,
                id_token: idToken,
                refresh_token: refreshToken2,
                expires_in: "5",
              ));

      final expiresAt = DateTime.now().toUtc().add(Duration(seconds: 5));
      account = await FirebaseAccount.apiRestore(
        mockApi,
        refreshToken1,
        autoRefresh: false,
        locale: "de-DE",
      );

      expect(account.api, mockApi);
      expect(account.localId, localId);
      expect(account.idToken, idToken);
      expect(account.refreshToken, refreshToken2);
      expect(account.expiresAt.difference(expiresAt).inSeconds, 0);
      expect(account.autoRefresh, false);
      expect(account.locale, "de-DE");
    });

    test("apiRestore starts refresh timer", () async {
      final expiresAt = DateTime.now().toUtc().add(Duration(seconds: 5));
      account = await FirebaseAccount.apiRestore(mockApi, "refreshToken");

      expect(account.autoRefresh, true);
      expect(account.expiresAt.difference(expiresAt).inSeconds, 0);
    });

    test("restore initializes api with correct client and key", () async {
      when(mockClient.post(
        any,
        body: anyNamed("body"),
        headers: anyNamed("headers"),
      )).thenAnswer((i) async {
        final res = MockResponse();
        when(res.statusCode).thenReturn(200);
        when(res.body)
            .thenReturn(json.encode(RefreshResponse(expires_in: "1").toJson()));
        return res;
      });

      const apiKey = "API-KEY";
      account = await FirebaseAccount.restore(
        mockClient,
        apiKey,
        "refreshToken",
      );

      expect(account.api.client, mockClient);
      expect(account.api.apiKey, apiKey);
    });
  });

  group("autoRefresh", () {
    test("does nothing if disabled", () async {
      when(mockResponse.expiresIn).thenReturn("61");

      account = FirebaseAccount.apiCreate(
        mockApi,
        mockResponse,
        autoRefresh: false,
      );

      await _wait(3);

      verifyZeroInteractions(mockApi);
    });

    test("sends token request one minute before timeout", () async {
      when(mockResponse.expiresIn).thenReturn("62");

      account = FirebaseAccount.apiCreate(
        mockApi,
        mockResponse,
      );

      await _wait(3);

      verify(mockApi.token(refresh_token: "refreshToken")).called(1);
    });

    test("sends token request again after timeout", () async {
      when(mockResponse.expiresIn).thenReturn("62");
      when(mockApi.token(refresh_token: anyNamed("refresh_token")))
          .thenAnswer((i) async => RefreshResponse(
                refresh_token: "refreshToken2",
                expires_in: "62",
              ));

      account = FirebaseAccount.apiCreate(
        mockApi,
        mockResponse,
      );

      await _wait(7);

      verify(mockApi.token(refresh_token: "refreshToken")).called(1);
      verify(mockApi.token(refresh_token: "refreshToken2")).called(2);
    });

    test("sends token request immediatly if timeout is below 60 seconds",
        () async {
      account = FirebaseAccount.apiCreate(
        mockApi,
        mockResponse,
      );

      await _wait(1);

      verify(mockApi.token(refresh_token: "refreshToken")).called(1);
    });
  });

  group("methods", () {
    setUp(() {
      account = FirebaseAccount.apiCreate(
        mockApi,
        mockResponse,
        autoRefresh: false,
        locale: "ab-CD",
      );
    });

    group("refresh", () {
      test("updates all properties", () async {
        const idToken = "id";
        const refreshToken = "refresh";
        when(mockApi.token(refresh_token: anyNamed("refresh_token")))
            .thenAnswer((i) async => RefreshResponse(
                  id_token: idToken,
                  refresh_token: refreshToken,
                  expires_in: "6000",
                ));

        final expiresAt = DateTime.now().toUtc().add(Duration(seconds: 6000));
        final token = await account.refresh();

        expect(token, idToken);
        expect(account.idToken, idToken);
        expect(account.refreshToken, refreshToken);
        expect(account.expiresAt.difference(expiresAt).inSeconds, 0);
      });

      test("forwards auth exceptions", () async {
        when(mockApi.token(refresh_token: anyNamed("refresh_token")))
            .thenAnswer((i) => throw AuthError());

        expect(() => account.refresh(), throwsA(isA<AuthError>()));
      });

      test("token updates are streamed", () async {
        const idToken = "nextId";
        when(mockApi.token(refresh_token: anyNamed("refresh_token")))
            .thenAnswer((i) async => RefreshResponse(
                  id_token: idToken,
                  expires_in: "5",
                ));

        expect(account.idTokenStream.isBroadcast, true);

        final firstElement = account.idTokenStream.first;
        await account.refresh();
        expect(await firstElement, idToken);
      });

      test("token update errors are streamed", () async {
        when(mockApi.token(refresh_token: anyNamed("refresh_token")))
            .thenAnswer((i) => throw AuthError());

        final firstElement = account.idTokenStream.first;
        expect(() => account.refresh(), throwsA(isA<AuthError>()));
        expect(() => firstElement, throwsA(isA<AuthError>()));
      });
    });

    testWithData("requestEmailConfirmation sends oobCode request", const [
      Fixture("ee-EE", "ee-EE"),
      Fixture(null, "ab-CD"),
    ], (fixture) async {
      await account.requestEmailConfirmation(locale: fixture.get0<String>());

      verify(mockApi.sendOobCode(
        OobCodeRequest.verifyEmail(
          idToken: "idToken",
          requestType: OobCodeRequestType.VERIFY_EMAIL,
        ),
        fixture.get1<String>(),
      ));
    });

    test("confirmEmail sends confirm email request", () async {
      const code = "code";
      await account.confirmEmail(code);

      verify(mockApi.confirmEmail(ConfirmEmailRequest(oobCode: code)));
    });

    group("getDetails", () {
      test("sends user data request", () async {
        when(mockApi.getUserData(any)).thenAnswer((i) async => UserDataResponse(
              users: [],
            ));

        final result = await account.getDetails();

        verify(mockApi.getUserData(UserDataRequest(idToken: "idToken")));
        expect(result, null);
      });

      test("returns first user data element", () async {
        final userData = UserData(displayName: "Max Muster");
        when(mockApi.getUserData(any)).thenAnswer((i) async => UserDataResponse(
              users: [
                userData,
                UserData(),
              ],
            ));

        final result = await account.getDetails();
        expect(result, userData);
      });
    });

    testWithData("updateEmail sends email update request", const [
      Fixture("ee-EE", "ee-EE"),
      Fixture(null, "ab-CD"),
    ], (fixture) async {
      const newEmail = "new@mail.de";
      await account.updateEmail(newEmail, locale: fixture.get0<String>());

      verify(mockApi.updateEmail(
        EmailUpdateRequest(
          idToken: "idToken",
          email: newEmail,
          returnSecureToken: false,
        ),
        fixture.get1<String>(),
      ));
    });

    test("updatePassword sends password update request", () async {
      const newPassword = "pw";
      await account.updatePassword(newPassword);

      verify(mockApi.updatePassword(PasswordUpdateRequest(
        idToken: "idToken",
        password: newPassword,
        returnSecureToken: false,
      )));
    });

    testWithData("updateProfile sends profile update", [
      Fixture(
        null,
        null,
        null,
        null,
        const <DeleteAttribute>[],
      ),
      Fixture(
        null,
        ProfileUpdate<Uri>.update(Uri.parse("http://example.com/image.jpg")),
        null,
        Uri.parse("http://example.com/image.jpg"),
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
        ProfileUpdate<String>.update("name"),
        null,
        "name",
        null,
        const <DeleteAttribute>[],
      ),
      Fixture(
        ProfileUpdate<String>.update("name"),
        ProfileUpdate<Uri>.update(Uri.parse("http://example.com/image.jpg")),
        "name",
        Uri.parse("http://example.com/image.jpg"),
        const <DeleteAttribute>[],
      ),
      Fixture(
        ProfileUpdate<String>.update("name"),
        ProfileUpdate<Uri>.delete(),
        "name",
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
        ProfileUpdate<Uri>.update(Uri.parse("http://example.com/image.jpg")),
        null,
        Uri.parse("http://example.com/image.jpg"),
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
      final deleteData = fixture.get4<List<DeleteAttribute>>();

      await account.updateProfile(
        displayName: nameUpdate,
        photoUrl: photoUpdate,
      );

      verify(mockApi.updateProfile(ProfileUpdateRequest(
        idToken: "idToken",
        displayName: nameData,
        photoUrl: photoData,
        deleteAttribute: deleteData,
        returnSecureToken: false,
      )));
    });

    group("linkEmail", () {
      test("sends link email request", () async {
        when(mockApi.linkEmail(any)).thenAnswer((i) async => LinkEmailResponse(
              emailVerified: false,
            ));

        const mail = "mail";
        const password = "password";
        final result = await account.linkEmail(
          mail,
          password,
          autoVerify: false,
        );

        verify(mockApi.linkEmail(LinkEmailRequest(
          idToken: "idToken",
          email: mail,
          password: password,
          returnSecureToken: false,
        )));
        expect(result, false);
      });

      test("returns email verified as result", () async {
        when(mockApi.linkEmail(any)).thenAnswer((i) async => LinkEmailResponse(
              emailVerified: true,
            ));

        final result = await account.linkEmail(
          "mail",
          "password",
          autoVerify: false,
        );

        expect(result, true);
      });

      testWithData(
          "requests email confirmation if not verified and enabled", const [
        Fixture("ee-EE", "ee-EE"),
        Fixture(null, "ab-CD"),
      ], (fixture) async {
        when(mockApi.linkEmail(any)).thenAnswer((i) async => LinkEmailResponse(
              emailVerified: false,
            ));

        final result = await account.linkEmail(
          "mail",
          "password",
          locale: fixture.get0<String>(),
        );
        expect(result, false);

        verify(mockApi.sendOobCode(
          OobCodeRequest.verifyEmail(
            idToken: "idToken",
          ),
          fixture.get1<String>(),
        ));
      });

      test("does not request email confirmation if verified and enabled",
          () async {
        when(mockApi.linkEmail(any)).thenAnswer((i) async => LinkEmailResponse(
              emailVerified: true,
            ));

        final result = await account.linkEmail(
          "mail",
          "password",
        );
        expect(result, true);

        verifyNever(mockApi.sendOobCode(any));
      });
    });

    test("linkIdp sends link idp request", () async {
      final provider = IdpProvider.google("token");
      final uri = Uri.parse("https://localhost:4242");
      await account.linkIdp(provider, uri);

      verify(mockApi.linkIdp(LinkIdpRequest(
        idToken: "idToken",
        postBody: provider.postBody,
        requestUri: uri,
        returnIdpCredential: false,
        returnSecureToken: false,
      )));
    });

    test("unlinkProvider sends unlink request", () async {
      const providers = ["a", "b"];
      await account.unlinkProviders(providers);

      verify(mockApi.unlinkProvider(UnlinkRequest(
        idToken: "idToken",
        deleteProvider: providers,
      )));
    });

    group("delete", () {
      test("sends delete request", () async {
        await account.delete();

        verify(mockApi.delete(DeleteRequest(
          idToken: "idToken",
        )));
      });

      test("sends null to idToken stream", () async {
        final firstElement = account.idTokenStream.first;
        await account.delete();
        expect(await firstElement, null);
      });
    });

    test("dispose disables auto refresh and clears controller", () async {
      account.autoRefresh = true;
      account.dispose();

      expect(account.autoRefresh, false);
      expect(await account.idTokenStream.length, 0);
      account = null;
    });
  });
}

Future _wait(int seconds) => Future<void>.delayed(Duration(seconds: seconds));
