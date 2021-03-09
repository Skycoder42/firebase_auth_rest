// ignore_for_file: constant_identifier_names
import 'package:freezed_annotation/freezed_annotation.dart';

part 'oob_code_request.freezed.dart';
part 'oob_code_request.g.dart';

/// Possible values for [OobCodeRequest.requestType]
enum OobCodeRequestType {
  /// VERIFY_EMAIL
  VERIFY_EMAIL,

  /// PASSWORD_RESET
  PASSWORD_RESET,
}

/// Meta-Class for multiple API-Endpoints
@freezed
class OobCodeRequest with _$OobCodeRequest {
  /// https://firebase.google.com/docs/reference/rest/auth#section-send-email-verification
  const factory OobCodeRequest.verifyEmail({
    /// The Firebase ID token of the user to verify.
    required String idToken,

    /// The type of confirmation code to send. Should always be
    /// [OobCodeRequestType.VERIFY_EMAIL].
    @Default(OobCodeRequestType.VERIFY_EMAIL) OobCodeRequestType requestType,
  }) = VerifyEmailRequest;

  /// https://firebase.google.com/docs/reference/rest/auth#section-send-password-reset-email
  const factory OobCodeRequest.passwordReset({
    /// User's email address.
    required String email,

    /// The kind of OOB code to return. Should be
    /// [OobCodeRequestType.PASSWORD_RESET] for password reset.
    @Default(OobCodeRequestType.PASSWORD_RESET) OobCodeRequestType requestType,
  }) = PasswordRestRequest;

  /// JSON constructor
  factory OobCodeRequest.fromJson(Map<String, dynamic> json) =>
      _$OobCodeRequestFromJson(json);
}
