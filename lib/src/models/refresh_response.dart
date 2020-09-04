// ignore_for_file: non_constant_identifier_names
import 'package:freezed_annotation/freezed_annotation.dart';

part 'refresh_response.freezed.dart';
part 'refresh_response.g.dart';

/// https://firebase.google.com/docs/reference/rest/auth#section-refresh-token
@freezed
abstract class RefreshResponse with _$RefreshResponse {
  const factory RefreshResponse({
    String token_type,
    String id_token,
    String user_id,
    String refresh_token,
    String expires_in,
    String project_id,
  }) = _RefreshResponse;

  factory RefreshResponse.fromJson(Map<String, dynamic> json) =>
      _$RefreshResponseFromJson(json);
}
