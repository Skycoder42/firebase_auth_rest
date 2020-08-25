import 'package:freezed_annotation/freezed_annotation.dart';

part 'password_reset_request.freezed.dart';
part 'password_reset_request.g.dart';

@freezed
abstract class PasswordResetRequest with _$PasswordResetRequest {
  const factory PasswordResetRequest.verify({
    @required String oobCode,
  }) = VerifyPasswordResetRequest;

  const factory PasswordResetRequest.confirm({
    @required String oobCode,
    @required String newPassword,
  }) = ConfirmPasswordResetRequest;

  factory PasswordResetRequest.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetRequestFromJson(json);
}
