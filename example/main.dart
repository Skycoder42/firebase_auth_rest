// ignore_for_file: avoid_print
import 'dart:io';

import 'package:firebase_auth_rest/firebase_auth_rest.dart';
import 'package:http/http.dart';

Future main(List<String> arguments) async {
  final client = Client();

  // optional:
  // parse the 2nd and 3rd args to get the emulatorHost and emulatorPort
  // make sure to run firebase emulators:start before doing this
  final emulatorHost = arguments.asMap().containsKey(1) ? arguments[1] : null;
  final emulatorPort =
      arguments.asMap().containsKey(2) ? int.tryParse(arguments[2]) : null;
  EmulatorConfig? emulator;
  if (emulatorHost != null && emulatorPort != null) {
    print(
      'Connecting to firebase auth emulator at http://$emulatorHost:$emulatorPort',
    );
    emulator = EmulatorConfig(host: emulatorHost, port: emulatorPort);
  }

  try {
    // create a firebase auth instance
    final fbAuth = FirebaseAuth(
      client,
      arguments[0],
      locale: 'en-US',
      emulator: emulator,
    );

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
