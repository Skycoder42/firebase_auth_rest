// ignore_for_file: non_constant_identifier_names
import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart';

import 'models/auth_error.dart';
import 'models/delete_request.dart';
import 'models/fetch_provider_request.dart';
import 'models/fetch_provider_response.dart';
import 'models/oob_code_request.dart';
import 'models/oob_code_response.dart';
import 'models/password_reset_request.dart';
import 'models/password_reset_response.dart';
import 'models/refresh_response.dart';
import 'models/signin_request.dart';
import 'models/signin_response.dart';
import 'models/update_request.dart';
import 'models/update_response.dart';
import 'models/userdata_request.dart';
import 'models/userdata_response.dart';

class RestApi {
  static const _firebaseLocaleHeader = "X-Firebase-Locale";
  static const _authHost = "identitytoolkit.googleapis.com";
  static const _tokenHost = "securetoken.googleapis.com";

  final Client _client;
  final String _apiKey;

  const RestApi(
    this._client,
    this._apiKey,
  );

  Future<RefreshResponse> token({
    @required String refresh_token,
    String grant_type = "refresh_token",
  }) async =>
      RefreshResponse.fromJson(await _postQuery(
        _buildUri(
          "token",
          isTokenRequest: true,
        ),
        {
          "refresh_token": refresh_token,
          "grant_type": grant_type,
        },
      ));

  Future<AnonymousSignInResponse> signUpAnonymous(
          AnonymousSignInRequest request) async =>
      AnonymousSignInResponse.fromJson(await _post(
        _buildUri("accounts:signUp"),
        request.toJson(),
      ));

  Future<PasswordSignInResponse> signUpWithPassword(
          PasswordSignInRequest request) async =>
      PasswordSignInResponse.fromJson(await _post(
        _buildUri("accounts:signUp"),
        request.toJson(),
      ));

  Future<IdpSignInResponse> signInWithIdp(IdpSignInRequest request) async =>
      IdpSignInResponse.fromJson(await _post(
        _buildUri("accounts:signInWithIdp"),
        request.toJson(),
      ));

  Future<PasswordSignInResponse> signInWithPassword(
          PasswordSignInRequest request) async =>
      PasswordSignInResponse.fromJson(await _post(
        _buildUri("accounts:signInWithPassword"),
        request.toJson(),
      ));

  Future<CustomTokenSignInResponse> signInWithCustomToken(
          CustomTokenSignInRequest request) async =>
      CustomTokenSignInResponse.fromJson(await _post(
        _buildUri("accounts:signInWithCustomToken"),
        request.toJson(),
      ));

  Future<SignInResponse> signUp(SignInRequest signInRequest) =>
      signInRequest.maybeMap<Future<SignInResponse>>(
        password: signUpWithPassword,
        orElse: () => throw ArgumentError.value(signInRequest.runtimeType),
      );

  Future<SignInResponse> signIn(SignInRequest signInRequest) =>
      signInRequest.maybeMap<Future<SignInResponse>>(
        anonymous: signUpAnonymous,
        internal_idp: signInWithIdp,
        password: signUpWithPassword,
        customToken: signInWithCustomToken,
        orElse: () => throw ArgumentError.value(signInRequest.runtimeType),
      );

  Future<UserDataResponse> getUserData(UserDataRequest request) async =>
      UserDataResponse.fromJson(await _post(
        _buildUri("accounts:lookup"),
        request.toJson(),
      ));

  Future<EmailUpdateResponse> updateEmail(EmailUpdateRequest request,
          [String locale]) async =>
      EmailUpdateResponse.fromJson(await _post(
        _buildUri("accounts:update"),
        request.toJson(),
        headers: locale != null ? {_firebaseLocaleHeader: locale} : null,
      ));

  Future<PasswordUpdateResponse> updatePassword(
          PasswordUpdateRequest request) async =>
      PasswordUpdateResponse.fromJson(await _post(
        _buildUri("accounts:update"),
        request.toJson(),
      ));

  Future<ProfileUpdateResponse> updateProfile(
          ProfileUpdateRequest request) async =>
      ProfileUpdateResponse.fromJson(await _post(
        _buildUri("accounts:update"),
        request.toJson(),
      ));

  Future<OobCodeResponse> sendOobCode(OobCodeRequest request,
          [String locale]) async =>
      OobCodeResponse.fromJson(await _post(
        _buildUri("accounts:sendOobCode"),
        request.toJson(),
        headers: locale != null ? {_firebaseLocaleHeader: locale} : null,
      ));

  Future<PasswordResetResponse> resetPassword(
          PasswordResetRequest request) async =>
      PasswordResetResponse.fromJson(await _post(
        _buildUri("accounts:resetPassword"),
        request.toJson(),
      ));

  Future<ConfirmEmailResponse> confirmEmail(
          ConfirmEmailRequest request) async =>
      ConfirmEmailResponse.fromJson(await _post(
        _buildUri("accounts:update"),
        request.toJson(),
      ));

  Future<FetchProviderResponse> fetchProviders(
          FetchProviderRequest request) async =>
      FetchProviderResponse.fromJson(await _post(
        _buildUri("accounts:createAuthUri"),
        request.toJson(),
      ));

  Future<LinkEmailResponse> linkEmail(LinkEmailRequest request) async =>
      LinkEmailResponse.fromJson(await _post(
        _buildUri("accounts:update"),
        request.toJson(),
      ));

  Future<LinkIdpResponse> linkIdp(LinkIdpRequest request) async =>
      LinkIdpResponse.fromJson(await _post(
        _buildUri("accounts:signInWithIdp"),
        request.toJson(),
      ));

  Future<UnlinkResponse> unlinkProvider(UnlinkRequest request) async =>
      UnlinkResponse.fromJson(await _post(
        _buildUri("accounts:update"),
        request.toJson(),
      ));

  Future delete(DeleteRequest request) => _post(
        _buildUri("accounts:delete"),
        request.toJson(),
        noContent: true,
      );

  Uri _buildUri(
    String path, {
    bool isTokenRequest = false,
    Map<String, dynamic> queryParameters,
  }) =>
      Uri(
        scheme: "https",
        host: isTokenRequest ? _tokenHost : _authHost,
        pathSegments: [
          "v1",
          path,
        ],
        queryParameters: {
          "key": _apiKey,
          ...?queryParameters,
        },
      );

  Future<Map<String, dynamic>> _post(
    Uri url,
    Map<String, dynamic> body, {
    Map<String, String> headers,
    bool noContent = false,
  }) async {
    final response = await _client.post(
      url,
      body: json.encode(body),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        ...?headers,
      },
    );
    return _parseResponse(response, noContent);
  }

  Future<Map<String, dynamic>> _postQuery(
          Uri url, Map<String, String> query) async =>
      _parseResponse(await _client.post(url, body: query));

  Map<String, dynamic> _parseResponse(Response response,
      [bool noContent = false]) {
    if (response.statusCode >= 300) {
      throw AuthError.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
    } else if (response.statusCode == 204 || noContent) {
      return null;
    } else {
      return json.decode(response.body) as Map<String, dynamic>;
    }
  }
}
