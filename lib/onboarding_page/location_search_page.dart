import 'dart:convert';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/auth.dart';
import 'package:foore/google_login_not_done_page/google_login_not_done_page.dart';
import 'package:foore/onboarding_page/location_claim.dart';
import 'package:foore/search_gmb/model/google_locations.dart';
import 'package:foore/search_gmb/search_gmb.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_translations.dart';

class LocationSearchPage extends StatefulWidget {
  static const routeName = '/location-search';
  LocationSearchPage({Key key}) : super(key: key);

  @override
  _LocationSearchPageState createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage>
    with AfterLayoutMixin<LocationSearchPage> {
  @override
  void afterFirstLayout(BuildContext context) {
    AuthBloc authBloc = Provider.of<AuthBloc>(context);
    this.loginToGoogleSilently(authBloc);
  }

  loginToGoogleSilently(AuthBloc authBloc) async {
    bool isSignedInWithGoogle = await authBloc.googleLoginSilently();
    if (!isSignedInWithGoogle) {
      Navigator.pushReplacementNamed(context, GoogleLoginNotDonePage.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context);
    onGoogleLocationSelected(GoogleLocation googleLocation) {
      var arguments = new Map<String, dynamic>();
      arguments['googleLocation'] = googleLocation;
      arguments['locationItem'] = googleLocation.location;
      Navigator.pushNamed(context, LocationClaimPage.routeName,
          arguments: arguments);
    }

    _launchGmbURL() async {
      final url = 'https://business.google.com/create';
      if (await canLaunch(url)) {
        await launch(url);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.of(context).text("location_search_page_title"),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).errorColor.withOpacity(0.2),
                ),
                child: StreamBuilder<AuthState>(
                    stream: authBloc.authStateObservable,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return null;
                      }
                      return Text(
                        sprintf(
                            AppTranslations.of(context)
                                .text("location_search_page_no_business"),
                            [snapshot.data.userEmail]),
                        style: Theme.of(context)
                            .textTheme
                            .body1
                            .copyWith(color: Theme.of(context).errorColor),
                      );
                    }),
              ),
              Container(
                padding: const EdgeInsets.only(
                  top: 32.0,
                  left: 16.0,
                  right: 16.0,
                ),
                alignment: Alignment.bottomLeft,
                child: Text(
                  AppTranslations.of(context)
                      .text("location_search_page_search_label"),
                  style: Theme.of(context).textTheme.subtitle,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                  top: 32.0,
                  left: 16.0,
                  right: 16.0,
                ),
                child: SearchMapPlaceWidget(
                  authBloc: authBloc,
                  onSelected: onGoogleLocationSelected,
                ),
              ),
              SizedBox(
                height: 100.0,
              ),
              Text(
                AppTranslations.of(context)
                    .text("location_search_page_cant_find_your_business"),
                style: Theme.of(context).textTheme.caption,
              ),
              FlatButton(
                child: Text(
                  AppTranslations.of(context)
                      .text("location_search_page_button_create_on_google"),
                  style: Theme.of(context).textTheme.button.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                ),
                onPressed: _launchGmbURL,
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
