import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/bloc/es_add_category.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_product.dart';
import 'package:provider/provider.dart';

class EsAddCategoryPage extends StatefulWidget {
  static const routeName = '/add-category';
  @override
  EsAddCategoryPageState createState() => EsAddCategoryPageState();
}

class EsAddCategoryPageState extends State<EsAddCategoryPage>
    with AfterLayoutMixin<EsAddCategoryPage> {
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
        this.esCategoriesBloc.addCategory((esCategory) {
          Navigator.of(context).pop(esCategory);
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.of(context).text('category_page_add_category'),
        ),
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
                          labelText: AppTranslations.of(context)
                              .text('category_page_category_name'),
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
                        controller:
                            this.esCategoriesBloc.descriptionEditController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: AppTranslations.of(context)
                              .text('category_page_category_description'),
                        ),
                      ),
                    ),
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
              text: AppTranslations.of(context).text('generic_save'),
              onPressed: submit,
              isLoading: snapshot.data.isSubmitting,
            );
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
