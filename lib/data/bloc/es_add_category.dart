import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/data/constants/es_api_path.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_categories.dart';
import 'package:rxdart/rxdart.dart';

class EsAddCategoryBloc {
  EsAddCategoryState _esAddCategoryState = new EsAddCategoryState();
  final nameEditController = TextEditingController();
  final descriptionEditController = TextEditingController();
  final HttpService httpService;
  final EsBusinessesBloc esBusinessesBloc;

  BehaviorSubject<EsAddCategoryState> _subjectEsEditProductState;

  EsAddCategoryBloc(this.httpService, this.esBusinessesBloc) {
    this._subjectEsEditProductState =
        new BehaviorSubject<EsAddCategoryState>.seeded(_esAddCategoryState);
  }

  Observable<EsAddCategoryState> get esEditProductStateObservable =>
      _subjectEsEditProductState.stream;

  addCategory(Function onAddCategorySuccess) {
    this._esAddCategoryState.isSubmitting = true;
    this._esAddCategoryState.isSubmitFailed = false;
    this._esAddCategoryState.isSubmitSuccess = false;
    this._updateState();
    var payload = new EsAddCategoryPayload(
        categoryName: this.nameEditController.text,
        categoryDescription: this.descriptionEditController.text);
    var payloadString = json.encode(payload.toJson());
    this
        .httpService
        .esPost(
            EsApiPaths.postAddProductToBusiness(
                this.esBusinessesBloc.getSelectedBusinessId()),
            payloadString)
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 202) {
        this._esAddCategoryState.isSubmitting = false;
        this._esAddCategoryState.isSubmitFailed = false;
        this._esAddCategoryState.isSubmitSuccess = true;
        var addedCategory = EsCategory.fromJson(json.decode(httpResponse.body));
        if (onAddCategorySuccess != null) {
          onAddCategorySuccess(addedCategory);
        }
      } else {
        this._esAddCategoryState.isSubmitting = false;
        this._esAddCategoryState.isSubmitFailed = true;
        this._esAddCategoryState.isSubmitSuccess = false;
      }
      this._updateState();
    }).catchError((onError) {
      this._esAddCategoryState.isSubmitting = false;
      this._esAddCategoryState.isSubmitFailed = true;
      this._esAddCategoryState.isSubmitSuccess = false;
      this._updateState();
    });
  }

  setIsSubmitting(bool isSubmitting) {
    this._esAddCategoryState.isSubmitting = isSubmitting;
    this._updateState();
  }

  _updateState() {
    if (!this._subjectEsEditProductState.isClosed) {
      this._subjectEsEditProductState.sink.add(this._esAddCategoryState);
    }
  }

  dispose() {
    this._subjectEsEditProductState.close();
  }
}

class EsAddCategoryState {
  bool isSubmitting = false;
  bool isSubmitSuccess = false;
  bool isSubmitFailed = false;
  EsAddCategoryState();
}
