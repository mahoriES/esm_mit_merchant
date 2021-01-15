import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/data/bloc/es_edit_product.dart';
import 'package:foore/data/model/es_categories.dart';
import 'package:foore/data/model/es_product.dart';
import 'package:foore/es_category_page/es_category_page.dart';
import 'package:provider/provider.dart';

import 'es_edit_product_image_list.dart';
import 'es_edit_product_name.dart';
import 'es_edit_product_unit.dart';
import 'es_edit_product_variation.dart';

class EsProductDetailPageParam {
  final EsProduct currentProduct;
  //if this is true, we push directly to add sku item
  final bool openSkuAddUpfront;
  EsProductDetailPageParam({this.currentProduct, this.openSkuAddUpfront});
}

class EsProductDetailPage extends StatefulWidget {
  static const routeName = '/view-menu-item';
  final EsProduct currentProduct;
  //if this is true, we push directly to add sku item
  final bool openSkuAddUpfront;

  EsProductDetailPage(this.currentProduct, {this.openSkuAddUpfront = false});

  @override
  EsProductDetailPageState createState() => EsProductDetailPageState();
}

class EsProductDetailPageState extends State<EsProductDetailPage>
    with AfterLayoutMixin<EsProductDetailPage> {
  final _formKey = GlobalKey<FormState>();

  Future<bool> _onWillPop() async {
    Navigator.pop(context);
    return false;
  }

  // todo Move this function to a common place.
  _showFailedAlertDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: true, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Submit failed'),
          content: const Text('Please try again.'),
          actions: <Widget>[
            FlatButton(
              child: const Text('Dismiss'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final esEditProductBloc = Provider.of<EsEditProductBloc>(context);
    esEditProductBloc.setCurrentProduct(widget.currentProduct);
    esEditProductBloc.getCategories();
    if (widget.openSkuAddUpfront) {
      //This page was called because the person added a
      //new product and now we want to add SKU for product directly
      addSku(esEditProductBloc);
    }
    esEditProductBloc.esEditProductStateObservable.listen((event) {
      if (event.isSubmitFailed) {
        this._showFailedAlertDialog();
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  addSku(EsEditProductBloc esEditProductBloc) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            EsEditProductVariationPage(esEditProductBloc, null)));
  }

  @override
  Widget build(BuildContext context) {
    final esEditProductBloc = Provider.of<EsEditProductBloc>(context);
    addCategory(List<int> preSelectedCategories) async {
      var selectedCategories = await Navigator.of(context).pushNamed(
          EsCategoryPage.routeName,
          arguments: preSelectedCategories);
      if (selectedCategories != null) {
        esEditProductBloc.putCategoriesToProduct(selectedCategories);
      }
    }

    removeCategory(EsCategory category) {
      esEditProductBloc.removeCategoryFromProduct(category);
    }

    submit() {
      if (this._formKey.currentState.validate()) {
        esEditProductBloc.addProduct((EsProduct product) {
          Navigator.of(context).pop(product);
        });
      }
    }

    editName() async {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => EsEditProductNamePage(esEditProductBloc)));
    }

    editUnit() async {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => EsEditProductUnitPage(esEditProductBloc)));
    }

    editSku(EsSku sku) async {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              EsEditProductVariationPage(esEditProductBloc, sku)));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.currentProduct.dProductName,
        ),
      ),
      body: StreamBuilder<EsEditProductState>(
          stream: esEditProductBloc.esEditProductStateObservable,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            return Form(
              key: _formKey,
              onWillPop: _onWillPop,
              child: Scrollbar(
                child: ListView(
                  children: <Widget>[
                    EsEditProductImageList(esEditProductBloc),
                    Container(
                      padding: const EdgeInsets.only(
                        top: 20.0,
                        left: 20,
                        right: 20,
                        bottom: 4,
                        // bottom: 8.0,
                      ),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        AppTranslations.of(context).text('products_page_name'),
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ),
                    Container(
                      child: snapshot.data.currentProduct.dProductName == ''
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                FlatButton(
                                  onPressed: editName,
                                  child: Text(
                                    AppTranslations.of(context)
                                        .text('products_page_add_name'),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      snapshot.data.currentProduct.dProductName,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: editName,
                                    icon: Icon(
                                      Icons.edit,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )
                                ],
                              ),
                            ),
                    ),
                    // Container(
                    //   padding: const EdgeInsets.only(
                    //     top: 24.0,
                    //     left: 20,
                    //     right: 20,
                    //     bottom: 4,
                    //     // bottom: 8.0,
                    //   ),
                    //   alignment: Alignment.bottomLeft,
                    //   child: Text(
                    //     AppTranslations.of(context).text('products_page_unit'),
                    //     style: Theme.of(context).textTheme.subtitle2,
                    //   ),
                    // ),
                    // Container(
                    //   child: snapshot.data.currentProduct.dUnit == ''
                    //       ? Row(
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: <Widget>[
                    //             FlatButton(
                    //               onPressed: editUnit,
                    //               child: Text(
                    //                 AppTranslations.of(context)
                    //                     .text('products_page_add_unit'),
                    //                 overflow: TextOverflow.ellipsis,
                    //               ),
                    //             ),
                    //           ],
                    //         )
                    //       : Padding(
                    //           padding:
                    //               const EdgeInsets.symmetric(horizontal: 20),
                    //           child: Row(
                    //             crossAxisAlignment: CrossAxisAlignment.center,
                    //             children: <Widget>[
                    //               Expanded(
                    //                 child: Text(
                    //                   snapshot.data.currentProduct.dUnit,
                    //                   overflow: TextOverflow.ellipsis,
                    //                   style:
                    //                       Theme.of(context).textTheme.subtitle1,
                    //                 ),
                    //               ),
                    //               IconButton(
                    //                 onPressed: editUnit,
                    //                 icon: Icon(
                    //                   Icons.edit,
                    //                   color: Theme.of(context).primaryColor,
                    //                 ),
                    //               )
                    //             ],
                    //           ),
                    //         ),
                    // ),
//////////////////////////////////////////////////
                    Container(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 20,
                        right: 20,
                        bottom: 8,
                        // bottom: 8.0,
                      ),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        AppTranslations.of(context)
                            .text('products_page_categories'),
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Wrap(
                              children: List.generate(
                                  snapshot.data.categories.length + 1, (index) {
                                if (index == snapshot.data.categories.length) {
                                  return InkWell(
                                    onTap: () {
                                      addCategory(snapshot.data.categories
                                          .map((e) => e.categoryId)
                                          .toList());
                                    },
                                    child: Chip(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      avatar: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        AppTranslations.of(context)
                                            .text('products_page_add_category'),
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .copyWith(color: Colors.white),
                                      ),
                                    ),
                                  );
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Chip(
                                    onDeleted: () {
                                      removeCategory(
                                          snapshot.data.categories[index]);
                                    },
                                    label: Text(
                                      snapshot
                                          .data.categories[index].dCategoryName,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Divider(
                      //height: 8,
                      thickness: 4,
                      //color: Colors.blue,
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        top: 16.0,
                        left: 20,
                        right: 20,
                        bottom: 8,
                        // bottom: 8.0,
                      ),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        AppTranslations.of(context)
                            .text('products_page_variations'),
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        top: 10.0,
                        left: 20,
                        right: 20,
                        bottom: 8,
                        // bottom: 8.0,
                      ),
                      // alignment: Alignment.bottomLeft,
                      child: Table(
                        children: List.generate(
                            snapshot.data.currentProduct.skus != null
                                ? widget.currentProduct.skus.length + 1
                                : 0, (index) {
                          if (snapshot.data.currentProduct.skus == null ||
                              widget.currentProduct.skus.length == index) {
                            return TableRow(children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  FlatButton(
                                    onPressed: () {
                                      addSku(esEditProductBloc);
                                    },
                                    child: Text(
                                      '+ ' +
                                          AppTranslations.of(context).text(
                                              'products_page_add_variation'),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ]);
                          }

                          return TableRow(children: [
                            VariationCard(
                              snapshot.data.currentProduct.skus[index],
                              esEditProductBloc,
                              editSku,
                            ),
                          ]);
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}

class VariationCard extends StatelessWidget {
  final EsSku sku;
  final EsEditProductBloc esEditProductBloc;
  final Function(EsSku sku) onSkuClick;
  const VariationCard(
    this.sku,
    this.esEditProductBloc,
    this.onSkuClick, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        bottom: 10,
        right: 20,
        left: 20,
      ),
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                (sku.variationValue != null) && sku.variationValue.isNotEmpty
                    ? Text(sku.dBasePrice + " (" + sku.variationValue + ")")
                    : Text(sku.dBasePrice),
                SizedBox(height: 4),
                Text(
                  sku.skuCode,
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    Text(
                      sku.inStock
                          ? AppTranslations.of(context)
                              .text('products_page_in_stock')
                          : AppTranslations.of(context)
                              .text('products_page_not_in_stock'),
                      style: TextStyle(
                          color: sku.inStock
                              ? Colors.green[400]
                              : Colors.red[400]),
                    ),
                    SizedBox(width: 16),
                    Text(
                      sku.isActive
                          ? AppTranslations.of(context)
                              .text('products_page_is_active')
                          : AppTranslations.of(context)
                              .text('products_page_not_active'),
                      style: TextStyle(
                          color: sku.isActive
                              ? Colors.green[400]
                              : Colors.red[400]),
                    ),
                  ],
                )
              ],
            ),
          ),
          IconButton(
              color: Theme.of(context).primaryColor,
              icon: Icon(Icons.edit),
              onPressed: () {
                this.onSkuClick(this.sku);
              })
        ],
      ),
    );
  }
}
