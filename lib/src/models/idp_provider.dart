import 'package:freezed_annotation/freezed_annotation.dart';

part 'idp_provider.freezed.dart';

@freezed
abstract class IdpProvider with _$IdpProvider {
  const IdpProvider._();

  const factory IdpProvider.google(String idToken) = _GoogleIdpProvider;
  const factory IdpProvider.facebook(String accessToken) = _FacebookIdpProvider;
  const factory IdpProvider.twitter({
    String accessToken,
    String oauthTokenSecret,
  }) = _TwitterIdpProvider;
  const factory IdpProvider.custom({
    String providerId,
    Map<String, dynamic> parameters,
  }) = _CustomIdpProvider;

  String get id => when(
        google: (_) => "google.com",
        facebook: (_) => "facebook.com",
        twitter: (_a, _b) => "twitter.com",
        custom: (providerId, _) => providerId,
      );

  String get postBody {
    final params = when(
      google: (idToken) => {"id_token": idToken},
      facebook: (accessToken) => {"access_token": accessToken},
      twitter: (accessToken, oauthTokenSecret) => {
        "access_token": accessToken,
        "oauth_token_secret": oauthTokenSecret,
      },
      custom: (_, parameters) => parameters,
    );
    return Uri(queryParameters: <String, dynamic>{
      ...params,
      "providerId": id,
    }).query;
  }
}
