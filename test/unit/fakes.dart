import 'dart:convert';

import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

class FakeRequest extends Fake implements BaseRequest {
  @override
  Uri get url => Uri.http('localhost', '/');
}

class FakeResponse extends Fake implements Response {
  FakeResponse({
    this.body = '{"error": {}}',
    this.statusCode = 200,
  });

  static FakeResponse forModel<T>(
    T model, [
    Map<String, dynamic>? overwrites,
  ]) =>
      FakeResponse(
        body: json.encode(
          overwrites != null
              ? <String, dynamic>{
                  // ignore: avoid_dynamic_calls
                  ...(model as dynamic).toJson(),
                  ...overwrites,
                }
              // ignore: avoid_dynamic_calls
              : (model as dynamic).toJson(),
        ),
      );

  @override
  BaseRequest get request => FakeRequest();

  @override
  Map<String, String> get headers => {};

  @override
  final int statusCode;

  @override
  final String body;
}
