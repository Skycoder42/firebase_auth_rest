import 'package:freezed_annotation/freezed_annotation.dart';

part 'signin_request.freezed.dart';
part 'signin_request.g.dart';

@freezed
abstract class IdpProvider with _$IdpProvider {
  factory IdpProvider.google(String idToken) = _GoogleIdpProvider;
  factory IdpProvider.facebook(String accessToken) = _FacebookIdpProvider;
  factory IdpProvider.twitter({
    String accessToken,
    String oauthTokenSecret,
  }) = _TwitterIdpProvider;
  factory IdpProvider.custom(
    String providerId,
    Map<String, dynamic> parameters,
  ) = _CustomIdpProvider;

  @late
  String get postBody => when(
        google: (idToken) => "id_token=$idToken&providerId=google.com",
        facebook: (accessToken) =>
            "access_token=$accessToken&providerId=facebook.com",
        twitter: (accessToken, oauthTokenSecret) =>
            "access_token=$accessToken&oauth_token_secret=$oauthTokenSecret&providerId=twitter.com",
        custom: (providerId, parameters) {
          final args = ["providerId=$providerId"];
          parameters.forEach((key, value) => args.add("$key=$value"));
          return args.join("&");
        },
      );
}

@freezed
abstract class SignInRequest with _$SignInRequest {
  const factory SignInRequest.anonymous({
    @Default(true) bool returnSecureToken,
  }) = AnonymousSignInRequest;

  const factory SignInRequest.internal_idp({
    @required Uri requestUri,
    @required String postBody,
    @Default(true) bool returnSecureToken,
    @Default(false) bool returnIdpCredential,
  }) = IdpSignInRequest;

  factory SignInRequest.idp({
    @required Uri requestUri,
    @required IdpProvider idpProvider,
    @Default(true) bool returnSecureToken,
    @Default(false) bool returnIdpCredential,
  }) =>
      SignInRequest.internal_idp(
        requestUri: requestUri,
        postBody: idpProvider.postBody,
        returnSecureToken: returnSecureToken,
        returnIdpCredential: returnIdpCredential,
      );

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
