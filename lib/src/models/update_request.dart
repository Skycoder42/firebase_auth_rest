// ignore_for_file: constant_identifier_names
import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_request.freezed.dart';
part 'update_request.g.dart';

/// Possible values for [UpdateRequest.profile()]
enum DeleteAttribute {
  /// Unsets displayName
  DISPLAY_NAME,

  /// Unsets photoUrl
  PHOTO_URL,
}

/// Meta-Class for multiple API-Endpoints
@freezed
abstract class UpdateRequest with _$UpdateRequest {
  /// https://firebase.google.com/docs/reference/rest/auth#section-confirm-email-verification
  const factory UpdateRequest.confirmEmail({
    @required String oobCode,
  }) = ConfirmEmailRequest;

  /// https://firebase.google.com/docs/reference/rest/auth#section-change-email
  const factory UpdateRequest.email({
    @required String idToken,
    @required String email,
    @Default(false) bool returnSecureToken,
  }) = EmailUpdateRequest;

  /// https://firebase.google.com/docs/reference/rest/auth#section-change-password
  const factory UpdateRequest.password({
    @required String idToken,
    @required String password,
    @Default(false) bool returnSecureToken,
  }) = PasswordUpdateRequest;

  /// https://firebase.google.com/docs/reference/rest/auth#section-update-profile
  const factory UpdateRequest.profile({
    @required String idToken,
    String displayName,
    Uri photoUrl,
    @Default(<DeleteAttribute>[]) List<DeleteAttribute> deleteAttribute,
    @Default(false) bool returnSecureToken,
  }) = ProfileUpdateRequest;

  /// https://firebase.google.com/docs/reference/rest/auth#section-link-with-email-password
  const factory UpdateRequest.linkEmail({
    @required String idToken,
    @required String email,
    @required String password,
    @Default(true) bool returnSecureToken,
  }) = LinkEmailRequest;

  /// https://firebase.google.com/docs/reference/rest/auth#section-unlink-provider
  const factory UpdateRequest.unlink({
    @required String idToken,
    @required List<String> deleteProvider,
  }) = UnlinkRequest;

  factory UpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateRequestFromJson(json);
}
