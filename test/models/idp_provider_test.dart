import 'package:firebase_rest_auth/src/models/idp_provider.dart';
import 'package:test/test.dart';

import '../test_fixture.dart';

void main() {
  testWithData("IdpProvider return correct postBody", [
    Fixture(
      IdpProvider.google("idToken"),
      "id_token=idToken&providerId=google.com",
    ),
    Fixture(
      IdpProvider.facebook("accessToken"),
      "access_token=accessToken&providerId=facebook.com",
    ),
    Fixture(
      IdpProvider.twitter(
        accessToken: "accessToken",
        oauthTokenSecret: "oauthTokenSecret",
      ),
      "access_token=accessToken&oauth_token_secret=oauthTokenSecret&providerId=twitter.com",
    ),
    Fixture(
      IdpProvider.custom(
        providerId: "custom",
        parameters: <String, dynamic>{"a": "b"},
      ),
      "a=b&providerId=custom",
    ),
  ], (fixture) {
    final provider = fixture.get0<IdpProvider>();
    final postBody = fixture.get1<String>();
    expect(provider.postBody, postBody);
  });
}
