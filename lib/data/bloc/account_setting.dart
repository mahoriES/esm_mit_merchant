import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/gmb_location.dart';
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

  getData() async {
    this._accountSettingState.isLoading = true;
    this._accountSettingState.isLoadingFailed = false;
    this._updateState();
    try {
      final reviewInfos = await getReviewInfo();
      this._accountSettingState.accountReviewInfo = reviewInfos;
      final httpResponse = await httpService.foGet(
          'ui/helper/account/?gmb_locations&location_connections&locations');
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
    } catch (onError) {
      print(onError.toString());
      this._accountSettingState.isLoadingFailed = true;
      this._accountSettingState.isLoading = false;
      this._updateState();
    }
  }

  Future<List<AccountReviewInfo>> getReviewInfo() async {
    final httpResponse = await httpService.foGet('google/account/review/info/');
    final reviewInfos = new List<AccountReviewInfo>();
    if (httpResponse.statusCode == 200 && httpResponse.body != null) {
      print(httpResponse.body);
      if (json.decode(httpResponse.body) != null) {
        json.decode(httpResponse.body).forEach((v) {
          reviewInfos.add(new AccountReviewInfo.fromJson(v));
        });
      }
    } else {
      throw Error();
    }
    return reviewInfos;
  }

  createStoreForGmbLocations(String gmbLocationId, Function onSuccess) {
    final gmbLocationIds = [gmbLocationId];
    if (this._accountSettingState.isSubmitting == false &&
        gmbLocationIds.length > 0) {
      this._accountSettingState.isSubmitting = true;
      this._updateState();
      var payload = CreateStorePayload(gmbLocationIds: gmbLocationIds);
      var payloadString = json.encode(payload.toJson());
      httpService
          .foPost('gmb/create/store/', payloadString)
          .then((httpResponse) {
        print(httpResponse.statusCode);
        if (httpResponse.statusCode == 200 || httpResponse.statusCode == 202) {
          this._accountSettingState.isSubmitting = false;
          if (onSuccess != null) {
            onSuccess();
          }
        } else {
          this._accountSettingState.isSubmitting = false;
        }
        this._updateState();
      }).catchError((onError) {
        print(onError.toString());
        this._accountSettingState.isSubmitting = false;
        this._updateState();
      });
    }
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
  bool isSubmitting = false;
  UiHelperResponse response;
  List<AccountReviewInfo> accountReviewInfo;

  List<GmbLocationWithUiData> get gmbLocationWithUiData {
    if (response == null) {
      return [];
    }

    if (accountReviewInfo == null) {
      return [];
    }

    var foLocations = response.foLocations;
    var gmbLocations = response.gmbLocations;
    var locationConnections = response.locationConnections;

    return gmbLocations.map((GmbLocation gmbLocation) {
      var gmbLocationId = gmbLocation.gmbLocationId;
      String foLocationId;
      FoLocation foLocation;
      AccountReviewInfo accReviewInfo;
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
      for(var accReview in accountReviewInfo ) {
        if(accReview.gmbLocationId == gmbLocationId) {
          accReviewInfo = accReview;
        }
      }
      return GmbLocationWithUiData(
        foLocation: foLocation,
        gmbLocation: gmbLocation,
        accountReviewInfo: accReviewInfo
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
          address = address +
              ', ' +
              locationItem.gmbLocationAddress.administrativeArea;
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

class GmbLocationWithUiData {
  GmbLocation gmbLocation;
  FoLocation foLocation;
  AccountReviewInfo accountReviewInfo;
  GmbLocationWithUiData({this.gmbLocation, this.foLocation, this.accountReviewInfo});

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
          address = address +
              ', ' +
              gmbLocation.gmbLocationAddress.administrativeArea;
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

class CreateStorePayload {
  List<String> gmbLocationIds;

  CreateStorePayload({
    this.gmbLocationIds,
  });

  CreateStorePayload.fromJson(Map<String, dynamic> json) {
    gmbLocationIds = json['gmb_location_ids'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['gmb_location_ids'] = this.gmbLocationIds;
    return data;
  }
}

class AccountReviewInfo {
  double rating;
  int numReview;
  String gmbLocationId;

  AccountReviewInfo({this.rating, this.numReview, this.gmbLocationId});

  AccountReviewInfo.fromJson(Map<String, dynamic> json) {
    rating = json['rating'];
    numReview = json['num_review'];
    gmbLocationId = json['gmb_location_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rating'] = this.rating;
    data['num_review'] = this.numReview;
    data['gmb_location_id'] = this.gmbLocationId;
    return data;
  }
}
