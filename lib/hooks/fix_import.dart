import 'dart:convert';
import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart';

Future<bool> fixupFile({
  @required File file,
  @required Directory rootDir,
  @required String packageName,
}) async {
  final isSubPath = isWithin(rootDir.path, file.path);
  final relPath = relative(file.path, from: rootDir.path);

  final stream = relativize(
    inStream:
        file.openRead().transform(utf8.decoder).transform(const LineSplitter()),
    packageName: packageName,
  );
  return stream.isEmpty;
}

Stream<String> relativize({
  @required Stream<String> inStream,
  @required String packageName,
}) async* {
  final regexp = RegExp(
      """^\\s*import\\s*(['"])package:$packageName\\/([^'"]*)['"]([^;]*);\\s*\$""");
  await for (final line in inStream) {
    final trimmedLine = line.trim();
    final match = regexp.firstMatch(trimmedLine);
    if (match != null) {
      final quote = match[1];
      final importPath = match[2];
      final ending = match[3];

      final relativeImport = importPath; // TODO here

      yield "import $quote$relativeImport$quote$ending;";
    } else {
      yield line;
    }
  }
}

/*

/**
 *
 * @param {string} file path to dart file
 * @param {boolean} verbose verbose logging
 * @returns {{lines: number, fixed: number}}
 */
async function fixImports(file, verbose) {
  if (verbose) console.log(`${file}`);
  const currentPath = file.replace(/(\/|\\)[^/\\]*.dart$/, "");
  if (!currentPath.startsWith(libFolder)) {
    throw Error(
      `Current file is not on project root or not on lib folder? File must be on ${libFolder}.`
    );
  }
  const relativePath = currentPath.substring(libFolder.length + 1);
  const fileContent = fs.readFileSync(file).toString();
  const lines = fileContent.split("\n");

  let count = 0;
  let codeLines = 0;
  for (let currentLine = 0; currentLine < lines.length; currentLine++) {
    const line = lines[currentLine].trim();
    if (line.length === 0) {
      continue;
    }
    codeLines++;
    const regex = new RegExp(
      `^\\s*import\\s*(['"])package:${packageName}\\/([^'"]*)['"]([^;]*);\\s*$`
    );

    const exec = regex.exec(line);
    if (exec) {
      if (verbose) console.log("FIX: " + line);
      const quote = exec[1];
      const importPath = exec[2];
      const ending = exec[3];
      const relativeImport = relativize(relativePath, importPath);
      const content = `import ${quote}${relativeImport}${quote}${ending};`;
      lines[currentLine] = content;
      count++;
    }
  }

  fs.writeFileSync(file, lines.join("\n"));

  return { lines: codeLines, fixed: count };
}















const os = require("os");
const fs = require("fs");

const pathSeperator = os.type() === "Windows_NT" ? "\\" : "/";

const libFolder = fs.realpathSync("./lib");

//ensure we are inside a flutter project
if (!fs.existsSync(libFolder))
  throw new Error(
    `command must be run from a flutter project root folder (you are in: ${fs.realpathSync(
      "."
    )})`
  );
const pubspec = fs.readFileSync("./pubspec.yaml").toString();
const packageName = pubspec.match(/^name:\s*(?:"|')?(\w+)(?:"|')?\s*$/m)[1];

/**
 *
 * @param {string} filePath
 * @param {string} importPath
 */
function relativize(filePath, importPath) {
  const dartSep = "/"; // dart uses this separator for imports no matter the platform
  const pathSplit = (path, sep) => (path.length === 0 ? [] : path.split(sep));
  const fileBits = pathSplit(filePath, pathSeperator);
  const importBits = pathSplit(importPath, dartSep);
  let dotdotAmount = 0,
    startIdx;
  for (startIdx = 0; startIdx < fileBits.length; startIdx++) {
    if (fileBits[startIdx] === importBits[startIdx]) {
      continue;
    }
    dotdotAmount = fileBits.length - startIdx;
    break;
  }
  const relativeBits = new Array(dotdotAmount)
    .fill("..")
    .concat(importBits.slice(startIdx));
  return relativeBits.join(dartSep);
}

/**
 * Sort imports by this order:
 * 1. DART ^\s*import\s+(?:"|')dart:
 * 2. PACKAGE ^\s*import\s+(?:"|')package:
 * 3. LOCAL ^\s*import\s+(?:"|')(?!package:|dart:)
 * then alphabetically
 *
 * @param {string} file path to dart file
 * @param {boolean} verbose verbose logging
 */
async function organizeImports(file, verbose) {
  if (verbose) console.log(`${file}`);
  const currentPath = file.replace(/(\/|\\)[^/\\]*.dart$/, "");
  if (!currentPath.startsWith(libFolder)) {
    throw Error(
      `Current file is not on project root or not on lib folder? File must be on ${libFolder}.`
    );
  }

  const fileContent = fs.readFileSync(file).toString();
  const lines = fileContent.split("\n");

  const dartImport = /^\s*import\s+(?:"|')dart:[^;]+;\s*$/;
  // const flutterImport = /^\s*import\s+(?:"|')package:flutter\/[^;]+;\s*$/;
  const packageImport = /^\s*import\s+(?:"|')package:[^;]+;\s*$/;
  const localImport = /^\s*import\s+(?:"|')(?!package:|dart:)[^;]+;\s*$/;
  const importRanking = [dartImport, packageImport, localImport];

  lines.sort((lineA, lineB) => {
    const rxIndexA = importRanking.findIndex((rx) => rx.test(lineA));
    const rxIndexB = importRanking.findIndex((rx) => rx.test(lineB));
    if (rxIndexA < 0 || rxIndexB < 0) return 0; //one or both of the lines is not an import

    if (rxIndexA !== rxIndexB) {
      return (
        importRanking.length - rxIndexB - (importRanking.length - rxIndexA)
      );
    } else {
      return lineA === lineB ? 0 : lineA < lineB ? -1 : 1;
    }
  });

  let currentRanking = undefined;
  //remove newlines
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    if (
      line.trim().length === 0 &&
      (typeof currentRanking === undefined || currentRanking >= 0)
    ) {
      lines.splice(i, 1);
      i--;
      continue;
    }
    currentRanking = importRanking.findIndex((rx) => rx.test(line));
  }

  //add newlines
  const finalLines = [];
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const lastRanking = currentRanking;
    currentRanking = importRanking.findIndex((rx) => rx.test(line));
    if (lastRanking >= 0 && lastRanking !== currentRanking) {
      finalLines.push("");
    }
    finalLines.push(line);
  }

  fs.writeFileSync(file, finalLines.join("\n"));
}

/**
 * Fix recursively all import paths in all dart file inside given folder
 * @param {string} inPath folder path were imports need to be fixed (recursive)
 * @param {boolean} organize organize order of imports
 * @param {boolean} verbose verbose logging
 * @returns {{lines: number, fixed: number}}
 */
async function fixImportsInAllDartFiles(inPath, organize, verbose) {
  const stats = fs.statSync(inPath);

  if (stats.isFile() && /\.dart$/.test(inPath)) {
    const result = await fixImports(inPath, verbose);
    if (organize) await organizeImports(inPath, verbose);
    if (organize) await organizeImports(inPath, verbose); //doppelt hält besser
    return result;
  } else if (stats.isDirectory()) {
    let count = { lines: 0, fixed: 0 };
    for (const thing of fs.readdirSync(inPath)) {
      const result = await fixImportsInAllDartFiles(
        inPath + pathSeperator + thing,
        organize,
        verbose
      );
      count.lines += result.lines;
      count.fixed += result.fixed;
    }
    return count;
  }
  //else: skip non-dart file
  return { lines: 0, fixed: 0 };
}

fixImportsInAllDartFiles(
  libFolder,
  process.argv.find((arg) => arg === "-organize"),
  process.argv.find((arg) => arg === "-v")
).then((count) => {
  console.log(`analysed ${count.lines} lines of Dart code`);
  if (count.fixed > 0) console.log(`fixed ${count.fixed} imports`);
  else console.log(`no imports needed fixing`);
});

*/
