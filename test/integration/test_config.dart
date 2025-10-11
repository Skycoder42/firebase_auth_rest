import 'package:dart_test_tools/test.dart';

sealed class TestConfig {
  static Map<String, String>? _cachedEnv;

  static Future<Map<String, String>> get _env async =>
      _cachedEnv ??= await TestEnv.load();

  static Future<String> get apiKey => _env.then((c) => c['FIREBASE_API_KEY']!);

  static Future<String?> get emulatorHost =>
      _env.then((c) => c['FIREBASE_EMULATOR_HOST']);

  static Future<int?> get emulatorPort =>
      _env.then((c) => int.tryParse(c['FIREBASE_EMULATOR_PORT'] ?? ''));
}
