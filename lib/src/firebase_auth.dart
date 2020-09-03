import 'package:http/http.dart';

import 'firebase_account.dart';
import 'models/fetch_provider_request.dart';
import 'models/idp_provider.dart';
import 'models/oob_code_request.dart';
import 'models/password_reset_request.dart';
import 'models/signin_request.dart';
import 'rest_api.dart';

class FirebaseAuth {
  final RestApi _api;

  String locale;

  FirebaseAuth(
    Client client,
    String apiKey, [
    this.locale,
  ]) : _api = RestApi(client, apiKey);

  FirebaseAuth.api(
    this._api, [
    this.locale,
  ]);

  RestApi get api => _api;

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
      FirebaseAccount.apiCreate(
        _api,
        await _api.signUpAnonymous(const AnonymousSignInRequest()),
        autoRefresh: autoRefresh,
        locale: locale,
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
        locale ?? this.locale,
      );
    }
    return FirebaseAccount.apiCreate(
      _api,
      response,
      locale: this.locale,
      autoRefresh: autoRefresh,
    );
  }

  Future<FirebaseAccount> signInWithIdp(
    IdpProvider provider,
    Uri requestUri, {
    bool autoRefresh = true,
  }) async =>
      FirebaseAccount.apiCreate(
        _api,
        await _api.signInWithIdp(IdpSignInRequest(
          postBody: provider.postBody,
          requestUri: requestUri,
        )),
        autoRefresh: autoRefresh,
        locale: locale,
      );

  Future<FirebaseAccount> signInWithPassword(
    String email,
    String password, {
    bool autoRefresh = true,
  }) async =>
      FirebaseAccount.apiCreate(
        _api,
        await _api.signInWithPassword(PasswordSignInRequest(
          email: email,
          password: password,
        )),
        autoRefresh: autoRefresh,
        locale: locale,
      );

  Future<FirebaseAccount> signInWithCustomToken(
    String token, {
    bool autoRefresh = true,
  }) async =>
      FirebaseAccount.apiCreate(
        _api,
        await _api.signInWithCustomToken(CustomTokenSignInRequest(
          token: token,
        )),
        autoRefresh: autoRefresh,
        locale: locale,
      );

  Future requestPasswordReset(
    String email, {
    String locale,
  }) async =>
      _api.sendOobCode(
        OobCodeRequest.passwordReset(email: email),
        locale ?? this.locale,
      );

  Future validatePasswordReset(String oobCode) async =>
      _api.resetPassword(PasswordResetRequest.verify(oobCode: oobCode));

  Future resetPassword(String oobCode, String newPassword) async =>
      _api.resetPassword(PasswordResetRequest.confirm(
        oobCode: oobCode,
        newPassword: newPassword,
      ));
}
