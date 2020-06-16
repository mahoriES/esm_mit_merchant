import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foore/data/constants/es_api_path.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_auth.dart';
import 'package:foore/data/model/es_profiles.dart';
import 'package:foore/environments/environment.dart';
import 'package:rxdart/rxdart.dart';

import '../../router.dart';
import 'auth.dart';

class EsLoginBloc {
  final EsLoginState _loginState = new EsLoginState();

  final phoneEditController = TextEditingController();
  final otpEditController = TextEditingController();

  final AuthBloc _authBloc;

  BehaviorSubject<EsLoginState> _subjectLoginState;

  HttpService _httpService;

  EsLoginBloc(this._httpService, this._authBloc) {
    this._subjectLoginState =
        new BehaviorSubject<EsLoginState>.seeded(_loginState);
  }

  Observable<EsLoginState> get esLoginStateObservable =>
      _subjectLoginState.stream;

  sendCode() {
    this._loginState.isLoading = true;
    this._updateState();
    final phoneNumberInput = this.phoneEditController.text;

    final TPID = Environment.esTPID;

    _httpService
        .esGetWithoutAuth(
            EsApiPaths.getOTP + '?phone=$phoneNumberInput&third_party_id=$TPID')
        .then((httpResponse) {
      print(httpResponse.body);
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

  signUp(BuildContext context) {
    this._loginState.isLoading = true;
    this._updateState();
    final phoneNumberInput = this.phoneEditController.text;

    final TPID = Environment.esTPID;

    _httpService
        .esPostWithoutAuth(
      EsApiPaths.postSignUp,
      json.encode(EsSignUpPayload(phone: phoneNumberInput, thirdPartyId: TPID)
          .toJson()),
    )
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

  useCode(BuildContext context) async {
    try {
      this._loginState.isSubmitOtp = true;
      this._updateState();
      final TPID = Environment.esTPID;
      var authResponse = await _httpService.esPostWithoutAuth(
          EsApiPaths.postToken,
          json.encode(EsGetTokenPayload(
                  phone: this.phoneEditController.text,
                  token: this.otpEditController.text,
                  thirdPartyId: TPID)
              .toJson()));

      if (authResponse.statusCode == 200 || authResponse.statusCode == 202) {
        var authData = EsAuthData.fromJson(json.decode(authResponse.body));
        var profilesResponse = await _httpService.esGetWithToken(
            EsApiPaths.getProfiles, authData.token);
        if (profilesResponse.statusCode == 200 ||
            profilesResponse.statusCode == 202) {
          var profilesResponseData = EsGetProfilesResponse.fromJson(
              json.decode(profilesResponse.body));
          this._authBloc.esLogin(authData, profilesResponseData.merchant);
          Navigator.of(context).pushNamedAndRemoveUntil(
              Router.homeRoute, (Route<dynamic> route) => false);
          this._loginState.isSubmitOtp = false;
          this._updateState();
          return;
        }
      }
      this._loginState.isSubmitOtp = false;
      this._updateState();
    } catch (error) {
      this._loginState.isSubmitOtp = false;
      this._updateState();
    }
  }

  _updateState() {
    this._subjectLoginState.sink.add(this._loginState);
  }

  dispose() {
    this._subjectLoginState.close();
    this.phoneEditController.dispose();
    this.otpEditController.dispose();
  }
}

class EsLoginState {
  bool isLoading;
  bool isSubmitOtp;
  bool isShowOtp;
  bool isSubmitFailed;
  EsLoginState() {
    this.isLoading = false;
    this.isShowOtp = false;
    this.isSubmitOtp = false;
    this.isSubmitFailed = false;
  }
}
