import 'package:freezed_annotation/freezed_annotation.dart';

import 'provider_user_info.dart';

part 'update_response.freezed.dart';
part 'update_response.g.dart';

@freezed
abstract class UpdateResponse with _$UpdateResponse {
  const factory UpdateResponse.confirmEmail({
    String email,
    String displayName,
    Uri photoUrl,
    String passwordHash,
    List<ProviderUserInfo> providerUserInfo,
    bool emailVerified,
  }) = ConfirmEmailResponse;

  const factory UpdateResponse.email({
    String localId,
    String email,
    String passwordHash,
    List<ProviderUserInfo> providerUserInfo,
    String idToken,
    String refreshToken,
    String expiresIn,
  }) = EmailUpdateResponse;

  const factory UpdateResponse.password({
    String localId,
    String email,
    String passwordHash,
    List<ProviderUserInfo> providerUserInfo,
    String idToken,
    String refreshToken,
    String expiresIn,
  }) = PasswordUpdateResponse;

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
