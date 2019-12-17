import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foore/data/http_service.dart';
import 'package:rxdart/rxdart.dart';

class SenderCodeBloc {
  final SenderCodeState _senderCodeState = SenderCodeState();
  final HttpService httpService;

  BehaviorSubject<SenderCodeState> _subjectCreatePromotionState;

  SenderCodeBloc({@required this.httpService}) {
    this._subjectCreatePromotionState =
        new BehaviorSubject<SenderCodeState>.seeded(_senderCodeState);
  }

  Observable<SenderCodeState> get SenderCodeStateObservable =>
      _subjectCreatePromotionState.stream;

  proposeSenderCode(String smsCode, Function(String) onDone) async {
    if (this._senderCodeState.isSubmitting) {
      return;
    }
    this._senderCodeState.isSubmitting = true;
    this._senderCodeState.isSubmitFailed = false;
    this._senderCodeState.isSubmitSuccess = false;
    this._updateState();

    /////////////
    var payload = SenderCodePayload(pSmsCode: smsCode);
    var payloadString = json.encode(payload.toJson());
    this
        .httpService
        .foPost('company/sms/set/', payloadString)
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 202) {
        // this.httpService.foAnalytics.trackUserEvent(
        //     name: FoAnalyticsEvents.nearby_promo_created,
        //     parameters: <String, String>{
        //       'promoReach': _senderCodeState.promoReach
        //     });
        var proposedSmsCode =
            SenderCodePayload.fromJson(json.decode(httpResponse.body));
        this._senderCodeState.isSubmitting = false;
        this._senderCodeState.isSubmitFailed = false;
        this._senderCodeState.isSubmitSuccess = true;
        if (onDone != null) {
          onDone(proposedSmsCode.pSmsCode);
        }
      } else {
        this._senderCodeState.isSubmitting = false;
        this._senderCodeState.isSubmitFailed = true;
        this._senderCodeState.isSubmitSuccess = false;
      }
      this._updateState();
    }).catchError((onError) {
      this._senderCodeState.isSubmitting = false;
      this._senderCodeState.isSubmitFailed = true;
      this._senderCodeState.isSubmitSuccess = false;
      this._updateState();
    });
  }

  _updateState() {
    if (!this._subjectCreatePromotionState.isClosed) {
      this._subjectCreatePromotionState.sink.add(this._senderCodeState);
    }
  }

  dispose() {
    this._subjectCreatePromotionState.close();
  }
}

class SenderCodeState {
  bool isSubmitting = false;
  bool isSubmitFailed = false;
  bool isSubmitSuccess = false;
}

class SenderCodePayload {
  String pSmsCode;

  SenderCodePayload({this.pSmsCode});

  SenderCodePayload.fromJson(Map<String, dynamic> json) {
    pSmsCode = json['p_sms_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['p_sms_code'] = this.pSmsCode;
    return data;
  }
}
