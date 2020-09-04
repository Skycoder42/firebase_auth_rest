import 'package:freezed_annotation/freezed_annotation.dart';

import 'userdata.dart';

part 'userdata_response.freezed.dart';
part 'userdata_response.g.dart';

/// https://firebase.google.com/docs/reference/rest/auth#section-get-account-info
@freezed
abstract class UserDataResponse with _$UserDataResponse {
  const factory UserDataResponse({
    List<UserData> users,
  }) = _UserDataResponse;

  factory UserDataResponse.fromJson(Map<String, dynamic> json) =>
      _$UserDataResponseFromJson(json);
}
