// ignore_for_file: prefer_const_constructors
import 'package:firebase_auth_rest/src/models/idp_provider.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../test_data.dart';

void main() {
  testData<Tuple3<IdpProvider, String, String>>(
      'IdpProvider returns correct id and postBody', [
    Tuple3(
      IdpProvider.google('idToken'),
      'google.com',
      'id_token=idToken&providerId=google.com',
    ),
    Tuple3(
      IdpProvider.facebook('accessToken'),
      'facebook.com',
      'access_token=accessToken&providerId=facebook.com',
    ),
    Tuple3(
      IdpProvider.twitter(
        accessToken: 'accessToken',
        oauthTokenSecret: 'oauthTokenSecret',
      ),
      'twitter.com',
      'access_token=accessToken'
          '&oauth_token_secret=oauthTokenSecret'
          '&providerId=twitter.com',
    ),
    Tuple3(
      IdpProvider.custom(
        providerId: 'custom',
        parameters: <String, dynamic>{'a': 'b'},
      ),
      'custom',
      'a=b&providerId=custom',
    ),
  ], (fixture) {
    expect(fixture.item1.id, fixture.item2);
    expect(fixture.item1.postBody, fixture.item3);
  });
}
