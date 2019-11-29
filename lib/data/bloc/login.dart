import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/login.dart';
import 'package:rxdart/rxdart.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../router.dart';
import 'auth.dart';

class LoginBloc {
  final LoginState _loginState = new LoginState();

  final emailEditController = TextEditingController();
  final otpEditController = TextEditingController();

  final AuthBloc _authBloc;

  BehaviorSubject<LoginState> _subjectLoginState;

  HttpService _httpService;

  LoginBloc(this._httpService, this._authBloc) {
    this._subjectLoginState =
        new BehaviorSubject<LoginState>.seeded(_loginState);
  }

  Observable<LoginState> get loginStateObservable => _subjectLoginState.stream;

  Future<void> signInWithGoogle(BuildContext context) async {
    if (this._loginState.isLoading == false) {
      this._loginState.isLoading = true;
      this._loginState.isSubmitFailed = false;
      this._updateState();
      try {
        GoogleSignInAccount account = await _authBloc.googleSignIn.signIn();
        GoogleSignInAuthentication authentication =
            await account.authentication;
        print('GOOGLE_ACCESS_TOKEN: ' + authentication.accessToken);
        GoogleAuthStateIdResponse authStateResponse =
            await getGoogleAuthStateId(authentication.serverAuthCode);
        AuthInfo loginInfo = await getAuthInfoWithGoogleAuthStateId(
            authStateResponse.authStateId);
        this._authBloc.login(loginInfo, authType: AuthType.Google);
        Navigator.of(context).pushNamedAndRemoveUntil(Router.homeRoute,(Route<dynamic> route) => false);
        this._loginState.isLoading = false;
        this._loginState.isSubmitFailed = false;
        this._updateState();
      } catch (error, s) {
        this._loginState.isSubmitFailed = true;
        this._loginState.isLoading = false;
        this._updateState();
        Crashlytics.instance.recordError(error, s);
      }
    }
  }

  Future<GoogleAuthStateIdResponse> getGoogleAuthStateId(
      String serverAuthCode) async {
    this._updateState();
    var authStateIdHttpResponse = await _httpService.foPostWithoutAuth(
        'google/account/login/init/', '{"gcode": "$serverAuthCode"}');
    if (authStateIdHttpResponse.statusCode == 200 ||
        authStateIdHttpResponse.statusCode == 202) {
      var authStateIdResponse = GoogleAuthStateIdResponse.fromJson(
          json.decode(authStateIdHttpResponse.body));
      return authStateIdResponse;
    } else {
      var responseBody = authStateIdHttpResponse.body ?? '';
      Crashlytics.instance.log(
          'url: google/account/login/init/, responseCode: ${authStateIdHttpResponse.statusCode}, response$responseBody');
      throw "Err";
    }
  }

  Future<AuthInfo> getAuthInfoWithGoogleAuthStateId(String authStateId) async {
    var httpResponse = await _httpService.foGetWithoutAuth(
        'google/account/login/info/?auth_state_id=$authStateId');
    if (httpResponse.statusCode == 200 || httpResponse.statusCode == 202) {
      print(httpResponse.body);
      var loginInfo = AuthInfo.fromJson(json.decode(httpResponse.body));
      if (loginInfo.code == AuthInfoCode.pending) {
        await Future.delayed(const Duration(seconds: 5));
        var result = await getAuthInfoWithGoogleAuthStateId(authStateId);
        return result;
      } else {
        return loginInfo;
      }
    } else {
      var responseBody = httpResponse.body ?? '';
      Crashlytics.instance.log(
          'url: google/account/login/info/?auth_state_id=$authStateId, responseCode: ${httpResponse.statusCode}, response$responseBody');
      this._authBloc.googleSignIn.signOut();
      throw "Err";
    }
  }

  sendCode() {
    this._loginState.isLoading = true;
    this._updateState();
    _httpService
        .foPostWithoutAuth('profile/login/send/code/',
            json.encode(SendCodePayload(email: this.emailEditController.text)))
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 202) {
        this._loginState.isLoading = false;
        this._loginState.isShowOtp = true;
      } else {
        this._loginState.isLoading = false;
      }
      this._updateState();
    }).catchError((onError) {
      this._loginState.isLoading = false;
      this._updateState();
    });
  }

  useCode(BuildContext context) {
    this._loginState.isSubmitOtp = true;
    this._updateState();
    _httpService
        .foPostWithoutAuth(
            'profile/login/use/code/',
            json.encode(UseCodePayload(
                    email: this.emailEditController.text,
                    token: this.otpEditController.text)
                .toJson()))
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 202) {
        print(httpResponse.body);
        this._authBloc.login(AuthInfo.fromJson(json.decode(httpResponse.body)));
        Navigator.of(context).pushNamedAndRemoveUntil(Router.homeRoute,(Route<dynamic> route) => false);
      } else {
        this._loginState.isSubmitOtp = false;
      }
      this._updateState();
    }).catchError((onError) {
      this._loginState.isSubmitOtp = false;
      this._updateState();
    });
  }

  _updateState() {
    this._subjectLoginState.sink.add(this._loginState);
  }

  dispose() {
    this._subjectLoginState.close();
    this.emailEditController.dispose();
    this.otpEditController.dispose();
  }
}

class LoginState {
  bool isLoading;
  bool isSubmitOtp;
  bool isShowOtp;
  bool isSubmitFailed;
  LoginState() {
    this.isLoading = false;
    this.isShowOtp = false;
    this.isSubmitOtp = false;
    this.isSubmitFailed = false;
  }
}

class SendCodePayload {
  String email;

  SendCodePayload({this.email});

  SendCodePayload.fromJson(Map<String, dynamic> json) {
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    return data;
  }
}

class UseCodePayload {
  String email;
  String token;

  UseCodePayload({this.email, this.token});

  UseCodePayload.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['token'] = this.token;
    return data;
  }
}

class GoogleAuthStateIdResponse {
  String authStateId;

  GoogleAuthStateIdResponse({this.authStateId});

  GoogleAuthStateIdResponse.fromJson(Map<String, dynamic> json) {
    authStateId = json['auth_state_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['auth_state_id'] = this.authStateId;
    return data;
  }
}
