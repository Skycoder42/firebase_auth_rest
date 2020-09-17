import "dart:io";

import "package:git_hooks/git_hooks.dart";

void main(List<String> arguments) {
  const params = {Git.preCommit: _preCommit};
  change(arguments, params);
}

Future<bool> _preCommit() async {
  final stagedChanges =
      await _runCommand("git", ["diff", "--name-only", "--cached"]);
  final indexChanges = await _runCommand("git", ["diff", "--name-only"]);
  final files = _orderFiles(stagedChanges, indexChanges);

  var failed = false;
  for (final entry in files.entries) {
    stdout.writeln("Fixing up ${entry.key}...");
    if (entry.value) {
      // partially staged
      final res = await Process.run("dartfmt.bat",
          ["--dry-run", "--set-exit-if-changed", "--fix", entry.key]);
      if (res.exitCode != 0) {
        stderr.writeln("Found fixes for partially staged file ${entry.key}!");
        failed = true;
      }
    } else {
      // fully staged
      await _runCommand("dartfmt.bat", ["--overwrite", "--fix", entry.key]);
    }
  }

  return !failed;
}

Future<List<String>> _runCommand(
    String programm, List<String> arguments) async {
  final res = await Process.run(programm, arguments);
  if (res.exitCode != 0) {
    throw res.stderr;
  }
  return (res.stdout as String).split("\n").map((l) => l.trim()).toList();
}

Map<String, bool> _orderFiles(List<String> staged, List<String> index) => {
      for (var path in staged)
        if (path.isNotEmpty && path.endsWith(".dart"))
          path: index.contains(path),
    };
