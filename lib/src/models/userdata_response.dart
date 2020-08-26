import 'package:freezed_annotation/freezed_annotation.dart';

import 'provider_user_info.dart';
import 'userdata.dart';

part 'userdata_response.freezed.dart';
part 'userdata_response.g.dart';

@freezed
abstract class UserDataResponse with _$UserDataResponse {
  const factory UserDataResponse({
    List<UserData> users,
  }) = _UserDataResponse;

  factory UserDataResponse.fromJson(Map<String, dynamic> json) =>
      _$UserDataResponseFromJson(json);
}
