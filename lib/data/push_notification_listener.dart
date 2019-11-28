import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:provider/provider.dart';

import 'http_service.dart';

class PushNotificationListener extends StatefulWidget {
  final Widget child;

  PushNotificationListener({this.child});

  @override
  _PushNotificationListenerState createState() =>
      _PushNotificationListenerState();
}

class _PushNotificationListenerState extends State<PushNotificationListener> {
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  HttpService _httpService;

  // @override
  // void didChangeDependencies() {
  //   this._httpService = Provider.of<HttpService>(context);
  //   _firebaseMessaging.configure(
  //     onMessage: (Map<String, dynamic> message) async {
  //       print("onMessage: $message");
  //     },
  //     onLaunch: (Map<String, dynamic> message) async {
  //       print("onLaunch: $message");
  //     },
  //     onResume: (Map<String, dynamic> message) async {
  //       print("onResume: $message");
  //     },
  //   );
  //   _firebaseMessaging.requestNotificationPermissions(
  //       const IosNotificationSettings(sound: true, badge: true, alert: true));
  //   _firebaseMessaging.onIosSettingsRegistered
  //       .listen((IosNotificationSettings settings) {});
  //   _firebaseMessaging.getToken().then((String token) {
  //     assert(token != null);
  //     this.postToken(FcmToken(token));
  //   });
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  postToken(FcmToken fcmToken) {
    var payloadString = json.encode(fcmToken.toJson());
    this
        ._httpService
        .foPost('fcm/add/foore/', payloadString)
        .then((httpResponse) {})
        .catchError((onError) {});
    Intercom.sendTokenToIntercom(fcmToken.fcmToken);
  }
}

class FcmToken {
  String fcmToken;
  FcmToken(this.fcmToken);
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fcm_token'] = this.fcmToken;
    return data;
  }
}
