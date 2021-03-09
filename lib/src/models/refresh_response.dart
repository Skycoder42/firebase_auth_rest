// ignore_for_file: non_constant_identifier_names
import 'package:freezed_annotation/freezed_annotation.dart';

part 'refresh_response.freezed.dart';
part 'refresh_response.g.dart';

/// https://firebase.google.com/docs/reference/rest/auth#section-refresh-token
@freezed
class RefreshResponse with _$RefreshResponse {
  /// Default constructor
  const factory RefreshResponse({
    /// The number of seconds in which the ID token expires.
    required String expires_in,
    // The type of the refresh token, always "Bearer".
    required String token_type,

    /// The Firebase Auth refresh token provided in the request or a new refresh
    /// token.
    required String refresh_token,

    /// A Firebase Auth ID token.
    required String id_token,

    /// The uid corresponding to the provided ID token.
    required String user_id,

    /// Your Firebase project ID.
    required String project_id,
  }) = _RefreshResponse;

  /// JSON constructor
  factory RefreshResponse.fromJson(Map<String, dynamic> json) =>
      _$RefreshResponseFromJson(json);
}
