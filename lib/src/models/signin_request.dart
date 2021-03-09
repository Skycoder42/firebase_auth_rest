import 'package:freezed_annotation/freezed_annotation.dart';

part 'signin_request.freezed.dart';
part 'signin_request.g.dart';

/// Meta-Class for multiple API-Endpoints
@freezed
class SignInRequest with _$SignInRequest {
  /// https://firebase.google.com/docs/reference/rest/auth#section-sign-in-anonymously
  const factory SignInRequest.anonymous({
    /// Whether or not to return an ID and refresh token. Should always be true.
    @Default(true) bool returnSecureToken,
  }) = AnonymousSignInRequest;

  /// https://firebase.google.com/docs/reference/rest/auth#section-sign-in-with-oauth-credential
  const factory SignInRequest.idp({
    /// The URI to which the IDP redirects the user back.
    required Uri requestUri,

    /// Contains the OAuth credential (an ID token or access token) and provider
    /// ID which issues the credential.
    required String postBody,

    /// Whether or not to return an ID and refresh token. Should always be true.
    @Default(true) bool returnSecureToken,

    /// Whether to force the return of the OAuth credential on the following
    /// errors: FEDERATED_USER_ID_ALREADY_LINKED and EMAIL_EXISTS.
    @Default(false) bool returnIdpCredential,
  }) = IdpSignInRequest;

  /// Meta-Class for multiple API-Endpoints
  ///
  /// - https://firebase.google.com/docs/reference/rest/auth#section-create-email-password
  /// - https://firebase.google.com/docs/reference/rest/auth#section-sign-in-email-password
  const factory SignInRequest.password({
    /// The email the user is signing in with.
    required String email,

    /// The password for the account.
    required String password,

    /// Whether or not to return an ID and refresh token. Should always be true.
    @Default(true) bool returnSecureToken,
  }) = PasswordSignInRequest; // TODO split into 2

  /// https://firebase.google.com/docs/reference/rest/auth#section-verify-custom-token
  const factory SignInRequest.customToken({
    /// A Firebase Auth custom token from which to create an ID and refresh
    /// token pair.
    required String token,

    /// Whether or not to return an ID and refresh token. Should always be true.
    @Default(true) bool returnSecureToken,
  }) = CustomTokenSignInRequest;

  /// https://firebase.google.com/docs/reference/rest/auth#section-link-with-oauth-credential
  const factory SignInRequest.linkIdp({
    /// The Firebase ID token of the account you are trying to link the
    /// credential to.
    required String idToken,

    /// The URI to which the IDP redirects the user back.
    required Uri requestUri,

    /// Contains the OAuth credential (an ID token or access token) and provider
    /// ID which issues the credential.
    required String postBody,

    /// Whether or not to return an ID and refresh token. Should always be true.
    @Default(true) bool returnSecureToken,

    /// Whether to force the return of the OAuth credential on the following
    /// errors: FEDERATED_USER_ID_ALREADY_LINKED and EMAIL_EXISTS.
    @Default(false) bool returnIdpCredential,
  }) = LinkIdpRequest;

  /// JSON constructor
  factory SignInRequest.fromJson(Map<String, dynamic> json) =>
      _$SignInRequestFromJson(json);
}
