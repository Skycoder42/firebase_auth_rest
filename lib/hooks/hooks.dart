import 'dart:io';

import 'fix_imports.dart';
import 'format.dart';
import 'run_program.dart';

class Hooks {
  final bool fixImports;
  final bool format;
  final bool analyze;

  final _runFixImports = FixImports(
    libDir: Directory("lib"),
    packageName: "",
  );
  final _runFormat = const Format();

  Hooks({
    this.fixImports = true,
    this.format = true,
    this.analyze = true,
  });

  Future<bool> call() async {
    try {
      final files = await _collectFiles();
      var hasPartiallyModified = false;
      for (final entry in files.entries) {
        final file = File(entry.key);
        if (!file.path.endsWith(".dart")) {
          continue;
        }

        stdout.writeln("Fixing up ${file.path}");
        var modified = false;
        if (fixImports) {
          modified = await _runFixImports(file) || modified;
        }
        if (format) {
          modified = await _runFormat(file) || modified;
        }

        if (modified) {
          if (entry.value) {
            hasPartiallyModified = true;
            stdout.writeln("\tWARNING: modified partially staged file");
          } else {
            await _git(["add", file.path]).drain<void>();
          }
        }
      }

      if (analyze) {}

      return !hasPartiallyModified;
    } catch (e) {
      stderr.writeln(e.toString());
      return false;
    }
  }

  Future<Map<String, bool>> _collectFiles() async {
    final indexChanges = await _git(["diff", "--name-only"]).toList();
    final stagedChanges = _git(["diff", "--name-only", "--cached"]);
    return {
      await for (var path in stagedChanges)
        if (path.isNotEmpty && path.endsWith(".dart"))
          path: indexChanges.contains(path),
    };
  }

  Stream<String> _git([List<String> arguments = const []]) =>
      runProgram("git", arguments);
}
