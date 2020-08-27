// ignore_for_file: avoid_print
import 'dart:io';

import 'package:args/command_runner.dart';

class TestCommand extends Command<int> {
  @override
  String get name => "test";

  @override
  String get description => "test is test.";

  @override
  Future<int> run() async {
    return 0;
  }
}

Future main(List<String> arguments) async {
  try {
    final runner = CommandRunner<int>(
      "firebase_account_info",
      "Demo application.",
    )..addCommand(TestCommand());
    exitCode = (await runner.run(arguments)) ?? 0;
  } on UsageException catch (error) {
    print(error);
    exitCode = 127;
  }
}
