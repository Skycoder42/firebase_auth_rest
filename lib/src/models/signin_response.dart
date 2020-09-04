import 'package:freezed_annotation/freezed_annotation.dart';

part 'signin_response.freezed.dart';
part 'signin_response.g.dart';

/// Meta-Class for multiple API-Endpoints
@freezed
abstract class SignInResponse with _$SignInResponse {
  /// https://firebase.google.com/docs/reference/rest/auth#section-sign-in-anonymously
  const factory SignInResponse.anonymous({
    String idToken,
    String email,
    String refreshToken,
    String expiresIn,
    String localId,
  }) = AnonymousSignInResponse;

  /// https://firebase.google.com/docs/reference/rest/auth#section-sign-in-with-oauth-credential
  const factory SignInResponse.idp({
    String federatedId,
    String providerId,
    String localId,
    bool emailVerified,
    String email,
    String oauthIdToken,
    String oauthAccessToken,
    String oauthTokenSecret,
    String rawUserInfo,
    String firstName,
    String lastName,
    String fullName,
    String displayName,
    Uri photoUrl,
    String idToken,
    String refreshToken,
    String expiresIn,
    bool needConfirmation,
  }) = IdpSignInResponse;

  /// Meta-Class for multiple API-Endpoints
  ///
  /// - https://firebase.google.com/docs/reference/rest/auth#section-create-email-password
  /// - https://firebase.google.com/docs/reference/rest/auth#section-sign-in-email-password
  const factory SignInResponse.password({
    String idToken,
    String email,
    String refreshToken,
    String expiresIn,
    String localId,
    bool registered,
  }) = PasswordSignInResponse;

  /// https://firebase.google.com/docs/reference/rest/auth#section-verify-custom-token
  const factory SignInResponse.custom({
    String idToken,
    String refreshToken,
    String expiresIn,
    String localId,
  }) = CustomTokenSignInResponse;

  /// https://firebase.google.com/docs/reference/rest/auth#section-link-with-oauth-credential
  const factory SignInResponse.linkIdp({
    String federatedId,
    String providerId,
    String localId,
    bool emailVerified,
    String email,
    String oauthIdToken,
    String oauthAccessToken,
    String oauthTokenSecret,
    String rawUserInfo,
    String firstName,
    String lastName,
    String fullName,
    String displayName,
    Uri photoUrl,
    String idToken,
    String refreshToken,
    String expiresIn,
  }) = LinkIdpResponse;

  factory SignInResponse.fromJson(Map<String, dynamic> json) =>
      _$SignInResponseFromJson(json);
}
