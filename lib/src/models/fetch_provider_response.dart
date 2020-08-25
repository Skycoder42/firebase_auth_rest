import 'package:freezed_annotation/freezed_annotation.dart';

part 'fetch_provider_response.freezed.dart';
part 'fetch_provider_response.g.dart';

@freezed
abstract class FetchProviderResponse with _$FetchProviderResponse {
  const factory FetchProviderResponse({
    List<String> allProviders,
    bool registered,
  }) = _FetchProviderResponse;

  factory FetchProviderResponse.fromJson(Map<String, dynamic> json) =>
      _$FetchProviderResponseFromJson(json);
}
