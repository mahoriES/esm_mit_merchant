import 'package:foore/data/model/gmb_location.dart';

class GoogleLocationsResponse {
  List<GoogleLocation> googleLocations;

  GoogleLocationsResponse({this.googleLocations});

  GoogleLocationsResponse.fromJson(Map<String, dynamic> json) {
    googleLocations = new List<GoogleLocation>();
    if (json['googleLocations'] != null) {
      json['googleLocations'].forEach((v) {
        googleLocations.add(new GoogleLocation.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.googleLocations != null) {
      data['googleLocations'] =
          this.googleLocations.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GoogleLocation {
  String name;
  GmbLocationItem location;
  String requestAdminRightsUrl;

  GoogleLocation({this.name, this.location, this.requestAdminRightsUrl});

  GoogleLocation.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    location = json['location'] != null
        ? new GmbLocationItem.fromJson(json['location'])
        : null;
    requestAdminRightsUrl = json['requestAdminRightsUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    if (this.location != null) {
      data['location'] = this.location.toJson();
    }
    data['requestAdminRightsUrl'] = this.requestAdminRightsUrl;
    return data;
  }
}

class GmbLocationItem {
  String name;
  String locationName;
  PrimaryCategory primaryCategory;
  String websiteUrl;
  LocationKey locationKey;
  Latlng latlng;
  String languageCode;
  Address address;
  LocationState locationState;

  GmbLocationItem({
    this.name,
    this.locationName,
    this.primaryCategory,
    this.websiteUrl,
    this.locationKey,
    this.latlng,
    this.languageCode,
    this.address,
    this.locationState,
  });

  GmbLocationItem.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    locationName = json['locationName'];
    primaryCategory = json['primaryCategory'] != null
        ? new PrimaryCategory.fromJson(json['primaryCategory'])
        : null;
    websiteUrl = json['websiteUrl'];
    locationKey = json['locationKey'] != null
        ? new LocationKey.fromJson(json['locationKey'])
        : null;
    latlng =
        json['latlng'] != null ? new Latlng.fromJson(json['latlng']) : null;
    languageCode = json['languageCode'];
    address =
        json['address'] != null ? new Address.fromJson(json['address']) : null;
    locationState = json['locationState'] != null
        ? new LocationState.fromJson(json['locationState'])
        : null;
  }

  GmbLocationItem.fromGmbLocation(GmbLocation location) {
    name = location.gmbLocationTpId;
    locationName = location.gmbLocationName;
    latlng = location.gmbLocationLatLong != null
        ? new Latlng.fromJson(location.gmbLocationLatLong.toJson())
        : null;
    address = location.gmbLocationAddress != null
        ? new Address.fromJson(location.gmbLocationAddress.toJson())
        : null;
    locationState = location.gmbLocationState != null
        ? new LocationState.fromJson(location.gmbLocationState.toJson())
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['locationName'] = this.locationName;
    if (this.primaryCategory != null) {
      data['primaryCategory'] = this.primaryCategory.toJson();
    }
    data['websiteUrl'] = this.websiteUrl;
    if (this.locationKey != null) {
      data['locationKey'] = this.locationKey.toJson();
    }
    if (this.latlng != null) {
      data['latlng'] = this.latlng.toJson();
    }
    data['languageCode'] = this.languageCode;
    if (this.address != null) {
      data['address'] = this.address.toJson();
    }
    if (this.locationState != null) {
      data['locationState'] = this.locationState.toJson();
    }
    return data;
  }
}

class PrimaryCategory {
  String displayName;
  String categoryId;

  PrimaryCategory({this.displayName, this.categoryId});

  PrimaryCategory.fromJson(Map<String, dynamic> json) {
    displayName = json['displayName'];
    categoryId = json['categoryId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['displayName'] = this.displayName;
    data['categoryId'] = this.categoryId;
    return data;
  }
}

class LocationKey {
  String placeId;

  LocationKey({this.placeId});

  LocationKey.fromJson(Map<String, dynamic> json) {
    placeId = json['placeId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['placeId'] = this.placeId;
    return data;
  }
}

class Latlng {
  double latitude;
  double longitude;

  Latlng({this.latitude, this.longitude});

  Latlng.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    return data;
  }
}

class Address {
  String regionCode;
  String languageCode;
  String postalCode;
  String administrativeArea;
  String locality;
  List<String> addressLines;

  Address(
      {this.regionCode,
      this.languageCode,
      this.postalCode,
      this.administrativeArea,
      this.locality,
      this.addressLines});

  Address.fromJson(Map<String, dynamic> json) {
    regionCode = json['regionCode'];
    languageCode = json['languageCode'];
    postalCode = json['postalCode'];
    administrativeArea = json['administrativeArea'];
    locality = json['locality'];
    if (json['addressLines'] != null) {
      addressLines = json['addressLines'].cast<String>();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['regionCode'] = this.regionCode;
    data['languageCode'] = this.languageCode;
    data['postalCode'] = this.postalCode;
    data['administrativeArea'] = this.administrativeArea;
    data['locality'] = this.locality;
    data['addressLines'] = this.addressLines;
    return data;
  }
}

class LocationState {
  bool canUpdate;
  bool canDelete;
  bool isDisconnected;
  bool hasPendingVerification;

  LocationState(
      {this.canUpdate,
      this.canDelete,
      this.isDisconnected,
      this.hasPendingVerification});

  LocationState.fromJson(Map<String, dynamic> json) {
    canUpdate = json['canUpdate'];
    canDelete = json['canDelete'];
    isDisconnected = json['isDisconnected'];
    hasPendingVerification = json['hasPendingVerification'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['canUpdate'] = this.canUpdate;
    data['canDelete'] = this.canDelete;
    data['isDisconnected'] = this.isDisconnected;
    data['hasPendingVerification'] = this.hasPendingVerification;
    return data;
  }
}
