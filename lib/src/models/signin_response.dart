import 'package:freezed_annotation/freezed_annotation.dart';

part 'signin_response.freezed.dart';
part 'signin_response.g.dart';

/// Meta-Class for multiple API-Endpoints
@freezed
class SignInResponse with _$SignInResponse {
  const SignInResponse._();

  /// The uid of the newly created user.
  String get localId => maybeMap(
        custom: (_) => '',
        orElse: () => throw StateError('Unreachable code was reached!'),
      );

  /// https://firebase.google.com/docs/reference/rest/auth#section-sign-in-anonymously
  const factory SignInResponse.anonymous({
    /// A Firebase Auth ID token for the newly created user.
    required String idToken,

    /// Since the user is anonymous, this should be empty.
    String? email,

    /// A Firebase Auth refresh token for the newly created user.
    required String refreshToken,

    /// The number of seconds in which the ID token expires.
    required String expiresIn,

    /// The uid of the newly created user.
    required String localId,
  }) = AnonymousSignInResponse;

  /// https://firebase.google.com/docs/reference/rest/auth#section-sign-in-with-oauth-credential
  const factory SignInResponse.idp({
    /// The unique ID identifies the IdP account.
    required String federatedId,

    /// The linked provider ID (e.g. "google.com" for the Google provider).
    required String providerId,

    /// The uid of the authenticated user.
    required String localId,

    /// Whether the sign-in email is verified.
    @Default(false) bool emailVerified,

    /// The email of the account.
    String? email,

    /// The OIDC id token if available.
    String? oauthIdToken,

    /// The OAuth access token if available.
    String? oauthAccessToken,

    /// The OAuth 1.0 token secret if available.
    String? oauthTokenSecret,

    /// The stringified JSON response containing all the IdP data corresponding
    /// to the provided OAuth credential.
    String? rawUserInfo,

    /// The first name for the account.
    String? firstName,

    /// The last name for the account.
    String? lastName,

    /// The full name for the account.
    String? fullName,

    /// The display name for the account.
    String? displayName,

    /// The photo Url for the account.
    Uri? photoUrl,

    /// A Firebase Auth ID token for the authenticated user.
    required String idToken,

    /// A Firebase Auth refresh token for the authenticated user.
    required String refreshToken,

    /// The number of seconds in which the ID token expires.
    required String expiresIn,

    /// Whether another account with the same credential already exists. The
    /// user will need to sign in to the original account and then link the
    /// current credential to it.
    @Default(false) bool needConfirmation,
  }) = IdpSignInResponse;

  /// Meta-Class for multiple API-Endpoints
  ///
  /// - https://firebase.google.com/docs/reference/rest/auth#section-create-email-password
  /// - https://firebase.google.com/docs/reference/rest/auth#section-sign-in-email-password
  const factory SignInResponse.password({
    /// A Firebase Auth ID token for the authenticated user.
    required String idToken,

    /// The email for the authenticated user.
    String? email,

    /// A Firebase Auth refresh token for the authenticated user.
    required String refreshToken,

    /// The number of seconds in which the ID token expires.
    required String expiresIn,

    /// The uid of the authenticated user.
    required String localId,

    /// Whether the email is for an existing account.
    @Default(false) bool registered,
  }) = PasswordSignInResponse; // TODO split into two

  /// https://firebase.google.com/docs/reference/rest/auth#section-verify-custom-token
  const factory SignInResponse.custom({
    /// A Firebase Auth ID token generated from the provided custom token.
    required String idToken,

    /// A Firebase Auth refresh token generated from the provided custom token.
    required String refreshToken,

    /// The number of seconds in which the ID token expires.
    required String expiresIn,
  }) = CustomTokenSignInResponse;

  /// https://firebase.google.com/docs/reference/rest/auth#section-link-with-oauth-credential
  const factory SignInResponse.linkIdp({
    /// The unique ID identifies the IdP account.
    required String federatedId,

    /// The linked provider ID (e.g. "google.com" for the Google provider).
    required String providerId,

    /// The uid of the authenticated user.
    required String localId,

    /// Whether the signin email is verified.
    @Default(false) bool emailVerified,

    /// The email of the account.
    String? email,

    /// The OIDC id token if available.
    String? oauthIdToken,

    /// The OAuth access token if available.
    String? oauthAccessToken,

    /// The OAuth 1.0 token secret if available.
    String? oauthTokenSecret,

    /// The stringified JSON response containing all the IdP data corresponding
    /// to the provided OAuth credential.
    String? rawUserInfo,

    /// The first name for the account.
    String? firstName,

    /// The last name for the account.
    String? lastName,

    /// The full name for the account.
    String? fullName,

    /// The display name for the account.
    String? displayName,

    /// The photo Url for the account.
    Uri? photoUrl,

    /// A Firebase Auth ID token for the authenticated user.
    required String idToken,

    /// A Firebase Auth refresh token for the authenticated user.
    required String refreshToken,

    /// The number of seconds in which the ID token expires.
    required String expiresIn,
  }) = LinkIdpResponse;

  /// JSON constructor
  factory SignInResponse.fromJson(Map<String, dynamic> json) =>
      _$SignInResponseFromJson(json);
}
