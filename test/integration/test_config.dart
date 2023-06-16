import 'package:dart_test_tools/test.dart';

abstract class TestConfig {
  TestConfig._();

  static Future<String> get apiKey =>
      TestEnv.load().then((c) => c['FIREBASE_API_KEY']!);
}
