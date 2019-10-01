import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foore/data/http_service.dart';
import 'package:rxdart/rxdart.dart';

import 'auth.dart';

class LoginBloc {
  final LoginState _loginState = new LoginState();

  final emailEditController = TextEditingController();
  final otpEditController = TextEditingController();

  final AuthBloc _authBloc;

  BehaviorSubject<LoginState> _subjectLoginState;

  HttpService _httpService;

  LoginBloc(this._httpService, this._authBloc) {
    this._subjectLoginState = new BehaviorSubject<LoginState>.seeded(
        _loginState); //initializes the subject with element already
  }

  Observable<LoginState> get loginStateObservable => _subjectLoginState.stream;

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
      print(onError.toString());
      this._loginState.isLoading = false;
      this._updateState();
    });
  }

  useCode() {
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
        this._authBloc.login(AuthData.fromJson(json.decode(httpResponse.body)));
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
  LoginState() {
    this.isLoading = false;
    this.isShowOtp = false;
    this.isSubmitOtp = false;
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
