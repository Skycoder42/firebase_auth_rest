import 'dart:io';

abstract class TestConfig {
  TestConfig._();

  static String get apiKey => Platform.environment['FIREBASE_API_KEY']!;
}
