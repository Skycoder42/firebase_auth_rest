import 'package:freezed_annotation/freezed_annotation.dart';

part 'idp_provider.freezed.dart';

/// Encapsulates IDP-Providers to log into firebase with.
///
/// The [IdpProvider] class provides various factory constructors for the
/// supported login providers used by [FirebaseAuth.signInWithIdp()]. The
/// currently supported providers are:
/// - google.com: [IdpProvider.google()]
/// - facebook.com: [IdpProvider.facebook()]
/// - twitter.com: [IdpProvider.twitter()]
///
/// If you want to use a provider other then the ones specified above, you can
/// use [IdpProvider.custom()] to create a custom provider instance.
@freezed
abstract class IdpProvider implements _$IdpProvider {
  const IdpProvider._();

  /// Create an IDP-Instance for google.com.
  ///
  /// Requires you to perform a Google-OAuth flow to obtain an [idToken]. You
  /// can then create a google provider with that data.
  const factory IdpProvider.google(String idToken) = _GoogleIdpProvider;

  /// Create an IDP-Instance for facebook.com.
  ///
  /// Requires you to perform a Facebook-OAuth flow to obtain an [accessToken].
  /// You can then create a facebook provider with that data.
  const factory IdpProvider.facebook(String accessToken) = _FacebookIdpProvider;

  /// Create an IDP-Instance for twitter.com.
  ///
  /// Requires you to perform a Twitter-OAuth flow to obtain an [accessToken].
  /// Together with an [oauthTokenSecret] you can then create a facebook
  /// provider with that data.
  const factory IdpProvider.twitter({
    required String accessToken,
    required String oauthTokenSecret,
  }) = _TwitterIdpProvider;

  /// Create an IDP-Instance for any provider not explicitly supported.
  ///
  /// After you have obtained the required credentials for your provider of
  /// choice, you can then create a provider by using the [providerId] (
  /// typically the domain of the provider) and additional [parameters], that
  /// contain the auth credentials required by firebase to log in the user.
  const factory IdpProvider.custom({
    required String providerId,
    @Default(<String, dynamic>{}) Map<String, dynamic> parameters,
  }) = _CustomIdpProvider;

  /// Returns the identifier of this provider.
  ///
  /// The provider id is typically the domain of the provider.
  String get id => when(
        google: (_) => 'google.com',
        facebook: (_) => 'facebook.com',
        twitter: (_a, _b) => 'twitter.com',
        custom: (providerId, _) => providerId,
      );

  /// Generates a HTTP-POST body to be used by the REST-API.
  ///
  /// The [postBody] is used by [FirebaseAuth.signInWithIdp()] to convert the
  /// provider to what is needed by the REST-API. This typically contains the
  /// provider [id] as well as provider-specific parameters as specified in the
  /// factory constructors.
  String get postBody {
    final params = when(
      google: (idToken) => {'id_token': idToken},
      facebook: (accessToken) => {'access_token': accessToken},
      twitter: (accessToken, oauthTokenSecret) => {
        'access_token': accessToken,
        'oauth_token_secret': oauthTokenSecret,
      },
      custom: (_, parameters) => parameters,
    );
    return Uri(queryParameters: <String, dynamic>{
      ...params,
      'providerId': id,
    }).query;
  }
}
