import 'package:http/http.dart';
import 'package:mockito/mockito.dart';

class FakeRequest extends Fake implements BaseRequest {
  @override
  Uri get url => Uri.http('localhost', '/');
}

class FakeResponse extends Fake implements Response {
  FakeResponse({
    this.body = '{"error":{}}',
    this.statusCode = 200,
  });

  @override
  BaseRequest get request => FakeRequest();

  @override
  Map<String, String> get headers => {};

  @override
  final int statusCode;

  @override
  final String body;
}
