import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart';

class FixImports {
  final String packageName;
  final Directory libDir;

  const FixImports({
    @required this.packageName,
    @required this.libDir,
  });

  Future<bool> call(File file) async {
    final inDigest = AccumulatorSink<Digest>();
    final outDigest = AccumulatorSink<Digest>();
    final result = await Stream.fromFuture(file.readAsString())
        .transform(const LineSplitter())
        .shaSum(inDigest)
        .relativize(
          packageName: packageName,
          filePath: file.path,
          libDirPath: libDir.path,
        )
        .organizeImports()
        .shaSum(outDigest)
        .withNewlines()
        .join();

    if (inDigest.events.single != outDigest.events.single) {
      await file.writeAsString(result);
      return true;
    } else {
      return false;
    }
  }
}

extension _ImportFixExtensions on Stream<String> {
  Stream<String> shaSum(AccumulatorSink<Digest> sink) async* {
    final input = sha512.startChunkedConversion(sink);
    try {
      await for (final part in this) {
        input.add(utf8.encode(part));
        yield part;
      }
    } finally {
      input.close();
    }
  }

  Stream<String> relativize({
    @required String packageName,
    @required String filePath,
    @required String libDirPath,
  }) async* {
    if (!isWithin(libDirPath, filePath)) {
      yield* this;
      return;
    }

    final regexp = RegExp(
        """^\\s*import\\s*(['"])package:$packageName\\/([^'"]*)['"]([^;]*);\\s*\$""");

    await for (final line in this) {
      final trimmedLine = line.trim();
      final match = regexp.firstMatch(trimmedLine);
      if (match != null) {
        final quote = match[1];
        final importPath = match[2];
        final ending = match[3];
        final relativeImport =
            relative(importPath, from: filePath).replaceAll("\\", "/");

        yield "import $quote$relativeImport$quote$ending;";
      } else {
        yield line;
      }
    }
  }

  Stream<String> organizeImports() async* {
    final dartRegexp = RegExp(r"""^\s*import\s+(?:"|')dart:[^;]+;\s*$""");
    final packageRegexp = RegExp(r"""^\s*import\s+(?:"|')package:[^;]+;\s*$""");
    final relativeRegexp =
        RegExp(r"""\s*import\s+(?:"|')(?!package:|dart:)[^;]+;\s*""");

    final prefixCode = <String>[];
    final dartImports = <String>[];
    final packageImports = <String>[];
    final relativeImports = <String>[];
    final code = <String>[];

    // split into import types and code
    await for (final line in this) {
      if (dartRegexp.hasMatch(line)) {
        dartImports.add(line.trim());
      } else if (packageRegexp.hasMatch(line)) {
        packageImports.add(line.trim());
      } else if (relativeRegexp.hasMatch(line)) {
        relativeImports.add(line.trim());
      } else if (dartImports.isEmpty &&
          packageImports.isEmpty &&
          relativeImports.isEmpty) {
        prefixCode.add(line);
      } else {
        code.add(line);
      }
    }

    // remove leading/trailing empty lines
    while (code.isNotEmpty && code.first.trim().isEmpty) {
      code.removeAt(0);
    }
    while (code.isNotEmpty && code.last.trim().isEmpty) {
      code.removeLast();
    }
    while (prefixCode.isNotEmpty && prefixCode.last.trim().isEmpty) {
      prefixCode.removeLast();
    }

    // sort individual imports
    dartImports.sort((a, b) => a.compareTo(b));
    packageImports.sort((a, b) => a.compareTo(b));
    relativeImports.sort((a, b) => a.compareTo(b));

    // yield into result
    yield* Stream.fromIterable(prefixCode);
    if (dartImports.isNotEmpty) {
      yield* Stream.fromIterable(dartImports);
      yield "";
    }
    if (packageImports.isNotEmpty) {
      yield* Stream.fromIterable(packageImports);
      yield "";
    }
    if (relativeImports.isNotEmpty) {
      yield* Stream.fromIterable(relativeImports);
      yield "";
    }
    yield* Stream.fromIterable(code);
  }

  Stream<String> withNewlines() async* {
    await for (final line in this) {
      yield "$line\n";
    }
  }
}
