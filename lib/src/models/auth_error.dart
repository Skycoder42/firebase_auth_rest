// ignore_for_file: constant_identifier_names
import "package:freezed_annotation/freezed_annotation.dart";

part "auth_error.freezed.dart";
part "auth_error.g.dart";

/// https://firebase.google.com/docs/reference/rest/auth#section-error-format
@freezed
abstract class ErrorDetails with _$ErrorDetails {
  const factory ErrorDetails({
    /// The domain in which the error occured
    String domain,

    /// The reason for the error
    String reason,

    /// The error message / code
    String message,
  }) = _ErrorDetails;

  factory ErrorDetails.fromJson(Map<String, dynamic> json) =>
      _$ErrorDetailsFromJson(json);
}

/// https://firebase.google.com/docs/reference/rest/auth#section-error-format
@freezed
abstract class ErrorData with _$ErrorData {
  const factory ErrorData({
    /// The error code
    int code,

    /// The error message
    String message,

    /// A list of details about this error
    List<ErrorDetails> errors,
  }) = _ErrorData;

  factory ErrorData.fromJson(Map<String, dynamic> json) =>
      _$ErrorDataFromJson(json);
}

/// https://firebase.google.com/docs/reference/rest/auth#section-error-format
@freezed
abstract class AuthError with _$AuthError {
  const factory AuthError([
    /// The actual error data
    ErrorData error,
  ]) = _AuthError;

  factory AuthError.fromJson(Map<String, dynamic> json) =>
      _$AuthErrorFromJson(json);
}
