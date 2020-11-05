import 'package:freezed_annotation/freezed_annotation.dart';

part 'delete_request.freezed.dart';
part 'delete_request.g.dart';

/// https://firebase.google.com/docs/reference/rest/auth#section-delete-account
@freezed
abstract class DeleteRequest with _$DeleteRequest {
  /// Default constructor
  const factory DeleteRequest({
    /// The Firebase ID token of the user to delete.
    @required String idToken,
  }) = _DeleteRequest;

  /// JSON constructor
  factory DeleteRequest.fromJson(Map<String, dynamic> json) =>
      _$DeleteRequestFromJson(json);
}
