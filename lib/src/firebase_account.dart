import 'dart:async';

import 'rest_api.dart';
import 'models/signin_response.dart';

class FirebaseAccount {
  final RestApi _api;

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
  );

  FirebaseAccount.create(
    this._api,
    SignInResponse signInResponse, {
    bool autoRefresh = true,
  })  : _localId = signInResponse.localId,
        _idToken = signInResponse.idToken,
        _refreshToken = signInResponse.refreshToken,
        _expiresAt = _expiresInToAt(_durFromString(signInResponse.expiresIn)) {
    this.autoRefresh = autoRefresh;
  }

  static Future<FirebaseAccount> restore(
    RestApi api,
    String refreshToken, {
    bool autoRefresh = true,
  }) async {
    final response = await api.token(refresh_token: refreshToken);
    final account = FirebaseAccount._(
      api,
      response.user_id,
      response.id_token,
      response.refresh_token,
      _expiresInToAt(_durFromString(response.expires_in)),
    );
    account.autoRefresh = autoRefresh;
    return account;
  }

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
      _scheduleAutoRefresh(expiresIn);
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
