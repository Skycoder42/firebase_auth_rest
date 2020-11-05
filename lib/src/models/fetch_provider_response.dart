import 'package:freezed_annotation/freezed_annotation.dart';

part 'fetch_provider_response.freezed.dart';
part 'fetch_provider_response.g.dart';

/// https://firebase.google.com/docs/reference/rest/auth#section-fetch-providers-for-email
@freezed
abstract class FetchProviderResponse with _$FetchProviderResponse {
  /// Default constructors
  const factory FetchProviderResponse({
    /// The list of providers that the user has previously signed in with.
    List<String> allProviders,

    /// Whether the email is for an existing account
    bool registered,
  }) = _FetchProviderResponse;

  /// JSON constructor
  factory FetchProviderResponse.fromJson(Map<String, dynamic> json) =>
      _$FetchProviderResponseFromJson(json);
}
