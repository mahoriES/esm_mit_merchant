import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/bloc/es_business_profile.dart';

class EsEditBaseTextPage extends StatefulWidget {
  final EsBusinessProfileBloc esBusinessProfileBloc;
  final String title;
  final String labelText;
  final Function onSave;
  final TextEditingController textEditingController;

  EsEditBaseTextPage(this.esBusinessProfileBloc, this.title, this.labelText,
      this.textEditingController, this.onSave);

  @override
  EsEditBaseTextPageState createState() => EsEditBaseTextPageState();
}

class EsEditBaseTextPageState extends State<EsEditBaseTextPage>
    with AfterLayoutMixin<EsEditBaseTextPage> {
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
    onSuccess() {
      Navigator.of(context).pop();
    }

    onFail() {
      this._showFailedAlertDialog();
    }

    submit() {
      if (this._formKey.currentState.validate()) {
        widget.onSave(onSuccess, onFail);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
        ),
      ),
      body: Form(
        key: _formKey,
        onWillPop: _onWillPop,
        child: StreamBuilder<EsBusinessProfileState>(
            stream: widget.esBusinessProfileBloc.createBusinessObservable,
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
                        controller: widget.textEditingController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: widget.labelText,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
      ),
      floatingActionButton: StreamBuilder<EsBusinessProfileState>(
          stream: widget.esBusinessProfileBloc.createBusinessObservable,
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
