import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:test/test.dart';

class Fixture {
  final dynamic _param0;
  final dynamic _param1;
  final dynamic _param2;
  final dynamic _param3;
  final dynamic _param4;
  final dynamic _param5;
  final dynamic _param6;
  final dynamic _param7;
  final dynamic _param8;
  final dynamic _param9;

  const Fixture([
    this._param0,
    this._param1,
    this._param2,
    this._param3,
    this._param4,
    this._param5,
    this._param6,
    this._param7,
    this._param8,
    this._param9,
  ]);

  T get0<T>() => _param0 as T;
  T get1<T>() => _param1 as T;
  T get2<T>() => _param2 as T;
  T get3<T>() => _param3 as T;
  T get4<T>() => _param4 as T;
  T get5<T>() => _param5 as T;
  T get6<T>() => _param6 as T;
  T get7<T>() => _param7 as T;
  T get8<T>() => _param8 as T;
  T get9<T>() => _param9 as T;

  @override
  String toString() {
    final data = <dynamic>[
      _param0,
      _param1,
      _param2,
      _param3,
      _param4,
      _param5,
      _param6,
      _param7,
      _param8,
      _param9,
    ];

    for (var i = data.length - 1; i >= 0; --i) {
      if (data[i] == null) {
        data.removeLast();
      } else {
        break;
      }
    }

    return data.join(", ");
  }
}

@isTestGroup
void testWithData(
  dynamic description,
  List<Fixture> fixtures,
  dynamic Function(Fixture fixture) body, {
  String testOn,
  Timeout timeout,
  dynamic skip,
  dynamic tags,
  Map<String, dynamic> onPlatform,
  int retry,
  String Function(Fixture fixture) fixtureToString,
}) {
  assert(fixtures.isNotEmpty);
  group(description, () {
    for (final fixture in fixtures) {
      test(
        fixtureToString != null ? fixtureToString(fixture) : '[$fixture]',
        () => body(fixture),
        testOn: testOn,
        timeout: timeout,
        skip: skip,
        tags: tags,
        onPlatform: onPlatform,
        retry: retry,
      );
    }
  });
}
