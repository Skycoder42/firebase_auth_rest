import 'dart:convert';
import 'dart:mirrors';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

class FakeRequest extends Fake implements BaseRequest {
  @override
  Uri get url => Uri.http('localhost', '/');
}

class FakeResponse extends Fake implements Response {
  FakeResponse({
    this.body = '{"error": {}}',
    this.statusCode = 200,
  });

  static FakeResponse forModel<T>([Map<String, dynamic>? overwrites]) {
    final members = reflectClass(T)
        .instanceMembers
        .entries
        .where((e) => e.value.isGetter)
        .where((e) => e.key != #hashCode && e.key != #runtimeType)
        .where((e) => !e.value.metadata
            .where(
              (metadata) =>
                  metadata.hasReflectee &&
                  metadata.type == reflectType(JsonKey),
            )
            .map((metadata) => metadata.reflectee as JsonKey)
            .any((jsonKey) => jsonKey.ignore ?? false))
        .map((e) => MapEntry<String, dynamic>(
              MirrorSystem.getName(e.key),
              _mapType(e.value.returnType),
            ));
    return FakeResponse(
      body: json.encode(
        overwrites != null
            ? <String, dynamic>{
                ...Map<String, dynamic>.fromEntries(members),
                ...overwrites,
              }
            : Map<String, dynamic>.fromEntries(members),
      ),
    );
  }

  static dynamic _mapType(TypeMirror typeMirror) {
    if (typeMirror.isSubtypeOf(reflectType(List))) {
      return const <dynamic>[];
    }
    switch (typeMirror.reflectedType) {
      case String:
        return 'string';
      case int:
        return 0;
      case double:
        return 0.0;
      case bool:
        return false;
      default:
        return null;
    }
  }

  @override
  BaseRequest get request => FakeRequest();

  @override
  Map<String, String> get headers => {};

  @override
  final int statusCode;

  @override
  final String body;
}
