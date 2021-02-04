// ignore_for_file: non_constant_identifier_names
import 'dart:convert';

import 'package:http/http.dart';
import 'package:logging/logging.dart'; // ignore: import_of_legacy_library_into_null_safe

import 'models/auth_exception.dart';
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

/// A client wrapper class for the firebase authentication REST-Api.
///
/// The class methods itself are not extensively documented, instead all members
/// link to their endpoint documentation of the Firebase API itself.
///
/// See https://firebase.google.com/docs/reference/rest/auth for more details.
class RestApi {
  /// The default logging tag used by instances of this class
  static const loggingTag = 'firebase_rest_auth.RestApi';

  static const _firebaseLocaleHeader = 'X-Firebase-Locale';
  static const _authHost = 'identitytoolkit.googleapis.com';
  static const _tokenHost = 'securetoken.googleapis.com';

  final Logger? _logger;

  /// The HTTP-Client used to access the remote api
  final Client client;

  /// The Firebase Web-API-Key to authenticate to the remote api
  final String apiKey;

  /// Create a new api instance
  ///
  /// The api is created with [client] and [apiKey] to initialize the
  /// equivalent members. They are used to access the firebase servers.
  ///
  /// Optionally, a [loggingCategory] can be passed as last parameter to the
  /// constructor to customize logging. By default, the API logs to
  /// [loggingTag], but any category can be used here. If you pass `null`,
  /// logging will be completely disabled. See [Logger] for more details about
  /// how logging in dart works.
  RestApi(
    this.client,
    this.apiKey, {
    String? loggingCategory = loggingTag,
  }) : _logger = loggingCategory != null ? Logger(loggingCategory) : null;

  /// https://firebase.google.com/docs/reference/rest/auth#section-refresh-token
  Future<RefreshResponse> token({
    required String refresh_token,
    String grant_type = 'refresh_token',
  }) async =>
      RefreshResponse.fromJson(await _postQuery(
        _buildUri(
          'token',
          isTokenRequest: true,
        ),
        {
          'refresh_token': refresh_token,
          'grant_type': grant_type,
        },
      ));

  /// https://firebase.google.com/docs/reference/rest/auth#section-sign-in-anonymously
  Future<AnonymousSignInResponse> signUpAnonymous(
    AnonymousSignInRequest request,
  ) async =>
      AnonymousSignInResponse.fromJson(await _post(
        _buildUri('accounts:signUp'),
        request.toJson(),
      ));

  /// https://firebase.google.com/docs/reference/rest/auth#section-create-email-password
  Future<PasswordSignInResponse> signUpWithPassword(
    PasswordSignInRequest request,
  ) async =>
      PasswordSignInResponse.fromJson(await _post(
        _buildUri('accounts:signUp'),
        request.toJson(),
      ));

  /// https://firebase.google.com/docs/reference/rest/auth#section-sign-in-with-oauth-credential
  Future<IdpSignInResponse> signInWithIdp(IdpSignInRequest request) async =>
      IdpSignInResponse.fromJson(await _post(
        _buildUri('accounts:signInWithIdp'),
        request.toJson(),
      ));

  /// https://firebase.google.com/docs/reference/rest/auth#section-sign-in-email-password
  Future<PasswordSignInResponse> signInWithPassword(
    PasswordSignInRequest request,
  ) async =>
      PasswordSignInResponse.fromJson(await _post(
        _buildUri('accounts:signInWithPassword'),
        request.toJson(),
      ));

  /// https://firebase.google.com/docs/reference/rest/auth#section-verify-custom-token
  Future<CustomTokenSignInResponse> signInWithCustomToken(
    CustomTokenSignInRequest request,
  ) async =>
      CustomTokenSignInResponse.fromJson(await _post(
        _buildUri('accounts:signInWithCustomToken'),
        request.toJson(),
      ));

  /// https://firebase.google.com/docs/reference/rest/auth#section-get-account-info
  Future<UserDataResponse> getUserData(UserDataRequest request) async =>
      UserDataResponse.fromJson(await _post(
        _buildUri('accounts:lookup'),
        request.toJson(),
      ));

  /// https://firebase.google.com/docs/reference/rest/auth#section-change-email
  Future<EmailUpdateResponse> updateEmail(
    EmailUpdateRequest request, [
    String? locale,
  ]) async =>
      EmailUpdateResponse.fromJson(await _post(
        _buildUri('accounts:update'),
        request.toJson(),
        headers: locale != null ? {_firebaseLocaleHeader: locale} : null,
      ));

  /// https://firebase.google.com/docs/reference/rest/auth#section-change-password
  Future<PasswordUpdateResponse> updatePassword(
    PasswordUpdateRequest request,
  ) async =>
      PasswordUpdateResponse.fromJson(await _post(
        _buildUri('accounts:update'),
        request.toJson(),
      ));

  /// https://firebase.google.com/docs/reference/rest/auth#section-update-profile
  Future<ProfileUpdateResponse> updateProfile(
    ProfileUpdateRequest request,
  ) async =>
      ProfileUpdateResponse.fromJson(await _post(
        _buildUri('accounts:update'),
        request.toJson(),
      ));

  /// Meta-Method for multiple API-Methods
  ///
  /// - https://firebase.google.com/docs/reference/rest/auth#section-send-email-verification
  /// - https://firebase.google.com/docs/reference/rest/auth#section-send-password-reset-email
  Future<OobCodeResponse> sendOobCode(
    OobCodeRequest request, [
    String? locale,
  ]) async =>
      OobCodeResponse.fromJson(await _post(
        _buildUri('accounts:sendOobCode'),
        request.toJson(),
        headers: locale != null ? {_firebaseLocaleHeader: locale} : null,
      ));

  /// Meta-Method for multiple API-Methods
  ///
  /// - https://firebase.google.com/docs/reference/rest/auth#section-verify-password-reset-code
  /// - https://firebase.google.com/docs/reference/rest/auth#section-confirm-reset-password
  Future<PasswordResetResponse> resetPassword(
    PasswordResetRequest request,
  ) async =>
      PasswordResetResponse.fromJson(await _post(
        _buildUri('accounts:resetPassword'),
        request.toJson(),
      ));

  /// https://firebase.google.com/docs/reference/rest/auth#section-confirm-email-verification
  Future<ConfirmEmailResponse> confirmEmail(
    ConfirmEmailRequest request,
  ) async =>
      ConfirmEmailResponse.fromJson(await _post(
        _buildUri('accounts:update'),
        request.toJson(),
      ));

  /// https://firebase.google.com/docs/reference/rest/auth#section-fetch-providers-for-email
  Future<FetchProviderResponse> fetchProviders(
    FetchProviderRequest request,
  ) async =>
      FetchProviderResponse.fromJson(await _post(
        _buildUri('accounts:createAuthUri'),
        request.toJson(),
      ));

  /// https://firebase.google.com/docs/reference/rest/auth#section-link-with-email-password
  Future<LinkEmailResponse> linkEmail(LinkEmailRequest request) async =>
      LinkEmailResponse.fromJson(await _post(
        _buildUri('accounts:update'),
        request.toJson(),
      ));

  /// https://firebase.google.com/docs/reference/rest/auth#section-link-with-oauth-credential
  Future<LinkIdpResponse> linkIdp(LinkIdpRequest request) async =>
      LinkIdpResponse.fromJson(await _post(
        _buildUri('accounts:signInWithIdp'),
        request.toJson(),
      ));

  /// https://firebase.google.com/docs/reference/rest/auth#section-unlink-provider
  Future<UnlinkResponse> unlinkProvider(UnlinkRequest request) async =>
      UnlinkResponse.fromJson(await _post(
        _buildUri('accounts:update'),
        request.toJson(),
      ));

  /// https://firebase.google.com/docs/reference/rest/auth#section-delete-account
  Future<void> delete(DeleteRequest request) => _post(
        _buildUri('accounts:delete'),
        request.toJson(),
        noContent: true,
      );

  Uri _buildUri(
    String path, {
    bool isTokenRequest = false,
    Map<String, dynamic>? queryParameters,
  }) =>
      Uri(
        scheme: 'https',
        host: isTokenRequest ? _tokenHost : _authHost,
        pathSegments: [
          'v1',
          path,
        ],
        queryParameters: <String, dynamic>{
          'key': apiKey,
          ...?queryParameters,
        },
      );

  Future<Map<String, dynamic>> _post(
    Uri url,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    bool noContent = false,
  }) async {
    final allHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
    };
    body.remove('runtimeType');
    _logger?.fine('Sending POST $url');
    _logger?.finer('> Headers: $allHeaders');
    _logger?.finer('> Body: $body');
    final response = await client.post(
      url,
      body: json.encode(body),
      headers: allHeaders,
    );
    return _parseResponse(response, noContent);
  }

  Future<Map<String, dynamic>> _postQuery(
      Uri url, Map<String, String> query) async {
    const allHeaders = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
    };
    _logger?.fine('Sending POST $url');
    _logger?.finer('> Headers: $allHeaders');
    _logger?.finer('> Body: $query');
    return _parseResponse(await client.post(
      url,
      body: query,
      headers: allHeaders,
    ));
  }

  Map<String, dynamic> _parseResponse(
    Response response, [
    bool noContent = false,
  ]) {
    _logger?.fine(
      'Response for ${response.request?.url} with code: ${response.statusCode}',
    );
    _logger?.finer('> Headers: ${response.headers}');
    if (response.statusCode >= 300) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      _logger?.finer('> Body: $body');
      throw AuthException.fromJson(body);
    } else if (response.statusCode == 204 || noContent) {
      return const <String, dynamic>{};
    } else {
      final body = json.decode(response.body) as Map<String, dynamic>;
      _logger?.finer('> Body: $body');
      return body;
    }
  }
}
