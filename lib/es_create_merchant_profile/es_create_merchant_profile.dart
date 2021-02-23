import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/bloc/auth.dart';
import 'package:foore/data/bloc/es_create_merchant_profile.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_profiles.dart';
import 'package:foore/es_home_page/es_home_page.dart';
import 'package:provider/provider.dart';

class EsCreateMerchantProfilePage extends StatefulWidget {
  static const routeName = '/create-merchant-profile';

  EsCreateMerchantProfilePage();

  static Route generateRoute(
      RouteSettings settings, HttpService httpService, AuthBloc authBloc) {
    return MaterialPageRoute(
      builder: (context) => Provider(
        builder: (context) =>
            EsCreateMerchantProfileBloc(httpService, authBloc),
        dispose: (context, value) => value.dispose(),
        child: EsCreateMerchantProfilePage(),
      ),
    );
  }

  @override
  EsCreateMerchantProfilePageState createState() =>
      EsCreateMerchantProfilePageState();
}

class EsCreateMerchantProfilePageState
    extends State<EsCreateMerchantProfilePage>
    with AfterLayoutMixin<EsCreateMerchantProfilePage> {
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
    final createMerchantProfileBloc =
        Provider.of<EsCreateMerchantProfileBloc>(context);

    onCreateMerchantProfileSuccess(EsProfile profile) {
      final authBloc = Provider.of<AuthBloc>(context);
      authBloc.setEsMerchantProfile(profile);
      Navigator.of(context).pushNamed(EsHomePage.routeName);
    }

    submit() {
      if (this._formKey.currentState.validate()) {
        createMerchantProfileBloc
            .createMerchantProfile(onCreateMerchantProfileSuccess);
      }
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
              AppTranslations.of(context).text('merchant_profile_page_title')),
        ),
        body: Form(
          key: _formKey,
          onWillPop: _onWillPop,
          child: StreamBuilder<EsCreateMerchantProfileState>(
              stream: createMerchantProfileBloc.createMerchantProfileObservable,
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
                          controller:
                              createMerchantProfileBloc.nameEditController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: AppTranslations.of(context)
                                .text('merchant_profile_page_name'),
                          ),
                        ),
                      ),
                      // Container(
                      //   padding: const EdgeInsets.only(
                      //     top: 24.0,
                      //     left: 20,
                      //     right: 20,
                      //     bottom: 8,
                      //     // bottom: 8.0,
                      //   ),
                      //   alignment: Alignment.bottomLeft,
                      //   child: Text(
                      //     'Categories',
                      //     style: Theme.of(context).textTheme.subtitle2,
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 16.0,
                      //     vertical: 4.0,
                      //   ),
                      //   child: DropdownButton<EsCluster>(
                      //     value: snapshot.data.selectedCluster,
                      //     elevation: 4,
                      //     onChanged: createMerchantProfileBloc.setSelectedCluster,
                      //     items: snapshot.data.clusters
                      //         .map<DropdownMenuItem<EsCluster>>(
                      //             (EsCluster cluster) {
                      //       return DropdownMenuItem<EsCluster>(
                      //         value: cluster,
                      //         child: Text(cluster.clusterName),
                      //       );
                      //     }).toList(),
                      //   ),
                      // ),
                    ],
                  ),
                );
              }),
        ),
        floatingActionButton: FoSubmitButton(
          text: AppTranslations.of(context).text('generic_save'),
          onPressed: submit,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
