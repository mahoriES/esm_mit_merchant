import 'dart:async';
import 'dart:convert';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/search_gmb/model/google_locations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationVerifyPage extends StatefulWidget {
  static const responseString =
      '{ "googleLocations": [ { "name": "googleLocations/ChIJ3a2l4X0RrjsRggWzPz6Q0xM", "location": { "locationName": "Mukesh Realtors", "primaryCategory": { "displayName": "Property management company", "categoryId": "gcid:property_management_company" }, "locationKey": { "placeId": "ChIJ3a2l4X0RrjsRggWzPz6Q0xM" }, "latlng": { "latitude": 12.969414, "longitude": 77.705732 }, "languageCode": "en", "address": { "regionCode": "IN", "languageCode": "en", "postalCode": "560037", "administrativeArea": "Karnataka", "locality": "Bengaluru", "addressLines": [ "# 51, Shanti Nivas 7th Cross chinapanahalli", "Doddanekundi, Ext" ] } }, "requestAdminRightsUrl": "https://business.google.com/arc/p/ChIJ3a2l4X0RrjsRggWzPz6Q0xM" } ] }';
  static GoogleLocationsResponse googleLocationsResponse =
      GoogleLocationsResponse.fromJson(json.decode(responseString));

  final GoogleLocation googleLocation =
      googleLocationsResponse.googleLocations[0];

  static const routeName = '/location-verify';
  LocationVerifyPage({Key key}) : super(key: key);

  @override
  _LocationVerifyPageState createState() => _LocationVerifyPageState();
}

class _LocationVerifyPageState extends State<LocationVerifyPage>
    with AfterLayoutMixin<LocationVerifyPage> {
  Completer<GoogleMapController> _controller = Completer();
  @override
  void afterFirstLayout(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify business."),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 32.0,
            ),
            Container(
              child: ListTile(
                title: Text(widget.googleLocation.location.locationName ?? ''),
                subtitle: Text(
                    '# 51, Shanti Nivas 7th Cross chinapanahalli, "Doddanekundi, Ext, Bengaluru, Karnataka'),
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
                'Enter the 5-digit verification code mailed to this address on Nov 21, 2019. Postcards take about 12 days to arrive.',
                style: Theme.of(context).textTheme.subtitle,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
              ),
              child: TextFormField(
                // controller: this._loginBloc.otpEditController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Enter code",
                ),
                maxLength: 5,
                // validator: (String value) {
                //   return value.length < 1
                //       ? AppTranslations.of(context)
                //           .text("otp_page_enter_otp_validation")
                //       : null;
                // },
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              width: double.infinity,
              child: RaisedButton(
                onPressed: () {},
                child: Text('Verify'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
