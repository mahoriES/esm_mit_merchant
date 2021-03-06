import 'dart:convert';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/data/constants/es_api_path.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_categories.dart';
import 'package:rxdart/rxdart.dart';

class EsCategoriesBloc {
  final EsCategoriesState _esCategoriesState = new EsCategoriesState();
  final HttpService httpService;
  final EsBusinessesBloc esBusinessesBloc;
  final List<int> preSelectedCategoryIds;

  BehaviorSubject<EsCategoriesState> _subjectEsCategoriesState;

  EsCategoriesBloc(
      this.httpService, this.esBusinessesBloc, this.preSelectedCategoryIds) {
    this._subjectEsCategoriesState =
        new BehaviorSubject<EsCategoriesState>.seeded(_esCategoriesState);
  }

  Observable<EsCategoriesState> get esCategoriesStateObservable =>
      _subjectEsCategoriesState.stream;

  getCategories() {
    this._esCategoriesState.isLoading = true;
    this._esCategoriesState.response = null;
    this._updateState();
    httpService
        .esGet(EsApiPaths.getCategories(
            this.esBusinessesBloc.getSelectedBusinessId()))
        .then((httpResponse) {
      if (httpResponse.statusCode == 200) {
        this._esCategoriesState.isLoadingFailed = false;
        this._esCategoriesState.isLoading = false;
        this._esCategoriesState.response =
            EsGetCategoriesResponse.fromJson(json.decode(httpResponse.body));
        this._esCategoriesState.items =
            this._esCategoriesState.response.categories;
        for (EsCategory cat in this._esCategoriesState.items) {
          if (this.preSelectedCategoryIds.contains(cat.categoryId)) {
            cat.dIsSelected = true;
          }
        }
      } else {
        this._esCategoriesState.isLoadingFailed = true;
        this._esCategoriesState.isLoading = false;
      }
      this._updateState();
    }).catchError((onError) {
      this._esCategoriesState.isLoadingFailed = true;
      this._esCategoriesState.isLoading = false;
      this._updateState();
    });
  }

  _updateState() {
    if (!this._subjectEsCategoriesState.isClosed) {
      this._subjectEsCategoriesState.sink.add(this._esCategoriesState);
    }
  }

  dispose() {
    this._subjectEsCategoriesState.close();
  }

  setCategorySelected(int categoryId, bool isSelected) {
    this._esCategoriesState.items =
        this._esCategoriesState.items.map((esCategory) {
      if (esCategory.categoryId == categoryId) {
        esCategory.dIsSelected = isSelected;
      }
      return esCategory;
    }).toList();
    this._updateState();
  }

  addUserCreatedCategory(EsCategory userCreatedCategory) {
    this._esCategoriesState.items.add(userCreatedCategory);
    this._updateState();
  }

  setCategoryExpanded(int categoryId, bool isExpanded) {
    this._esCategoriesState.items =
        this._esCategoriesState.items.map((esCategory) {
      if (esCategory.categoryId == categoryId) {
        esCategory.dIsExpanded = isExpanded;
      }
      return esCategory;
    }).toList();
    this._updateState();
  }
}

class EsCategoriesState {
  bool isLoading = false;
  EsGetCategoriesResponse response;
  List<EsCategory> items = new List<EsCategory>();
  bool isLoadingFailed = false;
  int get numberOfSelectedItems =>
      items.where((element) => element.dIsSelected).length;

  List<EsCategory> get selectedCategories =>
      items.where((element) => element.dIsSelected).toList();

  List<EsCategory> get parentCategories =>
      items.where((element) => element.parentCategoryId == null).toList();

  List<EsCategory> getSubCategories(int parentCategoryId) {
    return items
        .where((element) => element.parentCategoryId == parentCategoryId)
        .toList();
  }

  EsCategoriesState() {
    this.isLoading = false;
    this.isLoadingFailed = false;
  }
}
