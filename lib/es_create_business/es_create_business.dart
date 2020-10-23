import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/data/bloc/es_create_business.dart';
import 'package:foore/data/model/es_business.dart';
import 'package:foore/es_home_page/es_home_page.dart';
import 'package:provider/provider.dart';

class EsCreateBusinessPage extends StatefulWidget {
  static const routeName = '/create-business-page';

  EsCreateBusinessPage();

  @override
  EsCreateBusinessPageState createState() => EsCreateBusinessPageState();
}

class EsCreateBusinessPageState extends State<EsCreateBusinessPage>
    with AfterLayoutMixin<EsCreateBusinessPage> {
  final _formKey = GlobalKey<FormState>();
  EsCreateBusinessBloc createBusinessBloc;

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

  confirmBusinessAlert(String businessName) async {
    await showDialog(
      context: context,
      barrierDismissible: true, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Do you want to create a new business named '$businessName' ?",
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('Confirm'),
              onPressed: () {
                createBusinessBloc.createBusiness(
                  onCreateBusinessSuccess,
                  () => this._showFailedAlertDialog(),
                );
              },
            ),
            FlatButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // final createBusinessBloc = Provider.of<EsCreateBusinessBloc>(context);
    // createBusinessBloc.getData();
  }

  Future<bool> _onWillPop() async {
    Navigator.pop(context);
    return false;
  }

  @override
  void initState() {
    createBusinessBloc =
        Provider.of<EsCreateBusinessBloc>(context, listen: false);
    super.initState();
  }

  onCreateBusinessSuccess(EsBusinessInfo businessInfo) {
    var esBusinessesBloc = Provider.of<EsBusinessesBloc>(context);
    esBusinessesBloc.addCreatedBusiness(businessInfo);
    esBusinessesBloc.setSelectedBusiness(businessInfo);
    Navigator.of(context).pushNamed(EsHomePage.routeName);
  }

  @override
  Widget build(BuildContext context) {
    // final createBusinessBloc = Provider.of<EsCreateBusinessBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create business',
        ),
      ),
      body: Form(
        key: _formKey,
        onWillPop: _onWillPop,
        child: StreamBuilder<EsCreateBusinessState>(
            stream: createBusinessBloc.createBusinessObservable,
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
                        controller: createBusinessBloc.nameEditController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Business name',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 20,
                        right: 20,
                      ),
                      child: TextFormField(
                        controller: createBusinessBloc.circleEditController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Circle',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () async {},
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 16.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.blue.withOpacity(0.1),
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              child: Text(
                                'Get in touch with us to get Circle code',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                                softWrap: true,
                              ),
                            ),
                            Expanded(
                              child: Container(),
                            ),
                            Container(
                              margin: EdgeInsets.all(1.0),
                              height: 20,
                              width: 20,
                              child: Image(
                                image: AssetImage('assets/whatsapp.png'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            }),
      ),
      floatingActionButton: StreamBuilder<EsCreateBusinessState>(
          stream: createBusinessBloc.createBusinessObservable,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            return FoSubmitButton(
              text: 'Save',
              onPressed: () {
                if (this._formKey.currentState.validate()) {
                  confirmBusinessAlert(
                      createBusinessBloc.nameEditController.text);
                }
              },
              isLoading: snapshot.data.isSubmitting,
            );
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
