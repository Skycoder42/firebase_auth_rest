// ignore_for_file: sort_unnamed_constructors_first
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';

class MockResponse extends Mock implements Response {
  MockResponse._();

  factory MockResponse({int statusCode = 200, String body = "{}"}) {
    final response = MockResponse._();
    when(response.statusCode).thenReturn(statusCode);
    when(response.body).thenReturn(body);
    return response;
  }
}

class MockClient extends Mock implements Client {
  void setupMock() {
    when(this.post(
      any,
      body: anyNamed("body"),
      headers: anyNamed("headers"),
      encoding: anyNamed("encoding"),
    )).thenAnswer((i) => Future.value(MockResponse()));
  }

  void setupError() {
    when(this.post(
      any,
      body: anyNamed("body"),
      headers: anyNamed("headers"),
      encoding: anyNamed("encoding"),
    )).thenAnswer((i) => Future.value(MockResponse(statusCode: 400)));
  }
}
