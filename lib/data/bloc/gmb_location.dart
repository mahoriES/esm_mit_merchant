
class GmbLocation {
  String gmbLocationId;
  GmbLocationAddress gmbLocationAddress;
  String gmbLocationName;
  String gmbLocationMapUrl;

  GmbLocation(
      {this.gmbLocationId,
      this.gmbLocationAddress,
      this.gmbLocationName,
      this.gmbLocationMapUrl});

  GmbLocation.fromJson(Map<String, dynamic> json) {
    gmbLocationId = json['gmb_location_id'];
    gmbLocationAddress = json['gmb_location_address'] != null
        ? new GmbLocationAddress.fromJson(json['gmb_location_address'])
        : null;
    gmbLocationName = json['gmb_location_name'];
    gmbLocationMapUrl = json['gmb_location_map_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['gmb_location_id'] = this.gmbLocationId;
    if (this.gmbLocationAddress != null) {
      data['gmb_location_address'] = this.gmbLocationAddress.toJson();
    }
    data['gmb_location_name'] = this.gmbLocationName;
    data['gmb_location_map_url'] = this.gmbLocationMapUrl;
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