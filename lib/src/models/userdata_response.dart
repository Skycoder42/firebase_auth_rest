import 'package:freezed_annotation/freezed_annotation.dart';

import 'userdata.dart';

part 'userdata_response.freezed.dart';
part 'userdata_response.g.dart';

/// https://firebase.google.com/docs/reference/rest/auth#section-get-account-info
@freezed
class UserDataResponse with _$UserDataResponse {
  /// Default constructor
  const factory UserDataResponse({
    /// The account associated with the given Firebase ID token. Check
    /// [UserData] for more details.
    @Default(<UserData>[]) List<UserData> users,
  }) = _UserDataResponse;

  /// JSON constructor
  factory UserDataResponse.fromJson(Map<String, dynamic> json) =>
      _$UserDataResponseFromJson(json);
}
