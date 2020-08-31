// ignore_for_file: prefer_const_constructors
import 'dart:convert';

import 'package:firebase_rest_auth/src/firebase_account.dart';
import 'package:firebase_rest_auth/src/models/auth_error.dart';
import 'package:firebase_rest_auth/src/models/oob_code_request.dart';
import 'package:firebase_rest_auth/src/models/refresh_response.dart';
import 'package:firebase_rest_auth/src/models/signin_response.dart';
import 'package:firebase_rest_auth/src/models/update_request.dart';
import 'package:firebase_rest_auth/src/models/userdata.dart';
import 'package:firebase_rest_auth/src/models/userdata_request.dart';
import 'package:firebase_rest_auth/src/models/userdata_response.dart';
import 'package:firebase_rest_auth/src/rest_api.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

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

    test("requestEmailConfirmation sends oobCode request", () async {
      const locale = "ab-CD";
      await account.requestEmailConfirmation(locale: locale);

      verify(mockApi.sendOobCode(
        OobCodeRequest.verifyEmail(
          idToken: "idToken",
          requestType: OobCodeRequestType.VERIFY_EMAIL,
        ),
        locale,
      ));
    });

    test("confirmEmail sends confirm email request", () async {
      const code = "code";
      await account.confirmEmail(code);

      verify(mockApi.confirmEmail(ConfirmEmailRequest(oobCode: code)));
    });

    test("getDetails sends user data request", () async {
      when(mockApi.getUserData(any)).thenAnswer((i) async => UserDataResponse(
            users: [],
          ));

      final result = await account.getDetails();

      verify(mockApi.getUserData(UserDataRequest(idToken: "idToken")));
      expect(result, null);
    });
  });
}

Future _wait(int seconds) => Future<void>.delayed(Duration(seconds: seconds));
