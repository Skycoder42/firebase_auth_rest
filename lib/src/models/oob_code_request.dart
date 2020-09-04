// ignore_for_file: constant_identifier_names
import 'package:freezed_annotation/freezed_annotation.dart';

part 'oob_code_request.freezed.dart';
part 'oob_code_request.g.dart';

/// Possible values for [OobCodeRequest.requestType]
enum OobCodeRequestType {
  VERIFY_EMAIL,
  PASSWORD_RESET,
}

/// Meta-Class for multiple API-Endpoints
@freezed
abstract class OobCodeRequest with _$OobCodeRequest {
  /// https://firebase.google.com/docs/reference/rest/auth#section-send-email-verification
  const factory OobCodeRequest.verifyEmail({
    @required String idToken,
    @Default(OobCodeRequestType.VERIFY_EMAIL) OobCodeRequestType requestType,
  }) = VerifyEmailRequest;

  /// https://firebase.google.com/docs/reference/rest/auth#section-send-password-reset-email
  const factory OobCodeRequest.passwordReset({
    @required String email,
    @Default(OobCodeRequestType.PASSWORD_RESET) OobCodeRequestType requestType,
  }) = PasswordRestRequest;

  factory OobCodeRequest.fromJson(Map<String, dynamic> json) =>
      _$OobCodeRequestFromJson(json);
}
