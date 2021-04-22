import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/auth.dart';
import 'package:foore/data/bloc/complete_verification.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/google_login_not_done_page/google_login_not_done_page.dart';
import 'package:foore/home_page/app_drawer.dart';
import 'package:foore/search_gmb/model/google_locations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';

import '../app_translations.dart';

class LocationVerifyPage extends StatefulWidget {
  static const routeName = '/location-verify';
  LocationVerifyPage({Key key}) : super(key: key);

  @override
  _LocationVerifyPageState createState() => _LocationVerifyPageState();

  static Route generateRoute(RouteSettings settings,
      {@required HttpService httpService, @required AuthBloc authBloc}) {
    GmbLocationItem locationItem = settings.arguments;
    return MaterialPageRoute(
      builder: (context) => Provider<CompleteVerificationBloc>(
        create: (context) => CompleteVerificationBloc(
          httpService: httpService,
          authBloc: authBloc,
          locationItem: locationItem,
        ),
        dispose: (context, value) => value.dispose(),
        child: LocationVerifyPage(),
      ),
    );
  }
}

class _LocationVerifyPageState extends State<LocationVerifyPage>
    with AfterLayoutMixin<LocationVerifyPage> {
  Completer<GoogleMapController> _controller = Completer();
  StreamSubscription<CompleteVerificationState> _subscription;
  final _formVerifyWithPin = GlobalKey<FormState>();
  @override
  void afterFirstLayout(BuildContext context) {
    final completeVerificationBloc =
        Provider.of<CompleteVerificationBloc>(context);
    _subscription = completeVerificationBloc.completeVerificationStateObservable
        .listen(_onCompleteVerificationStateChange);
    completeVerificationBloc.getData();
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

  _onCompleteVerificationStateChange(CompleteVerificationState state) {
    if (state.isShowNotLoggedInWithGoogle) {
      Navigator.pushReplacementNamed(context, GoogleLoginNotDonePage.routeName);
    }
    if (state.isSubmitFailed) {
      _showFailedAlertDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final completeVerificationBloc =
        Provider.of<CompleteVerificationBloc>(context);
    onVerify() {
      if (_formVerifyWithPin.currentState.validate()) {
        completeVerificationBloc.completeVerification(context);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            AppTranslations.of(context).text("location_verify_page_title")),
      ),
      drawer: AppDrawer(),
      body: SafeArea(
        child: StreamBuilder<CompleteVerificationState>(
            stream:
                completeVerificationBloc.completeVerificationStateObservable,
            builder: (context, snapshot) {
              Widget child = Center(
                child: CircularProgressIndicator(),
              );
              if (snapshot.hasData) {
                if (snapshot.data.isLoading) {
                  child = Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  child = verificationWidget(context, snapshot.data, onVerify);
                }
              }
              return child;
            }),
      ),
    );
  }

  Widget verificationWidget(BuildContext context,
      CompleteVerificationState state, Function onVerify) {
    final completeVerificationBloc =
        Provider.of<CompleteVerificationBloc>(context);
    return Form(
      key: this._formVerifyWithPin,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 32.0,
          ),
          Container(
            child: ListTile(
              title: Text(state.locationName ?? ''),
              subtitle: Text(state.locationAddress ?? ''),
            ),
          ),
          Divider(
            thickness: 1.0,
            indent: 16.0,
            endIndent: 16.0,
            height: 32.0,
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Text(
              sprintf(
                  AppTranslations.of(context)
                      .text("location_verify_page_pin_label"),
                  [state.date]),
              style: Theme.of(context).textTheme.subtitle,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            child: TextFormField(
              controller: completeVerificationBloc.pinEditController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: AppTranslations.of(context)
                    .text("location_verify_page_pin_hint"),
              ),
              maxLength: 5,
              validator: (String value) {
                return value.length < 5
                    ? AppTranslations.of(context)
                        .text("location_verify_page_pin_validation")
                    : null;
              },
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            width: double.infinity,
            child: RaisedButton(
              onPressed: onVerify,
              child: Container(
                width: double.infinity,
                child: state.isSubmitting
                    ? Center(
                        child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      ))
                    : Text(
                        AppTranslations.of(context)
                            .text("location_verify_page_button_verify"),
                        style: Theme.of(context).textTheme.button.copyWith(
                              color: Colors.white,
                            ),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
