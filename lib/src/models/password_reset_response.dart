import 'package:freezed_annotation/freezed_annotation.dart';

part 'password_reset_response.freezed.dart';
part 'password_reset_response.g.dart';

@freezed
abstract class PasswordResetResponse with _$PasswordResetResponse {
  const factory PasswordResetResponse({
    String email,
    String requestType,
  }) = _PasswordResetResponse;

  factory PasswordResetResponse.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetResponseFromJson(json);
}
