part 'test_config_js.env.dart';

abstract class TestConfig {
  const TestConfig._();

  static String get apiKey => _firebaseApiKey;
}
