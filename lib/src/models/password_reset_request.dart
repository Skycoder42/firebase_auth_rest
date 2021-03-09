import 'package:freezed_annotation/freezed_annotation.dart';

part 'password_reset_request.freezed.dart';
part 'password_reset_request.g.dart';

/// Meta-Class for multiple API-Endpoints
@freezed
class PasswordResetRequest with _$PasswordResetRequest {
  /// https://firebase.google.com/docs/reference/rest/auth#section-verify-password-reset-code
  const factory PasswordResetRequest.verify({
    /// The email action code sent to the user's email for resetting the
    /// password.
    required String oobCode,
  }) = VerifyPasswordResetRequest;

  /// https://firebase.google.com/docs/reference/rest/auth#section-confirm-reset-password
  const factory PasswordResetRequest.confirm({
    /// The email action code sent to the user's email for resetting the
    /// password.
    required String oobCode,

    /// The user's new password.
    required String newPassword,
  }) = ConfirmPasswordResetRequest;

  /// JSON constructor
  factory PasswordResetRequest.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetRequestFromJson(json);
}
