import 'package:freezed_annotation/freezed_annotation.dart';

import 'provider_user_info.dart';

part 'userdata_response.freezed.dart';
part 'userdata_response.g.dart';

@freezed
abstract class UserData with _$UserData {
  const factory UserData({
    String localId,
    String email,
    bool emailVerified,
    String displayName,
    List<ProviderUserInfo> providerUserInfo,
    Uri photoUrl,
    String passwordHash,
    double passwordUpdatedAt,
    String validSince,
    bool disabled,
    String lastLoginAt,
    String createdAt,
    bool customAuth,
  }) = _UserData;

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);
}

@freezed
abstract class UserDataResponse with _$UserDataResponse {
  const factory UserDataResponse({
    List<UserData> users,
  }) = _UserDataResponse;

  factory UserDataResponse.fromJson(Map<String, dynamic> json) =>
      _$UserDataResponseFromJson(json);
}
