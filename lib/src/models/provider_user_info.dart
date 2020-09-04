import 'package:freezed_annotation/freezed_annotation.dart';

part 'provider_user_info.freezed.dart';
part 'provider_user_info.g.dart';

/// Used by multiple responses to list providers of an account.
///
/// - [UserData]
/// - [UpdateResponse]
@freezed
abstract class ProviderUserInfo with _$ProviderUserInfo {
  const factory ProviderUserInfo({
    String providerId,
    String federatedId,
  }) = _ProviderUserInfo;

  factory ProviderUserInfo.fromJson(Map<String, dynamic> json) =>
      _$ProviderUserInfoFromJson(json);
}
