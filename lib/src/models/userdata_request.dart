import 'package:freezed_annotation/freezed_annotation.dart';

part 'userdata_request.freezed.dart';
part 'userdata_request.g.dart';

/// https://firebase.google.com/docs/reference/rest/auth#section-get-account-info
@freezed
abstract class UserDataRequest with _$UserDataRequest {
  /// Default constructor
  const factory UserDataRequest({
    /// The Firebase ID token of the account.
    @required String idToken,
  }) = _UserDataRequest;

  /// JSON constructor
  factory UserDataRequest.fromJson(Map<String, dynamic> json) =>
      _$UserDataRequestFromJson(json);
}
