import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_products.dart';
import 'package:foore/data/model/es_product.dart';
import 'package:foore/data/model/es_product_catalogue.dart';
import 'package:foore/es_product_detail_page/es_product_detail_page.dart';
import 'package:foore/utils/utils.dart';
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
                    _Product(filter, snapshot.data.getProducts(filter)[index]),
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
            child: Icon(
              Icons.sort,
              color: Theme.of(context).primaryColorDark,
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

class _Product extends StatelessWidget {
  final EsBusinessCatalogueProduct businessCatalogueProduct;
  final ProductFilters filter;
  const _Product(
    this.filter,
    this.businessCatalogueProduct, {
    Key key,
  }) : super(key: key);

  viewItem(EsProductsBloc esProductBloc, BuildContext context) async {
    EsProductDetailPageParam esProductDetailPageParam =
        EsProductDetailPageParam(
            currentProduct: businessCatalogueProduct.product,
            openSkuAddUpfront: false);
    await Navigator.of(context).pushNamed(EsProductDetailPage.routeName,
        arguments: esProductDetailPageParam);
    esProductBloc.getProducts(filter);
  }

  @override
  Widget build(BuildContext context) {
    final esProductBloc = Provider.of<EsProductsBloc>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            viewItem(esProductBloc, context);
          },
          child: Material(
            elevation: 1.0,
            borderRadius: BorderRadius.circular(6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(11.0),
                  child: Material(
                    elevation: 1.0,
                    borderRadius: BorderRadius.circular(6.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6.0),
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: CachedNetworkImage(
                          imageUrl:
                              businessCatalogueProduct.product.dPhotoUrl ?? '',
                          fit: BoxFit.fill,
                          errorWidget: (_, __, ___) => placeHolderImage,
                          placeholder: (_, __) => Container(),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      businessCatalogueProduct.product.dProductName,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    esProductBloc.expandProduct(
                        filter,
                        businessCatalogueProduct.product.productId,
                        !businessCatalogueProduct.isExpanded);
                  },
                  child: Container(
                    height: 72.0,
                    width: 60.0,
                    child: Row(
                      children: [
                        Container(
                          color: Colors.black12,
                          height: 30.0,
                          width: 1.0,
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        Transform.rotate(
                          angle:
                              businessCatalogueProduct.isExpanded ? pi / 2 : 0,
                          child: Icon(
                            Icons.chevron_right,
                            size: 32,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (businessCatalogueProduct.isExpanded) ...[
          const SizedBox(
            height: 8.0,
          ),
          ...businessCatalogueProduct.product.skus.map((e) => _Sku(e)).toList()
        ],
        const SizedBox(
          height: 16.0,
        ),
      ],
    );
  }
}

class _Sku extends StatelessWidget {
  final EsSku sku;
  const _Sku(
    this.sku, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40.0, bottom: 8.0),
      child: Material(
        elevation: 1.0,
        borderRadius: BorderRadius.circular(6.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    sku.dVariationValue,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Container(
                color: Colors.black12,
                height: 16.0,
                width: 1.0,
              ),
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    sku.dBasePrice,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                          color: Theme.of(context).primaryColorDark,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
