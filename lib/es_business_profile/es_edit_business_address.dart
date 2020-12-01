import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/bloc/es_business_profile.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';

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
      Position pos = await Geolocator.getLastKnownPosition();
      print(pos);
      if (pos != null) {
        widget.esBusinessProfileBloc
            .setCurrentLocationPoint(pos.latitude, pos.longitude);
      } else {
        print(pos);
        Position posCurrent = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
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

  @override
  Widget build(BuildContext context) {
    onSuccess() {
      Navigator.of(context).pop();
    }

    onFail() {
      this._showFailedAlertDialog();
    }

    submit(bool isLocationValid) {
      if (this._formKey.currentState.validate() && isLocationValid) {
        widget.esBusinessProfileBloc.updateAddress(onSuccess, onFail);
      } else {
        Fluttertoast.showToast(msg: "Invalid Address");
      }
    }

    navigateToMap(LatLng initialPosition) async {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlacePicker(
            apiKey: "AIzaSyBGRrg0YVy9U3SUF34GoAeGbUP_s5RAYAY",
            initialPosition: initialPosition,
            onPlacePicked: (result) async {
              await widget.esBusinessProfileBloc.updateLocationField(result);
              WidgetsBinding.instance
                  .addPostFrameCallback((timeStamp) => Navigator.pop(context));
            },
            useCurrentLocation: true,
            autocompleteTypes: ["address"],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.of(context)
              .text('profile_page_update_business_address'),
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
                      child: GestureDetector(
                        onTap: () => navigateToMap(LatLng(
                          snapshot.data.currentLocationPoint.lat,
                          snapshot.data.currentLocationPoint.lon,
                        )),
                        child: TextFormField(
                          controller: widget
                              .esBusinessProfileBloc.addressEditController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: AppTranslations.of(context)
                                .text('profile_page_address'),
                          ),
                          maxLines: 5,
                          minLines: 1,
                          enabled: false,
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
              text: AppTranslations.of(context).text('generic_save'),
              onPressed: () => submit(
                snapshot.data.currentLocationPoint.lat != null &&
                    snapshot.data.currentLocationPoint.lon != null,
              ),
              isLoading: snapshot.data.isSubmitting,
            );
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
