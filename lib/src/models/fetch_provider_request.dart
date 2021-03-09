import 'package:freezed_annotation/freezed_annotation.dart';

part 'fetch_provider_request.freezed.dart';
part 'fetch_provider_request.g.dart';

/// https://firebase.google.com/docs/reference/rest/auth#section-fetch-providers-for-email
@freezed
class FetchProviderRequest with _$FetchProviderRequest {
  /// Default constructor
  const factory FetchProviderRequest({
    /// User's email address
    required String identifier,

    /// The URI to which the IDP redirects the user back. For this use case,
    /// this is just the current URL.
    required Uri continueUri,
  }) = _FetchProviderRequest;

  /// JSON constructor
  factory FetchProviderRequest.fromJson(Map<String, dynamic> json) =>
      _$FetchProviderRequestFromJson(json);
}
