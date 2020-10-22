import 'package:foore/data/model/es_business.dart';
import 'package:intl/intl.dart';

class FreeFormItemStatus {
  static String isAvailable = 'IS_AVAILABLE';
  static String added = 'FREE_FORM_ADDED';
  static String notAdded = 'FREE_FORM_NOT_ADDED';
}

class CatalogueItemStatus {
  static String isAvailable = 'IS_AVAILABLE';
  static String notPresent = 'NOT_IN_STOCK';
  static String createdByMerchant = 'CREATED_IN_CATALOGUE';
  // static String permanantlyUnavailable = 'PERMANENTLY_UNAVAILABLE';
}

class EsOrderStatus {
  static const CREATED = 'CREATED';
  static const MERCHANT_ACCEPTED = 'MERCHANT_ACCEPTED';
  static const READY_FOR_PICKUP = 'READY_FOR_PICKUP';
  static const REQUESTING_TO_DA = 'REQUESTING_TO_DA';
  static const COMPLETED = 'COMPLETED';
  static const MERCHANT_CANCELLED = 'MERCHANT_CANCELLED';
  static const MERCHANT_UPDATED = 'MERCHANT_UPDATED';
  static const ASSIGNED_TO_DA = 'ASSIGNED_TO_DA';
  static const PICKED_UP_BY_DA = 'PICKED_UP_BY_DA';
  static const CUSTOMER_CANCELLED = 'CUSTOMER_CANCELLED';
  static const ALL_ORDERS = 'ALL_ORDERS';
}

class EsOrderPaymentStatus {
  static const PENDING = 'PENDING';
  static const INITIATED = 'INITIATED';
  static const APPROVED = 'APPROVED';
  static const REJECTED = 'REJECTED';

  static String paymentString(paymentStatus) {
    String paymentString = "Payment pending";
    switch (paymentStatus) {
      case EsOrderPaymentStatus.INITIATED:
        paymentString = "Customer Paid";
        break;
      case EsOrderPaymentStatus.APPROVED:
        paymentString = "Payment Approved";
        break;
      case EsOrderPaymentStatus.REJECTED:
        paymentString = "Payment Rejected";
        break;
    }
    return paymentString;
  }
}

class EsGetOrdersResponse {
  int count;
  String next;
  String previous;
  List<EsOrder> results;

  EsGetOrdersResponse({this.count, this.next, this.previous, this.results});

  EsGetOrdersResponse.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      results = new List<EsOrder>();
      json['results'].forEach((v) {
        results.add(new EsOrder.fromJson(v));
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

class EsOrder {
  String orderId;
  String orderShortNumber;
  String deliveryType;
  String orderStatus;
  int itemTotal;
  int otherCharges;
  int orderTotal;
  List<BusinessImages> businessImages;
  String businessName;
  String clusterName;
  String customerName;
  String customerNote;
  PickupAddress pickupAddress;
  EsAddress deliveryAddress;
  String cancellationNote;
  List<String> businessPhones;
  List<String> customerPhones;
  String created;
  List<EsOrderItem> orderItems;
  EsOrderPaymentInfo paymentInfo;

  get dPaymentStatus {
    return paymentInfo == null
        ? EsOrderPaymentStatus.PENDING
        : paymentInfo.paymentStatus;
  }

  get dPaymentDateTimeString {
    return paymentInfo == null ? null : paymentInfo.lastUpdated;
  }

  get dIsStatusNew {
    bool withCustomer = false;

    switch (this.orderStatus) {
      case EsOrderStatus.CREATED:
      case EsOrderStatus.MERCHANT_UPDATED:
        withCustomer = true;
        break;
    }
    return withCustomer;
  }

  get dIsStatusCancelled {
    bool isCancelled = false;

    switch (this.orderStatus) {
      case EsOrderStatus.CUSTOMER_CANCELLED:
      case EsOrderStatus.MERCHANT_CANCELLED:
        isCancelled = true;
        break;
    }
    return isCancelled;
  }

  get dIsStatusComplete {
    return this.orderStatus == EsOrderStatus.COMPLETED;
  }

  get dDeliveryType {
    if (this.deliveryType == 'SELF_PICK_UP') {
      return 'Self Pickup';
    }
    return 'Delivery';
  }

  get dIsDelivery {
    return this.deliveryType != 'SELF_PICK_UP';
  }

  String getCreatedTimeText() {
    var lastInteractionDate = DateTime.parse(this.created).toLocal();
    var formatter = new DateFormat('hh:mm a, dd MMM, yyyy');
    String timeText = formatter.format(lastInteractionDate);
    return timeText;
  }

  String getTimeDiffrence() {
    DateTime createdAt = DateTime.parse(this.created).toLocal();
    DateTime currentTime = DateTime.now();
    Duration diffrence = currentTime.difference(createdAt);

    String displayText;

    if (diffrence.inSeconds < 60)
      displayText =
          '${diffrence.inSeconds} second${diffrence.inSeconds > 1 ? 's' : ''} ago';
    else if (diffrence.inMinutes < 60)
      displayText =
          '${diffrence.inMinutes} minute${diffrence.inMinutes > 1 ? 's' : ''} ago';
    else if (diffrence.inHours < 24)
      displayText =
          '${diffrence.inHours} hour${diffrence.inHours > 1 ? 's' : ''} ago';
    else if (diffrence.inDays < 7)
      displayText =
          '${diffrence.inDays} day${diffrence.inDays > 1 ? 's' : ''} ago';
    else if (diffrence.inDays < 31)
      displayText =
          '${diffrence.inDays ~/ 7} week${diffrence.inDays ~/ 7 > 1 ? 's' : ''} ago';
    else
      displayText =
          '${diffrence.inDays ~/ 31} month${diffrence.inDays ~/ 31 > 1 ? 's' : ''} ago';

    return displayText;
  }

  get dStatusString {
    String statusString = "Unknown";
    switch (this.orderStatus) {
      case EsOrderStatus.CREATED:
        statusString = "New";
        break;
      case EsOrderStatus.COMPLETED:
        statusString = "Complete";
        break;
      case EsOrderStatus.MERCHANT_ACCEPTED:
        statusString = "Preparing";
        break;
      case EsOrderStatus.MERCHANT_CANCELLED:
        statusString = "Merchant Cancelled";
        break;
      case EsOrderStatus.READY_FOR_PICKUP:
        statusString = "Ready";
        break;
      case EsOrderStatus.REQUESTING_TO_DA:
        statusString = "Searching Agent";
        break;
      case EsOrderStatus.ASSIGNED_TO_DA:
        statusString = "Agent Assigned";
        break;
      case EsOrderStatus.CUSTOMER_CANCELLED:
        statusString = "Customer cancelled";
        break;
      case EsOrderStatus.MERCHANT_UPDATED:
        statusString = "Merchant updated";
        break;
      case EsOrderStatus.PICKED_UP_BY_DA:
        statusString = "Delivering";
        break;
      case EsOrderStatus.READY_FOR_PICKUP:
        statusString = "Waiting pickup";
        break;
      default:
    }
    return statusString;
  }

  get dIsNew {
    return this.orderStatus == EsOrderStatus.CREATED;
  }

  get dIsPreparing {
    return this.orderStatus == EsOrderStatus.MERCHANT_ACCEPTED;
  }

  get dIsReady {
    return this.orderStatus == EsOrderStatus.READY_FOR_PICKUP;
  }

  get dIsShowAssign {
    return this.orderStatus == EsOrderStatus.READY_FOR_PICKUP && dIsDelivery;
  }

  get dIsShowComplete {
    return this.orderStatus == EsOrderStatus.READY_FOR_PICKUP && !dIsDelivery;
  }

  String get dOrderTotal {
    return orderTotal != null ? '${getPrice(orderTotal)}' : '₹ 0.00';
  }

  String getPrice(price) {
    return NumberFormat.simpleCurrency(locale: 'en_IN').format(price / 100);
  }

  EsOrder(
      {this.orderId,
      this.orderShortNumber,
      this.deliveryType,
      this.orderStatus,
      this.itemTotal,
      this.otherCharges,
      this.orderTotal,
      this.businessImages,
      this.businessName,
      this.clusterName,
      this.customerName,
      this.customerNote,
      this.pickupAddress,
      this.deliveryAddress,
      this.cancellationNote,
      this.businessPhones,
      this.customerPhones,
      this.created,
      this.paymentInfo});

  static getItems(Map<String, dynamic> json) {
    var items = new List<EsOrderItem>();
    if (json['order_items'] != null) {
      json['order_items'].forEach((v) {
        var item = new EsOrderItem.fromJson(v);
        items.add(item);
      });
    }
    return items;
  }

  EsOrder.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    orderShortNumber = json['order_short_number'];
    deliveryType = json['delivery_type'];
    orderStatus = json['order_status'];
    itemTotal = json['item_total'];
    otherCharges = json['other_charges'];
    orderTotal = json['order_total'];
    if (json['business_images'] != null) {
      businessImages = new List<BusinessImages>();
      json['business_images'].forEach((v) {
        businessImages.add(new BusinessImages.fromJson(v));
      });
    }
    businessName = json['business_name'];
    clusterName = json['cluster_name'];
    customerName = json['customer_name'];
    customerNote = json['customer_note'];
    pickupAddress = json['pickup_address'] != null
        ? new PickupAddress.fromJson(json['pickup_address'])
        : null;
    if (json['delivery_address'] != null) {
      deliveryAddress = EsAddress.fromJson(json['delivery_address']);
    }
    cancellationNote = json['cancellation_note'];
    businessPhones = json['business_phones'].cast<String>();
    customerPhones = json['customer_phones'].cast<String>();
    created = json['created'];
    paymentInfo = json['payment_info'] != null
        ? EsOrderPaymentInfo.fromJson(json['payment_info'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_id'] = this.orderId;
    data['order_short_number'] = this.orderShortNumber;
    data['delivery_type'] = this.deliveryType;
    data['order_status'] = this.orderStatus;
    data['item_total'] = this.itemTotal;
    data['other_charges'] = this.otherCharges;
    data['order_total'] = this.orderTotal;
    if (this.businessImages != null) {
      data['business_images'] =
          this.businessImages.map((v) => v.toJson()).toList();
    }
    data['business_name'] = this.businessName;
    data['cluster_name'] = this.clusterName;
    data['customer_name'] = this.customerName;
    data['customer_note'] = this.customerNote;
    if (this.pickupAddress != null) {
      data['pickup_address'] = this.pickupAddress.toJson();
    }
    data['delivery_address'] = this.deliveryAddress;
    data['cancellation_note'] = this.cancellationNote;
    data['business_phones'] = this.businessPhones;
    data['customer_phones'] = this.customerPhones;
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

class EsCancelOrderPayload {
  String cancellationNote;

  EsCancelOrderPayload({this.cancellationNote});

  EsCancelOrderPayload.fromJson(Map<String, dynamic> json) {
    cancellationNote = json['cancellation_note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cancellation_note'] = this.cancellationNote;
    return data;
  }
}

class EsRequestDeliveryPayload {
  List<String> deliveryagentIds;

  EsRequestDeliveryPayload({this.deliveryagentIds});

  EsRequestDeliveryPayload.fromJson(Map<String, dynamic> json) {
    deliveryagentIds = json['deliveryagent_ids'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['deliveryagent_ids'] = this.deliveryagentIds;
    return data;
  }
}

class EsDeliveryAgent {
  String name;
  String phone;
  String deliveryagentId;

  bool dIsSelected = false;

  selectAgent(bool isSelected) {
    this.dIsSelected = isSelected;
  }

  EsDeliveryAgent({this.name, this.phone, this.deliveryagentId});

  EsDeliveryAgent.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    phone = json['phone'];
    deliveryagentId = json['deliveryagent_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['deliveryagent_id'] = this.deliveryagentId;
    return data;
  }
}

class EsOrderItem {
  String productName;
  int itemQuantity;
  double unitPrice;
  String itemTotal;
  String skuId;
  //We will just use the first key for variation. This will break in future.
  String variationOption;
  // used to track the availability status of item.
  String itemStatus;

  EsOrderItem({
    this.skuId,
    this.productName,
    this.itemQuantity,
    this.itemTotal,
    this.unitPrice,
    this.itemStatus,
  });

  EsOrderItem.fromJson(
    Map<String, dynamic> inputJson, {
    bool divideUnitPriceBy100 = true,
  }) {
    // All the items available initially are added by customer, so by default it's status would be IS_AVAILABLE.
    itemStatus = CatalogueItemStatus.isAvailable;
    productName = inputJson['product_name'];
    itemQuantity = inputJson['quantity'];
    unitPrice = double.tryParse(
            (inputJson['unit_price'] / (divideUnitPriceBy100 ? 100 : 1))
                .toString()) ??
        0;
    itemTotal = getPrice(itemQuantity * unitPrice);
    skuId = inputJson['sku_id'].toString();

    if (inputJson.containsKey('variation_option') &&
        inputJson['variation_option'] != null) {
      if (inputJson['variation_option'] is String) {
        variationOption = inputJson['variation_option'];
      } else {
        Map<String, dynamic> variationOptions = inputJson['variation_option'];
        if (variationOptions.isNotEmpty) {
          variationOption = variationOptions.values.toList()[0];
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_name'] = this.productName;
    data['quantity'] = this.itemQuantity;
    data['unit_price'] = this.unitPrice;
    data['sku_id'] = this.skuId;
    data['variation_option'] = this.variationOption;
    return data;
  }

  String getPrice(price) {
    return NumberFormat.simpleCurrency(locale: 'en_IN').format(price);
  }

  @override
  String toString() {
    return productName +
        "  x  " +
        itemQuantity.toString() +
        "      " +
        itemTotal.toString();
  }
}

class EsOrderPaymentInfo {
  String paymentStatus;
  String lastUpdated;

  EsOrderPaymentInfo({this.paymentStatus, this.lastUpdated});

  EsOrderPaymentInfo.fromJson(Map<String, dynamic> inputJson) {
    paymentStatus = inputJson['status'];
    lastUpdated = inputJson['dt'];
  }
}
