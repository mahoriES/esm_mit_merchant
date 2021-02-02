import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/data/constants/string_constants.dart';
import 'package:foore/data/model/es_business.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:uuid/uuid.dart';

class EsAddressBloc {
  EsAddressState esAddressState = new EsAddressState();

  BehaviorSubject<EsAddressState> _subjectEsAddressState;

  EsAddressBloc() {
    _subjectEsAddressState =
        new BehaviorSubject<EsAddressState>.seeded(esAddressState);
  }

  Observable<EsAddressState> get esAddressStateObservable =>
      _subjectEsAddressState.stream;

  reset() {
    esAddressState = new EsAddressState();
    _updateState();
  }

  getInitialLocation() async {
    esAddressState.addressStatus = LaodingStatus.LOADING;
    _updateState();

    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final LatLng _latLng = LatLng(position.latitude, position.longitude);

      getAddressForLocation(_latLng);

      esAddressState.locationPoints =
          LatLng(position.latitude, position.longitude);

      esAddressState.addressStatus = LaodingStatus.SUCCESS;
    } catch (e) {
      esAddressState.addressStatus = LaodingStatus.FAILURE;
      Fluttertoast.showToast(msg: "Could not find current location");
    }
    _updateState();
  }

  getAddressForLocation(LatLng position) async {
    try {
      esAddressState.addressStatus = LaodingStatus.LOADING;
      _updateState();

      final List<Address> address =
          await Geocoder.local.findAddressesFromCoordinates(
        new Coordinates(position.latitude, position.longitude),
      );

      if (address != null && address.isNotEmpty) {
        esAddressState.prettyAddress = address.first.addressLine;
        esAddressState.pinCode = address.first.postalCode;
        esAddressState.city = address.first.subLocality;

        esAddressState.addressStatus = LaodingStatus.SUCCESS;
      } else {
        throw Exception();
      }
    } catch (e) {
      esAddressState.addressStatus = LaodingStatus.FAILURE;
      Fluttertoast.showToast(msg: "Could not fetch address");
    }

    _updateState();
  }

  updateMarkerPosition(LatLng position) {
    esAddressState.locationPoints =
        LatLng(position.latitude, position.longitude);
    _updateState();
  }

  resetSearchDetails() {
    esAddressState.suggestionsStatus = LaodingStatus.IDLE;
    _updateState();
  }

  addAddress() {
    esAddressState.selectedAddressRequest = new EsAddressPayload(
      addressName: "",
      prettyAddress: esAddressState.prettyAddress,
      lat: esAddressState.locationPoints.latitude,
      lon: esAddressState.locationPoints.longitude,
      geoAddr: new EsGeoAddr(
        pincode: esAddressState.pinCode,
        city: esAddressState.city,
        house: esAddressState.houseNumberController.text,
        landmark: esAddressState.landMarkController.text,
      ),
    );
    _updateState();
  }

  Future<List<Prediction>> getSuggestions(
    String input,
    BuildContext context,
  ) async {
    if (input.isEmpty) return null;
    try {
      final PlacesAutocompleteResponse geocodingResponse =
          await new GoogleMapsPlaces(apiKey: StringConstants.googleApiKey)
              .autocomplete(
        input,
        sessionToken: esAddressState.sessionToken,
        components: [Component("country", "in")],
      );

      if (geocodingResponse.isOkay || geocodingResponse.hasNoResults) {
        return geocodingResponse?.predictions ?? List<Prediction>();
      } else if (geocodingResponse.isOverQueryLimit) {
        Fluttertoast.showToast(
          msg: AppTranslations.of(context).text("address_over_query_error"),
        );
      } else {
        throw Exception();
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: AppTranslations.of(context).text("generic_something_went_wrong"),
      );
    }
    return null;
  }

  getPlaceDetails(String placeId) async {
    try {
      esAddressState.suggestionsStatus = LaodingStatus.LOADING;
      _updateState();

      final PlacesDetailsResponse placesDetailsResponse =
          await new GoogleMapsPlaces(apiKey: StringConstants.googleApiKey)
              .getDetailsByPlaceId(
        placeId,
        sessionToken: esAddressState.sessionToken,
        fields: StringConstants.placeDetailFields,
      );

      if (placesDetailsResponse.isOkay) {
        final PlaceDetails placeDetails = placesDetailsResponse.result;
        String _pinCode = "";
        String _city = "";

        placeDetails.addressComponents.forEach((element) {
          if (element.types.contains("postal_code")) {
            _pinCode = element.longName ?? "";
          } else if (element.types.contains("administrative_area_level_2")) {
            _city = element.longName ?? "";
          }
        });

        esAddressState.suggestionsStatus = LaodingStatus.SUCCESS;

        esAddressState.prettyAddress = placeDetails.formattedAddress;
        esAddressState.locationPoints = LatLng(
            placeDetails.geometry.location.lat,
            placeDetails.geometry.location.lng);
        esAddressState.pinCode = _pinCode;
        esAddressState.city = _city;

        esAddressState.sessionToken = new Uuid().v4();
      } else if (placesDetailsResponse.hasNoResults) {
        Fluttertoast.showToast(msg: "No Results Found");
        esAddressState.suggestionsStatus = LaodingStatus.FAILURE;
      } else {
        throw Exception();
      }
    } catch (e) {
      esAddressState.suggestionsStatus = LaodingStatus.FAILURE;
      Fluttertoast.showToast(msg: "Some Error Occured");
    }
    _updateState();
  }

  _updateState() {
    if (!_subjectEsAddressState.isClosed) {
      _subjectEsAddressState.sink.add(esAddressState);
    }
  }

  dispose() {
    _subjectEsAddressState.close();
  }
}

class EsAddressState {
  List<EsAddressPayload> savedAddressList;
  LaodingStatus addressStatus;
  LaodingStatus suggestionsStatus;
  EsAddressPayload selectedAddressRequest;
  String sessionToken;
  String prettyAddress;
  LatLng locationPoints;
  String pinCode;
  String city;
  TextEditingController houseNumberController;
  TextEditingController landMarkController;

  String get formattedAddressWithDeatails {
    return (selectedAddressRequest?.geoAddr?.house ?? "") +
        ", " +
        (selectedAddressRequest?.geoAddr?.landmark ?? "") +
        "\n" +
        (selectedAddressRequest?.prettyAddress ?? "");
  }

  bool get isLocationNull =>
      locationPoints?.latitude == null || locationPoints?.longitude == null;

  bool get isAddressUpdated => selectedAddressRequest != null;

  bool get isSelectedAddressValid =>
      selectedAddressRequest != null &&
      selectedAddressRequest?.lat != null &&
      selectedAddressRequest?.lon != null;

  EsAddressState() {
    this.savedAddressList = [];
    this.addressStatus = LaodingStatus.IDLE;
    this.suggestionsStatus = LaodingStatus.IDLE;
    this.selectedAddressRequest = null;
    sessionToken = new Uuid().v4();
    prettyAddress = "";
    locationPoints = null;
    pinCode = null;
    city = null;
    houseNumberController = new TextEditingController();
    landMarkController = new TextEditingController();
  }
}

enum LaodingStatus { LOADING, SUCCESS, FAILURE, IDLE }
