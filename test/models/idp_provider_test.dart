// ignore_for_file: prefer_const_constructors
import 'package:firebase_rest_auth/src/models/idp_provider.dart';
import 'package:test/test.dart';

import '../test_fixture.dart';

void main() {
  testWithData("IdpProvider returns correct id and postBody", [
    Fixture(
      IdpProvider.google("idToken"),
      "google.com",
      "id_token=idToken&providerId=google.com",
    ),
    Fixture(
      IdpProvider.facebook("accessToken"),
      "facebook.com",
      "access_token=accessToken&providerId=facebook.com",
    ),
    Fixture(
      IdpProvider.twitter(
        accessToken: "accessToken",
        oauthTokenSecret: "oauthTokenSecret",
      ),
      "twitter.com",
      "access_token=accessToken&oauth_token_secret=oauthTokenSecret&providerId=twitter.com",
    ),
    Fixture(
      IdpProvider.custom(
        providerId: "custom",
        parameters: <String, dynamic>{"a": "b"},
      ),
      "custom",
      "a=b&providerId=custom",
    ),
  ], (fixture) {
    final provider = fixture.get0<IdpProvider>();
    final id = fixture.get1<String>();
    final postBody = fixture.get2<String>();
    expect(provider.id, id);
    expect(provider.postBody, postBody);
  });
}
