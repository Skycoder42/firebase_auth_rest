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
  /// The internally used [RestApi] instance.
  final RestApi api;

  /// The default locale to be used for E-Mails sent by Firebase.
  String? locale;

  String _localId;
  String _idToken;
  String _refreshToken;
  DateTime _expiresAt;

  Timer? _refreshTimer;
  final StreamController<String> _refreshController =
      StreamController<String>.broadcast(
    onListen: () {},
    onCancel: () {},
  );

  FirebaseAccount._(
    this.api,
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
    String? locale,
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
  /// The account is created by using the [api] for accessing the Firebase REST
  /// endpoints. The user credentials are extracted from the [signInResponse].
  /// If [autoRefresh] and [locale] are used to initialize these properties.
  FirebaseAccount.apiCreate(
    this.api,
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
  ///
  /// If the refreshing fails, an [AuthError] will be thrown.
  static Future<FirebaseAccount> restore(
    Client client,
    String apiKey,
    String refreshToken, {
    bool autoRefresh = true,
    String? locale,
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
  /// The account is created by using the [api] for accessing the Firebase REST
  /// endpoints. If [autoRefresh] and [locale] are used to initialize these
  /// properties.
  ///
  /// If the refreshing fails, an [AuthError] will be thrown.
  static Future<FirebaseAccount> apiRestore(
    RestApi api,
    String refreshToken, {
    bool autoRefresh = true,
    String? locale,
  }) async {
    final response = await api.token(refresh_token: refreshToken);
    return FirebaseAccount._(
      api,
      response.user_id,
      response.id_token,
      response.refresh_token,
      _expiresInToAt(_durFromString(response.expires_in)),
      locale,
    )..autoRefresh = autoRefresh;
  }

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

  /// A broadcast stream of idTokens.
  ///
  /// Generates a new token everytime the users credentials are refreshed via
  /// [refresh()] or [autoRefresh]. The stream is a broadcast stream, so you can
  /// listen to it as you please.
  ///
  /// Whenever a new token is returned, [idToken] has also been updated.
  /// However, no intial event is sent to the stream when you subscribe. If an
  /// error happens during a refresh, the [AuthError] is passed as error to the
  /// stream, so you can react to these.
  ///
  /// **Note:** If no stream is connected, refresh errors fail silently.
  Stream<String> get idTokenStream => _refreshController.stream;

  /// Refreshes the accounts [idToken] and returns the new token.
  ///
  /// Sends the [refreshToken] to the firebase server to obtain a new [idToken].
  /// On a success, the [idToken] and [refreshToken] properties are updated and
  /// [idTokenStream] provides a new value. If the request fails, an [AuthError]
  /// is thrown.
  ///
  /// **Note:** Instead of manually refreshing whenever [expiresAt] comes close,
  /// you can simply set [autoRefresh] to true to enable automatic refreshing of
  /// the [idToken] in the background.
  Future<String> refresh() async {
    await _updateToken();
    return _idToken;
  }

  /// Sends a verification email at the users email.
  ///
  /// You can use this method, if [getDetails()] reveals that the users email
  /// has not been verified yet. This method will cause the firebase servers to
  /// send a verification email with a verification code. That code must be then
  /// sent back to firebase via [confirmEmail()] to complete the process.
  ///
  /// The language of the email is determined by [locale]. If not specified, the
  /// accounts [FirebaseAccount.locale] will be used.
  ///
  /// If the request fails, an [AuthError] will be thrown.
  Future requestEmailConfirmation({
    String? locale,
  }) async =>
      api.sendOobCode(
        OobCodeRequest.verifyEmail(
          idToken: _idToken,
        ),
        locale ?? this.locale,
      );

  /// Verifies the users email by completing the process.
  ///
  /// To confirm the users email, you need an [oobCode]. You can obtain that
  /// code by using [requestEmailConfirmation()]. That method will send the user
  /// an email that contains said [oobCode]. In an application you can extract
  /// that code from the email to complete the process with this method.
  ///
  /// If the request fails, including because an invalid code was passed to the
  /// method, an [AuthError] will be thrown.
  Future<void> confirmEmail(String oobCode) async =>
      api.confirmEmail(ConfirmEmailRequest(oobCode: oobCode));

  /// Fetches the user profile details of the account.
  ///
  /// Requests the account details that firebase itself has about the current
  /// account and returns them as [UserData]. If the request fails, an
  /// [AuthError] is thrown instead.
  ///
  /// **Note:** If the request succeeds, but there is not user-data associated
  /// with the user, null is returned. In theory, this should never happen, but
  /// it is not guaranteed to never happen.
  Future<UserData?> getDetails() async {
    final response = await api.getUserData(UserDataRequest(idToken: _idToken));
    return response.users.isNotEmpty ? response.users.first : null;
  }

  /// Updates the users email address.
  ///
  /// This is the email that is used by the user to login with a password. The
  /// current email is replaced by [newEmail]. If the request fails, an
  /// [AuthError] will be thrown.
  ///
  /// Firebase sents a notification email to the old email address to notify the
  /// user that his email has changed. The user may revoke the change via that
  /// email. The language of the email is determined by [locale]. If not
  /// specified, the accounts [FirebaseAccount.locale] will be used.
  ///
  /// **Note:** If the user has logged in anonymously or via an IDP-Provider,
  /// the mail may not be changeable, leading the a failure of this request. You
  /// can use [getDetails()] or [FirebaseAuth.fetchProviders] to find out which
  /// providers a user has activated for this account. You can instead link the
  /// account with an email address and a new password via [linkEmail()].
  Future<void> updateEmail(
    String newEmail, {
    String? locale,
  }) =>
      api.updateEmail(
        EmailUpdateRequest(
          idToken: _idToken,
          email: newEmail,
          returnSecureToken: false,
        ),
        locale ?? this.locale,
      );

  /// Updates the users login password.
  ///
  /// Replaces the users current password with [newPassword]. If the request
  /// fails, an [AuthError] will be thrown.
  ///
  /// This request can only be used, if the user has logged in via
  /// email/password. When logged in anonymously or via an IDP-Provider, this
  /// request will always fail. You can instead link the account with an email
  /// address and a new password via [linkEmail()].
  Future<void> updatePassword(String newPassword) =>
      api.updatePassword(PasswordUpdateRequest(
        idToken: _idToken,
        password: newPassword,
        returnSecureToken: false,
      ));

  /// Updates certain aspects of the users profile.
  ///
  /// Only the [displayName] and the [photoUrl] can be updated. For each of
  /// these parameters, you have one of three options:
  /// - Pass null to (or leave out the) parameter to keep it as it is
  /// - Pass [ProfileUpdate.update()] to change the property to a new value
  /// - Pass [ProfileUpdate.delete()] to remove the property. This will erase
  /// the data on firebase servers and set them to null.
  ///
  /// If the request fails, an [AuthError] will be thrown. The updated profile
  /// can be fetched via [getDetails()].
  Future<void> updateProfile({
    ProfileUpdate<String>? displayName,
    ProfileUpdate<Uri>? photoUrl,
  }) =>
      api.updateProfile(ProfileUpdateRequest(
        idToken: _idToken,
        displayName: displayName?.updateOr(),
        photoUrl: photoUrl?.updateOr(),
        deleteAttribute: [
          if (displayName?.isDelete ?? false) DeleteAttribute.DISPLAY_NAME,
          if (photoUrl?.isDelete ?? false) DeleteAttribute.PHOTO_URL,
        ],
        returnSecureToken: false,
      ));

  /// Links a new email address to this account.
  ///
  /// Linking allows a user to add a new login method to an existing account.
  /// After doing so, he can choose any of those methods to perform the login.
  ///
  /// With this method, an email address can be added to allow login with the
  /// given [email] and [password] via [FirebaseAuth.signInWithPassword()]. The
  /// method returns, whether the given [email] has already been verified. If
  /// the linking fails, an [AuthError] is thrown instead.
  ///
  /// By default, a verification email is sent automatically to the user, the
  /// language of the email is determined by [locale]. If not specified, the
  /// accounts [FirebaseAccount.locale] will be used.
  ///
  /// If you do not want the verification email to be sent immediatly, you can
  /// simply set [autoVerify] to false and send the email manually by calling
  /// [requestEmailConfirmation()].
  Future<bool> linkEmail(
    String email,
    String password, {
    bool autoVerify = true,
    String? locale,
  }) async {
    final response = await api.linkEmail(LinkEmailRequest(
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

  /// Links a new IDP-Account to this account.
  ///
  /// Linking allows a user to add a new login method to an existing account.
  /// After doing so, he can choose any of those methods to perform the login.
  ///
  /// With this method, an IDP-Provider based account (like google, facebook,
  /// twitter, etc.) can be added to allow login with the given [provider] and
  /// [requestUri] via [FirebaseAuth.signInWithIdp()]. If the linking fails, an
  /// [AuthError] is thrown.
  Future<void> linkIdp(
    IdpProvider provider,
    Uri requestUri,
  ) =>
      api.linkIdp(LinkIdpRequest(
        idToken: _idToken,
        postBody: provider.postBody,
        requestUri: requestUri,
        returnSecureToken: false,
      ));

  /// Unlinks all specified providers from the account.
  ///
  /// This removes all login providers from the account that are specified via
  /// [providers]. The expected IDs are the same as returned by
  /// [IdpProvider.id]. If the unlinking fails, an [AuthError] will be thrown.
  ///
  /// After a provider has been removed, the user cannot login anymore with that
  /// provider. However, you can always re-add providers via [linkEmail()] or
  /// [linkIdp()].
  Future<void> unlinkProviders(List<String> providers) =>
      api.unlinkProvider(UnlinkRequest(
        idToken: _idToken,
        deleteProvider: providers,
      ));

  /// Delete the account
  ///
  /// Deletes this firebase account. This is a permanent action and cannot be
  /// undone. After deleting, the account cannot be used anymore.
  ///
  /// If you were listeting to [idTokenStream], it will be closed. In addition
  /// [autoRefresh] will be set to false. This method automatically calls
  /// [dispose()], so you don't have to call it again, but it is ok to do so.
  ///
  /// **Note:** While this operation deletes the firebase account, it does
  /// *not* delete the original account, if an IDP-Provider like google was
  /// used. The user can always recreate the account by signing in/up again,
  /// but he will receive a new [localId] and will be treated as completely
  /// different user by firebase.
  Future<void> delete() async {
    await api.delete(DeleteRequest(idToken: _idToken));
    dispose();
  }

  /// Disposes the account
  ///
  /// Disables any ongoing [autoRefresh] and sets it to false. Also disposes of
  /// the internally used stream controller for [idTokenStream].
  ///
  /// **Important:** Even if you do not use any of the two properties mentioned
  /// above, you still have to always dispose of an account.
  void dispose() {
    autoRefresh = false;
    if (!_refreshController.isClosed) {
      _refreshController.close();
    }
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

  Future<void> _updateToken() async {
    try {
      final response = await api.token(refresh_token: _refreshToken);
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
    } catch (_) {
      autoRefresh = false;
      rethrow;
    }
  }

  Future _updateTokenTimout() async {
    try {
      await _updateToken();
    } catch (e, s) {
      // redirect exceptions to listeners, if any
      if (_refreshController.hasListener) {
        _refreshController.addError(e, s);
      } else {
        rethrow;
      }
    }
  }
}
