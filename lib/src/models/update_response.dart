import 'package:freezed_annotation/freezed_annotation.dart';

import 'provider_user_info.dart';

part 'update_response.freezed.dart';
part 'update_response.g.dart';

/// Meta-Class for multiple API-Endpoints
@freezed
abstract class UpdateResponse with _$UpdateResponse {
  /// https://firebase.google.com/docs/reference/rest/auth#section-confirm-email-verification
  const factory UpdateResponse.confirmEmail({
    String email,
    String displayName,
    Uri photoUrl,
    String passwordHash,
    List<ProviderUserInfo> providerUserInfo,
    bool emailVerified,
  }) = ConfirmEmailResponse;

  /// https://firebase.google.com/docs/reference/rest/auth#section-change-email
  const factory UpdateResponse.email({
    String localId,
    String email,
    String passwordHash,
    List<ProviderUserInfo> providerUserInfo,
    String idToken,
    String refreshToken,
    String expiresIn,
  }) = EmailUpdateResponse;

  /// https://firebase.google.com/docs/reference/rest/auth#section-change-password
  const factory UpdateResponse.password({
    String localId,
    String email,
    String passwordHash,
    List<ProviderUserInfo> providerUserInfo,
    String idToken,
    String refreshToken,
    String expiresIn,
  }) = PasswordUpdateResponse;

  /// https://firebase.google.com/docs/reference/rest/auth#section-update-profile
  const factory UpdateResponse.profile({
    String localId,
    String email,
    String displayName,
    Uri photoUrl,
    String passwordHash,
    List<ProviderUserInfo> providerUserInfo,
    String idToken,
    String refreshToken,
    String expiresIn,
  }) = ProfileUpdateResponse;

  /// https://firebase.google.com/docs/reference/rest/auth#section-link-with-email-password
  const factory UpdateResponse.linkEmail({
    String localId,
    String email,
    String displayName,
    Uri photoUrl,
    String passwordHash,
    List<ProviderUserInfo> providerUserInfo,
    bool emailVerified,
    String idToken,
    String refreshToken,
    String expiresIn,
  }) = LinkEmailResponse;

  /// https://firebase.google.com/docs/reference/rest/auth#section-unlink-provider
  const factory UpdateResponse.unlink({
    String localId,
    String email,
    String displayName,
    Uri photoUrl,
    String passwordHash,
    List<ProviderUserInfo> providerUserInfo,
    bool emailVerified,
  }) = UnlinkResponse;

  factory UpdateResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateResponseFromJson(json);
}
