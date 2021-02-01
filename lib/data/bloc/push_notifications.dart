import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:foore/data/constants/es_api_path.dart';
import 'package:foore/data/constants/push_notification.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/esdy_print.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotifications {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  static const String CLASSNAME = 'PushNotifications';
  static const String FILENAME = 'push_notificaitons.dart';
  final EsdyPrint esdyPrint =
      EsdyPrint(classname: CLASSNAME, filename: FILENAME);
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<Null> initialise() async {
    esdyPrint.debug("initialise >>");
    //TODO: Icon doesn't show up properly
    //even though, the ic_launcher is a valid file (foore icon)
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(initializationSettingsAndroid, null);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<Null> displayLocalNotification(String title, String body) async {
    esdyPrint.debug("displayLocalNotification >>");
    //TODO: Android Channel information
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        "",
        AnnoyingChannel.CONST_NAME,
        AnnoyingChannel.CONST_DESCRIPTION,
        importance: Importance.High,
        playSound: false,
        priority: Priority.High);
    var platformChannelSpecifics =
        NotificationDetails(androidPlatformChannelSpecifics, null);
    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics);
  }

  PushNotifications() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        //{notification: {title: Hey, body: Body}, data: {a: 1, b: 2}}
        esdyPrint.debug("onMessage: $message");

        if (message != null && message.containsKey('notification')) {
          var notification = message['notification'];
          await displayLocalNotification(
              notification['title'], notification['body']);
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        esdyPrint.debug("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        esdyPrint.debug("onResume: $message");
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

      esdyPrint.debug("Registered with esamudaay");

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

class LocalNotification {}
