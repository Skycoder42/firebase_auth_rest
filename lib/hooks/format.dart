import 'dart:io';

Future<bool> dartFormat(File file) async {
  final result = await Process.run(
    Platform.isWindows ? "dartfmt.bat" : "dartfmt",
    [
      "--overwrite",
      "--fix",
      "--set-exit-if-changed",
      file.path,
    ],
  );
  switch (result.exitCode) {
    case 0:
      return false;
    case 1:
      return true;
    default:
      throw result.stderr as String;
  }
}
