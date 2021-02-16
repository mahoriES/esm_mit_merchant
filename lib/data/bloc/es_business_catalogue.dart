import 'dart:async';
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
  StreamSubscription<EsBusinessesState> _subscription;

  BehaviorSubject<EsBusinessCatalogueState> _subjectBusinessCatalogueState;

  EsBusinessCatalogueBloc(this.httpService, this.esBusinessesBloc) {
    _esBusinessCatalogueState = new EsBusinessCatalogueState();
    this._subjectBusinessCatalogueState =
        new BehaviorSubject<EsBusinessCatalogueState>.seeded(
            _esBusinessCatalogueState);
    this._subscription =
        this.esBusinessesBloc.esBusinessesStateObservable.listen((event) {
      this.resetDataState();
    });
  }

  getCategories() {
    if (this._esBusinessCatalogueState._categoriesLoadingStatus ==
        DataState.SUCCESS) {
      return;
    }
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
            .map((e) => e.categoryId)
            .toList();
        if (this._esBusinessCatalogueState._categoryIdsList.length > 0) {
          this._esBusinessCatalogueState._selectedParentCategoryId =
              this._esBusinessCatalogueState._categoryIdsList[0];
        }
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

  selectParentCategory(int parentCategoryId) {
    _esBusinessCatalogueState._selectedParentCategoryId = parentCategoryId;
    this._updateState();
  }

  // Fetches the Products list under a child category
  getProductsList(int subCategoryId) async {
    final childCategory =
        _esBusinessCatalogueState._categoriesMap[subCategoryId];
    if (childCategory != null) {
      if (_esBusinessCatalogueState._productsLoadingStatusMap[subCategoryId] ==
              DataState.SUCCESS ||
          _esBusinessCatalogueState._productsLoadingStatusMap[subCategoryId] ==
              DataState.LOADING) return;
      _esBusinessCatalogueState._productsLoadingStatusMap[subCategoryId] =
          DataState.LOADING;
      _updateState();
      try {
        final httpResponse = await httpService.esGet(
            EsApiPaths.getProductsForCategory(
                this.esBusinessesBloc.getSelectedBusinessId(), subCategoryId));
        final productsResponse =
            EsGetProductsResponse.fromJson(json.decode(httpResponse.body));
        _esBusinessCatalogueState._productsUnderChildCateoryMap[subCategoryId] =
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
        _esBusinessCatalogueState._productsLoadingStatusMap[subCategoryId] =
            DataState.SUCCESS;
        _updateState();
      } catch (_) {
        _esBusinessCatalogueState._productsLoadingStatusMap[subCategoryId] =
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

  expandProduct(int productId, bool isExpanded) {
    final product = _esBusinessCatalogueState._productsMap[productId];
    if (product != null) {
      product.isExpanded = isExpanded;
      _updateState();
    }
  }

  Observable<EsBusinessCatalogueState> get esBusinessCatalogueStateObservable =>
      _subjectBusinessCatalogueState.stream;

  resetDataState() {
    _esBusinessCatalogueState = new EsBusinessCatalogueState();
    this._updateState();
  }

  _updateState() {
    if (!this._subjectBusinessCatalogueState.isClosed) {
      this
          ._subjectBusinessCatalogueState
          .sink
          .add(this._esBusinessCatalogueState);
    }
  }

  dispose() {
    this._subjectBusinessCatalogueState.close();
    this.searchController.dispose();
    this._subscription.cancel();
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
      _categoryIdsList.map((e) => _categoriesMap[e]).toList();

  List<EsCategory> get parentCategories => categoryList
      .where((element) => element.parentCategoryId == null)
      .toList();

  int _selectedParentCategoryId;

  bool getIsParentCategorySelected(int id) {
    return _selectedParentCategoryId == id;
  }

  List<EsCategory> get subCategories {
    if (_selectedParentCategoryId == null) return [];
    return categoryList
        .where(
            (element) => element.parentCategoryId == _selectedParentCategoryId)
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

  bool getIsShowLoadingNextPageForProducts(int childCategoryId) {
    return _productsUnderChildCateoryMap[childCategoryId]?.isLoadingMore ==
        true;
  }

  bool getIsShowNextPageForProducts(int childCategoryId) {
    return getIsShowLoadingNextPageForProducts(childCategoryId)
        ? false
        : _productsUnderChildCateoryMap[childCategoryId]?.nextPageUrl != null;
  }

  String getNumberOfProducts(int childCategoryId) {
    if (getProductsLoadingStatus(childCategoryId) == DataState.SUCCESS) {
      return ' (' +
          (_productsUnderChildCateoryMap[childCategoryId]?.count?.toString() ??
              '0') +
          ')';
    }
    return '';
  }

  DataState getProductsLoadingStatus(int childCategoryId) {
    if (_productsLoadingStatusMap[childCategoryId] == null) {
      return DataState.IDLE;
    }
    return _productsLoadingStatusMap[childCategoryId];
  }

  List<EsBusinessCatalogueProduct> getProductListForSubCategory(
    int childCategoryId,
  ) {
    if (_productsUnderChildCateoryMap[childCategoryId] == null) return [];
    return _productsUnderChildCateoryMap[childCategoryId]
        .ids
        .map((e) => _productsMap[e])
        .toList();
  }

  EsBusinessCatalogueState();
}
