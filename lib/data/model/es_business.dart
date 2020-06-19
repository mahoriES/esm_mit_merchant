import 'es_clusters.dart';

class EsCreateBusinessPayload {
  String businessName;
  String clusterCode;

  EsCreateBusinessPayload({this.businessName, this.clusterCode});

  EsCreateBusinessPayload.fromJson(Map<String, dynamic> json) {
    businessName = json['business_name'];
    clusterCode = json['cluster_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['business_name'] = this.businessName;
    data['cluster_code'] = this.clusterCode;
    return data;
  }
}

class EsGetBusinessesResponse {
  int count;
  String next;
  String previous;
  List<EsBusinessInfo> results;

  EsGetBusinessesResponse({this.count, this.next, this.previous, this.results});

  EsGetBusinessesResponse.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      results = new List<EsBusinessInfo>();
      json['results'].forEach((v) {
        results.add(new EsBusinessInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    data['next'] = this.next;
    data['previous'] = this.previous;
    if (this.results != null) {
      data['results'] = this.results.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EsBusinessInfo {
  String businessId;
  String businessName;
  int status;
  bool isOpen;
  EsAddress address;
  EsTiming timing;
  List<String> images;
  List<String> phones;
  bool hasDelivery;
  EsCluster cluster;

  get dBusinessName {
    if (businessName != null) {
      return businessName;
    }
    return ''; 
  }

  get dBusinessPrettyAddress {
    if (address != null) {
      if (address.prettyAddress != null) {
        return address.prettyAddress;
      }
    }
      return '';
  }

  EsBusinessInfo(
      {this.businessId,
      this.businessName,
      this.status,
      this.isOpen,
      this.address,
      this.timing,
      this.images,
      this.phones,
      this.hasDelivery,
      this.cluster});

  EsBusinessInfo.fromJson(Map<String, dynamic> json) {
    businessId = json['business_id'];
    businessName = json['business_name'];
    status = json['status'];
    isOpen = json['is_open'];
    address = json['address'] != null
        ? new EsAddress.fromJson(json['address'])
        : null;
    timing =
        json['timing'] != null ? new EsTiming.fromJson(json['timing']) : null;
    images = json['images'].cast<String>();
    phones = json['phones'].cast<String>();
    hasDelivery = json['has_delivery'];
    cluster = json['cluster'] != null
        ? new EsCluster.fromJson(json['cluster'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['business_id'] = this.businessId;
    data['business_name'] = this.businessName;
    data['status'] = this.status;
    data['is_open'] = this.isOpen;
    if (this.address != null) {
      data['address'] = this.address.toJson();
    }
    if (this.timing != null) {
      data['timing'] = this.timing.toJson();
    }
    data['images'] = this.images;
    data['phones'] = this.phones;
    data['has_delivery'] = this.hasDelivery;
    if (this.cluster != null) {
      data['cluster'] = this.cluster.toJson();
    }
    return data;
  }
}

class EsAddress {
  String addressId;
  String addressName;
  String prettyAddress;
  EsLocationPoint locationPoint;
  EsGeoAddr geoAddr;

  EsAddress(
      {this.addressId,
      this.addressName,
      this.prettyAddress,
      this.locationPoint,
      this.geoAddr});

  EsAddress.fromJson(Map<String, dynamic> json) {
    addressId = json['address_id'];
    addressName = json['address_name'];
    prettyAddress = json['pretty_address'];
    locationPoint = json['location_point'] != null
        ? new EsLocationPoint.fromJson(json['location_point'])
        : null;
    geoAddr = json['geo_addr'] != null
        ? new EsGeoAddr.fromJson(json['geo_addr'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address_id'] = this.addressId;
    data['address_name'] = this.addressName;
    data['pretty_address'] = this.prettyAddress;
    if (this.locationPoint != null) {
      data['location_point'] = this.locationPoint.toJson();
    }
    if (this.geoAddr != null) {
      data['geo_addr'] = this.geoAddr.toJson();
    }
    return data;
  }
}

class EsLocationPoint {
  double lon;
  double lat;

  EsLocationPoint({this.lon, this.lat});

  EsLocationPoint.fromJson(Map<String, dynamic> json) {
    lon = json['lon'];
    lat = json['lat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lon'] = this.lon;
    data['lat'] = this.lat;
    return data;
  }
}

class EsGeoAddr {
  String pincode;
  String city;

  EsGeoAddr({this.pincode, this.city});

  EsGeoAddr.fromJson(Map<String, dynamic> json) {
    pincode = json['pincode'];
    city = json['city'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pincode'] = this.pincode;
    data['city'] = this.city;
    return data;
  }
}

class EsTiming {
  List<String> mONDAY;

  EsTiming({this.mONDAY});

  EsTiming.fromJson(Map<String, dynamic> json) {
    mONDAY = json['MONDAY'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MONDAY'] = this.mONDAY;
    return data;
  }
}
