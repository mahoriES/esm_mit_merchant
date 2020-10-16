import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foore/data/constants/es_api_path.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_business.dart';
import 'package:rxdart/rxdart.dart';

import 'auth.dart';

class EsBusinessesBloc {
  static const FILENAME = 'es_businesses.dart';
  static const CLASSNAME = 'EsBusinessesBloc';
  static void esdyPrint(String message) {
    debugPrint(FILENAME + " : " + CLASSNAME + " : " + message);
  }

  EsBusinessesState _esBusinessesState = new EsBusinessesState();
  final HttpService _httpService;
  final AuthBloc authBloc;

  BehaviorSubject<EsBusinessesState> _subjectEsBusinessesState;

  EsBusinessesBloc(this._httpService, this.authBloc) {
    this._subjectEsBusinessesState =
        new BehaviorSubject<EsBusinessesState>.seeded(_esBusinessesState);
    this.authBloc.authStateObservable.listen((event) {
      if (event.isEsLoggedOut) {
        this._esBusinessesState = new EsBusinessesState();
        this._updateState();
      }
    });
  }

  Observable<EsBusinessesState> get esBusinessesStateObservable =>
      _subjectEsBusinessesState.stream;

  getData() {
    esdyPrint('getData');
    this.getBusinesses();
  }

  getBusinesses() {
    this._esBusinessesState.isLoading = true;
    this._esBusinessesState.isLoadingFailed = false;
    this._esBusinessesState.businesses = [];
    this._updateState();
    _httpService.esGet(EsApiPaths.getBusinesses).then((httpResponse) {
      if (httpResponse.statusCode == 200) {
        this._esBusinessesState.isLoading = false;
        this._esBusinessesState.isLoadingFailed = false;
        this._esBusinessesState.setBusinessesResponse(
            EsGetBusinessesResponse.fromJson(json.decode(httpResponse.body)));
      } else {
        this._esBusinessesState.isLoadingFailed = true;
        this._esBusinessesState.isLoading = false;
      }
      this._updateState();
    }).catchError((onError) {
      this._esBusinessesState.isLoadingFailed = true;
      this._esBusinessesState.isLoading = false;
      this._updateState();
    });
  }

  addCreatedBusiness(EsBusinessInfo businessInfo) {
    this._esBusinessesState.businesses.add(businessInfo);
  }

  setSelectedBusiness(EsBusinessInfo businessInfo) {
    esdyPrint('setSelectedBusiness');
    this._esBusinessesState.selectedBusiness = businessInfo;
    this._updateState();
  }

  updateSelectedBusiness(EsBusinessInfo businessInfo) {
    esdyPrint('setSelectedBusiness');
    this._esBusinessesState.selectedBusiness = businessInfo;
    this._esBusinessesState.businesses =
        this._esBusinessesState.businesses.map((info) {
      if (info.businessId == businessInfo.businessId) {
        return businessInfo;
      }
      return info;
    }).toList();
    this._updateState();
  }

  getSelectedBusinessId() {
    return this._esBusinessesState.selectedBusinessId;
  }

  getSelectedBusinessName() {
    return this._esBusinessesState.selectedBusiness.businessName;
  }

  _updateState() {
    if (!this._subjectEsBusinessesState.isClosed) {
      this._subjectEsBusinessesState.sink.add(this._esBusinessesState);
    }
  }

  dispose() {
    this._subjectEsBusinessesState.close();
  }
}

class EsBusinessesState {
  static const FILENAME = 'es_businesses.dart';
  static const CLASSNAME = 'EsBusinessesBloc';
  static void esdyPrint(String message) {
    debugPrint(FILENAME + " : " + CLASSNAME + " : " + message);
  }

  bool isLoading;
  bool isLoadingFailed;

  get isShowBusinesses => !isLoading && businesses.length > 0;

  get isCreateBusinessRequired {
    bool isRequired = (!isLoading) && (businesses.length == 0);
    esdyPrint("isCreateBusinessRequired: " + businesses.length.toString());
    esdyPrint("isCreateBusinessRequired: " + isLoading.toString());
    esdyPrint("isCreateBusinessRequired: " + isRequired.toString());
    return isRequired;
  }

  EsBusinessInfo selectedBusiness;

  get selectedBusinessId =>
      selectedBusiness != null ? selectedBusiness.businessId : null;

  EsGetBusinessesResponse businessesResponse;

  List<EsBusinessInfo> businesses;

  EsBusinessesState() {
    this.isLoading = true;
    this.isLoadingFailed = false;
    this.businesses = new List<EsBusinessInfo>();
  }

  setBusinessesResponse(EsGetBusinessesResponse response) {
    this.businessesResponse = response;
    this.businesses = response.results;
    if (this.businesses.length > 0) {
      selectedBusiness = this.businesses[0];
      esdyPrint(selectedBusiness.businessId);
    }
  }
}
