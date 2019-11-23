import 'dart:convert';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/auth.dart';
import 'package:foore/onboarding_page/location_claim.dart';
import 'package:foore/search_gmb/model/google_locations.dart';
import 'package:foore/search_gmb/search_gmb.dart';
import 'package:provider/provider.dart';
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
    if (!isSignedInWithGoogle) {}
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.of(context).text("onboarding_page_title"),
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
                child: Text(
                  "You don't have any Google Business location for your Google account paragjnath@foore.in.",
                  style: Theme.of(context)
                      .textTheme
                      .body1
                      .copyWith(color: Theme.of(context).errorColor),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                  top: 32.0,
                  left: 16.0,
                  right: 16.0,
                ),
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Search for your Business and claim to manage that business.",
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
                "Can't find your business ?",
                style: Theme.of(context).textTheme.caption,
              ),
              FlatButton(
                child: Text(
                  'Create a business on Google',
                  style: Theme.of(context).textTheme.button.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                ),
                onPressed: () {
                  final responseString =
                      '{ "googleLocations": [ { "name": "googleLocations/ChIJ3a2l4X0RrjsRggWzPz6Q0xM", "location": { "name": "accounts/100175924515635207658/locations/12164510788088057585", "locationName": "Mukesh Realtors", "primaryCategory": { "displayName": "Property management company", "categoryId": "gcid:property_management_company" }, "locationKey": { "placeId": "ChIJ3a2l4X0RrjsRggWzPz6Q0xM" }, "latlng": { "latitude": 12.969414, "longitude": 77.705732 }, "languageCode": "en", "locationState": {"hasPendingVerification": true }, "address": { "regionCode": "IN", "languageCode": "en", "postalCode": "560037", "administrativeArea": "Karnataka", "locality": "Bengaluru", "addressLines": [ "# 51, Shanti Nivas 7th Cross chinapanahalli", "Doddanekundi, Ext" ] } } } ] }';
                  GoogleLocationsResponse googleLocationsResponse =
                      GoogleLocationsResponse.fromJson(
                          json.decode(responseString));

                  final GoogleLocation googleLocation =
                      googleLocationsResponse.googleLocations[0];
                  final Map<String, dynamic> arguments =
                      new Map<String, dynamic>();
                  // arguments['googleLocation'] = googleLocation;
                  arguments['locationItem'] = googleLocation.location;
                  Navigator.pushNamed(context, LocationClaimPage.routeName,
                      arguments: arguments);
                },
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
