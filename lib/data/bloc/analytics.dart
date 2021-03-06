import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:flutter/material.dart';
import 'package:foore/data/model/login.dart';
import 'package:foore/environments/environment.dart';

class FoAnalytics {
  FirebaseAnalytics _firebaseAnalytics;

  bool isInitialized = false;
  bool isUserIdentified = false;

  init() async {
    firebaseAnalyticsInit();
    this.isInitialized = true;
  }

  identifyUser(AuthInfo authData) {
    firebaseAnalyticsLogin(authData);
    isUserIdentified = true;
  }

  resetUserIdentity() {
    this.firebaseAnalyticsLogout();
    isUserIdentified = false;
  }

  firebaseAnalyticsInit() {
    this._firebaseAnalytics = FirebaseAnalytics();
    _firebaseAnalytics.setAnalyticsCollectionEnabled(Environment.isProd);
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

  firebaseAnalyticsLogout() {
    this._firebaseAnalytics.resetAnalyticsData();
  }

  trackUserEvent({@required String name, Map<String, dynamic> parameters}) {
    try {
      if (isUserIdentified) {
        this._firebaseAnalytics.logEvent(name: name, parameters: parameters);
      }
    } catch (err, stacktrace) {
      print(stacktrace.toString());
      //TODO: Custom sentry error

    }
  }

  setCurrentScreen(String screenName) {
    try {
      this._firebaseAnalytics.setCurrentScreen(screenName: screenName);
    } catch (err, stacktrace) {
      print(stacktrace.toString());
//TODO: Custom sentry error

    }
  }

  addUserProperties({@required String name, @required dynamic value}) {
    try {
      if (isUserIdentified) {
        final customAttributes = new Map<String, dynamic>();
        customAttributes[name] = value;

        this
            ._firebaseAnalytics
            .setUserProperty(name: name, value: value.toString());
      }
    } catch (err, stacktrace) {
      //TODO: Custom sentry error

      print(stacktrace.toString());
    }
  }
}

class FoAnalyticsEvents {
  static const checkin_by_clicking_on_contact = 'checkin_by_contact';
  static const checkin_by_manual_entry_of_name_num = 'checkin_by_name_num';
  static const bulk_checkin = 'bulk_checkin';
  static const app_shared = 'app_shared';
  static const nearby_promo_clicked = 'nearby_promo_clicked';
  static const nearby_promo_created = 'nearby_promo_created';
  static const payment_started = 'payment_started';
  static const payment_response = 'payment_response';
  static const suggested_sms_codes = 'suggested_sms_codes';
}

class FoAnalyticsUserProperties {
  static const no_of_locations = 'no_of_locations';
  static const sms_code = 'sms_code';
  static const language_chosen = 'language_chosen';
  static const google_locations_count = 'g_locations_count';
  static const google_locations_info = 'g_locations_info';
  static const google_location_created_from_app = 'g_loc_created';
  static const google_location_verification_started_from_app =
      'g_loc_veri_started';
  static const google_location_verification_done_from_app = 'g_loc_veri_done';
  static const uses_google_to_login = 'uses_google_login';
  static const uses_company_email_to_login = 'uses_email_login';
  static const no_of_feedbacks = 'no_of_feedbacks';
  static const no_of_unirson = 'no_of_unirson';
}
