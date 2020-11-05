import 'package:freezed_annotation/freezed_annotation.dart';

part 'provider_user_info.freezed.dart';
part 'provider_user_info.g.dart';

/// Used by multiple responses to list providers of an account.
///
/// - [UserData]
/// - [UpdateResponse]
@freezed
abstract class ProviderUserInfo with _$ProviderUserInfo {
  /// Default constructor
  const factory ProviderUserInfo({
    /// The linked provider ID (e.g. "google.com" for the Google provider).
    String providerId,

    /// The unique ID identifies the IdP account.
    String federatedId,
  }) = _ProviderUserInfo;

  /// JSON constructor
  factory ProviderUserInfo.fromJson(Map<String, dynamic> json) =>
      _$ProviderUserInfoFromJson(json);
}
