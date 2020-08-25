import 'package:freezed_annotation/freezed_annotation.dart';

part 'delete_request.freezed.dart';
part 'delete_request.g.dart';

@freezed
abstract class DeleteRequest with _$DeleteRequest {
  const factory DeleteRequest({
    @required String idToken,
  }) = _DeleteRequest;

  factory DeleteRequest.fromJson(Map<String, dynamic> json) =>
      _$DeleteRequestFromJson(json);
}
