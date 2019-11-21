import 'dart:async';
import 'dart:convert';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/search_gmb/model/google_locations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationClaimPage extends StatefulWidget {
  static const responseString =
      '{ "googleLocations": [ { "name": "googleLocations/ChIJ3a2l4X0RrjsRggWzPz6Q0xM", "location": { "locationName": "Mukesh Realtors", "primaryCategory": { "displayName": "Property management company", "categoryId": "gcid:property_management_company" }, "locationKey": { "placeId": "ChIJ3a2l4X0RrjsRggWzPz6Q0xM" }, "latlng": { "latitude": 12.969414, "longitude": 77.705732 }, "languageCode": "en", "address": { "regionCode": "IN", "languageCode": "en", "postalCode": "560037", "administrativeArea": "Karnataka", "locality": "Bengaluru", "addressLines": [ "# 51, Shanti Nivas 7th Cross chinapanahalli", "Doddanekundi, Ext" ] } }, "requestAdminRightsUrl": "https://business.google.com/arc/p/ChIJ3a2l4X0RrjsRggWzPz6Q0xM" } ] }';
  static GoogleLocationsResponse googleLocationsResponse =
      GoogleLocationsResponse.fromJson(json.decode(responseString));

  final GoogleLocation googleLocation =
      googleLocationsResponse.googleLocations[0];

  static const routeName = '/location-claim';
  LocationClaimPage({Key key}) : super(key: key);

  @override
  _LocationClaimPageState createState() => _LocationClaimPageState();
}

class _LocationClaimPageState extends State<LocationClaimPage>
    with AfterLayoutMixin<LocationClaimPage> {
  Completer<GoogleMapController> _controller = Completer();
  @override
  void afterFirstLayout(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Claim business"),
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
            Container(
              height: 200.0,
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12.0))),
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    widget.googleLocation.location.latlng.latitude,
                    widget.googleLocation.location.latlng.longitude,
                  ),
                  zoom: 14.4746,
                ),
                markers: Set.from([
                  Marker(
                    position: LatLng(
                      widget.googleLocation.location.latlng.latitude,
                      widget.googleLocation.location.latlng.longitude,
                    ),
                    markerId: MarkerId('fooreMarker'),
                  )
                ]),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              width: double.infinity,
              child: RaisedButton(
                onPressed: () {},
                child: Text('Manage this business'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
