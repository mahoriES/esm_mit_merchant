import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/bloc/es_add_category.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_product.dart';
import 'package:provider/provider.dart';

class EsAddSubCategoryPageParams {
  final String parentCategoryName;
  final int parentCategoryId;
  
  EsAddSubCategoryPageParams(this.parentCategoryId, this.parentCategoryName);
}

class EsAddSubCategoryPage extends StatefulWidget {
  static const routeName = '/add-sub-category';
  final String parentCategoryName;
  final int parentCategoryId;

  EsAddSubCategoryPage(this.parentCategoryId, this.parentCategoryName);

  @override
  EsAddSubCategoryPageState createState() => EsAddSubCategoryPageState();
}

class EsAddSubCategoryPageState extends State<EsAddSubCategoryPage>
    with AfterLayoutMixin<EsAddSubCategoryPage> {
  EsAddCategoryBloc esCategoriesBloc;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    final httpService = Provider.of<HttpService>(context);
    final businessBloc = Provider.of<EsBusinessesBloc>(context);
    if (this.esCategoriesBloc == null) {
      this.esCategoriesBloc = EsAddCategoryBloc(httpService, businessBloc);
    }
    super.didChangeDependencies();
  }

  final _formKey = GlobalKey<FormState>();

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
  void afterFirstLayout(BuildContext context) {}

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
    onSuccess(EsProduct product) {
      Navigator.of(context).pop();
    }

    onFail() {
      this._showFailedAlertDialog();
    }

    submit() {
      if (this._formKey.currentState.validate()) {
        this.esCategoriesBloc.addSubCategory(this.widget.parentCategoryId,
            (esCategory) {
          Navigator.of(context).pop(esCategory);
          //Add to list
          
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Sub category\n" + this.widget.parentCategoryName),
      ),
      body: Form(
        key: _formKey,
        onWillPop: _onWillPop,
        child: StreamBuilder<EsAddCategoryState>(
            stream: this.esCategoriesBloc.esAddCategoryStateObservable,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              return Scrollbar(
                child: ListView(
                  children: <Widget>[
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 20,
                        right: 20,
                      ),
                      child: TextFormField(
                        controller: this.esCategoriesBloc.nameEditController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Sub Category name',
                        ),
                      ),
                    ),
                    /*
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 20,
                        right: 20,
                      ),
                      child: TextFormField(
                        controller:
                            this.esCategoriesBloc.descriptionEditController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Category description',
                        ),
                      ),
                    ),*/
                  ],
                ),
              );
            }),
      ),
      floatingActionButton: StreamBuilder<EsAddCategoryState>(
          stream: this.esCategoriesBloc.esAddCategoryStateObservable,
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
