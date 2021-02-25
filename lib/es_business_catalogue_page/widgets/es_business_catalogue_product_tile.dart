import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_business_catalogue.dart';
import 'package:foore/data/bloc/es_products.dart';
import 'package:foore/data/model/es_product.dart';
import 'package:foore/data/model/es_product_catalogue.dart';
import 'package:foore/es_product_detail_page/es_product_detail_page.dart';
import 'package:foore/utils/utils.dart';
import 'package:provider/provider.dart';

class EsBusinessCatalogueProductTile extends StatelessWidget {
  final EsBusinessCatalogueProduct businessCatalogueProduct;
  final ProductFilters filter;
  const EsBusinessCatalogueProductTile(
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
    esProductBloc.reloadProducts(filter);
    // TODO: We need a better way to handle this.
    Provider.of<EsBusinessCatalogueBloc>(context).resetDataState();
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
                          // TODO: Update the placeholder image.
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
