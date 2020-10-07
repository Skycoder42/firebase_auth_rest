import "package:git_hooks/git_hooks.dart";
import 'package:dart_pre_commit/dart_pre_commit.dart';

void main(List<String> arguments) {
  const params = {Git.preCommit: _preCommit};
  change(arguments, params);
}

Future<bool> _preCommit() async {
  final hooks = await Hooks.create();
  final result = await hooks();
  return result.isSuccess;
}
