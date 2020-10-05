import 'package:foore/data/model/es_orders.dart';

class FreeFormItemStatus {
  static String isAvailable = 'IS_AVAILABLE';
  static String added = 'FREE_FORM_ADDED';
  static String notAdded = 'FREE_FORM_NOT_ADDED';
}

class CatalogueItemStatus {
  static String addedToOrder = 'IS_AVAILABLE';
  static String notPresent = 'NOT_IN_STOCK';
  static String createdInCatalogue = 'CREATED_IN_CATALOGUE';
  // static String permanantlyUnavailable = 'PERMANENTLY_UNAVAILABLE';
}

class UpdateOrderItemsPayload {
  List<UpdateOrderItems> orderItems;
  List<FreeFormItems> freeFormItems;

  UpdateOrderItemsPayload({
    this.orderItems,
    this.freeFormItems,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.orderItems != null) {
      data['order_items'] = this.orderItems.map((v) => v.toJson()).toList();
    }
    if (this.freeFormItems != null) {
      data['free_form_items'] = [
        ...this.freeFormItems.map((v) => v.toJson()).toList()
      ];
    }
    return data;
  }
}

class UpdateOrderItems {
  int skuId;
  int quantity;
  String productStatus;
  double unitPriceInRupee;

  UpdateOrderItems({
    this.skuId,
    this.quantity,
    this.productStatus,
    this.unitPriceInRupee,
  });
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sku_id'] = this.skuId;
    data['quantity'] = this.quantity;
    if (this.productStatus != null) data['product_status'] = this.productStatus;
    data['unit_price'] = this.unitPriceInRupee * 100;
    return data;
  }
}

class EsOrderDetailsResponse {
  String orderId;
  String businessId;
  String orderShortNumber;
  String deliveryType;
  String orderStatus;
  int itemTotal;
  int otherCharges;
  int deliveryCharges;
  int orderTotal;
  List<BusinessImages> businessImages;
  String businessName;
  String clusterName;
  String customerName;
  String customerNote;
  List<String> customerNoteImages;
  PickupAddress pickupAddress;
  PickupAddress deliveryAddress;
  String cancellationNote;
  List<String> businessPhones;
  List<String> customerPhones;
  List<EsOrderItem> orderItems;
  List<FreeFormItems> freeFormItems;
  List<OtherChargesDetail> otherChargesDetail;
  List<OrderTrail> orderTrail;
  String created;
  String modified;
  Rating rating;
  PaymentInfo paymentInfo;

  EsOrderDetailsResponse(
      {this.orderId,
      this.businessId,
      this.orderShortNumber,
      this.deliveryType,
      this.orderStatus,
      this.itemTotal,
      this.otherCharges,
      this.deliveryCharges,
      this.orderTotal,
      this.businessImages,
      this.businessName,
      this.clusterName,
      this.customerName,
      this.customerNote,
      this.customerNoteImages,
      this.pickupAddress,
      this.deliveryAddress,
      this.cancellationNote,
      this.businessPhones,
      this.customerPhones,
      this.orderItems,
      this.freeFormItems,
      this.otherChargesDetail,
      this.orderTrail,
      this.created,
      this.modified,
      this.rating,
      this.paymentInfo});

  EsOrderDetailsResponse.fromJson(
    Map<String, dynamic> json, {
    bool divideUnitPriceBy100 = true,
  }) {
    orderId = json['order_id'];
    businessId = json['business_id'];
    orderShortNumber = json['order_short_number'];
    deliveryType = json['delivery_type'];
    orderStatus = json['order_status'];
    itemTotal = json['item_total'];
    otherCharges = json['other_charges'];
    deliveryCharges = json['delivery_charges'];
    orderTotal = json['order_total'];
    if (json['business_images'] != null) {
      businessImages = new List<BusinessImages>();
      json['business_images'].forEach((v) {
        businessImages.add(new BusinessImages.fromJson(v));
      });
    } else
      businessImages = [];
    businessName = json['business_name'];
    clusterName = json['cluster_name'];
    customerName = json['customer_name'];
    customerNote = json['customer_note'];
    customerNoteImages = json['customer_note_images'] != null
        ? json['customer_note_images'].cast<String>()
        : [];
    pickupAddress = json['pickup_address'] != null
        ? new PickupAddress.fromJson(json['pickup_address'])
        : null;
    deliveryAddress = json['delivery_address'] != null
        ? new PickupAddress.fromJson(json['delivery_address'])
        : null;
    cancellationNote = json['cancellation_note'];
    businessPhones = json['business_phones'] != null
        ? json['business_phones'].cast<String>()
        : [];
    customerPhones = json['customer_phones'] != null
        ? json['customer_phones'].cast<String>()
        : [];
    if (json['order_items'] != null) {
      orderItems = new List<EsOrderItem>();
      json['order_items'].forEach((v) {
        orderItems.add(new EsOrderItem.fromJson(
          v,
          divideUnitPriceBy100: divideUnitPriceBy100,
        ));
      });
    } else {
      orderItems = [];
    }
    if (json['free_form_items'] != null) {
      freeFormItems = new List<FreeFormItems>();
      json['free_form_items'].forEach((v) {
        freeFormItems.add(new FreeFormItems.fromJson(v));
      });
    } else {
      freeFormItems = [];
    }
    if (json['other_charges_detail'] != null) {
      otherChargesDetail = new List<OtherChargesDetail>();
      json['other_charges_detail'].forEach((v) {
        otherChargesDetail.add(new OtherChargesDetail.fromJson(v));
      });
    } else {
      otherChargesDetail = [];
    }
    if (json['order_trail'] != null) {
      orderTrail = new List<OrderTrail>();
      json['order_trail'].forEach((v) {
        orderTrail.add(new OrderTrail.fromJson(v));
      });
    } else {
      orderTrail = [];
    }
    created = json['created'];
    modified = json['modified'];
    rating =
        json['rating'] != null ? new Rating.fromJson(json['rating']) : null;
    paymentInfo = json['payment_info'] != null
        ? new PaymentInfo.fromJson(json['payment_info'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_id'] = this.orderId;
    data['business_id'] = this.businessId;
    data['order_short_number'] = this.orderShortNumber;
    data['delivery_type'] = this.deliveryType;
    data['order_status'] = this.orderStatus;
    data['item_total'] = this.itemTotal;
    data['other_charges'] = this.otherCharges;
    data['delivery_charges'] = this.deliveryCharges;
    data['order_total'] = this.orderTotal;
    if (this.businessImages != null) {
      data['business_images'] =
          this.businessImages.map((v) => v.toJson()).toList();
    }
    data['business_name'] = this.businessName;
    data['cluster_name'] = this.clusterName;
    data['customer_name'] = this.customerName;
    data['customer_note'] = this.customerNote;
    data['customer_note_images'] = this.customerNoteImages;
    if (this.pickupAddress != null) {
      data['pickup_address'] = this.pickupAddress.toJson();
    }
    if (this.deliveryAddress != null) {
      data['delivery_address'] = this.deliveryAddress.toJson();
    }
    data['cancellation_note'] = this.cancellationNote;
    data['business_phones'] = this.businessPhones;
    data['customer_phones'] = this.customerPhones;
    if (this.orderItems != null) {
      data['order_items'] = this.orderItems.map((v) => v.toJson()).toList();
    }
    if (this.freeFormItems != null) {
      data['free_form_items'] =
          this.freeFormItems.map((v) => v.toJson()).toList();
    }
    if (this.otherChargesDetail != null) {
      data['other_charges_detail'] =
          this.otherChargesDetail.map((v) => v.toJson()).toList();
    }
    if (this.orderTrail != null) {
      data['order_trail'] = this.orderTrail.map((v) => v.toJson()).toList();
    }
    data['created'] = this.created;
    data['modified'] = this.modified;
    if (this.rating != null) {
      data['rating'] = this.rating.toJson();
    }
    if (this.paymentInfo != null) {
      data['payment_info'] = this.paymentInfo.toJson();
    }
    return data;
  }
}

class BusinessImages {
  String photoId;
  String photoUrl;
  String contentType;

  BusinessImages({this.photoId, this.photoUrl, this.contentType});

  BusinessImages.fromJson(Map<String, dynamic> json) {
    photoId = json['photo_id'];
    photoUrl = json['photo_url'];
    contentType = json['content_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['photo_id'] = this.photoId;
    data['photo_url'] = this.photoUrl;
    data['content_type'] = this.contentType;
    return data;
  }
}

class PickupAddress {
  GeoAddr geoAddr;
  String addressId;
  String addressName;
  LocationPoint locationPoint;
  String prettyAddress;

  PickupAddress(
      {this.geoAddr,
      this.addressId,
      this.addressName,
      this.locationPoint,
      this.prettyAddress});

  PickupAddress.fromJson(Map<String, dynamic> json) {
    geoAddr = json['geo_addr'] != null
        ? new GeoAddr.fromJson(json['geo_addr'])
        : null;
    addressId = json['address_id'];
    addressName = json['address_name'];
    locationPoint = json['location_point'] != null
        ? new LocationPoint.fromJson(json['location_point'])
        : null;
    prettyAddress = json['pretty_address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.geoAddr != null) {
      data['geo_addr'] = this.geoAddr.toJson();
    }
    data['address_id'] = this.addressId;
    data['address_name'] = this.addressName;
    if (this.locationPoint != null) {
      data['location_point'] = this.locationPoint.toJson();
    }
    data['pretty_address'] = this.prettyAddress;
    return data;
  }
}

class GeoAddr {
  String city;
  String pincode;

  GeoAddr({this.city, this.pincode});

  GeoAddr.fromJson(Map<String, dynamic> json) {
    city = json['city'];
    pincode = json['pincode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['city'] = this.city;
    data['pincode'] = this.pincode;
    return data;
  }
}

class LocationPoint {
  double lat;
  double lon;

  LocationPoint({this.lat, this.lon});

  LocationPoint.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lon = json['lon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lat'] = this.lat;
    data['lon'] = this.lon;
    return data;
  }
}

class VariationOption {
  String weight;

  VariationOption({this.weight});

  VariationOption.fromJson(Map<String, dynamic> json) {
    weight = json['Weight'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Weight'] = this.weight;
    return data;
  }
}

class SkuCharges {
  SkuCharges();

  SkuCharges.fromJson(Map<String, dynamic> json) {
    //
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    return data;
  }
}

class FreeFormItems {
  int quantity;
  String skuName;
  String productStatus;

  FreeFormItems({
    this.quantity,
    this.skuName,
    this.productStatus,
  });

  FreeFormItems.fromJson(Map<String, dynamic> json) {
    quantity = json['quantity'];
    skuName = json['sku_name'];
    productStatus = json['product_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['quantity'] = this.quantity;
    data['sku_name'] = this.skuName;
    if (this.productStatus != null) data['product_status'] = this.productStatus;
    return data;
  }
}

class OtherChargesDetail {
  String name;
  int value;

  OtherChargesDetail({this.name, this.value});

  OtherChargesDetail.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['value'] = this.value;
    return data;
  }
}

class OrderTrail {
  String eventName;
  SkuCharges eventInfo;
  String created;

  OrderTrail({this.eventName, this.eventInfo, this.created});

  OrderTrail.fromJson(Map<String, dynamic> json) {
    eventName = json['event_name'];
    eventInfo = json['event_info'] != null
        ? new SkuCharges.fromJson(json['event_info'])
        : null;
    created = json['created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['event_name'] = this.eventName;
    if (this.eventInfo != null) {
      data['event_info'] = this.eventInfo.toJson();
    }
    data['created'] = this.created;
    return data;
  }
}

class Rating {
  int ratingValue;
  String ratingComment;

  Rating({this.ratingValue, this.ratingComment});

  Rating.fromJson(Map<String, dynamic> json) {
    ratingValue = json['rating_value'];
    ratingComment = json['rating_comment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rating_value'] = this.ratingValue;
    data['rating_comment'] = this.ratingComment;
    return data;
  }
}

class PaymentInfo {
  String upi;
  String status;
  var dt;

  PaymentInfo({this.upi, this.status, this.dt});

  PaymentInfo.fromJson(Map<String, dynamic> json) {
    upi = json['upi'];
    status = json['status'];
    dt = json['dt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['upi'] = this.upi;
    data['status'] = this.status;
    data['dt'] = this.dt;
    return data;
  }
}
