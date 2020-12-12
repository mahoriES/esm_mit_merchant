import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_address_bloc.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class GoogleMapView extends StatefulWidget {
  final VoidCallback goToConfirmLocation;
  GoogleMapView({@required this.goToConfirmLocation});
  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  Completer<GoogleMapController> _controller = Completer();
  EsAddressBloc _esVideoBloc;

  @override
  void initState() {
    _esVideoBloc = Provider.of<EsAddressBloc>(context, listen: false);
    _esVideoBloc.getInitialLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EsAddressState>(
      stream: _esVideoBloc.esAddressStateObservable,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        // if address was selected from search , then animate map location to the selected address.
        if (snapshot.data.suggestionsStatus == LaodingStatus.SUCCESS) {
          _controller.future.then(
            (mapController) {
              WidgetsBinding.instance.addPostFrameCallback(
                (timeStamp) {
                  mapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                          target: snapshot.data.location, zoom: 14.4746),
                    ),
                  );
                },
              );
            },
          );

          // reset the seardh details to avoid animating the map multiple times.
          // _esVideoBloc.resetSearchDetails();
        }

        return snapshot.data.isLocationNull || snapshot.data.location == null
            ? Center(child: CircularProgressIndicator())
            : GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: snapshot.data.location,
                  zoom: 14.4746,
                ),
                markers: Set<Marker>.from(
                  [
                    new Marker(
                      markerId: new MarkerId("pinLocation"),
                      position: snapshot.data.location,
                    ),
                  ],
                ),
                onMapCreated: (controllerValue) => setState(() {
                  _controller.complete(controllerValue);
                }),
                zoomGesturesEnabled: true,
                zoomControlsEnabled: false,
                onCameraMove: (CameraPosition position) =>
                    _esVideoBloc.updateMarkerPosition(position.target),
                onCameraIdle: () {
                  debugPrint("*********************** on Idle");
                  _esVideoBloc.getAddressForLocation(snapshot.data.location);
                },
                onCameraMoveStarted: widget.goToConfirmLocation,
                myLocationEnabled: true,
                compassEnabled: true,
                myLocationButtonEnabled: true,
              );
      },
    );
  }
}
