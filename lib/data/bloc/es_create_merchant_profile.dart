import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/auth.dart';
import 'package:foore/data/constants/es_api_path.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_profiles.dart';
import 'package:rxdart/rxdart.dart';

class EsCreateMerchantProfileBloc {
  EsCreateMerchantProfileState _esCreateMerchantProfileState =
      new EsCreateMerchantProfileState();
  final nameEditController = TextEditingController();
  final HttpService httpService;
  final AuthBloc authBloc;

  BehaviorSubject<EsCreateMerchantProfileState>
      _subjectEsCreateMerchantProfileState;

  EsCreateMerchantProfileBloc(this.httpService, this.authBloc) {
    this._subjectEsCreateMerchantProfileState =
        new BehaviorSubject<EsCreateMerchantProfileState>.seeded(
            _esCreateMerchantProfileState);
  }

  Observable<EsCreateMerchantProfileState>
      get createMerchantProfileObservable =>
          _subjectEsCreateMerchantProfileState.stream;

  createMerchantProfile(Function onCreateMerchantProfileSuccess) {
    this._esCreateMerchantProfileState.isSubmitting = true;
    this._esCreateMerchantProfileState.isSubmitFailed = false;
    this._esCreateMerchantProfileState.isSubmitSuccess = false;
    this._updateState();
    var payload = new AddMerchantProfilePayload(
      profileName: this.nameEditController.text,
      role: "MERCHANT",
    );
    var payloadString = json.encode(payload.toJson());
    this
        .httpService
        .esPostWithToken(EsApiPaths.postAddProfile, payloadString, this.authBloc.authState.esJwtToken)
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 202 || httpResponse.statusCode == 201) {
        this._esCreateMerchantProfileState.isSubmitting = false;
        this._esCreateMerchantProfileState.isSubmitFailed = false;
        this._esCreateMerchantProfileState.isSubmitSuccess = true;
        var createdMerchantProfile =
            EsProfile.fromJson(json.decode(httpResponse.body));
        if (onCreateMerchantProfileSuccess != null) {
          onCreateMerchantProfileSuccess(createdMerchantProfile);
        }
      } else {
        this._esCreateMerchantProfileState.isSubmitting = false;
        this._esCreateMerchantProfileState.isSubmitFailed = true;
        this._esCreateMerchantProfileState.isSubmitSuccess = false;
      }
      this._updateState();
    }).catchError((onError) {
      this._esCreateMerchantProfileState.isSubmitting = false;
      this._esCreateMerchantProfileState.isSubmitFailed = true;
      this._esCreateMerchantProfileState.isSubmitSuccess = false;
      this._updateState();
    });
  }

  setIsSubmitting(bool isSubmitting) {
    this._esCreateMerchantProfileState.isSubmitting = isSubmitting;
    this._updateState();
  }

  _updateState() {
    if (!this._subjectEsCreateMerchantProfileState.isClosed) {
      this
          ._subjectEsCreateMerchantProfileState
          .sink
          .add(this._esCreateMerchantProfileState);
    }
  }

  dispose() {
    this._subjectEsCreateMerchantProfileState.close();
  }
}

class EsCreateMerchantProfileState {
  bool isSubmitting;
  bool isSubmitSuccess;
  bool isSubmitFailed;

  EsCreateMerchantProfileState() {
    this.isSubmitting = false;
    this.isSubmitFailed = false;
    this.isSubmitSuccess = false;
  }
}
