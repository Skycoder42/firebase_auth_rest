import 'package:freezed_annotation/freezed_annotation.dart';

part 'oob_code_response.freezed.dart';
part 'oob_code_response.g.dart';

@freezed
abstract class OobCodeResponse with _$OobCodeResponse {
  const factory OobCodeResponse({
    String email,
  }) = _OobCodeResponse;

  factory OobCodeResponse.fromJson(Map<String, dynamic> json) =>
      _$OobCodeResponseFromJson(json);
}
