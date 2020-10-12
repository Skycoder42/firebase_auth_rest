import 'package:freezed_annotation/freezed_annotation.dart';

part 'signin_response.freezed.dart';
part 'signin_response.g.dart';

/// Meta-Class for multiple API-Endpoints
@freezed
abstract class SignInResponse with _$SignInResponse {
  /// https://firebase.google.com/docs/reference/rest/auth#section-sign-in-anonymously
  const factory SignInResponse.anonymous({
    /// A Firebase Auth ID token for the newly created user.
    String idToken,

    /// Since the user is anonymous, this should be empty.
    String email,

    /// A Firebase Auth refresh token for the newly created user.
    String refreshToken,

    /// The number of seconds in which the ID token expires.
    String expiresIn,

    /// The uid of the newly created user.
    String localId,
  }) = AnonymousSignInResponse;

  /// https://firebase.google.com/docs/reference/rest/auth#section-sign-in-with-oauth-credential
  const factory SignInResponse.idp({
    /// The unique ID identifies the IdP account.
    String federatedId,

    /// The linked provider ID (e.g. "google.com" for the Google provider).
    String providerId,

    /// The uid of the authenticated user.
    String localId,

    /// Whether the sign-in email is verified.
    bool emailVerified,

    /// The email of the account.
    String email,

    /// The OIDC id token if available.
    String oauthIdToken,

    /// The OAuth access token if available.
    String oauthAccessToken,

    /// The OAuth 1.0 token secret if available.
    String oauthTokenSecret,

    /// The stringified JSON response containing all the IdP data corresponding
    /// to the provided OAuth credential.
    String rawUserInfo,

    /// The first name for the account.
    String firstName,

    /// The last name for the account.
    String lastName,

    /// The full name for the account.
    String fullName,

    /// The display name for the account.
    String displayName,

    /// The photo Url for the account.
    Uri photoUrl,

    /// A Firebase Auth ID token for the authenticated user.
    String idToken,

    /// A Firebase Auth refresh token for the authenticated user.
    String refreshToken,

    /// The number of seconds in which the ID token expires.
    String expiresIn,

    /// Whether another account with the same credential already exists. The
    /// user will need to sign in to the original account and then link the
    /// current credential to it.
    bool needConfirmation,
  }) = IdpSignInResponse;

  /// Meta-Class for multiple API-Endpoints
  ///
  /// - https://firebase.google.com/docs/reference/rest/auth#section-create-email-password
  /// - https://firebase.google.com/docs/reference/rest/auth#section-sign-in-email-password
  const factory SignInResponse.password({
    /// A Firebase Auth ID token for the authenticated user.
    String idToken,

    /// The email for the authenticated user.
    String email,

    /// A Firebase Auth refresh token for the authenticated user.
    String refreshToken,

    /// The number of seconds in which the ID token expires.
    String expiresIn,

    /// The uid of the authenticated user.
    String localId,

    /// Whether the email is for an existing account.
    bool registered,
  }) = PasswordSignInResponse; // TODO split into two

  /// https://firebase.google.com/docs/reference/rest/auth#section-verify-custom-token
  const factory SignInResponse.custom({
    /// A Firebase Auth ID token generated from the provided custom token.
    String idToken,

    /// A Firebase Auth refresh token generated from the provided custom token.
    String refreshToken,

    /// The number of seconds in which the ID token expires.
    String expiresIn,

    /// @nodoc
    String localId,
  }) = CustomTokenSignInResponse;

  /// https://firebase.google.com/docs/reference/rest/auth#section-link-with-oauth-credential
  const factory SignInResponse.linkIdp({
    /// The unique ID identifies the IdP account.
    String federatedId,

    /// The linked provider ID (e.g. "google.com" for the Google provider).
    String providerId,

    /// The uid of the authenticated user.
    String localId,

    /// Whether the signin email is verified.
    bool emailVerified,

    /// The email of the account.
    String email,

    /// The OIDC id token if available.
    String oauthIdToken,

    /// The OAuth access token if available.
    String oauthAccessToken,

    /// The OAuth 1.0 token secret if available.
    String oauthTokenSecret,

    /// The stringified JSON response containing all the IdP data corresponding
    /// to the provided OAuth credential.
    String rawUserInfo,

    /// The first name for the account.
    String firstName,

    /// The last name for the account.
    String lastName,

    /// The full name for the account.
    String fullName,

    /// The display name for the account.
    String displayName,

    /// The photo Url for the account.
    Uri photoUrl,

    /// A Firebase Auth ID token for the authenticated user.
    String idToken,

    /// A Firebase Auth refresh token for the authenticated user.
    String refreshToken,

    /// The number of seconds in which the ID token expires.
    String expiresIn,
  }) = LinkIdpResponse;

  factory SignInResponse.fromJson(Map<String, dynamic> json) =>
      _$SignInResponseFromJson(json);
}
