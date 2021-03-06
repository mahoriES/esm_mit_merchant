import 'dart:convert';
import 'package:foore/data/bloc/push_notifications.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_auth.dart';
import 'package:foore/data/model/es_profiles.dart';
import 'package:foore/data/model/login.dart';
import 'package:foore/esdy_print.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'analytics.dart';

enum AuthType { Google, Foore }

class AuthBloc {
  static const String CLASSNAME = 'AuthBloc';
  static const String FILENAME = 'auth.dart';
  final EsdyPrint esdyPrint =
      EsdyPrint(classname: CLASSNAME, filename: FILENAME);

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

  AuthBloc() {
    this._subjectAuthState = new BehaviorSubject<AuthState>.seeded(authState);
    _pushNotifications.initialise();
    this._loadAuthState();
    this._loadEsAuthState();
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

    this.authState.isEsLoading = false;
  }

  Future<bool> googleLoginSilently() async {
    final isAuthTypeGoogle = await _getIsAuthTypeGoogle();
    if (isAuthTypeGoogle) {
      try {
        print("googleLoginSilently");
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

  logout({bool esLogout = false}) {
    if (esLogout) {
      this.esLogout();
      //clearSharedPreferences();
    }
    this.authState.authData = null;
    this.authState.isLoading = false;
    this._updateState();
    this.googleSignIn.signOut();
    this.foAnalytics.resetUserIdentity();

    //if (esLogout) {
    //  this.esLogout();
    //  clearSharedPreferences();
    //}
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

  //
  static const eSamudaayAuthenticationInformationSharedPrefKey =
      'eSamudaayAuthenticationInformation';
  static const eSamudaayMerchantProfileInformationSharedPrefKey =
      'eSamudaayMerchantProfileInformation';

  esLogin(EsAuthData esAuthData, EsProfile esMerchantProfile) {
    esdyPrint.debug("esLogin >>");
    this.authState.esAuthData = esAuthData;
    esdyPrint.debug("Token ${this.authState.esMerchantJwtToken}");

    this.authState.esMerchantProfile = esMerchantProfile;

    this.authState.isEsLoading = false;
    esdyPrint.debug("Token2 ${this.authState.esMerchantJwtToken}");
    this._updateState();
    esdyPrint.debug("Token3 ${this.authState.esMerchantJwtToken}");
    this._storeEsAuthState();
    esdyPrint.debug("Token4 ${this.authState.esMerchantJwtToken}");
    if (this.authState.esMerchantJwtToken != null) {
      //For new users who do not have profile yet,
      //this was causing trouble
      this._pushNotifications.subscribeForCurrentUser(HttpService(this));
    }
  }

  esLogoutSilently() {
    esdyPrint.debug("esLogoutSilently >>");
    this.authState.esAuthData = null;
    this.authState.esMerchantProfile = null;
    this.authState.isEsLoading = false;
    clearSharedPreferences();
    this._updateState();
    //this._storeEsAuthState();
  }

  esLogout() {
    esdyPrint.debug("esLogout >>");
    this.authState.esAuthData = null;
    this.authState.isEsLoading = false;
    this.authState.esMerchantProfile = null;
    this._pushNotifications.unsubscribeForCurrentUser(esUnsubscribe: true);
    clearSharedPreferences();
    this._updateState();
    //this._storeEsAuthState();
  }

  setEsMerchantProfile(EsProfile profile) {
    this.authState.esMerchantProfile = profile;
    this._updateState();
    this._storeEsAuthState();
  }

  _storeEsAuthState() async {
    esdyPrint.debug("_storeEsAuthState >>");
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (this.authState.esAuthData != null) {
      await sharedPreferences.setString(
          eSamudaayAuthenticationInformationSharedPrefKey,
          json.encode(this.authState.esAuthData.toJson()));
    } else {
      await sharedPreferences.setString(
          eSamudaayAuthenticationInformationSharedPrefKey, '');
    }
    if (this.authState.esMerchantProfile != null) {
      await sharedPreferences.setString(
          eSamudaayMerchantProfileInformationSharedPrefKey,
          json.encode(this.authState.esMerchantProfile.toJson()));
    } else {
      await sharedPreferences.setString(
          eSamudaayMerchantProfileInformationSharedPrefKey, '');
    }
  }

  _loadEsAuthState() async {
    esdyPrint.debug("_loadEsAuthState >>");
    this.authState.isEsLoading = true;
    this._updateState();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final esAuthString =
        prefs.getString(eSamudaayAuthenticationInformationSharedPrefKey) ?? '';

    final esMerchantProfileString =
        prefs.getString(eSamudaayMerchantProfileInformationSharedPrefKey) ?? '';

    if (esAuthString != '') {
      var esAuthData = json.decode(esAuthString);
      var esMerchantProfile = esMerchantProfileString != ''
          ? json.decode(esMerchantProfileString)
          : null;
      this.esLogin(
          EsAuthData.fromJson(esAuthData),
          esMerchantProfile != null
              ? EsProfile.fromJson(esMerchantProfile)
              : null);
    } else {
      this.esLogout();
    }
    this.authState.isEsLoading = false;
    this._updateState();
  }
}

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

  bool isEsLoading = true;
  EsAuthData esAuthData;
  EsProfile esMerchantProfile;
  bool get isEsMerchantLoggedIn =>
      esMerchantProfile != null ? esMerchantProfile.token != null : false;
  bool get isEsLoggedOut => isEsLoading == false && esJwtToken == null;
  bool get isMerchantProfileNotExist =>
      isEsLoading == false && esMerchantProfile == null;
  String get esJwtToken => esAuthData != null ? esAuthData.token : null;
  String get esMerchantJwtToken =>
      esMerchantProfile != null ? esMerchantProfile.token : null;
  String getMerchantPhone() {
    if (esAuthData != null && esAuthData.user != null) {
      return esAuthData.user.phone;
    }
    return "";
  }

  String getMerchantName() {
    if (esMerchantProfile != null && esMerchantProfile.data != null) {
      return esMerchantProfile.data.profileName;
    }
    return "";
  }

  AuthState() {
    this.isLoading = false;
  }
}
