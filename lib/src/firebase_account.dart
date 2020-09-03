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

/// A firebase account, representing the identity of a logged in user.
///
/// Provides account credentials and operations to get more data about the user
/// or to modify the remote account. Also provide automatic refreshing of the
/// idToken.
///
/// To create an account, either load one from an existing refresh token via
/// [FirebaseAccount.restore()], or use one of the various login methods of the
/// [FirebaseAuth] class.
class FirebaseAccount {
  final RestApi _api;

  /// The default locale to be used for E-Mails sent by Firebase.
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

  /// Creates a new account from a successfuly sign in response.
  ///
  /// Instead of using this constructor directly, prefer using one of the
  /// [FirebaseAuth] classes signIn/signUp methods.
  ///
  /// The account is created by using the [client] and [apiKey] for accessing
  /// the Firebase REST endpoints. The user credentials are extracted from the
  /// [signInResponse]. If [autoRefresh] and [locale] are used to initialize
  /// these properties.
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

  /// Creates a new account from a successfuly sign in response and a [RestApi].
  ///
  /// Instead of using this constructor directly, prefer using one of the
  /// [FirebaseAuth] classes signIn/signUp methods.
  ///
  /// The account is created by using the [_api] for accessing the Firebase REST
  /// endpoints. The user credentials are extracted from the [signInResponse].
  /// If [autoRefresh] and [locale] are used to initialize these properties.
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

  /// Restores an account by using a refresh token to log the user in again.
  ///
  /// If a user has logged in once normally, you can store the [refreshToken]
  /// and the later use this method to recreate the account instance without the
  /// user logging in again. Internally, this method calls [refresh()] to obtain
  /// user credentails and the returns a newly created account from the result.
  ///
  /// The account is created by using the [client] and [apiKey] for accessing
  /// the Firebase REST endpoints. If [autoRefresh] and [locale] are used to
  /// initialize these properties.
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

  /// Restores an account by using a refresh token to log the user in again.
  ///
  /// If a user has logged in once normally, you can store the [refreshToken]
  /// and the later use this method to recreate the account instance without the
  /// user logging in again. Internally, this method calls [refresh()] to obtain
  /// user credentails and the returns a newly created account from the result.
  ///
  /// The account is created by using the [_api] for accessing the Firebase REST
  /// endpoints. If [autoRefresh] and [locale] are used to initialize these
  /// properties.
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

  /// The internally used [RestApi] instance.
  RestApi get api => _api;

  /// The local id (account-id) of the logged in user.
  String get localId => _localId;

  /// The id token of the logged in user.
  ///
  /// Use [idTokenStream] to get a new token whenever the account credentials
  /// have been refreshed via [refresh()] or automatically in the background.
  String get idToken => _idToken;

  /// The refresh token token of the logged in user.
  ///
  /// If you want to log in the user again in the future, even after the app
  /// has been restarted, persist this token and use [FirebaseAccount.restore()]
  /// to recreate the account without the user having to log in again.
  String get refreshToken => _refreshToken;

  /// The point in time when the current [idToken] expires.
  ///
  /// When [autoRefresh] is enable, the account will automatically request a new
  /// idToken via [refresh()] roughly one minute before that timeout. If it is
  /// disabled, use this value to do so yourself.
  DateTime get expiresAt => _expiresAt;

  /// Specifies if the the account should automatically refresh the [idToken].
  ///
  /// When enabled, the account will start an internal timer that will timeout
  /// roughly one minute before [expiresAt] and call [refresh()] to renew the
  /// [idToken]. This loops indenfinitely, until this property has been set to
  /// false or the account was disposed of.
  ///
  /// **Important:** If you enable auto refreshing, make sure to always call
  /// [dispose()] when you don't need the account anymore to stop the automatic
  /// refreshing.
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
    return response.users != null && response.users.isNotEmpty
        ? response.users.first
        : null;
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

  Future unlinkProviders(List<String> providers) =>
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
      // TODO use logger?
    }
  }
}
