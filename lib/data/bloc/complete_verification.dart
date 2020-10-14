import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/analytics.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/router.dart';
import 'package:foore/search_gmb/model/google_locations.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

import 'package:http/http.dart' as http;

import 'auth.dart';

class CompleteVerificationBloc {
  final CompleteVerificationState _completeVerificationState =
      CompleteVerificationState();
  final HttpService httpService;
  final AuthBloc authBloc;
  final pinEditController = TextEditingController();

  BehaviorSubject<CompleteVerificationState> _subjectCompleteVerificationState;

  CompleteVerificationBloc(
      {@required this.httpService,
      @required this.authBloc,
      @required GmbLocationItem locationItem}) {
    this._completeVerificationState.locationItem = locationItem;
    this._subjectCompleteVerificationState =
        new BehaviorSubject<CompleteVerificationState>.seeded(
            _completeVerificationState);
    authBloc.googleSignIn.signInSilently();
  }

  Observable<CompleteVerificationState>
      get completeVerificationStateObservable =>
          _subjectCompleteVerificationState.stream;

  getData() async {
    await loginToGoogleSilently();
    this._completeVerificationState.isLoading = true;
    this._updateState();
    try {
      await getVerificationListForLocation();
    } finally {
      this._completeVerificationState.isLoading = false;
      this._updateState();
    }
  }

  getVerificationListForLocation() async {
    String url = "https://mybusiness.googleapis.com/v4/" +
        _completeVerificationState.locationItem.name +
        "/verifications";
    final headers = await authBloc.googleAuthHeaders;
    final httpResponse = await http.get(
      url,
      headers: headers,
    );
    Verification verification;
    print(httpResponse.statusCode);
    print(httpResponse.reasonPhrase);
    if (httpResponse.statusCode == 200) {
      final locationVerificationsResponse =
          LocationVerificationsResponse.fromJson(
              json.decode(httpResponse.body));
      if (locationVerificationsResponse.verifications != null) {
        for (var v in locationVerificationsResponse.verifications) {
          if (v.state == "PENDING") {
            verification = v;
          }
        }
      }
    } else {
      //TODO: Custom sentry error

    }
    if (verification != null) {
      this._completeVerificationState.verification = verification;
      this._updateState();
    } else {
      throw 'Err';
    }
  }

  loginToGoogleSilently() async {
    bool isSignedInWithGoogle = await this.authBloc.googleLoginSilently();
    if (!isSignedInWithGoogle) {
      this._completeVerificationState.isShowNotLoggedInWithGoogle = true;
      this._updateState();
    }
  }

  completeVerification(BuildContext context) async {
    await loginToGoogleSilently();
    this._completeVerificationState.isSubmitting = true;
    this._completeVerificationState.isSubmitFailed = false;
    this._updateState();

    String url = "https://mybusiness.googleapis.com/v4/" +
        _completeVerificationState.verification.name +
        ":complete";
    final code = this.pinEditController.text;
    final body = '{"pin": "$code"}';
    final headers = await authBloc.googleAuthHeaders;
    final httpResponse = await http.post(
      url,
      body: body,
      headers: headers,
    );
    await refreshBackend();
    if (httpResponse.statusCode == 200) {
      this.httpService.foAnalytics.addUserProperties(
          name: FoAnalyticsUserProperties
              .google_location_verification_done_from_app,
          value: true);
      //////////navigate away
      Navigator.pushReplacementNamed(context, AppRouter.homeRoute);
    } else {
      this._completeVerificationState.isSubmitFailed = true;
      //TODO: Custom sentry error

    }
    this._completeVerificationState.isSubmitting = false;
    this._updateState();
  }

  refreshBackend() async {
    try {
      await httpService.foPost('google/account/user/refresh/', null);
    } catch (err) {}
  }

  _updateState() {
    if (!this._subjectCompleteVerificationState.isClosed) {
      this
          ._subjectCompleteVerificationState
          .sink
          .add(this._completeVerificationState);
    }
  }

  dispose() {
    this._subjectCompleteVerificationState.close();
  }
}

class CompleteVerificationState {
  bool isLoading = false;
  GmbLocationItem locationItem;
  Verification verification;
  bool isSubmitting = false;
  bool isSubmitFailed = false;
  bool isShowNotLoggedInWithGoogle = false;

  get locationAddress =>
      locationItem != null ? getLocationAddress(locationItem) : null;

  get locationName => locationItem != null ? locationItem.locationName : null;

  get locationLatLang => locationItem != null ? locationItem.latlng : null;

  get date {
    if (verification == null) {
      return '';
    }
    var lastInteractionDate = DateTime.parse(verification.createTime);
    var formatter = new DateFormat('MMM dd, yyyy');
    String timeText = formatter.format(lastInteractionDate);
    return timeText;
  }

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

class LocationVerificationsResponse {
  List<Verification> verifications;

  LocationVerificationsResponse({this.verifications});

  LocationVerificationsResponse.fromJson(Map<String, dynamic> json) {
    if (json['verifications'] != null) {
      verifications = new List<Verification>();
      json['verifications'].forEach((v) {
        verifications.add(new Verification.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.verifications != null) {
      data['verifications'] =
          this.verifications.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Verification {
  String name;
  String method;
  String state;
  String createTime;

  Verification({this.name, this.method, this.state, this.createTime});

  Verification.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    method = json['method'];
    state = json['state'];
    createTime = json['createTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['method'] = this.method;
    data['state'] = this.state;
    data['createTime'] = this.createTime;
    return data;
  }
}
