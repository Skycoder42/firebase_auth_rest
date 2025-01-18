import 'package:freezed_annotation/freezed_annotation.dart';

part 'emulator_config.g.dart';
part 'emulator_config.freezed.dart';

/// Config with options for connecting the the Firebase auth emulator
@freezed
sealed class EmulatorConfig with _$EmulatorConfig {
  const factory EmulatorConfig({
    /// The URI host. Example: "127.0.0.1" or "localhost"
    required String host,

    /// The URI port. Example 4050
    required int port,

    /// The URI protocol. Default is "https".
    @Default('http') String protocol,
  }) = _EmulatorConfig;

  factory EmulatorConfig.fromJson(Map<String, dynamic> json) =>
      _$EmulatorConfigFromJson(json);
}
