import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foore/data/constants/es_api_path.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_auth.dart';
import 'package:foore/data/model/es_profiles.dart';
import 'package:foore/environments/environment.dart';
import 'package:foore/es_home_page/es_home_page.dart';
import 'package:foore/esdy_print.dart';
import 'package:rxdart/rxdart.dart';

import '../../router.dart';
import 'auth.dart';

class EsLoginBloc {
  static const String CLASSNAME = 'EsLoginBloc';
  static const String FILENAME = 'es_login.dart';
  final EsdyPrint esdyPrint =
      EsdyPrint(classname: CLASSNAME, filename: FILENAME);
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
    esdyPrint.debug("sendCode >>");
    this._loginState.isLoading = true;
    this._updateState();
    final phoneNumberInput = '+91' + this.phoneEditController.text;

    _httpService
        .esGetWithoutAuth(EsApiPaths.getOTP +
            '?phone=$phoneNumberInput&third_party_id=${Environment.esTPID}')
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 202) {
        debugPrint("es_login.dart: " + "sendCode :" + httpResponse.body);
        if (!Environment.isProd) {
          //Staging show toast for OTP
          Fluttertoast.showToast(
              msg: "OTP: " + json.decode(httpResponse.body)['token'].toString(),
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM);
        }
        this._loginState.isLoading = false;
        this._loginState.isShowOtp = true;
      } else if (httpResponse.statusCode == 400) {
        debugPrint("es_login.dart: " + "sendCode :" + httpResponse.body);
        Fluttertoast.showToast(
            msg: json.decode(httpResponse.body)['message'].toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM);
        this._loginState.isLoading = false;
      } else {
        debugPrint("es_login.dart: " + "sendCode :" + httpResponse.body);
        this._loginState.isLoading = false;
      }
      this._updateState();
    }).catchError((onError, s) {
      debugPrint("es_login.dart: " + "sendCode :" + s.toString());
      this._loginState.isLoading = false;
      this._updateState();
    });
  }

  signUp(BuildContext context) {
    esdyPrint.debug("signUp >>");
    this._loginState.isLoading = true;
    this._updateState();
    final phoneNumberInput = '+91' + this.phoneEditController.text;

    _httpService
        .esPostWithoutAuth(
            EsApiPaths.postSignUp,
            json.encode(EsSignUpPayload(
                    phone: phoneNumberInput, thirdPartyId: Environment.esTPID)
                .toJson()))
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 ||
          httpResponse.statusCode == 202 ||
          httpResponse.statusCode == 201) {
        debugPrint("es_login.dart: " + "signUp :" + httpResponse.body);
        if (!Environment.isProd) {
          //Staging show toast for OTP
          Fluttertoast.showToast(
              msg: "OTP: " + json.decode(httpResponse.body)['token'].toString(),
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM);
        }
        this._loginState.isLoading = false;
        this._loginState.isShowOtp = true;
      } else if (httpResponse.statusCode == 400) {
        debugPrint("es_login.dart: " + "signUp :" + httpResponse.body);
        Fluttertoast.showToast(
            msg: json.decode(httpResponse.body)['message'].toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM);
        this._loginState.isLoading = false;
      } else {
        debugPrint("es_login.dart: " + "signUp :" + httpResponse.body);
        this._loginState.isLoading = false;
      }

      this._updateState();
    }).catchError((onError, s) {
      debugPrint("es_login.dart: " + "signUp :" + s.toString());
      this._loginState.isLoading = false;
      this._updateState();
    });
  }

  useCode(BuildContext context) async {
    esdyPrint.debug("useCode >>");
    try {
      this._loginState.isSubmitOtp = true;
      this._updateState();
      var authResponse = await _httpService.esPostWithoutAuth(
          EsApiPaths.postToken,
          json.encode(EsGetTokenPayload(
                  phone: '+91' + this.phoneEditController.text,
                  token: this.otpEditController.text,
                  thirdPartyId: Environment.esTPID)
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
          // Navigator.of(context).pushNamedAndRemoveUntil(
          //     EsHomePage.routeName, (Route<dynamic> route) => false);
          Navigator.of(context).pop();
          this._loginState.isSubmitOtp = false;
          this._updateState();
          return;
        }
      } else {
        esdyPrint.debug("useCode ${authResponse.body}");
        Fluttertoast.showToast(
            msg: json.decode(authResponse.body)['message'].toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM);
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
