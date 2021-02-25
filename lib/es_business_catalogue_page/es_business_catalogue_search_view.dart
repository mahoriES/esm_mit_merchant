import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_products.dart';
import 'package:foore/data/model/es_product_catalogue.dart';
import 'package:foore/es_business_catalogue_page/widgets/es_business_catalogue_product_tile.dart';
import 'package:foore/widgets/empty_list.dart';
import 'package:foore/widgets/something_went_wrong.dart';
import 'package:provider/provider.dart';

import '../app_translations.dart';
import 'es_business_catalogue_list_view.dart';

class EsBusinessCatalogueSearchView extends StatelessWidget {
  static const routeName = 'EsBusinessCatalogueSearchView';
  static const searchBarHeroTag = 'searchBarHeroTag';
  const EsBusinessCatalogueSearchView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final esProductBloc = Provider.of<EsProductsBloc>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Hero(
          tag: EsBusinessCatalogueSearchView.searchBarHeroTag,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Material(
              elevation: 1,
              child: StreamBuilder<EsProductsState>(
                  stream: esProductBloc.esProductStateObservable,
                  builder: (_, __) {
                    return TextField(
                      autofocus: true,
                      controller: esProductBloc.searchController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: false,
                        hintText: AppTranslations.of(context)
                            .text('business_catalogue_page_search_hint'),
                        prefixIcon: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Icon(Icons.arrow_back),
                        ),
                        suffixIcon: esProductBloc.searchController.text != ''
                            ? InkWell(
                                onTap: () {
                                  esProductBloc.clearSearch();
                                },
                                child: Transform.rotate(
                                  angle: pi / 4,
                                  child: Icon(Icons.add),
                                ),
                              )
                            : null,
                      ),
                    );
                  }),
            ),
          ),
        ),
      ),
      body: StreamBuilder<EsProductsState>(
          stream: esProductBloc.esProductStateObservable,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }
            if (esProductBloc.searchController.text.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      size: 60.0,
                      color: Theme.of(context).primaryColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        AppTranslations.of(context).text(
                            'business_catalogue_page_search_for_products'),
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                    )
                  ],
                ),
              );
            } else if (snapshot.data
                    .getProductsLoadingStatus(ProductFilters.searchView) ==
                DataState.LOADING) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.data
                    .getProductsLoadingStatus(ProductFilters.searchView) ==
                DataState.FAILED) {
              return SomethingWentWrong(onRetry: () {
                esProductBloc.getProducts(ProductFilters.searchView);
              });
            } else if (snapshot.data
                    .getProducts(ProductFilters.searchView)
                    .length ==
                0) {
              return EmptyList(
                titleText: AppTranslations.of(context)
                    .text('products_page_no_products_found'),
              );
            }
            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
                  esProductBloc.loadMore(filter: ProductFilters.searchView);
                }
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 16.0,
                  bottom: 72,
                ),
                itemCount:
                    snapshot.data.getProducts(ProductFilters.searchView).length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      if (index == 0)
                        _ProductListHeaderTitle(
                          title: AppTranslations.of(context).text(
                              'business_catalogue_page_title_products_found'),
                          productsState: snapshot.data,
                          filter: ProductFilters.searchView,
                        ),
                      EsBusinessCatalogueProductTile(
                          ProductFilters.searchView,
                          snapshot.data
                              .getProducts(ProductFilters.searchView)[index]),
                    ],
                  );
                },
              ),
            );
          }),
    );
  }
}

class _ProductListHeaderTitle extends StatelessWidget {
  const _ProductListHeaderTitle({
    Key key,
    @required this.title,
    @required this.productsState,
    @required this.filter,
  }) : super(key: key);

  final String title;
  final EsProductsState productsState;
  final ProductFilters filter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 19.0),
      child: Row(
        children: [
          const Spacer(),
          Text(
            title + productsState.getNumberOfProducts(filter),
            style: Theme.of(context).textTheme.headline6.copyWith(
                  color: Theme.of(context).primaryColorDark,
                ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
