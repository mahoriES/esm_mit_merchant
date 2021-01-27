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
      print(sku.toJson());
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
              child: ListView(
                children: <Widget>[
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 14, right: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (snapshot.data.categories.length > 0) ...[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(
                                  snapshot.data.categories.length, (index) {
                                final category =
                                    snapshot.data.categories[index];
                                final parentCategory = snapshot.data
                                    .getCategoryById(category.parentCategoryId);
                                return Chip(
                                  backgroundColor:
                                      Colors.black.withOpacity(0.05),
                                  onDeleted: () {
                                    removeCategory(category);
                                  },
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        flex: 1,
                                        child: Container(
                                          child: parentCategory.dCategoryName !=
                                                  null
                                              ? Text(
                                                  parentCategory
                                                          .dCategoryName ??
                                                      '',
                                                  overflow: TextOverflow.fade,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle1
                                                      .copyWith(
                                                        color: ListTileTheme.of(
                                                                context)
                                                            .textColor,
                                                      ),
                                                )
                                              : null,
                                        ),
                                      ),
                                      Icon(Icons.chevron_right),
                                      Flexible(
                                        flex: 1,
                                        child: Container(
                                          child: Text(
                                            category.dCategoryName ?? '',
                                            overflow: TextOverflow.fade,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                .copyWith(
                                                  color:
                                                      ListTileTheme.of(context)
                                                          .textColor,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              addCategory(snapshot.data.categories
                                  .map((e) => e.categoryId)
                                  .toList());
                            },
                            icon: Icon(
                              Icons.add,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                        if (snapshot.data.categories.length == 0)
                          Chip(
                            backgroundColor: Theme.of(context).primaryColor,
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
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      top: 16.0,
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
                            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.only(
                      top: 16.0,
                      left: 20,
                      right: 20,
                      bottom: 8,
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
                      top: 4.0,
                      left: 20,
                      right: 20,
                      bottom: 8,
                    ),
                    child: Column(
                      children: List.generate(
                          snapshot.data.currentProduct.skus != null
                              ? widget.currentProduct.skus.length + 1
                              : 0, (index) {
                        if (snapshot.data.currentProduct.skus == null ||
                            widget.currentProduct.skus.length == index) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              FlatButton(
                                onPressed: () {
                                  addSku(esEditProductBloc);
                                },
                                child: Text(
                                  '+ ' +
                                      AppTranslations.of(context)
                                          .text('products_page_add_variation'),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                        }
                        return VariationCard(
                          snapshot.data.currentProduct.skus[index],
                          esEditProductBloc,
                          editSku,
                        );
                      }),
                    ),
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
                      'Product images',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ),
                  SizedBox(height: 16),
                  EsEditProductImageList(esEditProductBloc),
                  SizedBox(height: 16),
                ],
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
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'SKU: ' + sku.dSkuCode,
                style: Theme.of(context).textTheme.caption,
              ),
              SizedBox(
                width: 4.0,
              ),
              if (!sku.isActive)
                Text(
                  '(Inactive)',
                  style: Theme.of(context).textTheme.caption.copyWith(
                      color:
                          Theme.of(context).colorScheme.error.withOpacity(0.8)),
                ),
            ],
          ),
          SizedBox(
            height: 4.0,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                height: 72.0,
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                ),
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'In Stock',
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ),
                        Switch(
                          value: sku.inStock,
                          onChanged: (updatedVal) {
                            esEditProductBloc.editSkuStock(
                                sku.skuId, updatedVal);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Flexible(
                flex: 2,
                child: Container(
                  height: 72.0,
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Center(child: Text(sku.variationValue ?? '')),
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Flexible(
                flex: 3,
                child: Container(
                  height: 72.0,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Center(
                    child: Row(
                      children: [
                        Container(
                          height: 72.0,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          color: Colors.black12,
                          child: Center(
                            child: Text(
                              '₹',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Text(
                              sku.dBasePriceWithoutRupeeSymbol.toString(),
                              softWrap: true,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              IconButton(
                  color: Theme.of(context).primaryColor,
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    this.onSkuClick(this.sku);
                  })
            ],
          ),
        ],
      ),
    );
  }
}
