import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/search_gmb/model/google_locations.dart';
import 'package:rxdart/rxdart.dart';

import 'package:http/http.dart' as http;

import 'auth.dart';

class CompleteVerificationBloc {
  CompleteVerificationState _completeVerificationState =
      new CompleteVerificationState();
  final HttpService httpService;
  final AuthBloc authBloc;
  final pinEditController = TextEditingController();

  BehaviorSubject<CompleteVerificationState> _subjectCompleteVerificationState;

  CompleteVerificationBloc(
      {this.httpService, this.authBloc, GmbLocationItem locationItem}) {
    this._completeVerificationState.locationItem = locationItem;

    this._subjectCompleteVerificationState =
        new BehaviorSubject<CompleteVerificationState>.seeded(
            _completeVerificationState);
  }

  Observable<CompleteVerificationState> get checkinStateObservable =>
      _subjectCompleteVerificationState.stream;

  getData() async {
    this._completeVerificationState.isLoading = false;
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
    }
    if (verification != null) {
      this._completeVerificationState.verification = verification;
      this._updateState();
    } else {
      throw 'Err';
    }
  }

  completeVerification(BuildContext context) async {
    this._completeVerificationState.isSubmitting = true;
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
    if (httpResponse.statusCode == 200) {
      //////////navigate away
    }
    this._completeVerificationState.isSubmitting = true;
    this._updateState();
  }

  _updateState() {
    this
        ._subjectCompleteVerificationState
        .sink
        .add(this._completeVerificationState);
  }

  dispose() {
    this._subjectCompleteVerificationState.close();
  }
}

class CompleteVerificationState {
  bool isLoading;
  GmbLocationItem locationItem;
  Verification verification;
  bool isSubmitting;
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
