import 'dart:convert';
import 'dart:io';

Stream<String> runProgram(
  String program,
  List<String> arguments, {
  bool failOnExit = true,
}) async* {
  final process = await Process.start(program, arguments);
  process.stderr.pipe(stderr);
  if (failOnExit) {
    process.exitCode.then((code) {
      if (code != 0) {
        exit(code);
      }
    });
  }
  yield* process.stdout.transform(utf8.decoder).transform(const LineSplitter());
}
