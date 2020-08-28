// ignore_for_file: prefer_const_constructors
import 'dart:convert';

import 'package:firebase_rest_auth/firebase_rest_auth.dart';
import 'package:firebase_rest_auth/src/models/signin_response.dart';
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
  FirebaseAccount account;

  setUp(() {
    reset(mockApi);
  });

  tearDown(() {
    account?.dispose();
  });

  group("create", () {
    final mockClient = MockClient();
    final mockResponse = MockSignInResponse();

    setUp(() {
      reset(mockClient);

      reset(mockResponse);
      when(mockResponse.localId).thenReturn("localId");
      when(mockResponse.idToken).thenReturn("idToken");
      when(mockResponse.refreshToken).thenReturn("refreshToken");
      when(mockResponse.expiresIn).thenReturn("5");
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
}
