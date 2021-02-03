import 'package:http/http.dart'; // ignore: import_of_legacy_library_into_null_safe
import 'package:mockito/mockito.dart';

class FakeRequest extends Fake implements BaseRequest {
  @override
  Uri? get url => null;
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
