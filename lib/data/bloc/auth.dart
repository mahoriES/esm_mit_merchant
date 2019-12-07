import 'dart:convert';
import 'package:foore/data/bloc/push_notifications.dart';
import 'package:foore/data/branch_service.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/login.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'analytics.dart';

enum AuthType { Google, Foore }

class AuthBloc {
  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/business.manage',
      'https://www.googleapis.com/auth/userinfo.profile'
    ],
  );

  final AuthState authState = new AuthState();
  final PushNotifications _pushNotifications = PushNotifications();

  final FoAnalytics foAnalytics = new FoAnalytics();

  BehaviorSubject<AuthState> _subjectAuthState;

  BranchService _branchService;

  AuthBloc() {
    this._subjectAuthState = new BehaviorSubject<AuthState>.seeded(authState);
    this._branchService = new BranchService(this);
    this._loadAuthState();
  }

  Observable<AuthState> get authStateObservable => _subjectAuthState.stream;

  Future<Map<String, String>> get googleAuthHeaders =>
      googleSignIn.currentUser?.authHeaders;

  login(AuthInfo authData, {AuthType authType}) {
    if (authData != null) {
      if (authData.token == null || authData.token == '') {
        this.authState.authData = null;
      } else {
        this.authState.authData = authData;
      }
    } else {
      this.authState.authData = authData;
    }
    this.authState.isLoading = false;
    this._updateState();
    this._storeAuthState();
    if (authType == AuthType.Google) {
      this._storeAuthTypeGoogle(true);
      this.foAnalytics.addUserProperties(
          name: FoAnalyticsUserProperties.uses_google_to_login, value: true);
    } else {
      this.foAnalytics.addUserProperties(
          name: FoAnalyticsUserProperties.uses_company_email_to_login,
          value: true);
    }
    this._pushNotifications.subscribeForCurrentUser(HttpService(this));
    this.foAnalytics.identifyUser(authData);
    getReferralUrl();
  }

  getReferralUrl() async {
    var url = await this._branchService.getReferralUrl();
    return url;
  }

  Future<bool> googleLoginSilently() async {
    final isAuthTypeGoogle = await _getIsAuthTypeGoogle();
    if (isAuthTypeGoogle) {
      try {
        await this.googleSignIn.signInSilently(suppressErrors: false);
      } catch (exception) {
        this.logout();
      }
      // return false if the login is done by google
      return true;
    } else {
      // return false if the login is not done by google
      return false;
    }
  }

  Future<bool> shouldShowSharePrompt() async {
    return await this._branchService.shouldShowSharePrompt();
  }

  logout() {
    this.authState.authData = null;
    this.authState.isLoading = false;
    this._updateState();
    this.googleSignIn.signOut();
    this.foAnalytics.resetUserIdentity();
    this._pushNotifications.unsubscribeForCurrentUser();
    clearSharedPreferences();
    this._branchService.clear();
  }

  clearSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
  }

  _updateState() {
    this._subjectAuthState.sink.add(this.authState);
  }

  dispose() {
    this._subjectAuthState.close();
  }

  _loadAuthState() async {
    this.authState.isLoading = true;
    this._updateState();
    await this.foAnalytics.init();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final authString = prefs.getString('authenticationInformation') ?? '';
    if (authString != '') {
      var authData = json.decode(authString);
      this.login(AuthInfo.fromJson(authData));
    } else {
      this.logout();
    }
    this.authState.isLoading = false;
    this._updateState();
  }

  _storeAuthTypeGoogle(bool isAuthTypeGoogle) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool('googleSignIn', isAuthTypeGoogle);
  }

  _getIsAuthTypeGoogle() async {
    var isAuthTypeGoogle = false;
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      isAuthTypeGoogle = sharedPreferences.getBool('googleSignIn') ?? false;
      if (isAuthTypeGoogle) {
        print('Auth type google');
      } else {
        print('Auth type not google');
      }
    } catch (exception) {}
    return isAuthTypeGoogle;
  }

  _storeAuthState() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (this.authState.authData != null) {
      await sharedPreferences.setString('authenticationInformation',
          json.encode(this.authState.authData.toJson()));
    } else {
      await sharedPreferences.setString('authenticationInformation', '');
    }
  }
}

class AuthData {}

class AuthState {
  bool isLoading = true;
  AuthInfo authData;
  bool get isLoggedIn => authData != null ? authData.token != null : false;
  bool get isLoggedOut => isLoading == false && isLoggedIn == false;
  UserProfile get _userProfile => authData?.userProfile;
  String get userName => _userProfile?.name;
  String get userEmail => _userProfile?.email;
  String get userReferralCode => _userProfile?.sUid;
  String get userUUid => _userProfile?.userUuid;
  String get firstLetterOfUserName {
    if (userName != null && userName != '') {
      if (userName.length > 1) {
        return userName.substring(0, 1).toUpperCase();
      } else {
        return '';
      }
    }
    return '';
  }

  AuthState() {
    this.isLoading = false;
  }
}
