import 'firebase_account.dart';
import 'models/oob_code_request.dart';
import 'models/password_reset_request.dart';
import 'models/signin_request.dart';
import 'models/update_request.dart';
import 'rest_api.dart';

class FirebaseAuth {
  final RestApi _api;

  FirebaseAuth(this._api);

  Future<FirebaseAccount> signUpAnonymous({bool autoRefresh = true}) async =>
      FirebaseAccount.create(
        _api,
        await _api.signUpAnonymous(AnonymousSignInRequest()),
        autoRefresh: autoRefresh,
      );

  Future<FirebaseAccount> signUpWithPassword(
    String email,
    String password, {
    bool autoVerify = true,
    bool autoRefresh = true,
    String locale,
  }) async {
    final response = await _api.signUpWithPassword(PasswordSignInRequest(
      email: email,
      password: password,
    ));
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

  Future<FirebaseAccount> signInWithIdp(IdpProvider provider, Uri requestUri,
          {bool autoRefresh = true}) async =>
      FirebaseAccount.create(
        _api,
        await _api.signInWithIdp(IdpSignInRequest(
          postBody: provider.postBody,
          requestUri: requestUri,
        )),
        autoRefresh: autoRefresh,
      );

  Future<FirebaseAccount> signInWithPassword(
    String email,
    String password, {
    bool autoRefresh = true,
  }) async =>
      FirebaseAccount.create(
        _api,
        await _api.signInWithPassword(PasswordSignInRequest(
          email: email,
          password: password,
        )),
        autoRefresh: autoRefresh,
      );

  Future<FirebaseAccount> signInWithCustomToken(
    String token, {
    bool autoRefresh = true,
  }) async =>
      FirebaseAccount.create(
        _api,
        await _api.signInWithCustomToken(CustomTokenSignInRequest(
          token: token,
        )),
        autoRefresh: autoRefresh,
      );

  Future requestEmailVerification(
    FirebaseAccount account, {
    String locale,
  }) async =>
      _api.sendOobCode(
        OobCodeRequest.verifyEmail(
          idToken: account.idToken,
        ),
        locale,
      );

  Future confirmEmail(String oobCode) async =>
      _api.confirmEmail(ConfirmEmailRequest(oobCode: oobCode));

  Future requestPasswordReset(
    String email, {
    String locale,
  }) async =>
      _api.sendOobCode(
        OobCodeRequest.passwordReset(email: email),
        locale,
      );

  Future validatePasswordReset(String oobCode) async =>
      _api.resetPassword(PasswordResetRequest.verify(oobCode: oobCode));

  Future resetPassword(String oobCode, String newPassword) async =>
      _api.resetPassword(PasswordResetRequest.confirm(
        oobCode: oobCode,
        newPassword: newPassword,
      ));
}
