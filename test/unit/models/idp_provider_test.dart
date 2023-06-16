// ignore_for_file: prefer_const_constructors
import 'package:dart_test_tools/test.dart';
import 'package:firebase_auth_rest/src/models/idp_provider.dart';
import 'package:test/test.dart';

void main() {
  testData<(IdpProvider, String, String)>(
      'IdpProvider returns correct id and postBody', [
    (
      IdpProvider.google('idToken'),
      'google.com',
      'id_token=idToken&providerId=google.com',
    ),
    (
      IdpProvider.facebook('accessToken'),
      'facebook.com',
      'access_token=accessToken&providerId=facebook.com',
    ),
    (
      IdpProvider.twitter(
        accessToken: 'accessToken',
        oauthTokenSecret: 'oauthTokenSecret',
      ),
      'twitter.com',
      'access_token=accessToken'
          '&oauth_token_secret=oauthTokenSecret'
          '&providerId=twitter.com',
    ),
    (
      IdpProvider.custom(
        providerId: 'custom',
        parameters: <String, dynamic>{'a': 'b'},
      ),
      'custom',
      'a=b&providerId=custom',
    ),
  ], (fixture) {
    expect(fixture.$1.id, fixture.$2);
    expect(fixture.$1.postBody, fixture.$3);
  });
}
