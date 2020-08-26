import 'package:freezed_annotation/freezed_annotation.dart';

part 'idp_provider.freezed.dart';

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
