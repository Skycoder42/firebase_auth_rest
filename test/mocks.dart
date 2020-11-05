import 'package:http/http.dart';
import 'package:mockito/mockito.dart';

class MockRequest extends Mock implements Request {
  MockRequest([Uri url]) {
    when(this.url).thenReturn(url ?? Uri.http('localhost', '/'));
  }
}

class MockResponse extends Mock implements Response {
  MockResponse({
    int statusCode = 200,
    String body = '{}',
    Uri url,
  }) {
    when(this.statusCode).thenReturn(statusCode);
    when(this.body).thenReturn(body);
    final request = MockRequest(url);
    when(this.request).thenReturn(request);
  }
}

class MockClient extends Mock implements Client {
  void setupMock() {
    when(this.post(
      any,
      body: anyNamed('body'),
      headers: anyNamed('headers'),
      encoding: anyNamed('encoding'),
    )).thenAnswer((i) => Future.value(MockResponse()));
  }

  void setupError() {
    when(this.post(
      any,
      body: anyNamed('body'),
      headers: anyNamed('headers'),
      encoding: anyNamed('encoding'),
    )).thenAnswer((i) => Future.value(MockResponse(statusCode: 400)));
  }
}
