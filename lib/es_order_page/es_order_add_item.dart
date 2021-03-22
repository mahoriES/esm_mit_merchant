import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/data/bloc/es_products.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_orders.dart';
import 'package:foore/data/model/es_product.dart';
import 'package:foore/es_product_detail_page/es_product_detail_page.dart';
import 'package:foore/menu_page/menu_item.dart';
import 'package:foore/menu_page/menu_searchbar.dart';
import 'package:foore/widgets/empty_list.dart';
import 'package:foore/es_order_page/widgets/select_variation_dialogue.dart';
import 'package:foore/widgets/something_went_wrong.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';

import '../app_translations.dart';

class EsOrderAddItem extends StatefulWidget {
  static const routeName = '/addOrderItem';

  _EsOrderAddItemState createState() => _EsOrderAddItemState();
}

class _EsOrderAddItemState extends State<EsOrderAddItem> {
  EsProductsBloc esProductsBloc;
  Map<int, EsOrderItem> selectedItems;

  @override
  void initState() {
    selectedItems = {};
    super.initState();
  }

  @override
  void dispose() {
    this.esProductsBloc.resetDataState();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    final httpService = Provider.of<HttpService>(context);
    final businessBloc = Provider.of<EsBusinessesBloc>(context);
    if (this.esProductsBloc == null) {
      this.esProductsBloc = EsProductsBloc(httpService, businessBloc);
    }
    this.esProductsBloc.getProductsFromSearch();
    super.didChangeDependencies();
  }

  _addItem(
    int index,
    EsProduct currentProduct,
  ) async {
    if (selectedItems.containsKey(index)) {
      selectedItems.remove(index);
    } else {
      if (currentProduct.skus.length > 1) {
        await showDialog(
          context: context,
          builder: (context) => SelectVariationDialogue(
            currentProduct,
            (int skuIndex) {
              if (skuIndex >= 0) {
                selectedItems[index] = EsOrderItem(
                  productName: currentProduct?.productName ?? '',
                  itemQuantity: 1,
                  unitPrice:
                      (currentProduct?.skus[skuIndex].basePrice.toDouble() /
                              100) ??
                          0,
                  skuId: currentProduct.skus[skuIndex].skuId.toString(),
                  itemStatus: CatalogueItemStatus.createdByMerchant,
                );
              }
            },
          ),
        );
      } else {
        selectedItems[index] = EsOrderItem(
          productName: currentProduct?.productName ?? '',
          itemQuantity: 1,
          unitPrice:
              currentProduct.skus != null && currentProduct.skus.isNotEmpty
                  ? ((currentProduct?.skus[0].basePrice.toDouble() / 100) ?? 0)
                  : 0,
          skuId: currentProduct.skus != null && currentProduct.skus.isNotEmpty
              ? currentProduct.skus[0].skuId.toString()
              : '',
          itemStatus: CatalogueItemStatus.createdByMerchant,
        );
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    addProduct() async {
      EsProductDetailPageParam esProductDetailPageParam =
          EsProductDetailPageParam();
      await Navigator.of(context).pushNamed(
        EsProductDetailPage.routeName,
        arguments: esProductDetailPageParam,
      );
      esProductsBloc.getProductsFromSearch();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.of(context).text("products_page_add_item")),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              addProduct();
            },
          )
        ],
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: <Widget>[
              MenuSearchBar(this.esProductsBloc),
              Expanded(
                child: StreamBuilder<EsProductsState>(
                    stream: this.esProductsBloc.esProductStateObservable,
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
                          onRetry: this.esProductsBloc.getProductsFromSearch,
                        );
                      } else if (snapshot.data.items.length == 0) {
                        return EmptyList(
                          titleText: AppTranslations.of(context)
                              .text('products_page_no_products_found'),
                          subtitleText: AppTranslations.of(context).text(
                              'products_page_no_products_found_description'),
                        );
                      } else {
                        return NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent) {
                              this.esProductsBloc.loadMore();
                            }
                            return false;
                          },
                          child: ListView.builder(
                              padding: EdgeInsets.only(
                                bottom: 72,
                                // top: 30,
                              ),
                              itemCount: snapshot.data.items.length,
                              itemBuilder: (context, index) {
                                if (snapshot.data.items.length == index) {
                                  if (snapshot.data.isLoadingMore) {
                                    return Container(
                                      margin: EdgeInsets.all(4.0),
                                      height: 36,
                                      width: 36,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                }
                                final currentProduct =
                                    snapshot.data.items[index];
                                return MenuItemWidget(
                                  esProduct: currentProduct,
                                  onAdd: () => _addItem(index, currentProduct),
                                  isAddOrderItem: true,
                                  isItemAdded: selectedItems.containsKey(index),
                                );
                              }),
                        );
                      }
                    }),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: selectedItems.length == 0
          ? null
          : Transform.translate(
              offset: Offset(0, -15),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 25,
                ),
                onPressed: () async {
                  List<EsOrderItem> _items = [];
                  selectedItems.forEach((key, value) {
                    _items.add(value);
                  });
                  Navigator.of(context).pop(_items);
                },
                child: Container(
                  child: Text(
                    sprintf(
                        AppTranslations.of(context)
                            .text('products_page_add_n_item'),
                        [selectedItems.length]),
                    style: Theme.of(context).textTheme.subhead.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
