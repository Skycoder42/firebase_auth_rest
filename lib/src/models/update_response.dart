import 'package:freezed_annotation/freezed_annotation.dart';

import 'provider_user_info.dart';

part 'update_response.freezed.dart';
part 'update_response.g.dart';

/// Meta-Class for multiple API-Endpoints
@freezed
class UpdateResponse with _$UpdateResponse {
  /// https://firebase.google.com/docs/reference/rest/auth#section-confirm-email-verification
  const factory UpdateResponse.confirmEmail({
    /// The email of the account.
    String? email,

    /// The display name for the account.
    String? displayName,

    /// The photo Url for the account.
    Uri? photoUrl,

    /// The password hash.
    String? passwordHash,

    /// List of all linked [ProviderUserInfo]s.
    @Default(<ProviderUserInfo>[]) List<ProviderUserInfo> providerUserInfo,

    /// Whether or not the account's email has been verified.
    @Default(false) bool emailVerified,
  }) = ConfirmEmailResponse;

  /// https://firebase.google.com/docs/reference/rest/auth#section-change-email
  const factory UpdateResponse.email({
    /// The uid of the current user.
    required String localId,

    /// User's email address.
    String? email,

    /// Hash version of the password.
    String? passwordHash,

    /// List of all linked [ProviderUserInfo]s.
    @Default(<ProviderUserInfo>[]) List<ProviderUserInfo> providerUserInfo,

    /// New Firebase Auth ID token for user.
    String? idToken,

    /// A Firebase Auth refresh token.
    String? refreshToken,

    /// The number of seconds in which the ID token expires.
    String? expiresIn,
  }) = EmailUpdateResponse;

  /// https://firebase.google.com/docs/reference/rest/auth#section-change-password
  const factory UpdateResponse.password({
    /// The uid of the current user.
    required String localId,

    /// User's email address.
    String? email,

    /// Hash version of password.
    String? passwordHash,

    /// List of all linked [ProviderUserInfo]s.
    @Default(<ProviderUserInfo>[]) List<ProviderUserInfo> providerUserInfo,

    /// New Firebase Auth ID token for user.
    String? idToken,

    /// A Firebase Auth refresh token.
    String? refreshToken,

    /// The number of seconds in which the ID token expires.
    String? expiresIn,
  }) = PasswordUpdateResponse;

  /// https://firebase.google.com/docs/reference/rest/auth#section-update-profile
  const factory UpdateResponse.profile({
    /// The uid of the current user.
    required String localId,

    /// User's email address.
    String? email,

    /// User's new display name.
    String? displayName,

    /// User's new photo url.
    Uri? photoUrl,

    /// Hash version of password.
    String? passwordHash,

    /// List of all linked [ProviderUserInfo]s.
    @Default(<ProviderUserInfo>[]) List<ProviderUserInfo> providerUserInfo,

    /// New Firebase Auth ID token for user.
    String? idToken,

    /// A Firebase Auth refresh token.
    String? refreshToken,

    /// The number of seconds in which the ID token expires.
    String? expiresIn,
  }) = ProfileUpdateResponse;

  /// https://firebase.google.com/docs/reference/rest/auth#section-link-with-email-password
  const factory UpdateResponse.linkEmail({
    /// The uid of the current user.
    required String localId,

    /// The email of the account.
    String? email,

    /// The display name for the account.
    String? displayName,

    /// The photo Url for the account.
    Uri? photoUrl,

    /// Hash version of password.
    String? passwordHash,

    /// List of all linked [ProviderUserInfo]s.
    @Default(<ProviderUserInfo>[]) List<ProviderUserInfo> providerUserInfo,

    /// Whether or not the account's email has been verified.
    @Default(false) bool emailVerified,

    /// New Firebase Auth ID token for user.
    String? idToken,

    /// A Firebase Auth refresh token.
    String? refreshToken,

    /// The number of seconds in which the ID token expires.
    String? expiresIn,
  }) = LinkEmailResponse;

  /// https://firebase.google.com/docs/reference/rest/auth#section-unlink-provider
  const factory UpdateResponse.unlink({
    /// The uid of the current user.
    required String localId,

    /// The email of the account.
    String? email,

    /// The display name for the account.
    String? displayName,

    /// The photo Url for the account.
    Uri? photoUrl,

    /// Hash version of the password.
    String? passwordHash,

    /// List of all linked [ProviderUserInfo]s.
    @Default(<ProviderUserInfo>[]) List<ProviderUserInfo> providerUserInfo,

    /// Whether or not the account's email has been verified.
    @Default(false) bool emailVerified,
  }) = UnlinkResponse;

  /// JSON constructor
  factory UpdateResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateResponseFromJson(json);
}
