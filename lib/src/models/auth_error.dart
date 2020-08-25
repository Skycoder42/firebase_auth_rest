import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_error.freezed.dart';
part 'auth_error.g.dart';

@freezed
abstract class ErrorDetails with _$ErrorDetails {
  const factory ErrorDetails({
    String domain,
    String reason,
    String message,
  }) = _ErrorDetails;

  factory ErrorDetails.fromJson(Map<String, dynamic> json) =>
      _$ErrorDetailsFromJson(json);
}

@freezed
abstract class ErrorData with _$ErrorData {
  const factory ErrorData({
    int code,
    String message,
    List<ErrorDetails> errors,
  }) = _ErrorData;

  factory ErrorData.fromJson(Map<String, dynamic> json) =>
      _$ErrorDataFromJson(json);
}

@freezed
abstract class AuthError with _$AuthError {
  const factory AuthError([ErrorData error]) = _AuthError;

  factory AuthError.fromJson(Map<String, dynamic> json) =>
      _$AuthErrorFromJson(json);
}
