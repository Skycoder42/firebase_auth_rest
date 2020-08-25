import 'package:freezed_annotation/freezed_annotation.dart';

part 'fetch_provider_request.freezed.dart';
part 'fetch_provider_request.g.dart';

@freezed
abstract class FetchProviderRequest with _$FetchProviderRequest {
  const factory FetchProviderRequest({
    @required String identifier,
    @required Uri continueUri,
  }) = _FetchProviderRequest;

  factory FetchProviderRequest.fromJson(Map<String, dynamic> json) =>
      _$FetchProviderRequestFromJson(json);
}
