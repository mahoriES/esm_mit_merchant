import 'dart:convert';
import 'package:foore/data/model/login.dart';
import 'package:foore/environments/environment.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthBloc {
  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/business.manage',
      'https://www.googleapis.com/auth/userinfo.profile'
    ],
  );

  final AuthState authState = new AuthState();

  BehaviorSubject<AuthState> _subjectAuthState;

  AuthBloc() {
    this._subjectAuthState = new BehaviorSubject<AuthState>.seeded(authState);
    this._loadAuthState();
  }

  Observable<AuthState> get authStateObservable => _subjectAuthState.stream;

  login(AuthInfo authData) {
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
    intercomInit(authData);
  }

  intercomInit(AuthInfo authData) async {
    await Intercom.initialize(
      Environment.intercomAppId,
      iosApiKey: Environment.intercomIosApiKey,
      androidApiKey: Environment.intercomAndroidApiKey,
    );
    print(authData.userProfile.email);
    await Intercom.registerIdentifiedUser(
        userId: authData.userProfile.userUuid);
    var customAtt = Map<String, dynamic>();
    customAtt['mobile_app'] = true;
    await Intercom.updateUser(
      email: authData.userProfile.email,
      name: authData.userProfile.name,
      company: authData.companyInfo.name,
      companyId: authData.companyInfo.companyUuid,
      customAttributes: customAtt,
    );
  }

  logout() {
    this.authState.authData = null;
    this.authState.isLoading = false;
    this._updateState();
    this.googleSignIn.signOut();
    Intercom.logout();
    clearSharedPreferences();
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final authString = prefs.getString('authInfo') ?? '';
    if (authString != '') {
      var authData = json.decode(authString);
      this.login(AuthInfo.fromJson(authData));
    } else {
      this.logout();
    }
    // this.login(AuthInfo(
    //     token:
    //         "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoyMjgsInVzZXJuYW1lIjoidGVzdF9wYXJhZ0Bmb29yZS5pbiIsImV4cCI6MTU3ODA0OTQwMSwiZW1haWwiOiJ0ZXN0X3BhcmFnQGZvb3JlLmluIiwib3JpZ19pYXQiOjE1NzAyNzM0MDF9.5JHbCABlSrumJIxpOpQ_d9CHz1G5uwlWMMTjPLpAQ24"));
    this.authState.isLoading = false;
    this._updateState();
  }

  _storeAuthState() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (this.authState.authData != null) {
      await sharedPreferences.setString(
          'authInfo', json.encode(this.authState.authData.toJson()));
    } else {
      await sharedPreferences.setString('authInfo', '');
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
