import 'es_product.dart';

enum DataState {
  IDLE,
  LOADING,
  SUCCESS,
  FAILED,
}

enum ProductFilters { searchView, compatibitilyView, listView, spotlights, outOfStock }

enum ProductSorting {
  recentlyUpdatedAcending,
  alphabaticallyAcending,
  ratingDecending,
}

class ListOfIdsUnderParent {
  int count;
  String nextPageUrl;
  String previousPageUrl;
  List<int> ids = [];
  bool isLoadingMore = false;

  ListOfIdsUnderParent(
    this.count,
    this.nextPageUrl,
    this.previousPageUrl,
    this.ids,
  );

  addIds(List<int> newIds) {
    ids.addAll(newIds);
  }

  setLoadingMore(bool isLoading) {
    isLoadingMore = isLoading;
  }
}

class EsBusinessCatalogueProduct {
  EsProduct product;
  bool isExpanded;
  EsBusinessCatalogueProduct({this.isExpanded = false, this.product});
}
