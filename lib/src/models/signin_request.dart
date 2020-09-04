import 'package:freezed_annotation/freezed_annotation.dart';

part 'signin_request.freezed.dart';
part 'signin_request.g.dart';

/// Meta-Class for multiple API-Endpoints
@freezed
abstract class SignInRequest with _$SignInRequest {
  /// https://firebase.google.com/docs/reference/rest/auth#section-sign-in-anonymously
  const factory SignInRequest.anonymous({
    @Default(true) bool returnSecureToken,
  }) = AnonymousSignInRequest;

  /// https://firebase.google.com/docs/reference/rest/auth#section-sign-in-with-oauth-credential
  const factory SignInRequest.idp({
    @required String postBody,
    @required Uri requestUri,
    @Default(true) bool returnSecureToken,
    @Default(false) bool returnIdpCredential,
  }) = IdpSignInRequest;

  /// Meta-Class for multiple API-Endpoints
  ///
  /// - https://firebase.google.com/docs/reference/rest/auth#section-create-email-password
  /// - https://firebase.google.com/docs/reference/rest/auth#section-sign-in-email-password
  const factory SignInRequest.password({
    @required String email,
    @required String password,
    @Default(true) bool returnSecureToken,
  }) = PasswordSignInRequest;

  /// https://firebase.google.com/docs/reference/rest/auth#section-verify-custom-token
  const factory SignInRequest.customToken({
    @required String token,
    @Default(true) bool returnSecureToken,
  }) = CustomTokenSignInRequest;

  /// https://firebase.google.com/docs/reference/rest/auth#section-link-with-oauth-credential
  const factory SignInRequest.linkIdp({
    @required String idToken,
    @required Uri requestUri,
    @required String postBody,
    @Default(true) bool returnSecureToken,
    @Default(false) bool returnIdpCredential,
  }) = LinkIdpRequest;

  factory SignInRequest.fromJson(Map<String, dynamic> json) =>
      _$SignInRequestFromJson(json);
}
