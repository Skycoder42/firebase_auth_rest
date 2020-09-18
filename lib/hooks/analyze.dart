import 'dart:convert';
import 'dart:io';

class Analyze {
  final List<_AnalyzeResult> _resultStream;

  const Analyze._(this._resultStream);

  static Future<Analyze> run() async => Analyze._(await _runAnalyze().toList());

  static Stream<_AnalyzeResult> _runAnalyze() async* {
    final process = await Process.start(
      Platform.isWindows ? "dartanalyzer.bat" : "dartanalyzer",
      const [
        "--format",
        "machine",
      ],
    );
    // TODO use stderr
    yield* process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .parseResult();
  }
}

class _AnalyzeResult {
  String severity;
  String category;
  String type;
  String path;
  int line;
  int column;
  int length;
  String description;
}

extension ResultTransformer on Stream<String> {
  Stream<_AnalyzeResult> parseResult() async* {
    await for (final line in this) {
      final elements = line.trim().split("|");
      if (elements.length < 8) {
        throw "Invalid output from dartanalyzer: $line";
      }
      yield _AnalyzeResult()
        ..severity = elements[0]
        ..category = elements[1]
        ..type = elements[2]
        ..path = elements[3]
        ..line = int.parse(elements[4], radix: 10)
        ..column = int.parse(elements[5], radix: 10)
        ..length = int.parse(elements[6], radix: 10)
        ..description = elements.sublist(7).join("|");
    }
  }
}
