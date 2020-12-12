import 'package:fluttertoast/fluttertoast.dart';
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

      esAddressState.tempAddressRequest =
          esAddressState.tempAddressRequest.copyWith(
        lat: position.latitude,
        lon: position.longitude,
      );
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
        esAddressState.tempAddressRequest =
            esAddressState.tempAddressRequest.copyWith(
          prettyAddress: address.first.addressLine,
          geoAddr: esAddressState.tempAddressRequest.geoAddr.copyWith(
            pincode: address.first.postalCode,
            city: address.first.subLocality,
          ),
        );
        esAddressState.addressStatus = LaodingStatus.SUCCESS;
      } else {
        throw ("");
      }
    } catch (e) {
      esAddressState.addressStatus = LaodingStatus.FAILURE;
      Fluttertoast.showToast(msg: "Could not fetch address");
    }

    _updateState();
  }

  updateMarkerPosition(LatLng position) {
    esAddressState.tempAddressRequest =
        esAddressState.tempAddressRequest.copyWith(
      lat: position.latitude,
      lon: position.longitude,
    );
    _updateState();
  }

  resetSearchDetails() {
    esAddressState.suggestionsStatus = LaodingStatus.IDLE;
    esAddressState.placesSearchResponse = null;
    _updateState();
  }

  addAddress(String house, String landMark) {
    esAddressState.tempAddressRequest =
        esAddressState.tempAddressRequest.copyWith(
      addressName: "",
      geoAddr: esAddressState.tempAddressRequest.geoAddr.copyWith(
        house: house,
        landmark: landMark,
      ),
    );
    esAddressState.selectedAddressRequest = esAddressState.tempAddressRequest;
    _updateState();
  }

  getSuggestions(String input) async {
    try {
      final PlacesAutocompleteResponse geocodingResponse =
          await new GoogleMapsPlaces(apiKey: StringConstants.googleApiKey)
              .autocomplete(
        input,
        sessionToken: esAddressState.sessionToken,
        types: ["address"],
        components: [Component("country", "in")],
      );

      if (geocodingResponse.isOkay || geocodingResponse.hasNoResults) {
        esAddressState.placesSearchResponse = geocodingResponse;

        print(
            "got suggestions => ${esAddressState.placesSearchResponse.predictions.length}");
      } else {
        throw ("");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Some Error Occured");
    }
    _updateState();
  }

  getPlaceDetails(String placeId) async {
    try {
      final PlacesDetailsResponse placesDetailsResponse =
          await new GoogleMapsPlaces(apiKey: StringConstants.googleApiKey)
              .getDetailsByPlaceId(
        placeId,
        sessionToken: esAddressState.sessionToken,
      );

      if (placesDetailsResponse.isOkay) {
        final PlaceDetails placeDetails = placesDetailsResponse.result;
        String pinCode = "";
        String city = "";

        placeDetails.addressComponents.forEach((element) {
          if (element.types.contains("postal_code")) {
            pinCode = element.longName ?? "";
          } else if (element.types.contains("administrative_area_level_2")) {
            city = element.longName ?? "";
          }
        });

        esAddressState.suggestionsStatus = LaodingStatus.SUCCESS;
        esAddressState.tempAddressRequest =
            esAddressState.tempAddressRequest.copyWith(
          prettyAddress: placeDetails.formattedAddress,
          lat: placeDetails.geometry.location.lat,
          lon: placeDetails.geometry.location.lng,
          geoAddr: esAddressState.tempAddressRequest.geoAddr.copyWith(
            pincode: pinCode,
            city: city,
          ),
        );
      } else if (placesDetailsResponse.hasNoResults) {
        Fluttertoast.showToast(msg: "No Results Found");
        esAddressState.suggestionsStatus = LaodingStatus.FAILURE;
      } else {
        throw ("");
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
  EsAddressPayload tempAddressRequest;
  EsAddressPayload selectedAddressRequest;
  PlacesAutocompleteResponse placesSearchResponse;
  String sessionToken;

  LatLng get location => LatLng(tempAddressRequest.lat, tempAddressRequest.lon);

  bool get isLocationNull =>
      tempAddressRequest?.lat == null || tempAddressRequest?.lon == null;

  String get prettyAddress => tempAddressRequest.prettyAddress ?? "";

  EsAddressState() {
    this.savedAddressList = [];
    this.addressStatus = LaodingStatus.IDLE;
    this.suggestionsStatus = LaodingStatus.IDLE;
    this.tempAddressRequest = EsAddressPayload(geoAddr: new EsGeoAddr());
    this.selectedAddressRequest = null;
    placesSearchResponse = null;
    sessionToken = new Uuid().v4();
  }
}

enum LaodingStatus { LOADING, SUCCESS, FAILURE, IDLE }
