import 'dart:convert';
import 'dart:math';


import 'package:flutter/material.dart';
import 'package:foore/data/bloc/analytics.dart';
import 'package:foore/data/bloc/auth.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/onboarding_page/location_verify.dart';
import 'package:foore/search_gmb/model/google_locations.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

class LocationClaimBloc {
  final LocationClaimState _onboardingState = new LocationClaimState();
  final HttpService httpService;

  BehaviorSubject<LocationClaimState> _subjectLocationClaimState;

  final AuthBloc authBloc;

  LocationClaimBloc(
      {@required this.httpService,
      @required this.authBloc,
      @required GmbLocationItem locationItem,
      GoogleLocation googleLocation}) {
    this._onboardingState.locationItem = locationItem;
    this._onboardingState.googleLocation = googleLocation;
    this._subjectLocationClaimState =
        new BehaviorSubject<LocationClaimState>.seeded(_onboardingState);
  }

  loginToGoogleSilently() async {
    bool isSignedInWithGoogle = await this.authBloc.googleLoginSilently();
    if (!isSignedInWithGoogle) {
      this._onboardingState.isShowNotLoggedInWithGoogle = true;
      this._updateState();
    }
  }

  Observable<LocationClaimState> get onboardingStateObservable =>
      _subjectLocationClaimState.stream;

  _updateState() {
    this._subjectLocationClaimState.sink.add(this._onboardingState);
  }

  dispose() {
    this._subjectLocationClaimState.close();
  }

  manageLocation(BuildContext context) async {
    loginToGoogleSilently();
    try {
      this._onboardingState.isSubmitting = true;
      this._updateState();
      if (this._onboardingState.googleLocation != null) {
        await createLocation();
        await startVerification();
        Navigator.of(context).pushReplacementNamed(LocationVerifyPage.routeName,
            arguments: this._onboardingState.locationItem);
      } else {
        await startVerification();
        Navigator.of(context).pushReplacementNamed(LocationVerifyPage.routeName,
            arguments: this._onboardingState.locationItem);
      }
      refreshBackend();
    } finally {
      this._onboardingState.isSubmitting = false;
      this._updateState();
    }
  }

  refreshBackend() async {
    try {
      final response =
          await httpService.foPost('google/account/user/refresh/', null);
      print(response.statusCode);
    } catch (err) {}
  }

  getData() async {
    await loginToGoogleSilently();
    this._onboardingState.isLoading = true;
    this._onboardingState.isLoadingFailed = false;
    this._updateState();
    try {
      getAccounts();
      this._onboardingState.isLoadingFailed = false;
    } catch (err) {
      this._onboardingState.isLoadingFailed = true;
    } finally {
      this._onboardingState.isLoading = false;
      this._updateState();
    }
  }

  getAccounts() async {
    String url = "https://mybusiness.googleapis.com/v4/accounts";
    final headers = await authBloc.googleAuthHeaders;
    final httpResponse = await http.get(
      url,
      headers: headers,
    );
    String accountName;
    if (httpResponse.statusCode == 200) {
      final googleAccountResponse =
          GoogleAccountResponse.fromJson(json.decode(httpResponse.body));
      if (googleAccountResponse.accounts != null) {
        for (var account in googleAccountResponse.accounts) {
          if (account.type == 'PERSONAL') {
            accountName = account.name;
          }
        }
      }
    } else {
      //TODO: Custom sentry error
      
    }
    if (accountName != null) {
      this._onboardingState.accountName = accountName;
    } else {
      throw 'Error';
    }
  }

  createLocation() async {
    final rand = Random();
    final randomString = rand.nextInt(100000000).toString();
    String url = 'https://mybusiness.googleapis.com/v4/' +
        _onboardingState.accountName +
        '/locations?requestId=$randomString';
    final body =
        json.encode(this._onboardingState.googleLocation.location.toJson());
    final headers = await authBloc.googleAuthHeaders;
    final httpResponse = await http.post(
      url,
      body: body,
      headers: headers,
    );
    print(httpResponse.body);
    print(httpResponse.statusCode);
    if (httpResponse.statusCode == 200) {
      this.httpService.foAnalytics.addUserProperties(
          name: FoAnalyticsUserProperties.google_location_created_from_app,
          value: true);
      this.httpService.foAnalytics.addUserProperties(
          name: FoAnalyticsUserProperties.google_locations_info,
          value: httpResponse.body);
      this._onboardingState.locationItem =
          GmbLocationItem.fromJson(json.decode(httpResponse.body));
      this._onboardingState.googleLocation = null;
      this._updateState();
    } else {
      //TODO: Custom sentry error
      throw 'Error';
    }
  }

  startVerification() async {
    String customerName = authBloc.authState.userName;
    String url = 'https://mybusiness.googleapis.com/v4/' +
        _onboardingState.locationItem.name +
        ':verify';
    final body =
        '{"method": "ADDRESS","languageCode": "en","addressInput": {"mailerContactName": "$customerName"}}';
    print(body);
    final headers = await authBloc.googleAuthHeaders;
    final httpResponse = await http.post(
      url,
      body: body,
      headers: headers,
    );
    print(httpResponse.statusCode);
    if (httpResponse.statusCode == 200) {
      this.httpService.foAnalytics.addUserProperties(
          name: FoAnalyticsUserProperties
              .google_location_verification_started_from_app,
          value: true);
      this._onboardingState.locationItem.locationState.hasPendingVerification =
          true;

      this._updateState();
    } else {
      //TODO: Custom sentry error
      throw 'Error';
    }
  }
}

class LocationClaimState {
  GmbLocationItem locationItem;
  GoogleLocation googleLocation;
  String accountName;
  bool isSubmitting = false;
  bool isLoading = false;
  bool isLoadingFailed = false;
  bool isShowNotLoggedInWithGoogle = false;

  bool get isShowVerificationPending {
    if (googleLocation != null) {
      return false;
    }
    return locationItem.locationState != null
        ? (locationItem.locationState.hasPendingVerification ?? false)
        : false;
  }

  bool get isShowClaimed {
    return googleLocation != null
        ? googleLocation.requestAdminRightsUrl != null
        : false;
  }

  bool get isShowLocation {
    return !isShowVerificationPending && !isShowClaimed;
  }

  get locationAddress =>
      locationItem != null ? getLocationAddress(locationItem) : null;

  get locationName => locationItem != null ? locationItem.locationName : null;

  get locationLatLang => locationItem != null ? locationItem.latlng : null;

  String getLocationAddress(GmbLocationItem locationItem) {
    var address = '';
    if (locationItem.address != null) {
      if (locationItem.address.addressLines != null) {
        for (var line in locationItem.address.addressLines) {
          if (address == '') {
            address = line;
          } else {
            address = address + ', ' + line;
          }
        }
      }
      if (locationItem.address.locality != null) {
        if (address == '') {
          address = locationItem.address.locality;
        } else {
          address = address + ', ' + locationItem.address.locality;
        }
      }

      if (locationItem.address.administrativeArea != null) {
        if (address == '') {
          address = locationItem.address.administrativeArea;
        } else {
          address = address + ', ' + locationItem.address.administrativeArea;
        }
      }

      if (locationItem.address.postalCode != null) {
        if (address == '') {
          address = locationItem.address.postalCode;
        } else {
          address = address + ', ' + locationItem.address.postalCode;
        }
      }
    }

    return address;
  }
}

class GoogleAccountResponse {
  List<GmbAccount> accounts;

  GoogleAccountResponse({this.accounts});

  GoogleAccountResponse.fromJson(Map<String, dynamic> json) {
    if (json['accounts'] != null) {
      accounts = new List<GmbAccount>();
      json['accounts'].forEach((v) {
        accounts.add(new GmbAccount.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.accounts != null) {
      data['accounts'] = this.accounts.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GmbAccount {
  String name;
  String accountName;
  String type;
  LocationState state;
  String profilePhotoUrl;
  String role;
  String accountNumber;
  String permissionLevel;

  GmbAccount(
      {this.name,
      this.accountName,
      this.type,
      this.state,
      this.profilePhotoUrl,
      this.role,
      this.accountNumber,
      this.permissionLevel});

  GmbAccount.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    accountName = json['accountName'];
    type = json['type'];
    state = json['state'] != null
        ? new LocationState.fromJson(json['state'])
        : null;
    profilePhotoUrl = json['profilePhotoUrl'];
    role = json['role'];
    accountNumber = json['accountNumber'];
    permissionLevel = json['permissionLevel'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['accountName'] = this.accountName;
    data['type'] = this.type;
    if (this.state != null) {
      data['state'] = this.state.toJson();
    }
    data['profilePhotoUrl'] = this.profilePhotoUrl;
    data['role'] = this.role;
    data['accountNumber'] = this.accountNumber;
    data['permissionLevel'] = this.permissionLevel;
    return data;
  }
}

class LocationState {
  String status;
  String vettedStatus;

  LocationState({this.status, this.vettedStatus});

  LocationState.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    vettedStatus = json['vettedStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['vettedStatus'] = this.vettedStatus;
    return data;
  }
}
