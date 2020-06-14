import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foore/data/constants/es_api_path.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_business.dart';
import 'package:foore/data/model/es_clusters.dart';
import 'package:rxdart/rxdart.dart';

class EsCreateBusinessBloc {
  EsCreateBusinessState _esCreateBusinessStateState = new EsCreateBusinessState();
  final nameEditController = TextEditingController();
  final phoneNumberEditController = TextEditingController();
  final HttpService _httpService;

  BehaviorSubject<EsCreateBusinessState> _subjectEsCreateBusinessState;

  EsCreateBusinessBloc(this._httpService) {
    this._subjectEsCreateBusinessState =
        new BehaviorSubject<EsCreateBusinessState>.seeded(_esCreateBusinessStateState);
  }

  Observable<EsCreateBusinessState> get checkinStateObservable =>
      _subjectEsCreateBusinessState.stream;

  getData() {
    this.getClusters();
  }

  getClusters() {
    this._esCreateBusinessStateState.isLoading = true;
    this._esCreateBusinessStateState.isLoadingFailed = false;
    this._esCreateBusinessStateState.clusters = [];
    this._updateState();
    _httpService.esGet(EsApiPaths.getClusters).then((httpResponse) {
      if (httpResponse.statusCode == 200) {
        this._esCreateBusinessStateState.isLoading = false;
        this._esCreateBusinessStateState.isLoadingFailed = false;
        this._esCreateBusinessStateState.clusters = new List<EsCluster>();
        json.decode(httpResponse.body).forEach((v) {
          this._esCreateBusinessStateState.clusters.add(new EsCluster.fromJson(v));
        });
      } else {
        this._esCreateBusinessStateState.isLoadingFailed = true;
        this._esCreateBusinessStateState.isLoading = false;
      }
      this._updateState();
    }).catchError((onError) {
      this._esCreateBusinessStateState.isLoadingFailed = true;
      this._esCreateBusinessStateState.isLoading = false;
      this._updateState();
    });
  }

  createBusiness(Function onCreateBusinessSuccess) {
    this._esCreateBusinessStateState.isSubmitting = true;
    this._esCreateBusinessStateState.isSubmitFailed = false;
    this._esCreateBusinessStateState.isSubmitSuccess = false;
    this._updateState();
    var payload = new EsCreateBusinessPayload(
      businessName: this.nameEditController.text,
      clusterCode: this._esCreateBusinessStateState.selectedClusterCode,
    );
    var payloadString = json.encode(payload.toJson());
    this
        ._httpService
        .esPost(EsApiPaths.postCreateBusiness, payloadString)
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 202) {
        this._esCreateBusinessStateState.isSubmitting = false;
        this._esCreateBusinessStateState.isSubmitFailed = false;
        this._esCreateBusinessStateState.isSubmitSuccess = true;
        var createdBusinessInfo =
            EsBusinessInfo.fromJson(json.decode(httpResponse.body));
        if (onCreateBusinessSuccess != null) {
          onCreateBusinessSuccess(createdBusinessInfo);
        }
      } else {
        this._esCreateBusinessStateState.isSubmitting = false;
        this._esCreateBusinessStateState.isSubmitFailed = true;
        this._esCreateBusinessStateState.isSubmitSuccess = false;
      }
      this._updateState();
    }).catchError((onError) {
      this._esCreateBusinessStateState.isSubmitting = false;
      this._esCreateBusinessStateState.isSubmitFailed = true;
      this._esCreateBusinessStateState.isSubmitSuccess = false;
      this._updateState();
    });
  }

  setSelectedCluster(EsCluster cluster) {
    this._esCreateBusinessStateState.selectedCluster = cluster;
    this._updateState();
  }

  setIsSubmitting(bool isSubmitting) {
    this._esCreateBusinessStateState.isSubmitting = isSubmitting;
    this._updateState();
  }

  _updateState() {
    if (!this._subjectEsCreateBusinessState.isClosed) {
      this._subjectEsCreateBusinessState.sink.add(this._esCreateBusinessStateState);
    }
  }

  dispose() {
    this._subjectEsCreateBusinessState.close();
  }
}

class EsCreateBusinessState {
  bool isLoading;
  bool isLoadingFailed;

  get selectedClusterCode => '';

  EsCluster selectedCluster;

  List<EsCluster> clusters;

  bool isSubmitting;
  bool isSubmitSuccess;
  bool isSubmitFailed;

  EsCreateBusinessState() {
    this.isLoading = false;
    this.isLoadingFailed = false;
    this.isSubmitting = false;
    this.isSubmitFailed = false;
    this.isSubmitSuccess = false;
    this.clusters = new List<EsCluster>();
  }
}
