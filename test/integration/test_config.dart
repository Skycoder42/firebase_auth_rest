import 'package:dart_test_tools/test.dart';

abstract class TestConfig {
  TestConfig._();

  static Future<String> get apiKey =>
      TestEnv.load().then((c) => c['FIREBASE_API_KEY']!);

  static Future<String?> get emulatorHost =>
      TestEnv.load().then((c) => c['FIREBASE_EMULATOR_HOST']);

  static Future<int?> get emulatorPort => TestEnv.load().then(
    (c) => int.tryParse(c['FIREBASE_EMULATOR_PORT'] ?? ''),
  );
}
