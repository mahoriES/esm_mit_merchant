import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foore/data/constants/es_api_path.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_business.dart';
import 'package:foore/data/model/es_clusters.dart';
import 'package:rxdart/rxdart.dart';

class EsCreateBusinessBloc {
  EsCreateBusinessState _esCreateBusinessStateState =
      new EsCreateBusinessState();
  final nameEditController = TextEditingController();
  final HttpService httpService;

  BehaviorSubject<EsCreateBusinessState> _subjectEsCreateBusinessState;

  EsCreateBusinessBloc(this.httpService) {
    this._subjectEsCreateBusinessState =
        new BehaviorSubject<EsCreateBusinessState>.seeded(
            _esCreateBusinessStateState);
    nameEditController.addListener(() {_updateState();});
  }

  Observable<EsCreateBusinessState> get createBusinessObservable =>
      _subjectEsCreateBusinessState.stream;

  createBusiness(Function onCreateBusinessSuccess, onFail) {
    this._esCreateBusinessStateState.isSubmitting = true;
    this._esCreateBusinessStateState.isSubmitFailed = false;
    this._esCreateBusinessStateState.isSubmitSuccess = false;
    this._updateState();
    var payload = new EsCreateBusinessPayload(
      businessName: this.nameEditController.text,
      clusterCode: _esCreateBusinessStateState.selectedCircle.clusterCode,
    );
    var payloadString = json.encode(payload.toJson());
    this
        .httpService
        .esPost(EsApiPaths.postCreateBusiness, payloadString)
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
        this._esCreateBusinessStateState.isSubmitting = false;
        this._esCreateBusinessStateState.isSubmitFailed = false;
        this._esCreateBusinessStateState.isSubmitSuccess = true;
        var createdBusinessInfo =
            EsBusinessInfo.fromJson(json.decode(httpResponse.body));
        if (onCreateBusinessSuccess != null) {
          onCreateBusinessSuccess(createdBusinessInfo);
        }
      } else {
        onFail();
        this._esCreateBusinessStateState.isSubmitting = false;
        this._esCreateBusinessStateState.isSubmitFailed = true;
        this._esCreateBusinessStateState.isSubmitSuccess = false;
      }
      this._updateState();
    }).catchError((onError) {
      onFail();
      this._esCreateBusinessStateState.isSubmitting = false;
      this._esCreateBusinessStateState.isSubmitFailed = true;
      this._esCreateBusinessStateState.isSubmitSuccess = false;
      this._updateState();
    });
  }

  void handleCircleSelection(EsCluster selectedCircle) {
    if (selectedCircle == null) return;
    this._esCreateBusinessStateState.selectedCircle = selectedCircle;
    _updateState();
  }

  setIsSubmitting(bool isSubmitting) {
    this._esCreateBusinessStateState.isSubmitting = isSubmitting;
    this._updateState();
  }

  _updateState() {
    if (!this._subjectEsCreateBusinessState.isClosed) {
      this
          ._subjectEsCreateBusinessState
          .sink
          .add(this._esCreateBusinessStateState);
    }
  }

  dispose() {
    this._subjectEsCreateBusinessState.close();
  }
}

class EsCreateBusinessState {
  bool isSubmitting;
  bool isSubmitSuccess;
  bool isSubmitFailed;
  EsCluster selectedCircle;

  EsCreateBusinessState() {
    this.isSubmitting = false;
    this.isSubmitFailed = false;
    this.isSubmitSuccess = false;
    this.selectedCircle = null;
  }
}
