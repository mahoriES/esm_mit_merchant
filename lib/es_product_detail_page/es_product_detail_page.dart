import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_edit_product.dart';
import 'package:foore/data/model/es_categories.dart';
import 'package:foore/data/model/es_product.dart';
import 'package:foore/es_category_page/es_category_page.dart';
import 'package:provider/provider.dart';

import 'es_edit_product_display_line_1.dart';
import 'es_edit_product_image_list.dart';
import 'es_edit_product_long_description.dart';
import 'es_edit_product_name.dart';
import 'es_edit_product_short_description.dart';
import 'es_edit_product_unit.dart';
import 'es_edit_product_variation.dart';

class EsProductDetailPage extends StatefulWidget {
  static const routeName = '/view-menu-item';
  final EsProduct currentProduct;

  EsProductDetailPage(this.currentProduct);

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

  @override
  Widget build(BuildContext context) {
    final esEditProductBloc = Provider.of<EsEditProductBloc>(context);

    addCategory() async {
      var selectedCategories =
          await Navigator.of(context).pushNamed(EsCategoryPage.routeName);
      if (selectedCategories != null) {
        esEditProductBloc.addCategoriesToProduct(selectedCategories);
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

    editShortDescription() async {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              EsEditProductShortDescriptionPage(esEditProductBloc)));
    }

    editName() async {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => EsEditProductNamePage(esEditProductBloc)));
    }

    editLongDescription() async {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              EsEditProductLongDescriptionPage(esEditProductBloc)));
    }

    editUnit() async {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => EsEditProductUnitPage(esEditProductBloc)));
    }

    editDisplayLine1() async {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => EsEditDisplayLine1Page(esEditProductBloc)));
    }

    addSku() async {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => EsEditProductVariationPage(esEditProductBloc)));
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
                    // ListTile(
                    //   title: Text(
                    //     "Active",
                    //     overflow: TextOverflow.ellipsis,
                    //   ),
                    //   trailing: Switch(
                    //       value: snapshot.data.currentProduct.isActive,
                    //       onChanged: (isActive) {
                    //         esEditProductBloc.updateIsActive(
                    //             isActive, (product) {}, () {});
                    //       }),
                    // ),
                    // ListTile(
                    //   title: Text(
                    //     "Stock",
                    //     overflow: TextOverflow.ellipsis,
                    //   ),
                    //   trailing: Switch(
                    //       value: snapshot.data.currentProduct.inStock,
                    //       onChanged: (inStock) {
                    //         esEditProductBloc.updateInStock(
                    //             inStock, (product) {}, () {});
                    //       }),
                    // ),
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
                        'Name',
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
                                    "+ Add name",
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
                        'Short description',
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ),
                    Container(
                      child: snapshot.data.currentProduct.dProductDescription ==
                              ''
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                FlatButton(
                                  onPressed: editShortDescription,
                                  child: Text(
                                    "+ Add short description",
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
                                      snapshot.data.currentProduct
                                          .dProductDescription,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: editShortDescription,
                                    icon: Icon(
                                      Icons.edit,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )
                                ],
                              ),
                            ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 20,
                        right: 20,
                        bottom: 4,
                        // bottom: 8.0,
                      ),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Long description',
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ),
                    Container(
                      child: snapshot.data.currentProduct
                                  .dProductLongDescription ==
                              ''
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                FlatButton(
                                  onPressed: editLongDescription,
                                  child: Text(
                                    "+ Add long description",
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
                                      snapshot.data.currentProduct
                                          .dProductLongDescription,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: editLongDescription,
                                    icon: Icon(
                                      Icons.edit,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )
                                ],
                              ),
                            ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 20,
                        right: 20,
                        bottom: 4,
                        // bottom: 8.0,
                      ),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Display line 1',
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ),
                    Container(
                      child: snapshot.data.currentProduct.dLine1 == ''
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                FlatButton(
                                  onPressed: editDisplayLine1,
                                  child: Text(
                                    "+ Add display line 1",
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
                                      snapshot.data.currentProduct.dLine1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: editDisplayLine1,
                                    icon: Icon(
                                      Icons.edit,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )
                                ],
                              ),
                            ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 20,
                        right: 20,
                        bottom: 4,
                        // bottom: 8.0,
                      ),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Unit',
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ),
                    Container(
                      child: snapshot.data.currentProduct.dUnit == ''
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                FlatButton(
                                  onPressed: editUnit,
                                  child: Text(
                                    "+ Add unit",
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
                                      snapshot.data.currentProduct.dUnit,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: editUnit,
                                    icon: Icon(
                                      Icons.edit,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )
                                ],
                              ),
                            ),
                    ),
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
                        'Categories',
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
                                    onTap: addCategory,
                                    child: Chip(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      avatar: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        "Add category",
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
                        'Variations',
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
                                    onPressed: addSku,
                                    child: Text(
                                      "+ Add variation",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ]);
                          }

                          return TableRow(children: [
                            VariationCard(
                                snapshot.data.currentProduct.skus[index]),
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
  const VariationCard(
    this.sku, {
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
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text('Code'),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(sku.skuCode),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Text('Price'),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(sku.dBasePrice),
                  ),
                ],
              ),
              Expanded(child: Container()),
              Column(
                children: <Widget>[
                  Text('Active'),
                  Checkbox(value: sku.isActive, onChanged: (val) {}),
                ],
              ),
              Expanded(child: Container()),
              Column(
                children: <Widget>[
                  Text('Stock'),
                  Checkbox(value: sku.inStock, onChanged: (val) {}),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
