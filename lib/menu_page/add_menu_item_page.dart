import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/bloc/es_edit_product.dart';
import 'package:foore/data/model/es_product.dart';
import 'package:foore/menu_page/add_menu_image_list.dart';
import 'package:foore/services/validation.dart';
import 'package:provider/provider.dart';

class AddMenuItemPage extends StatefulWidget {
  static const routeName = '/add-menu-item';
  final EsProduct currentProduct;

  AddMenuItemPage(this.currentProduct);

  @override
  AddMenuItemPageState createState() => AddMenuItemPageState();
}

class AddMenuItemPageState extends State<AddMenuItemPage>
    with AfterLayoutMixin<AddMenuItemPage> {
  final _formKey = GlobalKey<FormState>();
  final List<String> unitsList = [
    "Piece",
    "Serving",
    "Kg",
    "Gm",
    "Litre",
    "Ml",
    "Dozen",
    "ft",
    "meter",
    "sq. ft.",
  ];

  String selectedUnit;

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
    submit() {
      if (this._formKey.currentState.validate()) {
        if (selectedUnit == null) {
          Fluttertoast.showToast(msg: 'Please Select Unit First');
        } else {
          esEditProductBloc.unitEditController.text = selectedUnit;
          esEditProductBloc.addProduct((EsProduct product) {
            Navigator.of(context).pop(product);
          });
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.currentProduct != null ? 'Edit Product' : 'Add Product',
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
                    const SizedBox(height: 20),
                    EsAddMenuItemImageList(esEditProductBloc),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 20,
                        right: 20,
                      ),
                      child: TextFormField(
                        controller: esEditProductBloc.nameEditController,
                        validator: ValidationService().validateProductName,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Product name',
                        ),
                        maxLength: 128,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 20,
                        right: 20,
                      ),
                      child: DropdownButtonFormField(
                        value: selectedUnit,
                        hint: Text('Select a unit'),
                        validator: (value) => ValidationService()
                            .validateString(value.toString()),
                        items: List.generate(
                          unitsList.length,
                          (index) => DropdownMenuItem(
                            value: unitsList[index],
                            child: Text(unitsList[index]),
                          ),
                        ),
                        onChanged: (v) {
                          setState(() {
                            selectedUnit = v;
                          });
                        },
                      ),
                    ),
                  ],
                ),
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
              text: 'Save',
              onPressed: submit,
              isLoading: snapshot.data.isSubmitting,
            );
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
