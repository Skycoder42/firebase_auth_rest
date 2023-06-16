// ignore_for_file: avoid_print
import 'dart:io';

import 'package:firebase_auth_rest/firebase_auth_rest.dart';
import 'package:http/http.dart';

Future main(List<String> arguments) async {
  final client = Client();
  try {
    // create a firebase auth instance
    final fbAuth = FirebaseAuth(client, arguments[0], 'en-US');

    // login, set autoRefresh to true to automatically refresh the idToken in
    // the background
    print('Signing in as anonymous user...');
    final account = await fbAuth.signUpAnonymous(autoRefresh: false);
    try {
      // print localId and idToken
      print('Local-ID: ${account.localId}');
      print('ID-Token: ${account.idToken}');

      // Do stuff with the account
      print('Loading user info...');
      final userInfo = await account.getDetails();
      print('User-Info: $userInfo');

      // delete the account
      print('Deleting account...');
      await account.delete();
      print('Account deleted!');
    } finally {
      // dispose of the account instance to clean up resources
      await account.dispose();
    }

    // ignore: avoid_catches_without_on_clauses
  } catch (e) {
    print(e);
    print(
      'Pass your API-Key as first parameter and make sure, anonymous '
      'authentication has been enabled!',
    );
    exitCode = 127;
  } finally {
    // close the client - fbAuth and all attached accounts will stop working
    client.close();
  }
}
