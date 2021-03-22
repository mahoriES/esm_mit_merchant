import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/bloc/es_edit_product.dart';
import 'package:foore/data/model/es_product.dart';
import 'package:foore/es_category_page/es_category_page.dart';
import 'package:foore/es_product_detail_page/es_product_image_list.dart';
import 'package:foore/utils/input_limit.dart';
import 'package:foore/utils/input_validations.dart';
import 'package:foore/utils/utils.dart';
import 'package:provider/provider.dart';

class EsProductDetailPageParam {
  final EsProduct currentProduct;
  EsProductDetailPageParam({this.currentProduct});
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

  @override
  void afterFirstLayout(BuildContext context) {
    final esEditProductBloc = Provider.of<EsEditProductBloc>(context);
    if (widget.currentProduct != null) {
      esEditProductBloc.setCurrentProduct(widget.currentProduct);
      esEditProductBloc.getCategories();
    } else {
      esEditProductBloc.getAllCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEditProductBloc = Provider.of<EsEditProductBloc>(context);

    addPreSelectedCategory(List<int> existedCategoryIds) async {
      final selectedCategories = await Navigator.of(context)
          .pushNamed(EsCategoryPage.routeName, arguments: existedCategoryIds);
      if (selectedCategories != null) {
        esEditProductBloc.addPreSelectedCategories(selectedCategories);
      }
    }

    removePreSelectedCategory(int categoryId) async {
      esEditProductBloc.removePreSelectedCategory(categoryId);
    }

    submit() {
      if (this._formKey.currentState.validate()) {
        if (widget.currentProduct != null) {
          esEditProductBloc.updateProductFull((EsProduct product) {
            Navigator.of(context).pop(product);
          }, () {
            showFailedAlertDialog(context);
          });
        } else {
          esEditProductBloc.addProductFull((EsProduct product) {
            Navigator.of(context).pop(product);
          }, () {
            showFailedAlertDialog(context);
          });
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.currentProduct != null
              ? AppTranslations.of(context).text('products_page_edit_product')
              : AppTranslations.of(context).text('products_page_add_product'),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Switch(
                            value: snapshot.data.inStock,
                            onChanged: (updatedVal) {
                              esEditProductBloc.updateProductStock(updatedVal);
                            },
                          ),
                          Text(
                            AppTranslations.of(context)
                                .text('products_page_in_stock'),
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              esEditProductBloc.updateProductSpotlight(
                                  !snapshot.data.spotlight);
                            },
                            child: ImageIcon(
                              AssetImage('assets/icons/spotlights.png'),
                              color: snapshot.data.spotlight
                                  ? Theme.of(context).primaryColor
                                  : Colors.black26,
                            ),
                          ),
                          const SizedBox(
                            width: 12.0,
                          ),
                          Text(
                            AppTranslations.of(context)
                                .text('products_page_spotlight'),
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ],
                      )
                    ],
                  ),
                  Divider(
                    color: Colors.black12,
                  ),

                  /// Categories Section
                  ///
                  Padding(
                    padding: const EdgeInsets.only(left: 14, right: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (snapshot.data.preSelectedCategories.length > 0) ...[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(
                                  snapshot.data.preSelectedCategories.length,
                                  (index) {
                                final category =
                                    snapshot.data.preSelectedCategories[index];
                                final parentCategory = snapshot.data
                                    .getCategoryById(category.parentCategoryId);
                                return Chip(
                                  backgroundColor:
                                      Colors.black.withOpacity(0.05),
                                  onDeleted: () {
                                    removePreSelectedCategory(
                                        category.categoryId);
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
                          // IconButton(
                          //   onPressed: () {
                          //     addPreSelectedCategory(snapshot
                          //         .data.preSelectedCategories
                          //         .map((e) => e.categoryId)
                          //         .toList());
                          //   },
                          //   icon: Icon(
                          //     Icons.add,
                          //     color: Theme.of(context).primaryColor,
                          //   ),
                          // ),
                        ],
                        if (snapshot.data.preSelectedCategories.length == 0)
                          InkWell(
                            onTap: () {
                              addPreSelectedCategory(snapshot
                                  .data.preSelectedCategories
                                  .map((e) => e.categoryId)
                                  .toList());
                            },
                            child: Chip(
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
                          ),
                      ],
                    ),
                  ),

                  /// Name Section
                  ///
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 24.0,
                      left: 20,
                      right: 20,
                    ),
                    child: TextFormField(
                      controller: esEditProductBloc.nameEditController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: AppTranslations.of(context)
                            .text('products_page_name'),
                      ),
                      maxLength: ProductsInputLimit.kProductName,
                    ),
                  ),

                  /// Variations Section
                  ///
                  Container(
                    padding: const EdgeInsets.only(
                      top: 4.0,
                      left: 20,
                      bottom: 8,
                    ),
                    child: Column(
                      children: List.generate(
                          snapshot.data.preSelectedActiveSKUs.length + 1,
                          (index) {
                        if (snapshot.data.preSelectedActiveSKUs.length ==
                            index) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              FlatButton(
                                onPressed: () {
                                  esEditProductBloc.addPreSelectedSKU();
                                },
                                child: Text(
                                  '+ ' +
                                      AppTranslations.of(context)
                                          .text('products_page_add_variation'),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Spacer(),
                              if (snapshot.data.preSelectedInactiveSKUs.length >
                                  0)
                                FlatButton(
                                  onPressed: () {
                                    showRestoreVariationsModel(context);
                                  },
                                  child: Text(
                                    AppTranslations.of(context).text(
                                        'products_page_restore_variations'),
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                  // color: Theme.of(context).colorScheme.surface,
                                ),
                            ],
                          );
                        }
                        return VariationCard(
                            snapshot.data.preSelectedActiveSKUs[index],
                            esEditProductBloc,
                            snapshot.data.preSelectedActiveSKUs.length);
                      }),
                    ),
                  ),

                  /// Images Section
                  ///
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
                      AppTranslations.of(context).text('products_page_images'),
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  EsProductItemImageList(esEditProductBloc),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: TextFormField(
                      controller:
                          esEditProductBloc.shortDescriptionEditController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: AppTranslations.of(context)
                              .text('products_page_description'),
                          helperText: AppTranslations.of(context)
                              .text('generic_optional')),
                      maxLength: ProductsInputLimit.kProductShortDescription,
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            );
          }),
      floatingActionButton: StreamBuilder<EsEditProductState>(
          stream: esEditProductBloc.esEditProductStateObservable,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            return FoSubmitButton(
              text: AppTranslations.of(context).text('products_page_save'),
              onPressed: submit,
              isLoading: snapshot.data.isSubmitting,
            );
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  showRestoreVariationsModel(BuildContext context) {
    final esEditProductBloc = Provider.of<EsEditProductBloc>(context);
    final subscription = esEditProductBloc.esEditProductStateObservable
        .map((state) => state.preSelectedInactiveSKUs.length)
        .where((skuLength) => skuLength == 0)
        .take(1)
        .listen((event) {
      Navigator.of(context).pop();
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () {
                subscription.cancel();
                Navigator.of(context).pop();
              },
              child: Container(color: Colors.transparent),
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: StreamBuilder<EsEditProductState>(
                stream: esEditProductBloc.esEditProductStateObservable,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  return DraggableScrollableSheet(
                    initialChildSize: 0.4,
                    minChildSize: 0.25,
                    maxChildSize: 1,
                    builder: (context, scrollController) {
                      return Container(
                        color: Colors.white,
                        child: ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 20.0),
                          itemCount:
                              snapshot.data.preSelectedInactiveSKUs.length,
                          itemBuilder: (context, index) {
                            return RestoreVariationCard(
                                snapshot.data.preSelectedInactiveSKUs[index],
                                esEditProductBloc);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class RestoreVariationCard extends StatelessWidget {
  final EsProductSKUTamplate skuTemplate;
  final EsEditProductBloc esEditProductBloc;
  const RestoreVariationCard(
    this.skuTemplate,
    this.esEditProductBloc, {
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
                'SKU: ' + skuTemplate.skuCode,
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
          const SizedBox(
            height: 4.0,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Flexible(
                flex: 2,
                child: Container(
                  height: 50.0,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Center(
                    child: Text(skuTemplate.quantityController.text +
                        ' ' +
                        (skuTemplate.unit)),
                  ),
                ),
              ),
              const SizedBox(
                width: 10.0,
              ),
              Flexible(
                flex: 3,
                child: Container(
                  height: 50.0,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Center(
                    child: Row(
                      children: [
                        Container(
                          height: 72.0,
                          padding: const EdgeInsets.symmetric(
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
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Text(
                              skuTemplate.priceController.text.toString(),
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
              const SizedBox(
                width: 10.0,
              ),
              IconButton(
                color: Theme.of(context).primaryColor,
                icon: Icon(Icons.replay),
                onPressed: () {
                  this.esEditProductBloc.restorePreSelectedSKU(skuTemplate.key);
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}

class VariationCard extends StatelessWidget {
  final EsProductSKUTamplate skuTemplate;
  final numberOfPreSelectetSkuTemplate;
  final EsEditProductBloc esEditProductBloc;
  const VariationCard(
    this.skuTemplate,
    this.esEditProductBloc,
    this.numberOfPreSelectetSkuTemplate, {
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
              skuTemplate.skuCode != null
                  ? Text(
                      'SKU: ' + skuTemplate.skuCode,
                      style: Theme.of(context).textTheme.caption,
                    )
                  : Text(
                      AppTranslations.of(context).text('products_page_new'),
                      style: Theme.of(context).textTheme.caption.copyWith(
                          // color: Theme.of(context).primaryColor,
                          fontStyle: FontStyle.italic),
                    ),
              const SizedBox(
                width: 4.0,
              ),
            ],
          ),
          const SizedBox(
            height: 4.0,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Colors.black26,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: skuTemplate.quantityController,
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            counterText: "",
                          ),
                          validator: (text) {
                            return text.length == 0
                                ? AppTranslations.of(context)
                                    .text('error_messages_required')
                                : null;
                          },
                          maxLength: ProductsInputLimit.kSkuQuantity,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: DropdownButton(
                            underline: const SizedBox.shrink(),
                            isExpanded: true,
                            value: skuTemplate.unit,
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                .copyWith(color: Colors.black),
                            items: esEditProductBloc
                                .getUnitsList(skuTemplate.unit)
                                .map((unit) => DropdownMenuItem(
                                    value: unit, child: Text(unit)))
                                .toList(),
                            onChanged: (String value) {
                              esEditProductBloc.updatePreSelectedSKUUnit(
                                  skuTemplate.key, value);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 12.0,
              ),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Colors.black26,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 6,
                        ),
                        color: Colors.black12,
                        child: Text(
                          '₹',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextFormField(
                            controller: skuTemplate.priceController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.end,
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                            ),
                            validator: (text) {
                              return validateSkuPrice(text, context);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 8.0,
              ),
              Container(
                height: 60.0,
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            AppTranslations.of(context)
                                .text('products_page_in_stock'),
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ),
                        SizedBox(
                          height: 36.0,
                          child: Switch(
                            value: skuTemplate.inStock,
                            onChanged: (updatedVal) {
                              esEditProductBloc.updatePreSelectedSKUStock(
                                  skuTemplate.key, updatedVal);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 4.0,
              ),
              PopupMenuButton<int>(
                onSelected: (result) {
                  if (result == 1) {
                    esEditProductBloc.removePreSelectedSKU(skuTemplate.key);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                  PopupMenuItem(
                    enabled: numberOfPreSelectetSkuTemplate > 1,
                    value: 1,
                    child: Text(
                        AppTranslations.of(context).text('generic_remove')),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
