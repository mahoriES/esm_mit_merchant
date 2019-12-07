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
    _firebaseAnalytics.setAnalyticsCollectionEnabled(Environment.isProd);
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
    if (isUserIdentified) {
      Intercom.logEvent(name, parameters);
      this._firebaseAnalytics.logEvent(name: name, parameters: parameters);
    }
  }

  setCurrentScreen(String screenName) {
    this._firebaseAnalytics.setCurrentScreen(screenName: screenName);
  }

  addUserProperties({@required String name, @required dynamic value}) {
    if (isUserIdentified) {
      Map customAttributes = new Map();
      customAttributes[name] = value;
      Intercom.updateUser(customAttributes: customAttributes);

      this._firebaseAnalytics.setUserProperty(name: name, value: value.toString());
    }
  }
}


class FoAnalyticsEvents {
  static const checkin_by_clicking_on_contact = 'checkin by clicking on contact';
  static const checkin_by_manual_entry_of_name_num = 'checkin by manual entry of name num';
  static const bulk_checkin = 'bulk checkin';
  static const app_shared = 'app shared';
  static const nearby_promo_clicked = 'nearby promo clicked';
  static const nearby_promo_created = 'nearby promo created';
}

class FoAnalyticsUserProperties {
  static const no_of_locations = 'no of locations';
  static const language_chosen = 'language chosen';
  static const google_locations_exists_or_not = 'google locations exists or not';
  static const google_locations_categories = 'google locations categories';
  static const google_location_created_from_app = 'google_location_created_from_app';
  static const google_location_verification_started_from_app = 'google_location_verification_started_from_app';
  static const google_location_verification_done_from_app = 'google_location_verification_done_from_app';
  static const nearby_promo_created = 'nearby promo created';
  static const uses_google_to_login = 'uses_google_to_login';
  static const uses_company_email_to_login = 'uses_company_email_to_login';
  static const no_of_feedbacks = 'no_of_feedbacks';
  static const no_of_unirson = 'no_of_unirson';
  static const app_shared = 'app shared';

}