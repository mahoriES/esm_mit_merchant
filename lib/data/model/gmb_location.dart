class GmbLocation {
  String gmbLocationId;
  String gmbLocationTpId;
  String gmbLocationName;
  GmbLocationCategory gmbLocationCategory;
  GmbLocationLatLong gmbLocationLatLong;
  GmbLocationState gmbLocationState;
  GmbLocationAddress gmbLocationAddress;
  bool isSelectedUi;

  GmbLocation(
      {this.gmbLocationId,
      this.gmbLocationTpId,
      this.gmbLocationName,
      this.gmbLocationCategory,
      this.gmbLocationLatLong,
      this.gmbLocationState,
      this.gmbLocationAddress});

  GmbLocation.fromJson(Map<String, dynamic> json) {
    gmbLocationId = json['gmb_location_id'];
    gmbLocationTpId = json['gmb_location_tp_id'];
    gmbLocationName = json['gmb_location_name'];
    gmbLocationCategory = json['gmb_location_category'] != null
        ? new GmbLocationCategory.fromJson(json['gmb_location_category'])
        : null;
    gmbLocationLatLong = json['gmb_location_lat_long'] != null
        ? new GmbLocationLatLong.fromJson(json['gmb_location_lat_long'])
        : null;
    gmbLocationState = json['gmb_location_state'] != null
        ? new GmbLocationState.fromJson(json['gmb_location_state'])
        : null;
    gmbLocationAddress = json['gmb_location_address'] != null
        ? new GmbLocationAddress.fromJson(json['gmb_location_address'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['gmb_location_id'] = this.gmbLocationId;
    data['gmb_location_tp_id'] = this.gmbLocationTpId;
    data['gmb_location_name'] = this.gmbLocationName;
    if (this.gmbLocationCategory != null) {
      data['gmb_location_category'] = this.gmbLocationCategory.toJson();
    }
    if (this.gmbLocationLatLong != null) {
      data['gmb_location_lat_long'] = this.gmbLocationLatLong.toJson();
    }
    if (this.gmbLocationState != null) {
      data['gmb_location_state'] = this.gmbLocationState.toJson();
    }
    if (this.gmbLocationAddress != null) {
      data['gmb_location_address'] = this.gmbLocationAddress.toJson();
    }
    return data;
  }
}

class GmbLocationCategory {
  String categoryId;
  String displayName;

  GmbLocationCategory({this.categoryId, this.displayName});

  GmbLocationCategory.fromJson(Map<String, dynamic> json) {
    categoryId = json['categoryId'];
    displayName = json['displayName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['categoryId'] = this.categoryId;
    data['displayName'] = this.displayName;
    return data;
  }
}

class GmbLocationLatLong {
  double latitude;
  double longitude;

  GmbLocationLatLong({this.latitude, this.longitude});

  GmbLocationLatLong.fromJson(Map<String, dynamic> json) {
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

class GmbLocationState {
  bool canDelete;
  bool canUpdate;
  bool isDisconnected;
  bool isVerified;
  bool hasPendingVerification;

  GmbLocationState({this.canDelete, this.canUpdate, this.isDisconnected});

  GmbLocationState.fromJson(Map<String, dynamic> json) {
    canDelete = json['canDelete'];
    canUpdate = json['canUpdate'];
    isDisconnected = json['isDisconnected'];
    isVerified = json['isVerified'];
    hasPendingVerification = json['hasPendingVerification'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['canDelete'] = this.canDelete;
    data['canUpdate'] = this.canUpdate;
    data['isDisconnected'] = this.isDisconnected;
    data['isVerified'] = this.isVerified;
    data['hasPendingVerification'] = this.hasPendingVerification;
    return data;
  }
}

class GmbLocationAddress {
  String locality;
  String postalCode;
  String regionCode;
  List<String> addressLines;
  String languageCode;
  String administrativeArea;

  GmbLocationAddress(
      {this.locality,
      this.postalCode,
      this.regionCode,
      this.addressLines,
      this.languageCode,
      this.administrativeArea});

  GmbLocationAddress.fromJson(Map<String, dynamic> json) {
    locality = json['locality'];
    postalCode = json['postalCode'];
    regionCode = json['regionCode'];
    addressLines = json['addressLines'].cast<String>();
    languageCode = json['languageCode'];
    administrativeArea = json['administrativeArea'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['locality'] = this.locality;
    data['postalCode'] = this.postalCode;
    data['regionCode'] = this.regionCode;
    data['addressLines'] = this.addressLines;
    data['languageCode'] = this.languageCode;
    data['administrativeArea'] = this.administrativeArea;
    return data;
  }
}
