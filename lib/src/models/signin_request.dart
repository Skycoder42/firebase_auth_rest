import 'package:freezed_annotation/freezed_annotation.dart';

part 'signin_request.freezed.dart';
part 'signin_request.g.dart';

@freezed
abstract class SignInRequest with _$SignInRequest {
  const factory SignInRequest.anonymous({
    @Default(true) bool returnSecureToken,
  }) = AnonymousSignInRequest;

  const factory SignInRequest.idp({
    @required String postBody,
    @required Uri requestUri,
    @Default(true) bool returnSecureToken,
    @Default(false) bool returnIdpCredential,
  }) = IdpSignInRequest;

  const factory SignInRequest.password({
    @required String email,
    @required String password,
    @Default(true) bool returnSecureToken,
  }) = PasswordSignInRequest;

  const factory SignInRequest.customToken({
    @required String token,
    @Default(true) bool returnSecureToken,
  }) = CustomTokenSignInRequest;

  const factory SignInRequest.linkIdp({
    @required String idToken,
    @required Uri requestUri,
    @required String postBody,
    @Default(true) bool returnSecureToken,
    @Default(false) bool returnIdpCredential,
  }) = LinkIdpRequest;

  factory SignInRequest.fromJson(Map<String, dynamic> json) =>
      _$SignInRequestFromJson(json);
}
