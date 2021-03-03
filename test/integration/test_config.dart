import 'dart:io';

abstract class TestConfig {
  const TestConfig._();

  static String get apiKey => Platform.environment['FIREBASE_API_KEY']!;
}
