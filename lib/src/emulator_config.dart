/// Config with options for connecting the the Firebase auth emulator
class EmulatorConfig {
  /// The URI host. Example: "127.0.0.1" or "localhost"
  final String host;

  /// The URI port. Example 4050
  final int port;

  /// The URI protocol. Default is "https".
  final String protocol;

  /// Create a new EmulatorConfig instance
  const EmulatorConfig({
    required this.host,
    required this.port,
    this.protocol = 'http',
  });
}
