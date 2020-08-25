// ignore_for_file: constant_identifier_names
import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_request.freezed.dart';
part 'update_request.g.dart';

enum DeleteAttribute {
  DISPLAY_NAME,
  PHOTO_URL,
}

@freezed
abstract class UpdateRequest with _$UpdateRequest {
  const factory UpdateRequest.confirmEmail({
    @required String oobCode,
  }) = ConfirmEmailRequest;

  const factory UpdateRequest.email({
    @required String idToken,
    @required String email,
    @Default(false) bool returnSecureToken,
  }) = EmailUpdateRequest;

  const factory UpdateRequest.password({
    @required String idToken,
    @required String password,
    @Default(false) bool returnSecureToken,
  }) = PasswordUpdateRequest;

  const factory UpdateRequest.profile({
    @required String idToken,
    String displayName,
    Uri photoUrl,
    @Default(<DeleteAttribute>[]) List<DeleteAttribute> deleteAttribute,
    @Default(false) bool returnSecureToken,
  }) = ProfileUpdateRequest;

  const factory UpdateRequest.linkEmail({
    @required String idToken,
    @required String email,
    @required String password,
    @Default(true) bool returnSecureToken,
  }) = LinkEmailRequest;

  const factory UpdateRequest.unlink({
    @required String idToken,
    @required List<String> deleteProvider,
  }) = UnlinkRequest;

  factory UpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateRequestFromJson(json);
}
