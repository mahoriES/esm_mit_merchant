import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/bloc/es_business_profile.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EsEditBusinessAddressPage extends StatefulWidget {
  static const routeName = '/create-business-page';

  final EsBusinessProfileBloc esBusinessProfileBloc;

  EsEditBusinessAddressPage(this.esBusinessProfileBloc);

  @override
  EsEditBusinessAddressPageState createState() =>
      EsEditBusinessAddressPageState();
}

class EsEditBusinessAddressPageState extends State<EsEditBusinessAddressPage>
    with AfterLayoutMixin<EsEditBusinessAddressPage> {
  final _formKey = GlobalKey<FormState>();

  Completer<GoogleMapController> _isReady = Completer();

  getPosition() async {
    try {
      Position pos = await Geolocator()
          .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
      print(pos);
      if (pos != null) {
        widget.esBusinessProfileBloc
            .setCurrentLocationPoint(pos.latitude, pos.longitude);
      } else {
        print(pos);
        Position posCurrent = await Geolocator()
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        if (posCurrent != null) {
          widget.esBusinessProfileBloc.setCurrentLocationPoint(
              posCurrent.latitude, posCurrent.longitude);
        }
      }
    } catch (err) {
      print(err);
    }
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

  @override
  void afterFirstLayout(BuildContext context) {
    getPosition();
  }

  Future<bool> _onWillPop() async {
    Navigator.pop(context);
    return false;
  }

  @override
  void initState() {
    super.initState();
  }

  // Set<Marker> markers = Set.from([]);

  // setMarkers(LatLng latLang) async {
  //   final Marker marker =
  //       Marker(markerId: MarkerId('foMarker'), position: latLang);
  //   setState(() {
  //     this.markers = Set.from([marker]);
  //   });
  // }

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
        widget.esBusinessProfileBloc.updateAddress(onSuccess, onFail);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update business address',
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
              var latLang = LatLng(
                0,
                0,
              );
              Set<Marker> markers = Set.from([]);
              if (snapshot.data.currentLocationPoint != null) {
                latLang = LatLng(
                  snapshot.data.currentLocationPoint.lat ?? 0,
                  snapshot.data.currentLocationPoint.lon ?? 0,
                );
                // this.setMarkers(latLang);
                final Marker marker =
                    Marker(markerId: MarkerId('foMarker'), position: latLang);
                markers = Set.from([marker]);
                _isReady.future.then((controller) {
                  controller.moveCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: latLang,
                        zoom: 14.4746,
                      ),
                    ),
                  );
                });
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
                            widget.esBusinessProfileBloc.addressEditController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Address',
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
                            widget.esBusinessProfileBloc.pinCodeEditController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Pin code',
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
                            widget.esBusinessProfileBloc.cityEditController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'City',
                        ),
                      ),
                    ),
                    Container(
                      height: 200,
                      // width: 500,
                      padding: EdgeInsets.all(20),
                      child: GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                          target: latLang,
                          zoom: 14.4746,
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          _isReady.complete(controller);
                        },
                        markers: markers,
                        onCameraMove: (CameraPosition position) {},
                        onTap: (LatLng latLng) {
                          widget.esBusinessProfileBloc.setCurrentLocationPoint(
                              latLng.latitude, latLang.longitude);
                          // this.setMarkers(latLang);
                        },
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
