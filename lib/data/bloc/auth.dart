import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/push_notifications.dart';
import 'package:foore/data/branch_service.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/login.dart';
import 'package:foore/environments/environment.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

class FoAnalytics {
  FirebaseAnalytics _firebaseAnalytics;

  bool isInitialized = false;
  bool isUserIdentified = false;

  init() async {
    await intercomInit();
    firebaseAnalyticsInit();
    this.isInitialized = true;
  }

  identifyUser(AuthInfo authData) {
    intercomLogin(authData);
    firebaseAnalyticsLogin(authData);
    isUserIdentified = true;
  }

  resetUserIdentity() {
    this.intercomLogout();
    this.firebaseAnalyticsLogout();
    isUserIdentified = false;
  }

  intercomInit() async {
    await Intercom.initialize(
      Environment.intercomAppId,
      iosApiKey: Environment.intercomIosApiKey,
      androidApiKey: Environment.intercomAndroidApiKey,
    );
  }

  firebaseAnalyticsInit() {
    this._firebaseAnalytics = FirebaseAnalytics();
    _firebaseAnalytics.setAnalyticsCollectionEnabled(Environment.isProd);
  }

  intercomLogin(AuthInfo authData) async {
    await Intercom.initialize(
      Environment.intercomAppId,
      iosApiKey: Environment.intercomIosApiKey,
      androidApiKey: Environment.intercomAndroidApiKey,
    );
    await Intercom.registerIdentifiedUser(
        userId: authData.userProfile.userUuid);
    await Intercom.updateUser(
      email: authData.userProfile.email,
      name: authData.userProfile.name,
      company: authData.companyInfo.name,
      companyId: authData.companyInfo.companyUuid,
    );
  }

  firebaseAnalyticsLogin(AuthInfo authData) {
    this._firebaseAnalytics.setUserId(authData.userProfile.userUuid);
    this
        ._firebaseAnalytics
        .setUserProperty(name: 'email', value: authData.userProfile.email);
    this
        ._firebaseAnalytics
        .setUserProperty(name: 'name', value: authData.userProfile.name);
    this
        ._firebaseAnalytics
        .setUserProperty(name: 'company', value: authData.companyInfo.name);
    this._firebaseAnalytics.setUserProperty(
        name: 'companyId', value: authData.companyInfo.companyUuid);
  }

  intercomLogout() async {
    await Intercom.logout();
  }

  firebaseAnalyticsLogout() {
    this._firebaseAnalytics.resetAnalyticsData();
  }

  trackUserEvent({@required String name, Map<String, dynamic> parameters}) {
    if (isUserIdentified) {
      Intercom.logEvent(name, parameters);
      this._firebaseAnalytics.logEvent(name: name, parameters: parameters);
    }
  }

  setCurrentScreen(String screenName) {
    this._firebaseAnalytics.setCurrentScreen(screenName: screenName);
  }

  addUserProperties({@required String name, @required String value}) {
    if (isUserIdentified) {
      Map customAttributes = new Map();
      customAttributes[name] = value;
      Intercom.updateUser(customAttributes: customAttributes);

      this._firebaseAnalytics.setUserProperty(name: name, value: value);
    }
  }
}
