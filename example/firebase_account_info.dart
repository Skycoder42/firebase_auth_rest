import 'dart:io';

import 'package:args/args.dart';

void main(List<String> arguments) {
  final result = _runParser(arguments);
}

ArgResults _runParser(List<String> arguments) {
  final parser = ArgParser()
    ..addFlag('help',
        abbr: 'h', negatable: false, help: "Displays this help information.");

  final result = parser.parse(arguments);

  if (result['help'] as bool) {
    print(parser.usage);
    exit(0);
  }

  return result;
}
