import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/data/constants/es_api_path.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_product.dart';
import 'package:rxdart/rxdart.dart';

class EsProductsBloc {
  final EsProductsState _esProductsState = new EsProductsState();
  final HttpService httpService;
  final EsBusinessesBloc esBusinessesBloc;

  String searchText = '';

  BehaviorSubject<EsProductsState> _subjectEsProductsState;

  onSearchTextChanged(TextEditingController controller) {
    this.searchText = controller.text != null ? controller.text : '';
    this.getProductsFromSearch();
  }

  EsProductsBloc(this.httpService, this.esBusinessesBloc) {
    this._subjectEsProductsState =
        new BehaviorSubject<EsProductsState>.seeded(_esProductsState);
  }

  Observable<EsProductsState> get esProductStateObservable =>
      _subjectEsProductsState.stream;

  getProductsFromSearch() {
    this._esProductsState.isLoading = true;
    this._esProductsState.response = null;
    this._updateState();
    httpService
        .esGet(EsApiPaths.getProducts(
                this.esBusinessesBloc.getSelectedBusinessId()) +
            '?filter=${this.searchText}')
        .then((httpResponse) {
      if (httpResponse.statusCode == 200) {
        this._esProductsState.isLoadingFailed = false;
        this._esProductsState.isLoading = false;
        this._esProductsState.response =
            EsGetProductsResponse.fromJson(json.decode(httpResponse.body));
        this._esProductsState.items = this._esProductsState.response.results;
      } else {
        this._esProductsState.isLoadingFailed = true;
        this._esProductsState.isLoading = false;
      }
      this._updateState();
    }).catchError((onError) {
      this._esProductsState.isLoadingFailed = true;
      this._esProductsState.isLoading = false;
      this._updateState();
    });
  }

  loadMore() {
    if (this._esProductsState.response == null ||
        this._esProductsState.isLoadingMore) {
      return;
    }
    if (this._esProductsState.response.next == null) {
      return;
    }
    this._esProductsState.isLoadingMore = true;
    this._esProductsState.isLoadingMoreFailed = false;
    this._updateState();
    httpService
        .esGetUrl(this._esProductsState.response.next)
        .then((httpResponse) {
      if (httpResponse.statusCode == 200) {
        this._esProductsState.response =
            EsGetProductsResponse.fromJson(json.decode(httpResponse.body));
        this
            ._esProductsState
            .items
            .addAll(this._esProductsState.response.results);
        this._esProductsState.isLoadingMoreFailed = false;
        this._esProductsState.isLoadingMore = false;
      } else {
        this._esProductsState.isLoadingMoreFailed = true;
        this._esProductsState.isLoadingMore = false;
      }
      this._updateState();
    }).catchError((err) {
      this._esProductsState.isLoadingMoreFailed = true;
      this._esProductsState.isLoadingMore = false;
      this._updateState();
    });
  }

  _updateState() {
    if (!this._subjectEsProductsState.isClosed) {
      this._subjectEsProductsState.sink.add(this._esProductsState);
    }
  }

  dispose() {
    this._subjectEsProductsState.close();
  }
}

class EsProductsState {
  bool isLoading = false;
  EsGetProductsResponse response;
  List<EsProduct> items = new List<EsProduct>();
  bool isLoadingFailed = false;
  bool isLoadingMore;
  bool isLoadingMoreFailed;
  EsProductsState() {
    this.isLoading = false;
    this.isLoadingFailed = false;
    this.isLoadingMore = false;
    this.isLoadingMoreFailed = false;
  }
}
