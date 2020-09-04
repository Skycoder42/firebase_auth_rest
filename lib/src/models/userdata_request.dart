import 'package:freezed_annotation/freezed_annotation.dart';

part 'userdata_request.freezed.dart';
part 'userdata_request.g.dart';

/// https://firebase.google.com/docs/reference/rest/auth#section-get-account-info
@freezed
abstract class UserDataRequest with _$UserDataRequest {
  const factory UserDataRequest({
    @required String idToken,
  }) = _UserDataRequest;

  factory UserDataRequest.fromJson(Map<String, dynamic> json) =>
      _$UserDataRequestFromJson(json);
}
