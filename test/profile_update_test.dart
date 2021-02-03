// ignore_for_file: prefer_const_constructors
import 'package:firebase_auth_rest/src/profile_update.dart';
import 'package:test/test.dart';

void main() {
  test('update works as expected', () {
    final update = ProfileUpdate<int>.update(42);
    expect(update.isUpdate, true);
    expect(update.isDelete, false);
    expect(update.data, 42);
    expect(update.updateOr(55), 42);
  });

  test('delete works as expected', () {
    final update = ProfileUpdate<int>.delete();
    expect(update.isUpdate, false);
    expect(update.isDelete, true);
    expect(update.data, null);
    expect(update.updateOr(), null);
    expect(update.updateOr(55), 55);
  });
}
