import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_business_catalogue.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_categories.dart';
import 'package:foore/data/model/es_product.dart';
import 'package:foore/data/model/es_product_catalogue.dart';
import 'package:foore/es_product_detail_page/es_product_detail_page.dart';
import 'package:foore/widgets/empty_list.dart';
import 'package:foore/widgets/something_went_wrong.dart';
import 'package:provider/provider.dart';

import '../app_translations.dart';

class EsBusinessCatalogueTreeView extends StatefulWidget {
  static const routeName = '/business_catalogue';

  EsBusinessCatalogueTreeView({Key key}) : super(key: key);

  _EsBusinessCatalogueTreeViewState createState() =>
      _EsBusinessCatalogueTreeViewState();
}

class _EsBusinessCatalogueTreeViewState
    extends State<EsBusinessCatalogueTreeView> {
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
      child: StreamBuilder<EsBusinessCatalogueState>(
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
                      .text('business_catalogue_page_no_categories'));
            }
            return SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 8.0,
                  ),
                  Flexible(
                    flex: 6,
                    child: Material(
                      elevation: 2,
                      child: ListView.builder(
                        itemCount: snapshot.data.parentCategories.length,
                        itemBuilder: (context, index) {
                          return _ParentCategory(
                            snapshot.data.parentCategories[index],
                            snapshot.data.getIsParentCategorySelected(snapshot
                                .data.parentCategories[index].categoryId),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 16.0,
                  ),
                  Flexible(
                    flex: 17,
                    child: snapshot.data.subCategories.length == 0
                        ? Container(
                            height: MediaQuery.of(context).size.height,
                            width: 500,
                            child: EmptyList(
                                titleText: AppTranslations.of(context)
                                    .text('business_catalogue_page_no_sub_categories')),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.only(bottom: 72.0),
                            itemCount: snapshot.data.subCategories.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return _SubCategory(
                                snapshot.data.subCategories[index],
                              );
                            },
                          ),
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                ],
              ),
            );
          }),
    );
  }
}

class _ParentCategory extends StatelessWidget {
  final EsCategory parentCategory;
  final bool isSelected;
  const _ParentCategory(this.parentCategory, this.isSelected, {Key key})
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
        margin: const EdgeInsets.only(bottom: 2),
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

class _SubCategory extends StatelessWidget {
  final EsCategory subCategory;
  const _SubCategory(
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
              padding: const EdgeInsets.all(16.0),
              child: Text(
                subCategory.categoryName +
                    snapshot.data
                        .getNumberOfProducts(this.subCategory.categoryId),
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: Theme.of(context).primaryColorDark,
                    ),
              ),
            ),
            if (snapshot.data
                    .getProductsLoadingStatus(this.subCategory.categoryId) ==
                DataState.LOADING)
              CircularProgressIndicator(),
            ...snapshot.data
                .getProductListForSubCategory(subCategory.categoryId)
                .map((e) => _Product(e))
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
                      AppTranslations.of(context)
                          .text('business_catalogue_page_see_more_products'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.caption.copyWith(
                            color: Theme.of(context).primaryColorDark,
                          ),
                    ),
                  ),
                ),
              ),
            if (snapshot.data.getIsShowLoadingNextPageForProducts(
                this.subCategory.categoryId))
              CircularProgressIndicator(),
            const SizedBox(
              height: 12.0,
            ),
          ],
        );
      },
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
    final esBusinessCatalogueBloc =
        Provider.of<EsBusinessCatalogueBloc>(context);
    viewItem() async {
      EsProductDetailPageParam esProductDetailPageParam =
          EsProductDetailPageParam(
              currentProduct: businessCatalogueProduct.product,
              openSkuAddUpfront: false);
      await Navigator.of(context).pushNamed(EsProductDetailPage.routeName,
          arguments: esProductDetailPageParam);
      esBusinessCatalogueBloc.getCategories();
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
                  padding: EdgeInsets.symmetric(horizontal: 12),
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
                  padding: EdgeInsets.symmetric(horizontal: 12),
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
