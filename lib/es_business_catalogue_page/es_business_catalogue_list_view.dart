import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/data/bloc/es_products.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_product.dart';
import 'package:foore/data/model/es_product_catalogue.dart';
import 'package:foore/es_product_detail_page/es_product_detail_page.dart';
import 'package:foore/widgets/empty_list.dart';
import 'package:foore/widgets/something_went_wrong.dart';
import 'package:provider/provider.dart';

import '../app_translations.dart';

class EsBusinessCatalogueListView extends StatefulWidget {
  final ProductFilters filter;

  EsBusinessCatalogueListView(this.filter, {Key key}) : super(key: key);

  _EsBusinessCatalogueListViewState createState() =>
      _EsBusinessCatalogueListViewState();
}

class _EsBusinessCatalogueListViewState
    extends State<EsBusinessCatalogueListView> {
  EsProductsBloc esBusinessCatalogueBloc;

  @override
  void didChangeDependencies() {
    final httpService = Provider.of<HttpService>(context);
    final businessBloc = Provider.of<EsBusinessesBloc>(context);
    this.esBusinessCatalogueBloc = EsProductsBloc(httpService, businessBloc);
    this.esBusinessCatalogueBloc.setFilter(widget.filter);
    this.esBusinessCatalogueBloc.getProducts();
    super.didChangeDependencies();
  }

  String getTile(BuildContext context) {
    switch (widget.filter) {
      case ProductFilters.outOfStock:
        return 'Out of Stock';
      case ProductFilters.spotlights:
        return 'Sportlights';
      case ProductFilters.listView:
      default:
        return 'All Products';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = getTile(context);
    return Provider<EsProductsBloc>(
      create: (context) => this.esBusinessCatalogueBloc,
      dispose: (context, value) => value.dispose(),
      child: StreamBuilder<EsProductsState>(
          stream: this.esBusinessCatalogueBloc.esProductStateObservable,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            if (snapshot.data.isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.data.isLoadingFailed) {
              return SomethingWentWrong(
                onRetry: this.esBusinessCatalogueBloc.getProducts,
              );
            } else if (snapshot.data.products.length == 0) {
              return EmptyList(
                titleText: AppTranslations.of(context)
                    .text('products_page_no_products_found'),
              );
            }
            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
                  esBusinessCatalogueBloc.loadMore();
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
                itemCount: snapshot.data.products.length,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(),
                            ),
                            Text(
                              title + snapshot.data.getNumberOfProducts(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                            ),
                            Expanded(
                              child: Container(),
                            ),
                            PopupMenuButton<ProductSorting>(
                              child: Icon(
                                Icons.sort,
                                color: Theme.of(context).primaryColorDark,
                              ),
                              onSelected: esBusinessCatalogueBloc.setSorting,
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<ProductSorting>>[
                                PopupMenuItem(
                                  value: ProductSorting.recentlyUpdatedAcending,
                                  child: Text(
                                    'Recently Updated',
                                    style: TextStyle(
                                        color: snapshot.data.selectedSorting ==
                                                ProductSorting
                                                    .recentlyUpdatedAcending
                                            ? Colors.black87
                                            : Colors.black26),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: ProductSorting.alphabaticallyAcending,
                                  child: Text(
                                    'A - Z',
                                    style: TextStyle(
                                        color: snapshot.data.selectedSorting ==
                                                ProductSorting
                                                    .alphabaticallyAcending
                                            ? Colors.black87
                                            : Colors.black26),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: ProductSorting.ratingDecending,
                                  child: Text(
                                    'Rating (High to Low)',
                                    style: TextStyle(
                                        color: snapshot.data.selectedSorting ==
                                                ProductSorting.ratingDecending
                                            ? Colors.black87
                                            : Colors.black26),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 19.0,
                        ),
                        _Product(snapshot.data.products[index]),
                      ],
                    );
                  }
                  return _Product(snapshot.data.products[index]);
                },
              ),
            );
          }),
    );
  }
}

class _Product extends StatelessWidget {
  final EsBusinessCatalogueProduct businessCatalogueProduct;
  const _Product(
    this.businessCatalogueProduct, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final esBusinessCatalogueBloc = Provider.of<EsProductsBloc>(context);
    viewItem() async {
      EsProductDetailPageParam esProductDetailPageParam =
          EsProductDetailPageParam(
              currentProduct: businessCatalogueProduct.product,
              openSkuAddUpfront: false);
      await Navigator.of(context).pushNamed(EsProductDetailPage.routeName,
          arguments: esProductDetailPageParam);
      esBusinessCatalogueBloc.getProducts();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
          onTap: viewItem,
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
                          errorWidget: (_, __, ___) => Container(),
                          placeholder: (_, __) => Container(),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.all(0.0),
                    title: Text(
                      businessCatalogueProduct.product.dProductName,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    esBusinessCatalogueBloc.expandProduct(
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
          SizedBox(
            height: 8.0,
          ),
          ...businessCatalogueProduct.product.skus.map((e) => _Sku(e)).toList()
        ],
        SizedBox(
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
      padding: const EdgeInsets.only(left: 60.0, bottom: 8.0),
      child: Material(
        elevation: 1.0,
        borderRadius: BorderRadius.circular(6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 2),
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
                margin: const EdgeInsets.only(bottom: 2),
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
    );
  }
}
