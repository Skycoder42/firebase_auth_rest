import 'dart:async';

import 'models/oob_code_request.dart';
import 'models/signin_response.dart';
import 'models/update_request.dart';
import 'models/userdata_request.dart';
import 'models/userdata_response.dart';
import 'rest_api.dart';

class ProfileUpdate<T> {
  final T _data;

  bool get update => _data != null;
  bool get delete => _data == null;
  T get data => _data;

  const ProfileUpdate.update(this._data);
  const ProfileUpdate.delete() : _data = null;
}

class FirebaseAccount {
  final RestApi _api;
  String _locale;

  String _localId;
  String _idToken;
  String _refreshToken;
  DateTime _expiresAt;

  Timer _refreshTimer = null;
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
    this._locale,
  );

  FirebaseAccount.create(
    this._api,
    SignInResponse signInResponse, {
    bool autoRefresh = true,
    String locale,
  })  : _localId = signInResponse.localId,
        _idToken = signInResponse.idToken,
        _refreshToken = signInResponse.refreshToken,
        _expiresAt = _expiresInToAt(_durFromString(signInResponse.expiresIn)),
        _locale = locale {
    this.autoRefresh = autoRefresh;
  }

  static Future<FirebaseAccount> restore(
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

  String get locale => _locale;
  set locale(String locale) => _locale = locale;

  String get localId => _localId;
  String get idToken => _idToken;
  String get refreshToken => _idToken;
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
    return _idToken;
  }

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
        ),
        locale ?? _locale,
      );

  Future updatePassword(String newPassword) =>
      _api.updatePassword(PasswordUpdateRequest(
        idToken: _idToken,
        password: newPassword,
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
      ));

  Future requestEmailConfirmation(
    FirebaseAccount account, {
    String locale,
  }) async =>
      _api.sendOobCode(
        OobCodeRequest.verifyEmail(
          idToken: account.idToken,
        ),
        locale ?? _locale,
      );

  Future confirmEmail(String oobCode) async =>
      _api.confirmEmail(ConfirmEmailRequest(oobCode: oobCode));

  static Duration _durFromString(String expiresIn) =>
      Duration(seconds: int.parse(expiresIn));

  static DateTime _expiresInToAt(Duration expiresIn) =>
      DateTime.now().toUtc().add(expiresIn);

  void _scheduleAutoRefresh(Duration expiresIn) {
    var triggerTimer = expiresIn - const Duration(minutes: 1);
    if (triggerTimer < const Duration(minutes: 1)) {
      triggerTimer = Duration.zero;
    }
    _refreshTimer = Timer(triggerTimer, _updateToken);
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
    }
  }
}
