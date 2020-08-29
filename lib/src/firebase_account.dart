import 'dart:async';

import 'package:http/http.dart';

import 'models/delete_request.dart';
import 'models/idp_provider.dart';
import 'models/oob_code_request.dart';
import 'models/signin_request.dart';
import 'models/signin_response.dart';
import 'models/update_request.dart';
import 'models/userdata.dart';
import 'models/userdata_request.dart';
import 'profile_update.dart';
import 'rest_api.dart';

class FirebaseAccount {
  final RestApi _api;
  String locale;

  String _localId;
  String _idToken;
  String _refreshToken;
  DateTime _expiresAt;

  Timer _refreshTimer;
  final StreamController<String> _refreshController =
      StreamController<String>.broadcast(
    onListen: () {},
    onCancel: () {},
  );

  FirebaseAccount._(
    this._api,
    this._localId,
    this._idToken,
    this._refreshToken,
    this._expiresAt,
    this.locale,
  );

  FirebaseAccount.create(
    Client client,
    String apiKey,
    SignInResponse signInResponse, {
    bool autoRefresh = true,
    String locale,
  }) : this.apiCreate(
          RestApi(client, apiKey),
          signInResponse,
          autoRefresh: autoRefresh,
          locale: locale,
        );

  FirebaseAccount.apiCreate(
    this._api,
    SignInResponse signInResponse, {
    bool autoRefresh = true,
    this.locale,
  })  : _localId = signInResponse.localId,
        _idToken = signInResponse.idToken,
        _refreshToken = signInResponse.refreshToken,
        _expiresAt = _expiresInToAt(_durFromString(signInResponse.expiresIn)) {
    this.autoRefresh = autoRefresh;
  }

  static Future<FirebaseAccount> restore(
    Client client,
    String apiKey,
    String refreshToken, {
    bool autoRefresh = true,
    String locale,
  }) =>
      apiRestore(
        RestApi(client, apiKey),
        refreshToken,
        autoRefresh: autoRefresh,
        locale: locale,
      );

  static Future<FirebaseAccount> apiRestore(
    RestApi api,
    String refreshToken, {
    bool autoRefresh = true,
    String locale,
  }) async {
    final response = await api.token(refresh_token: refreshToken);
    final account = FirebaseAccount._(
      api,
      response.user_id,
      response.id_token,
      response.refresh_token,
      _expiresInToAt(_durFromString(response.expires_in)),
      locale,
    );
    account.autoRefresh = autoRefresh;
    return account;
  }

  RestApi get api => _api;
  String get localId => _localId;
  String get idToken => _idToken;
  String get refreshToken => _refreshToken;
  DateTime get expiresAt => _expiresAt;

  bool get autoRefresh => _refreshTimer != null;
  set autoRefresh(bool autoRefresh) {
    if (autoRefresh != this.autoRefresh) {
      if (autoRefresh) {
        _scheduleAutoRefresh(_expiresAt.difference(DateTime.now().toUtc()));
      } else {
        _refreshTimer?.cancel();
        _refreshTimer = null;
      }
    }
  }

  Stream<String> get idTokenStream => _refreshController?.stream;

  Future<String> refresh() async {
    await _updateToken();
    print("2");
    return _idToken;
  }

  Future requestEmailConfirmation({
    String locale,
  }) async =>
      _api.sendOobCode(
        OobCodeRequest.verifyEmail(
          idToken: _idToken,
        ),
        locale ?? this.locale,
      );

  Future confirmEmail(String oobCode) async =>
      _api.confirmEmail(ConfirmEmailRequest(oobCode: oobCode));

  Future<UserData> getDetails() async {
    final response = await _api.getUserData(UserDataRequest(idToken: _idToken));
    return response.users.isNotEmpty ? response.users.first : null;
  }

  Future updateEmail(
    String newEmail, {
    String locale,
  }) =>
      _api.updateEmail(
        EmailUpdateRequest(
          idToken: _idToken,
          email: newEmail,
          returnSecureToken: false,
        ),
        locale ?? this.locale,
      );

  Future updatePassword(String newPassword) =>
      _api.updatePassword(PasswordUpdateRequest(
        idToken: _idToken,
        password: newPassword,
        returnSecureToken: false,
      ));

  Future updateProfile({
    ProfileUpdate<String> displayName,
    ProfileUpdate<Uri> photoUrl,
  }) =>
      _api.updateProfile(ProfileUpdateRequest(
        idToken: _idToken,
        displayName:
            displayName != null && displayName.update ? displayName.data : null,
        photoUrl: photoUrl != null && photoUrl.update ? photoUrl.data : null,
        deleteAttribute: [
          if (displayName != null && displayName.delete)
            DeleteAttribute.DISPLAY_NAME,
          if (photoUrl != null && photoUrl.delete) DeleteAttribute.PHOTO_URL,
        ],
        returnSecureToken: false,
      ));

  Future<bool> linkEmail(
    String email,
    String password, {
    bool autoVerify = true,
    String locale,
  }) async {
    final response = await _api.linkEmail(LinkEmailRequest(
      idToken: _idToken,
      email: email,
      password: password,
      returnSecureToken: false,
    ));
    if (!response.emailVerified && autoVerify) {
      await requestEmailConfirmation(locale: locale);
    }
    return response.emailVerified;
  }

  Future linkIdp(
    IdpProvider provider,
    Uri requestUri,
  ) =>
      _api.linkIdp(LinkIdpRequest(
        idToken: _idToken,
        postBody: provider.postBody,
        requestUri: requestUri,
        returnSecureToken: false,
      ));

  Future unlinkProvider(List<String> providers) =>
      _api.unlinkProvider(UnlinkRequest(
        idToken: _idToken,
        deleteProvider: providers,
      ));

  Future delete() async {
    await _api.delete(DeleteRequest(idToken: _idToken));
    _localId = null;
    _idToken = null;
    _refreshToken = null;
    _expiresAt = null;
    autoRefresh = false;
    if (_refreshController.hasListener) {
      _refreshController.add(null);
    }
  }

  void dispose() {
    autoRefresh = false;
    _refreshController.close();
  }

  static Duration _durFromString(String expiresIn) =>
      Duration(seconds: int.parse(expiresIn));

  static DateTime _expiresInToAt(Duration expiresIn) =>
      DateTime.now().toUtc().add(expiresIn);

  void _scheduleAutoRefresh(Duration expiresIn) {
    var triggerTimer = expiresIn - const Duration(minutes: 1);
    if (triggerTimer < const Duration(seconds: 1)) {
      triggerTimer = Duration.zero;
    }
    _refreshTimer = Timer(triggerTimer, _updateTokenTimout);
  }

  Future _updateToken() async {
    try {
      final response = await _api.token(refresh_token: _refreshToken);
      _idToken = response.id_token;
      _refreshToken = response.refresh_token;
      final expiresIn = _durFromString(response.expires_in);
      _expiresAt = _expiresInToAt(expiresIn);
      if (autoRefresh) {
        _scheduleAutoRefresh(expiresIn);
      }
      if (_refreshController.hasListener) {
        _refreshController.add(_idToken);
      }
    } catch (e, s) {
      autoRefresh = false;
      if (_refreshController.hasListener) {
        _refreshController.addError(e, s);
      }
      rethrow;
    }
  }

  Future _updateTokenTimout() async {
    try {
      await _updateToken();
    } catch (e) {
      // ignore e
    }
  }
}
