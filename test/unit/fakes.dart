import 'dart:convert';

import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

class FakeRequest() extends Fake implements BaseRequest {
  @override
  Uri get url => Uri.http('localhost', '/');
}

class FakeResponse({
  @override final String body = '{"error": {}}',
  @override final int statusCode = 200,
}) extends Fake implements Response {
  static FakeResponse forModel<T>(
    T model, [
    Map<String, dynamic>? overwrites,
  ]) => FakeResponse(
    body: json.encode(
      overwrites != null
          ? <String, dynamic>{
              ...(model as dynamic).toJson() as Map<String, dynamic>,
              ...overwrites,
            }
          : (model as dynamic).toJson(),
    ),
  );

  @override
  BaseRequest get request => FakeRequest();

  @override
  Map<String, String> get headers => {};
}
