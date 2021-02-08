import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_business_catalogue.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_categories.dart';
import 'package:foore/data/model/es_product.dart';
import 'package:foore/data/model/es_product_catalogue.dart';
import 'package:foore/widgets/empty_list.dart';
import 'package:foore/widgets/something_went_wrong.dart';
import 'package:provider/provider.dart';

import '../app_translations.dart';

class EsBusinessCataloguePage extends StatefulWidget {
  static const routeName = '/business_catalogue';

  EsBusinessCataloguePage({Key key}) : super(key: key);

  _EsBusinessCataloguePageState createState() =>
      _EsBusinessCataloguePageState();
}

class _EsBusinessCataloguePageState extends State<EsBusinessCataloguePage> {
  EsBusinessCatalogueBloc esBusinessCatalogueBloc;

  @override
  void didChangeDependencies() {
    final httpService = Provider.of<HttpService>(context);
    final businessBloc = Provider.of<EsBusinessesBloc>(context);
    this.esBusinessCatalogueBloc =
        EsBusinessCatalogueBloc(httpService, businessBloc);
    this.esBusinessCatalogueBloc.getCategories();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<EsBusinessCatalogueBloc>(
      create: (context) => this.esBusinessCatalogueBloc,
      dispose: (context, value) => value.dispose(),
      child: Scaffold(
        body: StreamBuilder<EsBusinessCatalogueState>(
            stream: this.esBusinessCatalogueBloc.esOrdersStateObservable,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              if (snapshot.data.categoriesLoadingStatus == DataState.LOADING) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.data.categoriesLoadingStatus ==
                  DataState.FAILED) {
                return SomethingWentWrong(
                  onRetry: this.esBusinessCatalogueBloc.getCategories,
                );
              } else if (snapshot.data.parentCategories.length == 0) {
                return EmptyList(
                  titleText: AppTranslations.of(context)
                      .text('products_page_no_products_found'),
                  subtitleText: AppTranslations.of(context)
                      .text('products_page_no_products_found_description'),
                );
              }
              return SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 8.0,
                    ),
                    Flexible(
                      flex: 4,
                      child: Material(
                        elevation: 2,
                        child: ListView.builder(
                          itemCount: snapshot.data.parentCategories.length,
                          itemBuilder: (context, index) {
                            return ParentCategory(
                                snapshot.data.parentCategories[index],
                                snapshot.data.getIsParentCategorySelected(
                                    snapshot.data.parentCategories[index]
                                        .categoryId));
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 16.0,
                    ),
                    Flexible(
                      flex: 9,
                      child: ListView.builder(
                        itemCount: snapshot.data.subCategories.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return SubCategory(
                            snapshot.data.subCategories[index],
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }
}

class ParentCategory extends StatelessWidget {
  final EsCategory parentCategory;
  final bool isSelected;
  const ParentCategory(this.parentCategory, this.isSelected, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final esBusinessCatalogueBloc =
        Provider.of<EsBusinessCatalogueBloc>(context);
    return InkWell(
      onTap: () {
        esBusinessCatalogueBloc.selectParentCategory(parentCategory.categoryId);
      },
      child: Container(
        color: isSelected ? Colors.blue : null,
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.only(bottom: 2),
        child: Text(
          parentCategory.categoryName,
          style: Theme.of(context).textTheme.bodyText2.copyWith(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).primaryColorDark,
              ),
        ),
      ),
    );
  }
}

class SubCategory extends StatelessWidget {
  final EsCategory subCategory;
  const SubCategory(
    this.subCategory, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final esBusinessCatalogueBloc =
        Provider.of<EsBusinessCatalogueBloc>(context);
    esBusinessCatalogueBloc.getProductsList(subCategory.categoryId);
    return StreamBuilder<EsBusinessCatalogueState>(
      stream: esBusinessCatalogueBloc.esOrdersStateObservable,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                subCategory.categoryName +
                    snapshot.data
                        .getNumberOfProducts(this.subCategory.categoryId),
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: Theme.of(context).primaryColorDark,
                    ),
              ),
            ),
            ...snapshot.data
                .getProductListForSubCategory(subCategory.categoryId)
                .map((e) => Product(e))
                .toList(),
            if (snapshot.data
                .getIsShowNextPageForProducts(subCategory.categoryId))
              InkWell(
                onTap: () {
                  esBusinessCatalogueBloc
                      .getProductsNextPage(subCategory.categoryId);
                },
                child: Material(
                  elevation: 2,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'See more items',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.caption.copyWith(
                            color: Theme.of(context).primaryColorDark,
                          ),
                    ),
                  ),
                ),
              ),
            SizedBox(
              height: 12.0,
            ),
          ],
        );
      },
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
    final esBusinessCatalogueBloc =
        Provider.of<EsBusinessCatalogueBloc>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Material(
          elevation: 2.0,
          child: ListTile(
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
