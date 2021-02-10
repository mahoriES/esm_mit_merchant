import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_business_catalogue.dart';
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
  EsBusinessCatalogueListView({Key key}) : super(key: key);

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
    this.esBusinessCatalogueBloc.getProductsFromSearch();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
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
                onRetry: this.esBusinessCatalogueBloc.getProductsFromSearch,
              );
            } else if (snapshot.data.products.length == 0) {
              return EmptyList(
                titleText: AppTranslations.of(context)
                    .text('products_page_no_products_found'),
                subtitleText: AppTranslations.of(context)
                    .text('products_page_no_products_found_description'),
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
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                itemCount: snapshot.data.products.length,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'All Products' +
                                snapshot.data.getNumberOfProducts(),
                            style:
                                Theme.of(context).textTheme.subtitle1.copyWith(
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                          ),
                        ),
                        Product(snapshot.data.products[index]),
                      ],
                    );
                  }
                  return Product(snapshot.data.products[index]);
                },
              ),
            );
          }),
    );
  }
}

class Product extends StatelessWidget {
  final EsBusinessCatalogueProduct businessCatalogueProduct;
  const Product(
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
      var result = await Navigator.of(context).pushNamed(
          EsProductDetailPage.routeName,
          arguments: esProductDetailPageParam);
      esBusinessCatalogueBloc.getProductsFromSearch();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Material(
          elevation: 2.0,
          child: ListTile(
            onTap: viewItem,
            contentPadding: EdgeInsets.all(8.0),
            dense: true,
            leading: Material(
              elevation: 1.0,
              borderRadius: BorderRadius.circular(4.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Container(
                  height: 60,
                  width: 60,
                  child: CachedNetworkImage(
                    imageUrl: businessCatalogueProduct.product.dPhotoUrl ?? '',
                    fit: BoxFit.fill,
                    errorWidget: (_, __, ___) => Container(),
                    placeholder: (_, __) => Container(),
                  ),
                ),
              ),
            ),
            title: Text(businessCatalogueProduct.product.dProductName),
            trailing: InkWell(
              onTap: () {
                esBusinessCatalogueBloc.expandProduct(
                    businessCatalogueProduct.product.productId,
                    !businessCatalogueProduct.isExpanded);
              },
              child: Container(
                height: 28.0,
                width: 32.0,
                child: Row(
                  children: [
                    Container(
                      color: Colors.black12,
                      height: 16.0,
                      width: 1.0,
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Transform.rotate(
                      angle: businessCatalogueProduct.isExpanded ? pi / 2 : 0,
                      child: Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 8.0,
        ),
        if (businessCatalogueProduct.isExpanded)
          ...businessCatalogueProduct.product.skus.map((e) => Sku(e)).toList(),
        SizedBox(
          height: 8.0,
        ),
      ],
    );
  }
}

class Sku extends StatelessWidget {
  final EsSku sku;
  const Sku(
    this.sku, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 28.0, bottom: 8.0),
      child: Material(
        elevation: 2.0,
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 2),
                child: Text(
                  sku.variationValue,
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
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 2),
                child: Text(
                  sku.dBasePrice,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
