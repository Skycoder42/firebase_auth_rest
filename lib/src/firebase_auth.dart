import 'firebase_account.dart';
import 'models/fetch_provider_request.dart';
import 'models/oob_code_request.dart';
import 'models/password_reset_request.dart';
import 'models/signin_request.dart';
import 'rest_api.dart';

class FirebaseAuth {
  final RestApi _api;

  String _locale;

  FirebaseAuth(
    this._api, [
    this._locale,
  ]);

  String get locale => _locale;
  set locale(String locale) => _locale = locale;

  Future<List<String>> fetchProviders(
    String email, [
    Uri continueUri,
  ]) async {
    final response = await _api.fetchProviders(FetchProviderRequest(
      identifier: email,
      continueUri: continueUri ?? Uri.http("localhost", ""),
    ));
    return [
      if (response.registered) "email",
      ...response.allProviders,
    ];
  }

  Future<FirebaseAccount> signUpAnonymous({bool autoRefresh = true}) async =>
      FirebaseAccount.create(
        _api,
        await _api.signUpAnonymous(AnonymousSignInRequest()),
        autoRefresh: autoRefresh,
        locale: _locale,
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
        locale ?? _locale,
      );
    }
    return FirebaseAccount.create(
      _api,
      response,
      locale: _locale,
    );
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
        locale: _locale,
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
        locale: _locale,
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
        locale: _locale,
      );

  Future requestPasswordReset(
    String email, {
    String locale,
  }) async =>
      _api.sendOobCode(
        OobCodeRequest.passwordReset(email: email),
        locale ?? _locale,
      );

  Future validatePasswordReset(String oobCode) async =>
      _api.resetPassword(PasswordResetRequest.verify(oobCode: oobCode));

  Future resetPassword(String oobCode, String newPassword) async =>
      _api.resetPassword(PasswordResetRequest.confirm(
        oobCode: oobCode,
        newPassword: newPassword,
      ));
}
