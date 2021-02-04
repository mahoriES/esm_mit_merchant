import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/data/constants/es_api_path.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_categories.dart';
import 'package:foore/data/model/es_product.dart';
import 'package:foore/data/model/es_product_catalogue.dart';
import 'package:rxdart/rxdart.dart';

class EsBusinessCatalogueBloc {
  EsBusinessCatalogueState _esBusinessCatalogueState;
  final HttpService httpService;
  final EsBusinessesBloc esBusinessesBloc;
  final searchController = TextEditingController();

  BehaviorSubject<EsBusinessCatalogueState> _subjectProductsCatalogueState;

  EsBusinessCatalogueBloc(this.httpService, this.esBusinessesBloc) {
    _esBusinessCatalogueState = new EsBusinessCatalogueState();
    this._subjectProductsCatalogueState =
        new BehaviorSubject<EsBusinessCatalogueState>.seeded(
            _esBusinessCatalogueState);
  }

  getCategories() {
    this._esBusinessCatalogueState._categoriesLoadingStatus = DataState.LOADING;
    this._esBusinessCatalogueState._categoriesResponse = null;
    this._updateState();
    httpService
        .esGet(EsApiPaths.getCategories(
            this.esBusinessesBloc.getSelectedBusinessId()))
        .then((httpResponse) {
      if (httpResponse.statusCode == 200) {
        this._esBusinessCatalogueState._categoriesLoadingStatus =
            DataState.SUCCESS;
        this._esBusinessCatalogueState._categoriesResponse =
            EsGetCategoriesResponse.fromJson(json.decode(httpResponse.body));
        this._esBusinessCatalogueState._categoryIdsList = this
            ._esBusinessCatalogueState
            ._categoriesResponse
            .categories
            .map((e) => e.categoryId);
        _esBusinessCatalogueState._categoriesMap = this
            ._esBusinessCatalogueState
            ._categoriesResponse
            .categories
            .fold<Map<int, EsCategory>>(
          _esBusinessCatalogueState._categoriesMap,
          (previousValue, element) {
            if (previousValue[element.categoryId] == null) {
              previousValue[element.categoryId] = element;
            }
            return previousValue;
          },
        );
      } else {
        this._esBusinessCatalogueState._categoriesLoadingStatus =
            DataState.FAILED;
      }
      this._updateState();
    }).catchError((onError) {
      this._esBusinessCatalogueState._categoriesLoadingStatus =
          DataState.FAILED;
      this._updateState();
    });
  }

  // Fetches the Products list under a child category
  getProductsList(int categoryId) async {
    final childCategory = _esBusinessCatalogueState._categoriesMap[categoryId];
    if (childCategory != null) {
      _esBusinessCatalogueState._productsLoadingStatusMap[categoryId] =
          DataState.LOADING;
      _updateState();
      try {
        final httpResponse = await httpService.esGet(
            EsApiPaths.getProductsForCategory(
                this.esBusinessesBloc.getSelectedBusinessId(), categoryId));
        final productsResponse =
            EsGetProductsResponse.fromJson(json.decode(httpResponse.body));
        _esBusinessCatalogueState._productsUnderChildCateoryMap[categoryId] =
            ListOfIdsUnderParent(
          productsResponse.count,
          productsResponse.next,
          productsResponse.previous,
          productsResponse.results.map((e) => e.productId).toList(),
        );
        _esBusinessCatalogueState._productsMap =
            productsResponse.results.fold<Map<int, EsBusinessCatalogueProduct>>(
          _esBusinessCatalogueState._productsMap,
          (previousValue, element) {
            if (previousValue[element.productId] == null) {
              previousValue[element.productId] = EsBusinessCatalogueProduct(
                product: element,
                isExpanded: false,
              );
            }
            return previousValue;
          },
        );
        _esBusinessCatalogueState._productsLoadingStatusMap[categoryId] =
            DataState.SUCCESS;
        _updateState();
      } catch (_) {
        _esBusinessCatalogueState._productsLoadingStatusMap[categoryId] =
            DataState.FAILED;
        _updateState();
      }
    }
  }

  getProductsNextPage(int childMasterId) async {
    final productListDetail =
        _esBusinessCatalogueState._productsUnderChildCateoryMap[childMasterId];

    if (productListDetail != null) {
      productListDetail.isLoadingMore = true;
      _updateState();

      try {
        final httpResponse =
            await httpService.esGetUrl(productListDetail.nextPageUrl);

        if (httpResponse.statusCode == 200) {
          final responseJson = json.decode(httpResponse.body);
          final productsResponse = EsGetProductsResponse.fromJson(responseJson);

          productListDetail.count = productsResponse.count;
          productListDetail.nextPageUrl = productsResponse.next;
          productListDetail.previousPageUrl = productsResponse.previous;
          productListDetail.ids = [
            ...productListDetail.ids,
            ...productsResponse.results.map((e) => e.productId).toList()
          ];

          _esBusinessCatalogueState._productsMap = productsResponse.results
              .fold<Map<int, EsBusinessCatalogueProduct>>(
            _esBusinessCatalogueState._productsMap,
            (previousValue, element) {
              if (previousValue[element.productId] == null) {
                previousValue[element.productId] = EsBusinessCatalogueProduct(
                    isExpanded: false, product: element);
              }
              return previousValue;
            },
          );
          productListDetail.isLoadingMore = false;
          _updateState();
        } else {
          productListDetail.isLoadingMore = false;
          _updateState();
        }
      } catch (_) {
        productListDetail.isLoadingMore = false;
        _updateState();
      }
    }
  }

  Observable<EsBusinessCatalogueState> get esOrdersStateObservable =>
      _subjectProductsCatalogueState.stream;

  resetDataState() {
    _esBusinessCatalogueState = new EsBusinessCatalogueState();
    this._updateState();
  }

  _updateState() {
    if (!this._subjectProductsCatalogueState.isClosed) {
      this
          ._subjectProductsCatalogueState
          .sink
          .add(this._esBusinessCatalogueState);
    }
  }

  dispose() {
    this._subjectProductsCatalogueState.close();
    this.searchController.dispose();
  }
}

class EsBusinessCatalogueState {
  // Categories
  DataState _categoriesLoadingStatus = DataState.IDLE;
  DataState _categoriesLoadingMoreStatus = DataState.IDLE;
  EsGetCategoriesResponse _categoriesResponse;
  List<int> _categoryIdsList = new List();
  Map<int, EsCategory> _categoriesMap = new Map();

  List<EsCategory> get categoryList =>
      _categoryIdsList.map((e) => _categoriesMap[e]);

  List<EsCategory> get parentCategories => categoryList
      .where((element) => element.parentCategoryId == null)
      .toList();

  List<EsCategory> getSubCategories(int parentCategoryId) {
    return categoryList
        .where((element) => element.parentCategoryId == parentCategoryId)
        .toList();
  }

  // Getters
  DataState get categoriesLoadingStatus => _categoriesLoadingStatus;
  DataState get categoriesLoadingMoreStatus => _categoriesLoadingMoreStatus;

  // All products are stored with productID
  Map<int, EsBusinessCatalogueProduct> _productsMap = Map();
  // Products belonging to Subcategories are mapped to SubcategoryId
  Map<int, ListOfIdsUnderParent> _productsUnderChildCateoryMap = Map();
  Map<int, DataState> _productsLoadingStatusMap = Map();

  bool getIsShowLoadingNextPageForProducts(int childMasterId) {
    return _productsUnderChildCateoryMap[childMasterId]?.isLoadingMore == true;
  }

  bool getIsShowNextPageForProducts(int childMasterId) {
    return getIsShowLoadingNextPageForProducts(childMasterId)
        ? false
        : _productsUnderChildCateoryMap[childMasterId]?.nextPageUrl != null;
  }

  DataState getProductsLoadingStatus(int childMasterId) {
    if (_productsLoadingStatusMap[childMasterId] == null) {
      return DataState.IDLE;
    }
    return _productsLoadingStatusMap[childMasterId];
  }

  List<EsBusinessCatalogueProduct> getProductListForSubCategory(
    int childMasterId,
  ) {
    return _productsUnderChildCateoryMap[childMasterId]
        .ids
        .map((e) => _productsMap[e])
        .toList();
  }

  EsBusinessCatalogueState();
}
