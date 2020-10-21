import 'dart:io';

import 'package:dart_pre_commit/dart_pre_commit.dart';

Future<void> main(List<String> arguments) async {
  final hooks = await Hooks.create(
    pullUpDependencies: true,
  );
  final result = await hooks();
  exitCode = result.isSuccess ? 0 : 1;
}
