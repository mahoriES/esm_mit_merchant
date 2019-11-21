import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:foore/data/bloc/auth.dart';
import 'package:foore/data/http_service.dart';
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

  Observable<LocationClaimState> get onboardingStateObservable =>
      _subjectLocationClaimState.stream;

  _updateState() {
    this._subjectLocationClaimState.sink.add(this._onboardingState);
  }

  dispose() {
    this._subjectLocationClaimState.close();
  }

  manageLocation() async {
    try {
      this._onboardingState.isSubmitting = true;
      this._updateState();
      if (this._onboardingState.googleLocation != null) {
        await createLocation();
        await startVerification();
      } else {
        await startVerification();
      }
    } finally {
      this._onboardingState.isSubmitting = false;
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
    }
    if (accountName != null) {
      this._onboardingState.accountName = accountName;
    } else {
      throw 'Error';
    }
  }

  createLocation() async {
    String url = 'https://mybusiness.googleapis.com/v4/' +
        _onboardingState.accountName +
        '/locations?requestId=request1';
    final body = json.encode(this._onboardingState.googleLocation.toJson());
    final headers = await authBloc.googleAuthHeaders;
    final httpResponse = await http.post(
      url,
      body: body,
      headers: headers,
    );
    if (httpResponse.statusCode == 200) {
      this._onboardingState.locationItem =
          GmbLocationItem.fromJson(json.decode(httpResponse.body));
      this._onboardingState.googleLocation = null;
      this._updateState();
    } else {
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
    final headers = await authBloc.googleAuthHeaders;
    final httpResponse = await http.post(
      url,
      body: body,
      headers: headers,
    );
    if (httpResponse.statusCode == 200) {
      this._onboardingState.locationItem.locationState.hasPendingVerification =
          true;
      this._updateState();
    } else {
      throw 'Error';
    }
  }
}

class LocationClaimState {
  GmbLocationItem locationItem;
  GoogleLocation googleLocation;
  String accountName;
  bool isSubmitting = false;

  bool get isShowVerificationPending {
    if (googleLocation != null) {
      return false;
    }
    return locationItem.locationState != null
        ? locationItem.locationState.hasPendingVerification
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
  State state;
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
    state = json['state'] != null ? new State.fromJson(json['state']) : null;
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

class State {
  String status;
  String vettedStatus;

  State({this.status, this.vettedStatus});

  State.fromJson(Map<String, dynamic> json) {
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
