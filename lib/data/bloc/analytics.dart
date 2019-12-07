import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/model/login.dart';
import 'package:foore/environments/environment.dart';
import 'package:intercom_flutter/intercom_flutter.dart';

class FoAnalytics {
  FirebaseAnalytics _firebaseAnalytics;

  bool isInitialized = false;
  bool isUserIdentified = false;

  init() async {
    await intercomInit();
    firebaseAnalyticsInit();
    this.isInitialized = true;
  }

  identifyUser(AuthInfo authData) {
    intercomLogin(authData);
    firebaseAnalyticsLogin(authData);
    isUserIdentified = true;
  }

  resetUserIdentity() {
    this.intercomLogout();
    this.firebaseAnalyticsLogout();
    isUserIdentified = false;
  }

  intercomInit() async {
    await Intercom.initialize(
      Environment.intercomAppId,
      iosApiKey: Environment.intercomIosApiKey,
      androidApiKey: Environment.intercomAndroidApiKey,
    );
  }

  firebaseAnalyticsInit() {
    this._firebaseAnalytics = FirebaseAnalytics();
    // _firebaseAnalytics.setAnalyticsCollectionEnabled(Environment.isProd);
    _firebaseAnalytics.setAnalyticsCollectionEnabled(true);
  }

  intercomLogin(AuthInfo authData) async {
    await Intercom.initialize(
      Environment.intercomAppId,
      iosApiKey: Environment.intercomIosApiKey,
      androidApiKey: Environment.intercomAndroidApiKey,
    );
    await Intercom.registerIdentifiedUser(
        userId: authData.userProfile.userUuid);
    await Intercom.updateUser(
      email: authData.userProfile.email,
      name: authData.userProfile.name,
      company: authData.companyInfo.name,
      companyId: authData.companyInfo.companyUuid,
    );
  }

  firebaseAnalyticsLogin(AuthInfo authData) {
    this._firebaseAnalytics.setUserId(authData.userProfile.userUuid);
    this
        ._firebaseAnalytics
        .setUserProperty(name: 'email', value: authData.userProfile.email);
    this
        ._firebaseAnalytics
        .setUserProperty(name: 'name', value: authData.userProfile.name);
    this
        ._firebaseAnalytics
        .setUserProperty(name: 'company', value: authData.companyInfo.name);
    this._firebaseAnalytics.setUserProperty(
        name: 'companyId', value: authData.companyInfo.companyUuid);
  }

  intercomLogout() async {
    await Intercom.logout();
  }

  firebaseAnalyticsLogout() {
    this._firebaseAnalytics.resetAnalyticsData();
  }

  trackUserEvent({@required String name, Map<String, dynamic> parameters}) {
      print(name);
    print(parameters.toString());
    if (isUserIdentified) {
      Intercom.logEvent(name, parameters);
      this._firebaseAnalytics.logEvent(name: name, parameters: parameters);
    }
  }

  setCurrentScreen(String screenName) {
    print(screenName);
    // try {
    //   this._firebaseAnalytics.setCurrentScreen(screenName: screenName);
    // } catch (err) {}
  }

  addUserProperties({@required String name, @required dynamic value}) {
    print(name);
    print(value.toString());
    try {
      if (isUserIdentified) {
        final customAttributes = new Map<String, dynamic>();
        customAttributes[name] = value;
        Intercom.updateUser(customAttributes: customAttributes);
        this
            ._firebaseAnalytics
            .setUserProperty(name: name, value: value.toString());
      }
    } catch (err, stacktrace) {
      print(err.toString());
      print(stacktrace.toString());
    }
  }
}

class FoAnalyticsEvents {
  static const checkin_by_clicking_on_contact =
      'checkin_by_clicking_on_contact';
  static const checkin_by_manual_entry_of_name_num =
      'checkin_by_manual_entry_of_name_num';
  static const bulk_checkin = 'bulk_checkin';
  static const app_shared = 'app_shared';
  static const nearby_promo_clicked = 'nearby_promo_clicked';
  static const nearby_promo_created = 'nearby_promo_created';
}

class FoAnalyticsUserProperties {
  static const no_of_locations = 'no_of_locations';
  static const language_chosen = 'language_chosen';
  static const google_locations_count = 'google_locations_count';
  static const google_locations_info = 'google_locations_info';
  static const google_location_created_from_app =
      'google_location_created_from_app';
  static const google_location_verification_started_from_app =
      'google_location_verification_started_from_app';
  static const google_location_verification_done_from_app =
      'google_location_verification_done_from_app';
  static const nearby_promo_created = 'nearby_promo_created';
  static const uses_google_to_login = 'uses_google_to_login';
  static const uses_company_email_to_login = 'uses_company_email_to_login';
  static const no_of_feedbacks = 'no_of_feedbacks';
  static const no_of_unirson = 'no_of_unirson';
  static const app_shared = 'app_shared';
}
