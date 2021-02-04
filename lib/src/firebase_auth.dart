import 'package:http/http.dart';

import 'firebase_account.dart';
import 'models/fetch_provider_request.dart';
import 'models/idp_provider.dart';
import 'models/oob_code_request.dart';
import 'models/password_reset_request.dart';
import 'models/signin_request.dart';
import 'rest_api.dart';

/// A Firebase Authentication class, that allows you to log into firebase.
///
/// Provides methods to create new firebase accounts, log a user into
/// firebase and more. Most methods here create an instance of a
/// [FirebaseAccount], which can be used to manage an individual account. All
/// methods provided here are global methods for firebase auth.
class FirebaseAuth {
  /// The internally used [RestApi] instance.
  final RestApi api;

  /// The default locale to be used for E-Mails sent by Firebase.
  String? locale;

  /// Creates a new firebase auth instance.
  ///
  /// The instance uses [client] and [apiKey] for accessing the Firebase REST
  /// endpoints. If [locale] is specified, it is used to initialize
  /// the [FirebaseAuth.locale] property.
  FirebaseAuth(
    Client client,
    String apiKey, [
    this.locale,
  ]) : api = RestApi(client, apiKey);

  /// Creates a new firebase auth instance.
  ///
  /// The instance uses the [api] for accessing the Firebase REST endpoints. If
  /// [locale] is specified, it is used to initialize the [FirebaseAuth.locale]
  /// property.
  FirebaseAuth.api(
    this.api, [
    this.locale,
  ]);

  /// Returns a list of all providers that can be used to login.
  ///
  /// The given [email] and [continueUri] are sent to firebase to figure out
  /// which providers can be used. Returns the provider names as in
  /// [IdpProvider.id] or the string `"email"`, if the user can login with the
  /// email and a password.
  ///
  /// If the request fails, an [AuthError] will be thrown.
  Future<List<String>> fetchProviders(
    String email, [
    Uri? continueUri,
  ]) async {
    final response = await api.fetchProviders(FetchProviderRequest(
      identifier: email,
      continueUri: continueUri ?? Uri.http('localhost', ''),
    ));
    return [
      if (response.registered) 'email',
      ...response.allProviders,
    ];
  }

  /// Signs up to firebase as an anonymous user.
  ///
  /// This will return a newly created [FirebaseAccount] with no login method
  /// attached. This means, you can only keep using this account by regularly
  /// refreshing the idToken. This happens automatically if [autoRefresh] is
  /// true or via [FirebaseAccount.refresh()].
  ///
  /// If the request fails, an [AuthError] will be thrown. This also happens if
  /// anonymous logins have not been enabled in the firebase console.
  ///
  /// If you ever want to "promote" an anonymous account to a normal account,
  /// you can do so by using [FirebaseAccount.linkEmail()] or
  /// [FirebaseAccount.linkIdp()] to add credentials to the account. This will
  /// preserve any data associated with this account.
  ///
  /// Optionally, a [loggingCategory] can be passed as last parameter to the
  /// constructor to customize logging. By default, the API logs to
  /// [FirebaseAccount.loggingTag], but any category can be used here. If you
  /// pass `null`, logging will be completely disabled. See [Logger] for more
  /// details about how logging in dart works.
  Future<FirebaseAccount> signUpAnonymous({
    bool autoRefresh = true,
    String? loggingCategory = FirebaseAccount.loggingTag,
  }) async =>
      FirebaseAccount.apiCreate(
        api,
        await api.signUpAnonymous(const AnonymousSignInRequest()),
        autoRefresh: autoRefresh,
        locale: locale,
        loggingCategory: loggingCategory,
      );

  /// Signs up to firebase with an email and a password.
  ///
  /// This creates a new firebase account and returns it's credentials as
  /// [FirebaseAccount] if the request succeeds, or throws an [AuthError] if it
  /// fails. From now on, the user can log into this account by using the same
  /// [email] and [password] used for this request via [signInWithPassword()].
  ///
  /// If [autoVerify] is true (the default), this method will also send an email
  /// confirmation request for that email so the users mail can be verified. See
  /// [FirebaseAccount.requestEmailConfirmation()] for more details. The
  /// language of that mail is determined by [locale], if specified,
  /// [FirebaseAuth.locale] otherwise.
  ///
  /// If [autoRefresh] is enabled (the default), the created accounts
  /// [FirebaseAccount.autoRefresh] is set to true as well, wich will start an
  /// automatic token refresh in the background, as soon as the current token
  /// comes close to expiring. See [FirebaseAccount.autoRefresh] for more
  /// details.
  ///
  /// Optionally, a [loggingCategory] can be passed as last parameter to the
  /// constructor to customize logging. By default, the API logs to
  /// [FirebaseAccount.loggingTag], but any category can be used here. If you
  /// pass `null`, logging will be completely disabled. See [Logger] for more
  /// details about how logging in dart works.
  Future<FirebaseAccount> signUpWithPassword(
    String email,
    String password, {
    bool autoVerify = true,
    bool autoRefresh = true,
    String? locale,
    String? loggingCategory = FirebaseAccount.loggingTag,
  }) async {
    final response = await api.signUpWithPassword(PasswordSignInRequest(
      email: email,
      password: password,
    ));
    if (autoVerify) {
      await api.sendOobCode(
        OobCodeRequest.verifyEmail(
          idToken: response.idToken,
        ),
        locale ?? this.locale,
      );
    }
    return FirebaseAccount.apiCreate(
      api,
      response,
      locale: this.locale,
      autoRefresh: autoRefresh,
      loggingCategory: loggingCategory,
    );
  }

  /// Signs into firebase with an IDP-Provider.
  ///
  /// This logs the user into firebase by using an [IdpProvider] - aka google,
  /// facebook, twitter, etc. As long as the provider has been enabled in the
  /// firebase console, it can be used. If the passed [provider] and
  /// [requestUri] are valid, the associated firebase account is returned or a
  /// new one gets created. On a failure, an [AuthError] is thrown instead.
  ///
  /// If [autoRefresh] is enabled (the default), the created accounts
  /// [FirebaseAccount.autoRefresh] is set to true as well, wich will start an
  /// automatic token refresh in the background, as soon as the current token
  /// comes close to expiring. See [FirebaseAccount.autoRefresh] for more
  /// details.
  ///
  /// Optionally, a [loggingCategory] can be passed as last parameter to the
  /// constructor to customize logging. By default, the API logs to
  /// [FirebaseAccount.loggingTag], but any category can be used here. If you
  /// pass `null`, logging will be completely disabled. See [Logger] for more
  /// details about how logging in dart works.
  Future<FirebaseAccount> signInWithIdp(
    IdpProvider provider,
    Uri requestUri, {
    bool autoRefresh = true,
    String? loggingCategory = FirebaseAccount.loggingTag,
  }) async =>
      FirebaseAccount.apiCreate(
        api,
        await api.signInWithIdp(IdpSignInRequest(
          postBody: provider.postBody,
          requestUri: requestUri,
        )),
        autoRefresh: autoRefresh,
        locale: locale,
        loggingCategory: loggingCategory,
      );

  /// Signs into firebase with an email and a password.
  ///
  /// This logs into an exsiting account and returns it's credentials as
  /// [FirebaseAccount] if the request succeeds, or throws an [AuthError] if it
  /// fails.
  ///
  /// If [autoRefresh] is enabled (the default), the created accounts
  /// [FirebaseAccount.autoRefresh] is set to true as well, wich will start an
  /// automatic token refresh in the background, as soon as the current token
  /// comes close to expiring. See [FirebaseAccount.autoRefresh] for more
  /// details.
  ///
  /// Optionally, a [loggingCategory] can be passed as last parameter to the
  /// constructor to customize logging. By default, the API logs to
  /// [FirebaseAccount.loggingTag], but any category can be used here. If you
  /// pass `null`, logging will be completely disabled. See [Logger] for more
  /// details about how logging in dart works.
  ///
  /// **Note:** To create a new account, use [signUpWithPassword()].
  Future<FirebaseAccount> signInWithPassword(
    String email,
    String password, {
    bool autoRefresh = true,
    String? loggingCategory = FirebaseAccount.loggingTag,
  }) async =>
      FirebaseAccount.apiCreate(
        api,
        await api.signInWithPassword(PasswordSignInRequest(
          email: email,
          password: password,
        )),
        autoRefresh: autoRefresh,
        locale: locale,
        loggingCategory: loggingCategory,
      );

  /// Signs into firebase with a custom token.
  ///
  /// This logs into an exsiting account and returns it's credentials as
  /// [FirebaseAccount] if the request succeeds, or throws an [AuthError] if it
  /// fails.
  ///
  /// If [autoRefresh] is enabled (the default), the created accounts
  /// [FirebaseAccount.autoRefresh] is set to true as well, wich will start an
  /// automatic token refresh in the background, as soon as the current token
  /// comes close to expiring. See [FirebaseAccount.autoRefresh] for more
  /// details.
  ///
  /// Optionally, a [loggingCategory] can be passed as last parameter to the
  /// constructor to customize logging. By default, the API logs to
  /// [FirebaseAccount.loggingTag], but any category can be used here. If you
  /// pass `null`, logging will be completely disabled. See [Logger] for more
  /// details about how logging in dart works.
  Future<FirebaseAccount> signInWithCustomToken(
    String token, {
    bool autoRefresh = true,
    String? loggingCategory = FirebaseAccount.loggingTag,
  }) async =>
      FirebaseAccount.apiCreate(
        api,
        await api.signInWithCustomToken(CustomTokenSignInRequest(
          token: token,
        )),
        autoRefresh: autoRefresh,
        locale: locale,
        loggingCategory: loggingCategory,
      );

  /// Sends a password reset email to a user.
  ///
  /// This tells firebase to generate a password reset mail and send it to
  /// [email]. The language of that mail is determined by [locale], if
  /// specified, [FirebaseAuth.locale] otherwise. If the request fails, an
  /// [AuthError] is thrown.
  Future requestPasswordReset(
    String email, {
    String? locale,
  }) async =>
      api.sendOobCode(
        OobCodeRequest.passwordReset(email: email),
        locale ?? this.locale,
      );

  /// Checks, if a password reset code is valid.
  ///
  /// When using [requestPasswordReset()] to send a mail to the user, that mail
  /// contains an [oobCode]. You can use this method to verify if the code is a
  /// valid code, before allowing the user to enter a new password.
  ///
  /// If the check succeeds, the future simply resolves without a value. If it
  /// fails instead, an [AuthError] is thrown.
  Future validatePasswordReset(String oobCode) async =>
      api.resetPassword(PasswordResetRequest.verify(oobCode: oobCode));

  /// Completes a password reset by setting a new password.
  ///
  /// When using [requestPasswordReset()] to send a mail to the user, that mail
  /// contains an [oobCode]. You can use this method to complete the process and
  /// reset the users password to [newPassword].
  ///
  /// If this method succeeds, the user must from now on use [newPassword] when
  /// signing in via [signInWithPassword()]. If it fails, an [AuthError] is
  /// thrown.
  Future resetPassword(String oobCode, String newPassword) async =>
      api.resetPassword(PasswordResetRequest.confirm(
        oobCode: oobCode,
        newPassword: newPassword,
      ));
}
