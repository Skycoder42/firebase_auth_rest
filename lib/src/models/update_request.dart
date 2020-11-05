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
    /// The action code sent to user's email for email verification.
    @required String oobCode,
  }) = ConfirmEmailRequest;

  /// https://firebase.google.com/docs/reference/rest/auth#section-change-email
  const factory UpdateRequest.email({
    /// A Firebase Auth ID token for the user.
    @required String idToken,

    /// The user's new email.
    @required String email,

    /// Whether or not to return an ID and refresh token.
    @Default(false) bool returnSecureToken,
  }) = EmailUpdateRequest;

  /// https://firebase.google.com/docs/reference/rest/auth#section-change-password
  const factory UpdateRequest.password({
    /// A Firebase Auth ID token for the user.
    @required String idToken,

    /// User's new password.
    @required String password,

    /// Whether or not to return an ID and refresh token.
    @Default(false) bool returnSecureToken,
  }) = PasswordUpdateRequest;

  /// https://firebase.google.com/docs/reference/rest/auth#section-update-profile
  const factory UpdateRequest.profile({
    /// A Firebase Auth ID token for the user.
    @required String idToken,

    /// User's new display name.
    String displayName,

    /// User's new photo url.
    Uri photoUrl,

    /// List of attributes to delete, [DeleteAttribute.DISPLAY_NAME] or
    /// [DeleteAttribute.PHOTO_URL]. This will nullify these values.
    @Default(<DeleteAttribute>[]) List<DeleteAttribute> deleteAttribute,

    /// Whether or not to return an ID and refresh token.
    @Default(false) bool returnSecureToken,
  }) = ProfileUpdateRequest;

  /// https://firebase.google.com/docs/reference/rest/auth#section-link-with-email-password
  const factory UpdateRequest.linkEmail({
    /// The Firebase ID token of the account you are trying to link the
    /// credential to.
    @required String idToken,

    /// The email to link to the account.
    @required String email,

    /// The new password of the account.
    @required String password,

    /// Whether or not to return an ID and refresh token. Should always be true.
    @Default(true) bool returnSecureToken,
  }) = LinkEmailRequest;

  /// https://firebase.google.com/docs/reference/rest/auth#section-unlink-provider
  const factory UpdateRequest.unlink({
    /// The Firebase ID token of the account.
    @required String idToken,

    /// The list of provider IDs to unlink, eg: 'google.com', 'password', etc.
    @required List<String> deleteProvider,
  }) = UnlinkRequest;

  /// JSON constructor
  factory UpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateRequestFromJson(json);
}
