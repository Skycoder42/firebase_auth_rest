import 'dart:io';

class Format {
  const Format();

  Future<bool> call(File file) async {
    final process = await Process.start(
      Platform.isWindows ? "dartfmt.bat" : "dartfmt",
      [
        "--overwrite",
        "--fix",
        "--set-exit-if-changed",
        file.path,
      ],
    );
    process.stderr.pipe(stderr);
    process.stdout.drain<void>();
    final exitCode = await process.exitCode;
    switch (exitCode) {
      case 0:
        return false;
      case 1:
        return true;
      default:
        throw "Failed to format ${file.path}";
    }
  }
}
