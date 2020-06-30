import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/bloc/es_edit_product.dart';
import 'package:foore/data/model/es_product.dart';

class EsEditDisplayLine1Page extends StatefulWidget {
  final EsEditProductBloc esEditProductBloc;

  EsEditDisplayLine1Page(this.esEditProductBloc);

  @override
  EsEditDisplayLine1PageState createState() =>
      EsEditDisplayLine1PageState();
}

class EsEditDisplayLine1PageState
    extends State<EsEditDisplayLine1Page>
    with AfterLayoutMixin<EsEditDisplayLine1Page> {
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
        widget.esEditProductBloc.updateShortDescription(onSuccess, onFail);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update business description',
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
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 20,
                        right: 20,
                      ),
                      child: TextFormField(
                        controller: widget
                            .esEditProductBloc.shortDescriptionEditController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Business description',
                        ),
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
