import 'es_clusters.dart';
import 'es_video_models/es_video_list.dart';

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
    print("<< EsGetBusinessesResponse.fromJson: " + results.length.toString());
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
  String description;
  String notice;
  int status;
  bool isOpen;
  EsAddress address;
  EsTiming timing;
  List<EsImages> images;
  List<String> phones;
  List<EsBusinessCategory> businessCategories;
  bool hasDelivery;
  EsCluster cluster;
  EsBusinessPaymentInfo paymentInfo;
  EsBusinessNotificationInfo notificationInfo;

  get dBusinessName {
    if (businessName != null) {
      return businessName;
    }
    return '';
  }

  get dBusinessNotice {
    if (notice != null) {
      return notice;
    }
    return '';
  }

  get dBusinessDescription {
    if (description != null) {
      return description;
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

  get dBusinessNotApproved {
    return status == 1;
  }

  get dBusinessPincode {
    if (address != null) {
      if (address.geoAddr.pincode != null) {
        if (address.geoAddr.pincode != null) {
          return address.geoAddr.pincode;
        }
      }
    }
    return '';
  }

  get dBusinessCity {
    if (address != null) {
      if (address.geoAddr.city != null) {
        if (address.geoAddr.city != null) {
          return address.geoAddr.city;
        }
      }
    }
    return '';
  }

  get dBusinessClusterCode {
    if (cluster != null) {
      if (cluster.clusterCode != null) {
        return cluster.clusterCode;
      }
    }
    return '';
  }

  get dBusinessClusterName {
    if (cluster != null) {
      if (cluster.clusterName != null) {
        return cluster.clusterName;
      }
    }
    return '';
  }

  List<String> get dPhones {
    if (phones != null) {
      return phones.map((phone) {
        if (phone != null) {
          return phone;
        }
        return '';
      }).toList();
    }
    return [];
  }

  List<EsImages> get dImages {
    if (images != null) {
      return images;
    }
    return [];
  }

  get dBusinessPaymentUpiAddress {
    if (paymentInfo != null) {
      if (paymentInfo.upiAddress != null) {
        return paymentInfo.upiAddress;
      }
    }
    return '';
  }

  bool get dBusinessPaymentStatus {
    return (paymentInfo != null) && (paymentInfo.upiStatus == true);
  }

  bool get notificationEmailStatus =>
      (notificationInfo != null) && (notificationInfo.notifyViaEmail == true);

  bool get notificationPhoneStatus =>
      (notificationInfo != null) && (notificationInfo.notifyViaPhone == true);

  List<String> get notificationEmails {
    if (notificationInfo != null &&
        notificationInfo.notificationEmails != null) {
      return notificationInfo.notificationEmails;
    }
    return List<String>();
  }

  List<String> get notificationPhones {
    if (notificationInfo != null &&
        notificationInfo.notificationPhones != null) {
      return notificationInfo.notificationPhones;
    }
    return List<String>();
  }

  List<String> get businessCategoriesNamesList {
    if (businessCategories != null && businessCategories.isNotEmpty)
      return businessCategories.map((e) => e.name).toList();
    return List<String>();
  }

  EsBusinessInfo(
      {this.businessId,
      this.businessName,
      this.notice,
      this.status,
      this.isOpen,
      this.address,
      this.timing,
      this.images,
      this.description,
      this.phones,
      this.hasDelivery,
      this.businessCategories,
      this.cluster,
      this.paymentInfo,
      this.notificationInfo});

  EsBusinessInfo.fromJson(Map<String, dynamic> json) {
    businessId = json['business_id'];
    businessName = json['business_name'];
    description = json['description'];
    notice = json['notice'];
    status = json['status'];
    isOpen = json['is_open'];
    address = json['address'] != null
        ? new EsAddress.fromJson(json['address'])
        : null;
    timing =
        json['timing'] != null ? new EsTiming.fromJson(json['timing']) : null;

    if (json['images'] != null) {
      images = new List<EsImages>();
      json['images'].forEach((v) {
        images.add(new EsImages.fromJson(v));
      });
    }
    if (json['bcats'] != null && json['bcats'] is List) {
      businessCategories = List<EsBusinessCategory>();
      json['bcats']?.forEach((json){
        businessCategories.add(EsBusinessCategory.fromJson(json));
      });
    }
    phones = json['phones'].cast<String>();
    hasDelivery = json['has_delivery'];
    cluster = json['cluster'] != null
        ? new EsCluster.fromJson(json['cluster'])
        : null;
    paymentInfo = json['payment_info'] != null
        ? new EsBusinessPaymentInfo.fromJson(json['payment_info'])
        : null;

    notificationInfo = json['notification_info'] != null
        ? new EsBusinessNotificationInfo.fromJson(json['notification_info'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['business_id'] = this.businessId;
    data['business_name'] = this.businessName;
    data['description'] = this.description;
    data['notice'] = this.notice;
    data['status'] = this.status;
    data['is_open'] = this.isOpen;
    if (this.address != null) {
      data['address'] = this.address.toJson();
    }
    if (this.timing != null) {
      data['timing'] = this.timing.toJson();
    }
    data['phones'] = this.phones;
    data['has_delivery'] = this.hasDelivery;
    if (this.cluster != null) {
      data['cluster'] = this.cluster.toJson();
    }
    if (this.images != null) {
      data['images'] = this.images.map((v) => v.toJson()).toList();
    }
    if (this.businessCategories != null) {
      data['bcats'] = this.businessCategories.map((e) => e.toJson()).toList();
    }
    if (this.paymentInfo != null) {
      data['payment_info'] = this.paymentInfo.toJson();
    }
    return data;
  }
}

class EsBusinessCategory {
  int bcat;
  bool isActive;
  String name;
  String description;
  Photo image;

  EsBusinessCategory.fromJson(Map<String, dynamic> json) {
    bcat = json['bcat'];
    isActive = json['is_active'];
    name = json['name'];
    description = json['description'];
    if (json['image'] != null && json['image'] is Map) {
      image = Photo.fromJson(json['image']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['bcat'] = this.bcat;
    data['name'] = this.name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EsBusinessCategory &&
          runtimeType == other.runtimeType &&
          bcat == other.bcat;

  @override
  int get hashCode => bcat.hashCode;
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
  String landmark;
  String house;

  EsGeoAddr({this.pincode, this.city, this.house, this.landmark});

  EsGeoAddr.fromJson(Map<String, dynamic> json) {
    pincode = json['pincode'];
    city = json['city'];
    landmark = json['landmark'];
    house = json['house'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pincode'] = this.pincode;
    data['city'] = this.city;
    data['landmark'] = this.landmark;
    data['house'] = this.house;
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

class EsUpdateBusinessPayload {
  String businessId;
  String businessName;
  int status;
  bool isOpen;
  EsAddress address;
  EsTiming timing;
  List<EsImages> images;
  List<String> phones;
  bool hasDelivery;
  EsCluster cluster;
  String description;
  String notice;
  String upiAddress;
  bool upiStatus;
  List<String> notificationEmails;
  List<String> notificationPhones;
  bool notifyViaPhone;
  bool notifyViaEmail;
  List<int> businessCategories;

  EsUpdateBusinessPayload(
      {this.businessId,
      this.businessName,
      this.status,
      this.isOpen,
      this.address,
      this.timing,
      this.images,
      this.phones,
      this.hasDelivery,
      this.cluster,
      this.description,
      this.businessCategories,
      this.notice,
      this.upiAddress,
      this.upiStatus,
      this.notificationEmails,
      this.notificationPhones,
      this.notifyViaEmail,
      this.notifyViaPhone});

  EsUpdateBusinessPayload.fromJson(Map<String, dynamic> json) {
    businessId = json['business_id'];
    businessName = json['business_name'];
    status = json['status'];
    isOpen = json['is_open'];
    address = json['address'] != null
        ? new EsAddress.fromJson(json['address'])
        : null;
    timing =
        json['timing'] != null ? new EsTiming.fromJson(json['timing']) : null;
    if (json['images'] != null) {
      images = new List<EsImages>();
      json['images'].forEach((v) {
        images.add(new EsImages.fromJson(v));
      });
    }
    if (json['bcats'] != null && json['bcats'] is List) {
      businessCategories = List<int>();
      json['bcats']?.forEach((json){
        businessCategories.add(EsBusinessCategory.fromJson(json).bcat);
      });
    }
    phones = json['phones'].cast<String>();
    hasDelivery = json['has_delivery'];
    cluster = json['cluster'] != null
        ? new EsCluster.fromJson(json['cluster'])
        : null;
    description = json['description'];
    notice = json['notice'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.businessId != null) {
      data['business_id'] = this.businessId;
    }

    if (this.businessName != null) {
      data['business_name'] = this.businessName;
    }

    if (this.status != null) {
      data['status'] = this.status;
    }

    if (this.isOpen != null) {
      data['is_open'] = this.isOpen;
    }

    if (this.businessCategories != null) {
      data['bcats'] = this.businessCategories;
    }

    if (this.address != null) {
      data['address'] = this.address.toJson();
    }
    if (this.timing != null) {
      data['timing'] = this.timing.toJson();
    }
    if (this.images != null) {
      data['images'] = this.images.map((v) => v.toJson()).toList();
    }

    if (this.phones != null) {
      data['phones'] = this.phones;
    }

    if (this.hasDelivery != null) {
      data['has_delivery'] = this.hasDelivery;
    }

    if (this.cluster != null) {
      data['cluster'] = this.cluster.toJson();
    }

    if (this.description != null) {
      data['description'] = this.description;
    }

    if (this.notice != null) {
      data['notice'] = this.notice;
    }

    if (this.upiAddress != null) {
      data['upi'] = this.upiAddress;
    }
    if (this.upiStatus != null) {
      data['upi_status'] = (this.upiStatus == true);
    }

    if (this.notifyViaEmail != null) {
      data['notify_via_email'] = (this.notifyViaEmail == true);
    }

    if (this.notifyViaPhone != null) {
      data['notify_via_phone'] = (this.notifyViaPhone == true);
    }

    if (this.notificationEmails != null) {
      data['notification_emails'] = this.notificationEmails;
    }

    if (this.notificationPhones != null) {
      data['notification_phones'] = this.notificationPhones;
    }

    return data;
  }
}

class EsImages {
  String photoId;
  String photoUrl;
  String contentType;

  EsImages({this.photoId, this.photoUrl, this.contentType});

  EsImages.fromJson(Map<String, dynamic> json) {
    photoId = json['photo_id'];
    photoUrl = json['photo_url'];
    contentType = json['content_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['photo_id'] = this.photoId;
    if (this.photoUrl != null) {
      data['photo_url'] = this.photoUrl;
    }
    if (this.contentType != null) {
      data['content_type'] = this.contentType;
    }
    return data;
  }
}

class EsAddressPayload {
  String addressName;
  String prettyAddress;
  double lat;
  double lon;
  EsGeoAddr geoAddr;

  EsAddressPayload(
      {this.addressName, this.prettyAddress, this.lat, this.lon, this.geoAddr});

  EsAddressPayload.fromJson(Map<String, dynamic> json) {
    addressName = json['address_name'];
    prettyAddress = json['pretty_address'];
    lat = json['lat'];
    lon = json['lon'];
    geoAddr = json['geo_addr'] != null
        ? new EsGeoAddr.fromJson(json['geo_addr'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address_name'] = this.addressName;
    data['pretty_address'] = this.prettyAddress;
    data['lat'] = this.lat;
    data['lon'] = this.lon;
    if (this.geoAddr != null) {
      data['geo_addr'] = this.geoAddr.toJson();
    }
    return data;
  }
}

class EsBusinessPaymentInfo {
  String upiAddress;
  bool upiStatus;

  EsBusinessPaymentInfo({this.upiAddress, this.upiStatus});

  EsBusinessPaymentInfo.fromJson(Map<String, dynamic> json) {
    upiAddress = json['upi'];
    upiStatus = json['upi_active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['upi'] = this.upiAddress;
    data['upi_status'] = this.upiStatus;

    return data;
  }
}

class EsBusinessNotificationInfo {
  List<String> notificationEmails;
  List<String> notificationPhones;
  bool notifyViaEmail;
  bool notifyViaPhone;
  EsBusinessNotificationInfo(
      {this.notificationEmails,
      this.notificationPhones,
      this.notifyViaEmail,
      this.notifyViaPhone});

  EsBusinessNotificationInfo.fromJson(Map<String, dynamic> json) {
    //"notification_emails":null,"notification_phones":null,"notify_via_email":false,"notify_via_phone":false

    notificationEmails = json['notification_emails'] == null
        ? []
        : json['notification_emails'].cast<String>();
    notificationPhones = json['notification_phones'] == null
        ? []
        : json['notification_phones'].cast<String>();
    notifyViaEmail = json['notify_via_email'];
    notifyViaPhone = json['notify_via_phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['notification_emails'] = this.notificationEmails;
    data['notification_phones'] = this.notificationPhones;
    data['notify_via_email'] = this.notifyViaEmail;
    data['notify_via_phone'] = this.notifyViaPhone;
    return data;
  }
}
