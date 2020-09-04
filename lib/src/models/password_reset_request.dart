import 'package:freezed_annotation/freezed_annotation.dart';

part 'password_reset_request.freezed.dart';
part 'password_reset_request.g.dart';

/// Meta-Class for multiple API-Endpoints
@freezed
abstract class PasswordResetRequest with _$PasswordResetRequest {
  /// https://firebase.google.com/docs/reference/rest/auth#section-verify-password-reset-code
  const factory PasswordResetRequest.verify({
    @required String oobCode,
  }) = VerifyPasswordResetRequest;

  /// https://firebase.google.com/docs/reference/rest/auth#section-confirm-reset-password
  const factory PasswordResetRequest.confirm({
    @required String oobCode,
    @required String newPassword,
  }) = ConfirmPasswordResetRequest;

  factory PasswordResetRequest.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetRequestFromJson(json);
}
