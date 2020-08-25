import 'package:freezed_annotation/freezed_annotation.dart';

part 'signin_response.freezed.dart';
part 'signin_response.g.dart';

@freezed
abstract class SignInResponse with _$SignInResponse {
  const factory SignInResponse.anonymous({
    String idToken,
    String email,
    String refreshToken,
    String expiresIn,
    String localId,
  }) = AnonymousSignInResponse;

  const factory SignInResponse.idp({
    String federatedId,
    String providerId,
    String localId,
    bool emailVerified,
    String email,
    String oauthIdToken,
    String oauthAccessToken,
    String oauthTokenSecret,
    String rawUserInfo,
    String firstName,
    String lastName,
    String fullName,
    String displayName,
    Uri photoUrl,
    String idToken,
    String refreshToken,
    String expiresIn,
    bool needConfirmation,
  }) = IdpSignInResponse;

  const factory SignInResponse.password({
    String idToken,
    String email,
    String refreshToken,
    String expiresIn,
    String localId,
    bool registered,
  }) = PasswordSignInResponse;

  const factory SignInResponse.custom({
    String idToken,
    String refreshToken,
    String expiresIn,
    String localId,
  }) = CustomTokenSignInResponse;

  const factory SignInResponse.linkIdp({
    String federatedId,
    String providerId,
    String localId,
    bool emailVerified,
    String email,
    String oauthIdToken,
    String oauthAccessToken,
    String oauthTokenSecret,
    String rawUserInfo,
    String firstName,
    String lastName,
    String fullName,
    String displayName,
    Uri photoUrl,
    String idToken,
    String refreshToken,
    String expiresIn,
  }) = LinkIdpResponse;

  factory SignInResponse.fromJson(Map<String, dynamic> json) =>
      _$SignInResponseFromJson(json);
}
