// ignore_for_file: constant_identifier_names
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_exception.freezed.dart';
part 'auth_exception.g.dart';

/// https://firebase.google.com/docs/reference/rest/auth#section-error-format
@freezed
abstract class ErrorDetails with _$ErrorDetails {
  /// Default constructor
  const factory ErrorDetails({
    /// The domain in which the error occured
    String domain,

    /// The reason for the error
    String reason,

    /// The error message / code
    String message,
  }) = _ErrorDetails;

  /// JSON constructor
  factory ErrorDetails.fromJson(Map<String, dynamic> json) =>
      _$ErrorDetailsFromJson(json);
}

/// https://firebase.google.com/docs/reference/rest/auth#section-error-format
@freezed
abstract class ErrorData with _$ErrorData {
  /// Default constructor
  const factory ErrorData({
    /// The error code
    int code,

    /// The error message
    String message,

    /// A list of details about this error
    List<ErrorDetails> errors,
  }) = _ErrorData;

  /// JSON Constructor
  factory ErrorData.fromJson(Map<String, dynamic> json) =>
      _$ErrorDataFromJson(json);
}

/// https://firebase.google.com/docs/reference/rest/auth#section-error-format
@freezed
abstract class AuthException with _$AuthException implements Exception {
  /// Default constructor
  const factory AuthException([
    /// The actual error data
    ErrorData error,
  ]) = _AuthException;

  /// JSON Constructor
  factory AuthException.fromJson(Map<String, dynamic> json) =>
      _$AuthExceptionFromJson(json);
}
