# firebase_auth_rest
[![Continous Integration](https://github.com/Skycoder42/firebase_auth_rest/workflows/Continous%20Integration/badge.svg)](https://github.com/Skycoder42/firebase_auth_rest/actions?query=workflow%3A%22Continous+Integration%22)
[![Pub Version](https://img.shields.io/pub/v/firebase_auth_rest)](https://pub.dev/packages/firebase_auth_rest)

A platform independent Dart/Flutter Wrapper for the Firebase Authentication API based on REST

## Features
- Pure Dart-based implementation
  - works on all platforms supported by dart
- Uses the official REST-API endpoints
- Provides high-level classes to manage authentication and users
- Supports multiple parallel Logins of different users
- Supports automatic background refresh
- Supports all login methods
- Proivides low-level REST classes for direct API access (import `firebase_auth_rest/rest.dart`)

## Installation
Simply add `firebase_auth_rest` to your `pubspec.yaml` and run `pub get` (or `flutter pub get`).

## Usage
The libary consists of two primary classes - the `FirebaseAuth` and the `FirebaseAccount`. You can use the `FirebaseAuth` class to perform "global" API actions that are not directly tied to a logged in user - This are things like creating accounts and signing in a user, but also functions like resetting a password that a user has forgotten.

The sign in/up methods of `FirebaseAuth` will provide you with a `FirebaseAccount`. It holds the users authentication data, like an ID-Token, and can be used to perform various account related operations, like changing the users email address or getting the full user profile. It also automatically refreshes the users credentials shortly before timeout - allthough that can be disabled and done manually.

Thw following code is a simple example, which can be found in full length, including errorhandling, at https://pub.dev/packages/firebase_auth_rest/example. It loggs into firebase as anonymous user, prints credentials and account details and then proceeds to permanently delete the account.

```.dart
// Create auth instance and sign up as anonymous user
final fbAuth = FirebaseAuth(Client(), "API-KEY");
final account = await fbAuth.signUpAnonymous();

// print credentials und user details
print("Local-ID: ${account.localId}");
final userInfo = await account.getDetails();
print("User-Info: $userInfo");

// delete and dispose the account
await account.delete();
account.dispose();
```

## Documentation
The documentation is available at https://pub.dev/documentation/firebase_auth_rest/latest/. A full example can be found at https://pub.dev/packages/firebase_auth_rest/example.