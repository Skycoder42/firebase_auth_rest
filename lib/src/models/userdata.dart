import 'package:freezed_annotation/freezed_annotation.dart';

import 'provider_user_info.dart';

part 'userdata.freezed.dart';
part 'userdata.g.dart';

/// A user data object as defined by the firebase REST-API endpoints.
///
/// Check https://firebase.google.com/docs/reference/rest/auth#section-get-account-info
/// for more details about the underlying REST request.
@freezed
abstract class UserData with _$UserData {
  const factory UserData({
    /// The uid of the current user.
    String localId,

    /// The email of the account.
    String email,

    /// Whether or not the account's [email] has been verified.
    bool emailVerified,

    /// The display name for the account.
    String displayName,

    /// List of all linked [ProviderUserInfo]s.
    List<ProviderUserInfo> providerUserInfo,

    /// The photo Url for the account.
    Uri photoUrl,

    /// Hash version of password.
    String passwordHash,

    /// The timestamp, in milliseconds, that the account password was last
    /// changed.
    int passwordUpdatedAt,

    /// The timestamp, in seconds, which marks a boundary, before which Firebase
    /// ID token are considered revoked.
    String validSince,

    /// Whether the account is disabled or not.
    bool disabled,

    /// The timestamp, in milliseconds, that the account last logged in at.
    String lastLoginAt,

    /// The timestamp, in milliseconds, that the account was created at.
    String createdAt,

    /// Whether the account is authenticated by the developer.
    bool customAuth,
  }) = _UserData;

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);
}
