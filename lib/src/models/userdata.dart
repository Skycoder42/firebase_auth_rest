import 'package:freezed_annotation/freezed_annotation.dart';

import 'provider_user_info.dart';

part 'userdata.freezed.dart';
part 'userdata.g.dart';

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
