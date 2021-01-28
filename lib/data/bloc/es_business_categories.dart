import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:foore/data/constants/es_api_path.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_business.dart';
import 'package:foore/environments/environment.dart';
import 'package:rxdart/rxdart.dart';

class EsBusinessCategoriesBloc {
  EsBusinessCategoriesState _esBusinessCategoriesState =
      EsBusinessCategoriesState();
  TextEditingController searchCategoryTextfieldController =
      TextEditingController();

  BehaviorSubject<EsBusinessCategoriesState> _subjectEsBusinessCategoriesState;

  Observable<EsBusinessCategoriesState> get businessCategoriesObservable =>
      _subjectEsBusinessCategoriesState.stream;

  final HttpService httpService;

  EsBusinessCategoriesBloc(this.httpService) {
    this._subjectEsBusinessCategoriesState =
        BehaviorSubject<EsBusinessCategoriesState>.seeded(
            _esBusinessCategoriesState);
  }

  void getBusinessCategories() async {
    if (this._esBusinessCategoriesState.businessCategoriesLoading) return;
    if (this._esBusinessCategoriesState.currentBusinessCategoryResponseModel !=
            null &&
        this._esBusinessCategoriesState.currentNextUrl == null) return;
    this._esBusinessCategoriesState.businessCategoriesLoading = true;
    if (this._esBusinessCategoriesState.currentBusinessCategoryResponseModel == null)
      _updateState();
    final response = await this.httpService.esGet(
        this._esBusinessCategoriesState.currentNextUrl?.substring(Environment.esApiUrl.toString().length) ??
            EsApiPaths.getBusinessCategories);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonDecodedResponse = jsonDecode(response.body);
      final responseModel =
          BusinessCategoriesResponseModel.fromJson(jsonDecodedResponse);
      this
          ._esBusinessCategoriesState
          .businessCategoryResponseModels
          .add(responseModel);
      this._esBusinessCategoriesState.currentBusinessCategoryResponseModel =
          responseModel;
      this._esBusinessCategoriesState.currentNextUrl = responseModel.next;
      this._esBusinessCategoriesState.currentPreviousUrl =
          responseModel.previous;
      this._esBusinessCategoriesState.businessCategories +=
          responseModel.businessCategories;
    }
    this._esBusinessCategoriesState.businessCategoriesLoading = false;
    _updateState();
  }

  void updateCategorySelections() {
    _updateState();
  }

  void getSearchResultsForBusinessCategoriesByQuery() async {
    if (_esBusinessCategoriesState.searchResultsLoading) return;
    this._esBusinessCategoriesState.searchResultsLoading = true;
    this._esBusinessCategoriesState.searchResultsBusinessCategories = [];
    _updateState();
    final response = await httpService.esGet(EsApiPaths.getBusinessCategories +
        "?filter=${searchCategoryTextfieldController.text}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseModel =
          BusinessCategoriesResponseModel.fromJson(jsonDecode(response.body));
      this._esBusinessCategoriesState.searchResultsBusinessCategories =
          responseModel.businessCategories;
    }
    this._esBusinessCategoriesState.searchResultsLoading = false;
    _updateState();
  }

  void dispose() {
    this._subjectEsBusinessCategoriesState.close();
    this.searchCategoryTextfieldController.dispose();
  }

  void _updateState() {
    if (!this._subjectEsBusinessCategoriesState.isClosed) {
      this
          ._subjectEsBusinessCategoriesState
          .sink
          .add(this._esBusinessCategoriesState);
    }
  }
}

class EsBusinessCategoriesState {
  List<EsBusinessCategory> businessCategories;
  List<EsBusinessCategory> searchResultsBusinessCategories;
  BusinessCategoriesResponseModel currentBusinessCategoryResponseModel;
  List<BusinessCategoriesResponseModel> businessCategoryResponseModels;
  bool businessCategoriesLoading;
  bool searchResultsLoading;
  String currentNextUrl;
  String currentPreviousUrl;

  EsBusinessCategoriesState() {
    businessCategories = [];
    searchResultsBusinessCategories = [];
    businessCategoriesLoading = false;
    searchResultsLoading = false;
    businessCategoryResponseModels = [];
    currentBusinessCategoryResponseModel = null;
    currentNextUrl = null;
    currentPreviousUrl = null;
  }
}

class BusinessCategoriesResponseModel {
  int count;
  String next;
  String previous;
  List<EsBusinessCategory> businessCategories;

  BusinessCategoriesResponseModel.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      businessCategories = [];
      json['results']?.forEach((json) {
        businessCategories.add(EsBusinessCategory.fromJson(json));
      });
    }
  }
}
