import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/data/constants/es_api_path.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_product.dart';
import 'package:foore/data/model/es_product_catalogue.dart';
import 'package:foore/utils/utils.dart';
import 'package:rxdart/rxdart.dart';

class EsProductsBloc {
  final EsProductsState _esProductsState = new EsProductsState();
  final HttpService httpService;
  final EsBusinessesBloc esBusinessesBloc;

  String searchText = '';

  BehaviorSubject<EsProductsState> _subjectEsProductsState;

  onSearchTextChanged(TextEditingController controller) {
    this.searchText = controller.text != null ? controller.text : '';
    this.getProducts();
  }

  EsProductsBloc(this.httpService, this.esBusinessesBloc) {
    this._subjectEsProductsState =
        new BehaviorSubject<EsProductsState>.seeded(_esProductsState);
  }

  Observable<EsProductsState> get esProductStateObservable =>
      _subjectEsProductsState.stream;

  getProducts() {
    this._esProductsState.isLoading = true;
    this._esProductsState.response = null;
    this._updateState();
    final Map<String, String> queryParameters = Map();
    if (this._esProductsState.selectedFilter == ProductFilters.outOfStock) {
      queryParameters.addAll({'in_stock': 'false'});
    } else if (this._esProductsState.selectedFilter ==
        ProductFilters.spotlights) {
      queryParameters.addAll({'spotlight': 'true'});
    }
    switch (this._esProductsState.selectedSorting) {
      case ProductSorting.recentlyUpdatedAcending:
        queryParameters.addAll({
          'sort_by': 'modified',
        });
        break;
      case ProductSorting.alphabaticallyAcending:
        queryParameters.addAll({'sort_by': 'product_name'});
        break;
      case ProductSorting.ratingDecending:
        queryParameters.addAll({'sort_by': '-rating_val'});
        break;
    }
    final query = Utils.makeQuery(queryParameters);
    httpService
        .esGet(EsApiPaths.getProducts(
                this.esBusinessesBloc.getSelectedBusinessId()) +
            query)
        .then((httpResponse) {
      if (httpResponse.statusCode == 200) {
        this._esProductsState.isLoadingFailed = false;
        this._esProductsState.isLoading = false;
        this._esProductsState.response =
            EsGetProductsResponse.fromJson(json.decode(httpResponse.body));
        this._esProductsState.items = this._esProductsState.response.results;
        this._esProductsState.products =
            this._esProductsState.response.results.map(
          (element) {
            return EsBusinessCatalogueProduct(
              product: element,
              isExpanded: false,
            );
          },
        ).toList();
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
        this._esProductsState.products = this
            ._esProductsState
            .response
            .results
            .fold<List<EsBusinessCatalogueProduct>>(
          this._esProductsState.products,
          (previousValue, element) {
            previousValue.add(EsBusinessCatalogueProduct(
              product: element,
              isExpanded: false,
            ));
            return previousValue;
          },
        );
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

  expandProduct(int productId, bool isExpanded) {
    _esProductsState.products = _esProductsState.products.map((e) {
      if (e.product.productId == productId) {
        e.isExpanded = isExpanded;
      }
      return e;
    }).toList();
    _updateState();
  }

  setSorting(ProductSorting sorting) {
    _esProductsState.selectedSorting = sorting;
    getProducts();
  }

  setFilter(ProductFilters filter) {
    _esProductsState.selectedFilter = filter;
    _updateState();
  }
}

class EsProductsState {
  bool isLoading = false;
  EsGetProductsResponse response;
  List<EsProduct> items = new List<EsProduct>();

  List<EsBusinessCatalogueProduct> products =
      new List<EsBusinessCatalogueProduct>();

  ProductFilters selectedFilter;

  ProductSorting selectedSorting = ProductSorting.recentlyUpdatedAcending;

  getNumberOfProducts() {
    if (response == null) {
      return '';
    }
    return ' (${response.count})';
  }

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
