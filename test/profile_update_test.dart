// ignore_for_file: prefer_const_constructors
import 'package:firebase_auth_rest/src/profile_update.dart';
import 'package:test/test.dart';

void main() {
  test("update works as expected", () {
    final update = ProfileUpdate<int>.update(42);
    expect(update.update, true);
    expect(update.delete, false);
    expect(update.data, 42);
  });

  test("delete works as expected", () {
    final update = ProfileUpdate<int>.delete();
    expect(update.update, false);
    expect(update.delete, true);
    expect(update.data, null);
  });
}
