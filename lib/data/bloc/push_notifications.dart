import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:foore/data/constants/es_api_path.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/esdy_print.dart';

class PushNotifications {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  static const String CLASSNAME = 'PushNotifications';
  static const String FILENAME = 'push_notificaitons.dart';
  final EsdyPrint esdyPrint =
      EsdyPrint(classname: CLASSNAME, filename: FILENAME);

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
    esdyPrint.debug("subscribeForCurrentUser >>");
    var token = await this._firebaseMessaging.getToken();
    if (token != null) {
      esdyPrint.debug(token);
      //ES Token
      var esFcmToken = EsFcmToken(token);
      var esPayloadString = json.encode(esFcmToken.toJson());
      httpService.esPost(EsApiPaths.addFcmToken, esPayloadString);

      esdyPrint.debug("registered with esamudaay");

      var fcmToken = FcmToken(token);
      var payloadString = json.encode(fcmToken.toJson());
      httpService.foPost('fcm/add/foore/', payloadString);

      esdyPrint.debug("registered with Foore");
    }
    return token;
  }

  Future<bool> unsubscribeForCurrentUser({bool esUnsubscribe = false}) async {
    esdyPrint.debug("unsubscribeForCurrentUser");
    if (esUnsubscribe) {
      var val = await this._firebaseMessaging.deleteInstanceID();
      return val;
    }
    return false;
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
