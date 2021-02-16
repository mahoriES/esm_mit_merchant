import 'dart:async';
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
  EsProductsState _esProductsState = new EsProductsState();
  final HttpService httpService;
  final EsBusinessesBloc esBusinessesBloc;

  StreamSubscription<EsBusinessesState> _subscription;

  String searchText = '';

  BehaviorSubject<EsProductsState> _subjectEsProductsState;

  onSearchTextChanged(TextEditingController controller) {
    this.searchText = controller.text != null ? controller.text : '';
    _esProductsState
            ._productsLoadingStatusMap[ProductFilters.compatibitilyView] =
        DataState.IDLE;
    this.getProducts(ProductFilters.compatibitilyView);
  }

  EsProductsBloc(this.httpService, this.esBusinessesBloc) {
    this._subjectEsProductsState =
        new BehaviorSubject<EsProductsState>.seeded(_esProductsState);
    this._subscription =
        this.esBusinessesBloc.esBusinessesStateObservable.listen((event) {
      this.resetDataState();
    });
  }

  Observable<EsProductsState> get esProductStateObservable =>
      _subjectEsProductsState.stream;

  getProductsFromSearch() {
    getProducts(ProductFilters.compatibitilyView);
  }

  getProducts(ProductFilters filter) {
    if (this._esProductsState.getProductsLoadingStatus(filter) ==
        DataState.SUCCESS) {
      return;
    }
    this._esProductsState._productsLoadingStatusMap[filter] = DataState.LOADING;
    this._updateState();
    final Map<String, String> queryParameters = Map();
    if (filter == ProductFilters.outOfStock) {
      queryParameters.addAll({'in_stock': 'false'});
    } else if (filter == ProductFilters.spotlights) {
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
        this._esProductsState._productsLoadingStatusMap[filter] =
            DataState.SUCCESS;
        this._esProductsState._responseMap[filter] =
            EsGetProductsResponse.fromJson(json.decode(httpResponse.body));
        this._esProductsState._productsMap[filter] =
            this._esProductsState.getResponse(filter).results.map(
          (element) {
            return EsBusinessCatalogueProduct(
              product: element,
              isExpanded: false,
            );
          },
        ).toList();
      } else {
        this._esProductsState._productsLoadingStatusMap[filter] =
            DataState.FAILED;
      }
      this._updateState();
    }).catchError((onError) {
      this._esProductsState._productsLoadingStatusMap[filter] =
          DataState.FAILED;
      this._updateState();
    });
  }

  loadMore({filter = ProductFilters.compatibitilyView}) {
    if (this._esProductsState.getResponse(filter) == null ||
        this._esProductsState.getProductsLoadingMoreStatus(filter) ==
            DataState.LOADING) {
      return;
    }
    if (this._esProductsState.getResponse(filter).next == null) {
      return;
    }
    this._esProductsState._productsLoadingMoreStatusMap[filter] =
        DataState.LOADING;
    this._updateState();
    httpService
        .esGetUrl(this._esProductsState.getResponse(filter).next)
        .then((httpResponse) {
      if (httpResponse.statusCode == 200) {
        this._esProductsState._responseMap[filter] =
            EsGetProductsResponse.fromJson(json.decode(httpResponse.body));
        this._esProductsState._productsMap[filter] = this
            ._esProductsState
            .getResponse(filter)
            .results
            .fold<List<EsBusinessCatalogueProduct>>(
          this._esProductsState._productsMap[filter],
          (previousValue, element) {
            previousValue.add(EsBusinessCatalogueProduct(
              product: element,
              isExpanded: false,
            ));
            return previousValue;
          },
        );
        this._esProductsState._productsLoadingMoreStatusMap[filter] =
            DataState.SUCCESS;
      } else {
        this._esProductsState._productsLoadingMoreStatusMap[filter] =
            DataState.FAILED;
      }
      this._updateState();
    }).catchError((err) {
      this._esProductsState._productsLoadingMoreStatusMap[filter] =
          DataState.FAILED;
      this._updateState();
    });
  }

  _updateState() {
    if (!this._subjectEsProductsState.isClosed) {
      this._subjectEsProductsState.sink.add(this._esProductsState);
    }
  }

  resetDataState() {
    _esProductsState = new EsProductsState();
    this._updateState();
  }

  dispose() {
    this._subjectEsProductsState.close();
    this._subscription.cancel();
  }

  expandProduct(ProductFilters filter, int productId, bool isExpanded) {
    _esProductsState._productsMap[filter] =
        _esProductsState.getProducts(filter).map((e) {
      if (e.product.productId == productId) {
        e.isExpanded = isExpanded;
      }
      return e;
    }).toList();
    _updateState();
  }

  setSorting(ProductFilters filter, ProductSorting sorting) {
    _esProductsState.selectedSorting = sorting;
    _esProductsState._productsLoadingStatusMap[filter] = DataState.IDLE;
    getProducts(filter);
  }
}

class EsProductsState {
  Map<ProductFilters, DataState> _productsLoadingStatusMap;
  Map<ProductFilters, DataState> _productsLoadingMoreStatusMap;
  Map<ProductFilters, EsGetProductsResponse> _responseMap;
  Map<ProductFilters, List<EsBusinessCatalogueProduct>> _productsMap;

  List<EsBusinessCatalogueProduct> getProducts(ProductFilters filter) =>
      _productsMap[filter] ?? [];

  EsGetProductsResponse getResponse(ProductFilters filter) =>
      _responseMap[filter];

  DataState getProductsLoadingStatus(ProductFilters filter) =>
      _productsLoadingStatusMap[filter] ?? DataState.IDLE;

  DataState getProductsLoadingMoreStatus(ProductFilters filter) =>
      _productsLoadingMoreStatusMap[filter] ?? DataState.IDLE;

  ProductSorting selectedSorting;

  // Backwards compatibility
  List<EsProduct> get items => getProducts(ProductFilters.compatibitilyView)
      .map((e) => e.product)
      .toList();
  bool get isLoading =>
      getProductsLoadingStatus(ProductFilters.compatibitilyView) ==
      DataState.LOADING;
  bool get isLoadingFailed =>
      getProductsLoadingStatus(ProductFilters.compatibitilyView) ==
      DataState.FAILED;
  bool get isLoadingMore =>
      getProductsLoadingMoreStatus(ProductFilters.compatibitilyView) ==
      DataState.LOADING;

  getNumberOfProducts(ProductFilters filter) {
    if (getResponse(filter) == null) {
      return '';
    }
    return ' (${getResponse(filter).count})';
  }

  EsProductsState({
    this.selectedSorting = ProductSorting.recentlyUpdatedAcending,
    Map<ProductFilters, DataState> productsLoadingStatusMap,
    Map<ProductFilters, DataState> productsLoadingMoreStatusMap,
    Map<ProductFilters, EsGetProductsResponse> responseMap,
    Map<ProductFilters, List<EsBusinessCatalogueProduct>> productsMap,
  }) {
    this._productsLoadingStatusMap = productsLoadingStatusMap ?? Map();
    this._productsLoadingMoreStatusMap = productsLoadingMoreStatusMap ?? Map();
    this._productsMap = productsMap ?? Map();
    this._responseMap = responseMap ?? Map();
  }
}
