import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_products.dart';
import 'package:foore/data/model/es_product_catalogue.dart';
import 'package:foore/es_business_catalogue_page/widgets/es_business_catalogue_product_tile.dart';
import 'package:foore/widgets/empty_list.dart';
import 'package:foore/widgets/something_went_wrong.dart';
import 'package:provider/provider.dart';

import '../app_translations.dart';

class EsBusinessCatalogueListView extends StatelessWidget {
  final ProductFilters filter;
  const EsBusinessCatalogueListView(this.filter, {Key key}) : super(key: key);

  String getTile(BuildContext context) {
    switch (filter) {
      case ProductFilters.outOfStock:
        return AppTranslations.of(context)
            .text('business_catalogue_page_out_of_stock');
      case ProductFilters.spotlights:
        return AppTranslations.of(context)
            .text('business_catalogue_page_spotlights');
      case ProductFilters.listView:
      default:
        return AppTranslations.of(context)
            .text('business_catalogue_page_all_products');
    }
  }

  @override
  Widget build(BuildContext context) {
    final esProductBloc = Provider.of<EsProductsBloc>(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      esProductBloc.getProducts(filter);
    });
    final title = getTile(context);
    return StreamBuilder<EsProductsState>(
        stream: esProductBloc.esProductStateObservable,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }
          if (snapshot.data.getProductsLoadingStatus(filter) ==
              DataState.LOADING) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.data.getProductsLoadingStatus(filter) ==
              DataState.FAILED) {
            return SomethingWentWrong(onRetry: () {
              esProductBloc.getProducts(filter);
            });
          } else if (snapshot.data.getProducts(filter).length == 0) {
            return EmptyList(
              titleText: AppTranslations.of(context)
                  .text('products_page_no_products_found'),
            );
          }
          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
                esProductBloc.loadMore(filter: filter);
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
              itemCount: snapshot.data.getProducts(filter).length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    if (index == 0)
                      ProductListHeaderTitle(
                        title: title,
                        productsState: snapshot.data,
                        esBusinessCatalogueBloc: esProductBloc,
                        filter: filter,
                      ),
                    EsBusinessCatalogueProductTile(
                        filter, snapshot.data.getProducts(filter)[index]),
                  ],
                );
              },
            ),
          );
        });
  }
}

class ProductListHeaderTitle extends StatelessWidget {
  const ProductListHeaderTitle({
    Key key,
    @required this.title,
    @required this.productsState,
    @required this.esBusinessCatalogueBloc,
    @required this.filter,
  }) : super(key: key);

  final String title;
  final EsProductsState productsState;
  final EsProductsBloc esBusinessCatalogueBloc;
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
          PopupMenuButton<ProductSorting>(
            child: ImageIcon(
              AssetImage('assets/icons/sort.png'),
              color: Theme.of(context).primaryColor,
            ),
            onSelected: (sorting) {
              esBusinessCatalogueBloc.setSorting(filter, sorting);
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<ProductSorting>>[
              PopupMenuItem(
                value: ProductSorting.recentlyUpdatedAcending,
                child: Text(
                  AppTranslations.of(context)
                      .text('business_catalogue_page_recently_updated'),
                  style: TextStyle(
                      color: productsState.selectedSorting ==
                              ProductSorting.recentlyUpdatedAcending
                          ? Colors.black87
                          : Colors.black26),
                ),
              ),
              PopupMenuItem(
                value: ProductSorting.alphabaticallyAcending,
                child: Text(
                  AppTranslations.of(context)
                      .text('business_catalogue_page_a_to_z'),
                  style: TextStyle(
                      color: productsState.selectedSorting ==
                              ProductSorting.alphabaticallyAcending
                          ? Colors.black87
                          : Colors.black26),
                ),
              ),
              PopupMenuItem(
                value: ProductSorting.ratingDecending,
                child: Text(
                  AppTranslations.of(context)
                      .text('business_catalogue_page_rating_high_to_low'),
                  style: TextStyle(
                      color: productsState.selectedSorting ==
                              ProductSorting.ratingDecending
                          ? Colors.black87
                          : Colors.black26),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}