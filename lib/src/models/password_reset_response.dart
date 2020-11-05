import 'package:freezed_annotation/freezed_annotation.dart';

part 'password_reset_response.freezed.dart';
part 'password_reset_response.g.dart';

/// Meta-Class for multiple API-Endpoints
///
/// - https://firebase.google.com/docs/reference/rest/auth#section-verify-password-reset-code
/// - https://firebase.google.com/docs/reference/rest/auth#section-confirm-reset-password
@freezed
abstract class PasswordResetResponse with _$PasswordResetResponse {
  /// Default constructor
  const factory PasswordResetResponse({
    /// User's email address.
    String email,

    /// Type of the email action code. Should be "PASSWORD_RESET".
    String requestType,
  }) = _PasswordResetResponse;

  /// JSON constructor
  factory PasswordResetResponse.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetResponseFromJson(json);
}
