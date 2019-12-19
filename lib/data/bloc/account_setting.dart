import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foore/data/http_service.dart';
import 'package:rxdart/rxdart.dart';

class AccountSettingBloc {
  final AccountSettingState _accountSettingState = AccountSettingState();
  final HttpService httpService;

  BehaviorSubject<AccountSettingState> _subjectAccountSettingState;

  AccountSettingBloc({@required this.httpService}) {
    this._subjectAccountSettingState =
        new BehaviorSubject<AccountSettingState>.seeded(_accountSettingState);
  }

  Observable<AccountSettingState> get accountSettingStateObservable =>
      _subjectAccountSettingState.stream;

  getData() {
    this._accountSettingState.isLoading = true;
    this._accountSettingState.isLoadingFailed = false;
    this._updateState();
    httpService
        .foGet(
            'ui/helper/account/?gmb_locations&location_connections&locations')
        .then((httpResponse) {
      if (httpResponse.statusCode == 200) {
        this._accountSettingState.response =
            UiHelperResponse.fromJson(json.decode(httpResponse.body));
        print(httpResponse.body);
        this._accountSettingState.isLoadingFailed = false;
        this._accountSettingState.isLoading = false;
      } else {
        this._accountSettingState.isLoadingFailed = true;
        this._accountSettingState.isLoading = false;
      }
      this._updateState();
    }).catchError((onError) {
      print(onError.toString());
      this._accountSettingState.isLoadingFailed = true;
      this._accountSettingState.isLoading = false;
      this._updateState();
    });
  }

  _updateState() {
    if (!this._subjectAccountSettingState.isClosed) {
      this._subjectAccountSettingState.sink.add(this._accountSettingState);
    }
  }

  dispose() {
    this._subjectAccountSettingState.close();
  }
}

class AccountSettingState {
  bool isLoading = false;
  bool isLoadingFailed = false;
  UiHelperResponse response;

  List<GmbLocationWithUiData> get gmbLocationWithUiData {
    if (response == null) {
      return [];
    }

    var foLocations = response.foLocations;
    var gmbLocations = response.gmbLocations;
    var locationConnections = response.locationConnections;

    return gmbLocations.map((GmbLocation gmbLocation) {
      var gmbLocationId = gmbLocation.gmbLocationId;
      String foLocationId;
      FoLocation foLocation;
      for (var locationConnection in locationConnections) {
        if (locationConnection.gmbLocationId == gmbLocationId) {
          foLocationId = locationConnection.fbLocationId;
          break;
        }
      }
      if (foLocationId != null) {
        for (var location in foLocations) {
          if (location.fbLocationId == foLocationId) {
            foLocation = location;
            break;
          }
        }
      }
      return GmbLocationWithUiData(
        foLocation: foLocation,
        gmbLocation: gmbLocation,
      );
    }).toList();
  }

   String getLocationAddress(GmbLocation locationItem) {
    var address = '';
    if (locationItem.gmbLocationAddress != null) {
      if (locationItem.gmbLocationAddress.addressLines != null) {
        for (var line in locationItem.gmbLocationAddress.addressLines) {
          if (address == '') {
            address = line;
          } else {
            address = address + ', ' + line;
          }
        }
      }
      if (locationItem.gmbLocationAddress.locality != null) {
        if (address == '') {
          address = locationItem.gmbLocationAddress.locality;
        } else {
          address = address + ', ' + locationItem.gmbLocationAddress.locality;
        }
      }

      if (locationItem.gmbLocationAddress.administrativeArea != null) {
        if (address == '') {
          address = locationItem.gmbLocationAddress.administrativeArea;
        } else {
          address = address + ', ' + locationItem.gmbLocationAddress.administrativeArea;
        }
      }

      if (locationItem.gmbLocationAddress.postalCode != null) {
        if (address == '') {
          address = locationItem.gmbLocationAddress.postalCode;
        } else {
          address = address + ', ' + locationItem.gmbLocationAddress.postalCode;
        }
      }
    }

    return address;
  }
}

class UiHelperResponse {
  List<LocationConnection> locationConnections;
  List<FoLocation> foLocations;
  List<GmbLocation> gmbLocations;

  UiHelperResponse({
    this.locationConnections,
    this.foLocations,
    this.gmbLocations,
  });

  UiHelperResponse.fromJson(Map<String, dynamic> json) {
    foLocations = new List<FoLocation>();
    if (json['locations'] != null) {
      json['locations'].forEach((v) {
        foLocations.add(new FoLocation.fromJson(v));
      });
    }

    locationConnections = new List<LocationConnection>();
    if (json['location_connections'] != null) {
      json['location_connections'].forEach((v) {
        locationConnections.add(new LocationConnection.fromJson(v));
      });
    }

    gmbLocations = new List<GmbLocation>();
    if (json['gmb_locations'] != null) {
      json['gmb_locations'].forEach((v) {
        gmbLocations.add(new GmbLocation.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.foLocations != null) {
      data['locations'] = this.foLocations.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LocationConnection {
  String name;
  String fbLocationId;
  String gmbLocationId;
  int facebookPageId;
  String address;
  LocationConnectionMetaData metaData;

  LocationConnection(
      {this.name,
      this.fbLocationId,
      this.gmbLocationId,
      this.facebookPageId,
      this.address,
      this.metaData});

  LocationConnection.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    fbLocationId = json['fb_location_id'];
    gmbLocationId = json['gmb_location_id'];
    facebookPageId = json['facebook_page_id'];
    address = json['address'];
    metaData = json['meta_data'] != null
        ? new LocationConnectionMetaData.fromJson(json['meta_data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['fb_location_id'] = this.fbLocationId;
    data['gmb_location_id'] = this.gmbLocationId;
    data['facebook_page_id'] = this.facebookPageId;
    data['address'] = this.address;
    if (this.metaData != null) {
      data['meta_data'] = this.metaData.toJson();
    }
    return data;
  }
}

class LocationConnectionMetaData {
  double latitude;
  String googleId;
  double longitude;

  LocationConnectionMetaData({this.latitude, this.googleId, this.longitude});

  LocationConnectionMetaData.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    googleId = json['google_id'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['latitude'] = this.latitude;
    data['google_id'] = this.googleId;
    data['longitude'] = this.longitude;
    return data;
  }
}

class FoLocation {
  String name;
  String fbLocationId;
  FoLocationMetaData metaData;

  FoLocation({this.name, this.fbLocationId});

  FoLocation.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    fbLocationId = json['fb_location_id'];
    metaData = json['meta_data'] != null
        ? new FoLocationMetaData.fromJson(json['meta_data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['fb_location_id'] = this.fbLocationId;
    if (this.metaData != null) {
      data['meta_data'] = this.metaData.toJson();
    }
    return data;
  }
}

class FoLocationMetaData {
  double latitude;
  double longitude;

  FoLocationMetaData({this.latitude, this.longitude});

  FoLocationMetaData.fromJson(Map<String, dynamic> json) {
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

class GmbLocation {
  String gmbLocationId;
  String gmbLocationTpId;
  String gmbLocationName;
  String gmbLocationPhone;
  GmbLocationCategory gmbLocationCategory;
  String gmbLocationWebsite;
  GmbLocationTiming gmbLocationTiming;
  GmbLocationLatLong gmbLocationLatLong;
  GmbLocationState gmbLocationState;
  String gmbLocationMapUrl;
  String gmbLocationReviewUrl;
  GmbLocationAddress gmbLocationAddress;

  GmbLocation(
      {this.gmbLocationId,
      this.gmbLocationTpId,
      this.gmbLocationName,
      this.gmbLocationPhone,
      this.gmbLocationCategory,
      this.gmbLocationWebsite,
      this.gmbLocationTiming,
      this.gmbLocationLatLong,
      this.gmbLocationState,
      this.gmbLocationMapUrl,
      this.gmbLocationReviewUrl,
      this.gmbLocationAddress});

  GmbLocation.fromJson(Map<String, dynamic> json) {
    gmbLocationId = json['gmb_location_id'];
    gmbLocationTpId = json['gmb_location_tp_id'];
    gmbLocationName = json['gmb_location_name'];
    gmbLocationPhone = json['gmb_location_phone'];
    gmbLocationCategory = json['gmb_location_category'] != null
        ? new GmbLocationCategory.fromJson(json['gmb_location_category'])
        : null;
    gmbLocationWebsite = json['gmb_location_website'];
    gmbLocationTiming = json['gmb_location_timing'] != null
        ? new GmbLocationTiming.fromJson(json['gmb_location_timing'])
        : null;
    gmbLocationLatLong = json['gmb_location_lat_long'] != null
        ? new GmbLocationLatLong.fromJson(json['gmb_location_lat_long'])
        : null;
    gmbLocationState = json['gmb_location_state'] != null
        ? new GmbLocationState.fromJson(json['gmb_location_state'])
        : null;
    gmbLocationMapUrl = json['gmb_location_map_url'];
    gmbLocationReviewUrl = json['gmb_location_review_url'];
    gmbLocationAddress = json['gmb_location_address'] != null
        ? new GmbLocationAddress.fromJson(json['gmb_location_address'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['gmb_location_id'] = this.gmbLocationId;
    data['gmb_location_tp_id'] = this.gmbLocationTpId;
    data['gmb_location_name'] = this.gmbLocationName;
    data['gmb_location_phone'] = this.gmbLocationPhone;
    if (this.gmbLocationCategory != null) {
      data['gmb_location_category'] = this.gmbLocationCategory.toJson();
    }
    data['gmb_location_website'] = this.gmbLocationWebsite;
    if (this.gmbLocationTiming != null) {
      data['gmb_location_timing'] = this.gmbLocationTiming.toJson();
    }
    if (this.gmbLocationLatLong != null) {
      data['gmb_location_lat_long'] = this.gmbLocationLatLong.toJson();
    }
    if (this.gmbLocationState != null) {
      data['gmb_location_state'] = this.gmbLocationState.toJson();
    }
    data['gmb_location_map_url'] = this.gmbLocationMapUrl;
    data['gmb_location_review_url'] = this.gmbLocationReviewUrl;
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

class GmbLocationTiming {
  List<Periods> periods;

  GmbLocationTiming({this.periods});

  GmbLocationTiming.fromJson(Map<String, dynamic> json) {
    if (json['periods'] != null) {
      periods = new List<Periods>();
      json['periods'].forEach((v) {
        periods.add(new Periods.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.periods != null) {
      data['periods'] = this.periods.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Periods {
  String openDay;
  String closeDay;
  String openTime;
  String closeTime;

  Periods({this.openDay, this.closeDay, this.openTime, this.closeTime});

  Periods.fromJson(Map<String, dynamic> json) {
    openDay = json['openDay'];
    closeDay = json['closeDay'];
    openTime = json['openTime'];
    closeTime = json['closeTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['openDay'] = this.openDay;
    data['closeDay'] = this.closeDay;
    data['openTime'] = this.openTime;
    data['closeTime'] = this.closeTime;
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
  bool isVerified;
  bool isPublished;

  GmbLocationState(
      {this.canDelete, this.canUpdate, this.isVerified, this.isPublished});

  GmbLocationState.fromJson(Map<String, dynamic> json) {
    canDelete = json['canDelete'];
    canUpdate = json['canUpdate'];
    isVerified = json['isVerified'];
    isPublished = json['isPublished'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['canDelete'] = this.canDelete;
    data['canUpdate'] = this.canUpdate;
    data['isVerified'] = this.isVerified;
    data['isPublished'] = this.isPublished;
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

class GmbLocationWithUiData {
  GmbLocation gmbLocation;
  FoLocation foLocation;
  GmbLocationWithUiData({this.gmbLocation, this.foLocation});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.foLocation != null) {
      data['foLocation'] = foLocation.toJson();
    }
    if (this.gmbLocation != null) {
      data['gmbLocation'] = gmbLocation.gmbLocationName;
    }
    return data;
  }

   String getLocationAddress() {
    var address = '';
    if (gmbLocation.gmbLocationAddress != null) {
      if (gmbLocation.gmbLocationAddress.addressLines != null) {
        for (var line in gmbLocation.gmbLocationAddress.addressLines) {
          if (address == '') {
            address = line;
          } else {
            address = address + ', ' + line;
          }
        }
      }
      if (gmbLocation.gmbLocationAddress.locality != null) {
        if (address == '') {
          address = gmbLocation.gmbLocationAddress.locality;
        } else {
          address = address + ', ' + gmbLocation.gmbLocationAddress.locality;
        }
      }

      if (gmbLocation.gmbLocationAddress.administrativeArea != null) {
        if (address == '') {
          address = gmbLocation.gmbLocationAddress.administrativeArea;
        } else {
          address = address + ', ' + gmbLocation.gmbLocationAddress.administrativeArea;
        }
      }

      if (gmbLocation.gmbLocationAddress.postalCode != null) {
        if (address == '') {
          address = gmbLocation.gmbLocationAddress.postalCode;
        } else {
          address = address + ', ' + gmbLocation.gmbLocationAddress.postalCode;
        }
      }
    }

    return address;
  }

  getIsLocationVerified() {
    if (gmbLocation.gmbLocationState == null) {
      return false;
    }
    return gmbLocation.gmbLocationState.isVerified ?? false;
  }
}
