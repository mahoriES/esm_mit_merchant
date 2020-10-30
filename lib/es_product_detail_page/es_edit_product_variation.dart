import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/bloc/es_edit_product.dart';
import 'package:foore/data/model/es_product.dart';
import 'package:foore/services/validation.dart';

class EsEditProductVariationPage extends StatefulWidget {
  final EsEditProductBloc esEditProductBloc;
  final EsSku currentSku;

  EsEditProductVariationPage(this.esEditProductBloc, this.currentSku);

  @override
  EsEditProductVariationPageState createState() =>
      EsEditProductVariationPageState();
}

class EsEditProductVariationPageState extends State<EsEditProductVariationPage>
    with AfterLayoutMixin<EsEditProductVariationPage> {
  final _formKey = GlobalKey<FormState>();
  bool inStock = true;
  bool isActive = true;

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
    if (widget.currentSku != null) {
      widget.esEditProductBloc.setCurrentSku(widget.currentSku);
      this.isActive = widget.currentSku.isActive;
      this.inStock = widget.currentSku.inStock;
    } else {
      widget.esEditProductBloc.skuPriceEditController.text = "";
      widget.esEditProductBloc.skuVariationValueEditController.text = "";
      this.isActive = true;
      this.inStock = true;
    }
  }

  Future<bool> _onWillPop() async {
    Navigator.pop(context);
    return false;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    onSuccess() {
      Navigator.of(context).pop();
    }

    onFail() {
      this._showFailedAlertDialog();
    }

    submit() {
      if (this._formKey.currentState.validate()) {
        if (widget.currentSku == null) {
          widget.esEditProductBloc
              .addSkuToProduct(this.inStock, this.isActive, onSuccess, onFail);
        } else {
          widget.esEditProductBloc.editCurrentSku(widget.currentSku.skuId,
              this.inStock, this.isActive, onSuccess, onFail);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.currentSku != null
              ? "Edit ${widget.currentSku.skuCode}"
              : 'Add variation',
        ),
      ),
      body: Form(
        key: _formKey,
        onWillPop: _onWillPop,
        child: StreamBuilder<EsEditProductState>(
            stream: widget.esEditProductBloc.esEditProductStateObservable,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              return Scrollbar(
                child: ListView(
                  children: <Widget>[
                    const SizedBox(height: 20),
                    // Padding(
                    //   padding: const EdgeInsets.only(
                    //     top: 24.0,
                    //     left: 20,
                    //     right: 20,
                    //   ),
                    //   child: TextFormField(
                    //     enabled: widget.currentSku == null,
                    //     controller:
                    //         widget.esEditProductBloc.skuCodeEditController,
                    //     decoration: InputDecoration(
                    //       border: OutlineInputBorder(),
                    //       labelText: 'Sku code',
                    //     ),
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 20,
                        right: 20,
                      ),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller:
                            widget.esEditProductBloc.skuPriceEditController,
                        validator: ValidationService().validateDouble,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Price (eg. 120.0)',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 20,
                        right: 20,
                      ),
                      child: TextFormField(
                        controller: widget
                            .esEditProductBloc.skuVariationValueEditController,
                        validator: ValidationService().validateDouble,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Variation (eg. 500gm)',
                          suffix: Text(
                              widget.esEditProductBloc.unitEditController.text),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 20,
                        right: 20,
                      ),
                      child: SwitchListTile(
                        value: this.isActive,
                        onChanged: (updatedVal) {
                          setState(() {
                            this.isActive = updatedVal;
                          });
                        },
                        title: Text("Active"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 20,
                        right: 20,
                      ),
                      child: SwitchListTile(
                        value: this.inStock,
                        onChanged: (updatedVal) {
                          setState(() {
                            this.inStock = updatedVal;
                          });
                        },
                        title: Text("Stock"),
                      ),
                    ),
                  ],
                ),
              );
            }),
      ),
      floatingActionButton: StreamBuilder<EsEditProductState>(
          stream: widget.esEditProductBloc.esEditProductStateObservable,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            return FoSubmitButton(
              text: 'Save',
              onPressed: submit,
              isLoading: snapshot.data.isSubmitting,
            );
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
