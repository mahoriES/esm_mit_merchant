import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthBloc {
  final AuthState authState = new AuthState();

  BehaviorSubject<AuthState> _subjectAuthState;

  AuthBloc() {
    this._subjectAuthState = new BehaviorSubject<AuthState>.seeded(
        authState); //initializes the subject with element already
    this._loadAuthState();
  }

  Observable<AuthState> get authStateObservable => _subjectAuthState.stream;

  login(AuthData authData) {
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
  }

  logout() {
    this.authState.authData = null;
    this.authState.isLoading = false;
    this._updateState();
    this._storeAuthState();
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
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // final authString = prefs.getString('auth') ?? '';
    // if (authString != '') {
    //   var authData = json.decode(authString);
    //   this.login(AuthData.fromJson(authData));
    // } else {
    //   this.logout();
    // }
    this.login(AuthData(
        token:
            "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoyMjgsInVzZXJuYW1lIjoidGVzdF9wYXJhZ0Bmb29yZS5pbiIsImV4cCI6MTU3ODA0OTQwMSwiZW1haWwiOiJ0ZXN0X3BhcmFnQGZvb3JlLmluIiwib3JpZ19pYXQiOjE1NzAyNzM0MDF9.5JHbCABlSrumJIxpOpQ_d9CHz1G5uwlWMMTjPLpAQ24"));
    this.authState.isLoading = false;
    this._updateState();
  }

  _storeAuthState() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (this.authState.authData != null) {
      await sharedPreferences.setString(
          'auth', json.encode(this.authState.authData.toJson()));
    } else {
      await sharedPreferences.setString('auth', '');
    }
  }
}

class AuthState {
  bool isLoading = true;
  AuthData authData;
  bool get isLoggedIn => authData != null ? authData.token != null : false;
  bool get isLoggedOut => isLoading == false && isLoggedIn == false;

  AuthState() {
    this.isLoading = false;
  }
}

class AuthData {
  final String token;

  AuthData({this.token});

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    var map = new Map<String, dynamic>();
    map['token'] = this.token;
    return map;
  }

  @override
  String toString() {
    return 'token ' + token;
  }
}
