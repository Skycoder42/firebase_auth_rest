import 'package:freezed_annotation/freezed_annotation.dart';

part 'oob_code_response.freezed.dart';
part 'oob_code_response.g.dart';

/// Meta-Class for multiple API-Endpoints
///
/// - https://firebase.google.com/docs/reference/rest/auth#section-send-email-verification
/// - https://firebase.google.com/docs/reference/rest/auth#section-send-password-reset-email
@freezed
abstract class OobCodeResponse with _$OobCodeResponse {
  const factory OobCodeResponse({
    /// User's email address.
    String email,
  }) = _OobCodeResponse;

  factory OobCodeResponse.fromJson(Map<String, dynamic> json) =>
      _$OobCodeResponseFromJson(json);
}
