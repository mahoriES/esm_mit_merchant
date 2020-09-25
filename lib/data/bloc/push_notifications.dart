import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:foore/data/constants/es_api_path.dart';
import 'package:foore/data/http_service.dart';

class PushNotifications {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  PushNotifications() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});
  }

  Future<String> subscribeForCurrentUser(HttpService httpService) async {
    var token = await this._firebaseMessaging.getToken();
    if (token != null) {
      var fcmToken = FcmToken(token);
      var payloadString = json.encode(fcmToken.toJson());
      httpService.foPost('fcm/add/foore/', payloadString);

      //ES Token
      var esFcmToken = EsFcmToken(token);
      var esPayloadString = json.encode(esFcmToken.toJson());
      httpService.esPost(EsApiPaths.addFcmToken, esPayloadString);
    }
    return token;
  }

  Future<bool> unsubscribeForCurrentUser() async {
    var val = await this._firebaseMessaging.deleteInstanceID();
    return val;
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

class EsFcmToken extends FcmToken {
  EsFcmToken(String fcmToken) : super(fcmToken);
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['token_type'] = 'ANDROID';
    return data;
  }
}
