import 'package:firebase_rest_auth/firebase_rest_auth.dart';

import 'firebase_account.dart';
import 'models/oob_code_request.dart';
import 'models/signin_request.dart';
import 'rest_api.dart';

class FirebaseAuth {
  final RestApi _api;

  FirebaseAuth(this._api);

  Future<FirebaseAccount> signIn(
    SignInRequest request, {
    bool autoRefresh = true,
  }) async {
    var response = await request.maybeMap(
      anonymous: (request) => _api.signUpAnonymous(request),
      internal_idp: (request) => _api.signInWithIdp(request),
      password: (request) => _api.signInWithPassword(request),
      customToken: (request) => _api.signInWithCustomToken(request),
      orElse: () => throw ArgumentError.value(request.runtimeType),
    );
    return FirebaseAccount.create(_api, response);
  }

  Future<FirebaseAccount> signUp(
    PasswordSignInRequest request, {
    bool autoVerify = true,
    bool autoRefresh = true,
    String locale,
  }) async {
    var response = await _api.signUpWithPassword(request);
    if (autoVerify) {
      await _api.sendOobCode(
        OobCodeRequest.verifyEmail(
          idToken: response.idToken,
        ),
        locale,
      );
    }
    return FirebaseAccount.create(_api, response);
  }

  Future verifyEmail(String oobCode) =>
      _api.confirmEmail(ConfirmEmailRequest(oobCode: oobCode));
}
