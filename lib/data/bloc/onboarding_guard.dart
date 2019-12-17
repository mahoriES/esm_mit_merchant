import 'dart:convert';
import 'package:foore/data/bloc/analytics.dart';
import 'package:foore/data/http_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingGuardBloc {
  final OnboardingGuardState _onboardingState = new OnboardingGuardState();
  final HttpService _httpService;

  BehaviorSubject<OnboardingGuardState> _subjectOnboardingState;

  OnboardingGuardBloc(this._httpService) {
    this._subjectOnboardingState =
        new BehaviorSubject<OnboardingGuardState>.seeded(
            _onboardingState); //initializes the subject with element already
  }

  Observable<OnboardingGuardState> get onboardingStateObservable =>
      _subjectOnboardingState.stream;

  getData() {
    this._onboardingState.isLoading = true;
    this._onboardingState.isLoadingFailed = false;
    this._updateState();
    _httpService
        .foGet('ui/helper/account/?onboarding&locations&company_info')
        .then((httpResponse) {
      if (httpResponse.statusCode == 200) {
        print(httpResponse.body);
        this._onboardingState.response =
            UiHelperResponse.fromJson(json.decode(httpResponse.body));
        this._httpService.foAnalytics.addUserProperties(
            name: FoAnalyticsUserProperties.no_of_locations,
            value: this._onboardingState.response.locations.length);
        this._onboardingState.isLoadingFailed = false;
        this._onboardingState.isLoading = false;
      } else {
        this._onboardingState.isLoadingFailed = true;
        this._onboardingState.isLoading = false;
      }
      this._updateState();
    }).catchError((onError) {
      this._onboardingState.isLoadingFailed = true;
      this._onboardingState.isLoading = false;
      this._updateState();
    });
  }

  setOnboardingDone() {
    if (this._onboardingState.response != null) {
      this._onboardingState.response.onboarding = 0;
      this._updateState();
    }
  }

  String getLocationNameById(String locationId) {
    String locationName = '';
    if (this._onboardingState.locations.length > 1) {
      for (var location in this._onboardingState.locations) {
        if (location.fbLocationId == locationId) {
          locationName = location.name;
          break;
        }
      }
    }
    return locationName;
  }

  _updateState() {
    this._subjectOnboardingState.sink.add(this._onboardingState);
  }

  dispose() {
    this._subjectOnboardingState.close();
  }

  Future<bool> shouldShowSmsCodeCustomize() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var showSmsCode = sharedPreferences.getBool('showSmsCode') ?? false;
    if (!showSmsCode) {
      await sharedPreferences.setBool('showSmsCode', true);
    }
    return showSmsCode;
  }
}

class OnboardingGuardState {
  bool isLoading;
  bool isLoadingFailed;
  UiHelperResponse response;
  get onboarding => response?.onboarding;

  String get smsCode {
    var code = 'oFoore';
    if (response == null) {
      return code;
    }
    if (response.companyInfo == null) {
      return code;
    }
    if (response.companyInfo.sms == null) {
      return code;
    }
    if (response.companyInfo.sms.smsCode == null) {
      return code;
    }
    return response.companyInfo.sms.smsCode;
  }

  get isOnboardingRequired =>
      isLoading == false &&
      isLoadingFailed == false &&
      onboarding != 0 &&
      onboarding != null;

  List<FoLocations> get locations => response != null ? response.locations : [];

  // get isOnboardingRequired => isLoading == false;

  get isShowChild =>
      response != null && isLoading == false && isLoadingFailed == false;

  get shouldFetch => isLoading == false && response == null;

  OnboardingGuardState() {
    this.isLoading = false;
    this.isLoadingFailed = false;
  }
}

class UiHelperResponse {
  int onboarding;
  List<FoLocations> locations;
  CompanyInfo companyInfo;

  UiHelperResponse({this.onboarding, this.companyInfo});

  UiHelperResponse.fromJson(Map<String, dynamic> json) {
    locations = new List<FoLocations>();
    if (json['locations'] != null) {
      json['locations'].forEach((v) {
        locations.add(new FoLocations.fromJson(v));
      });
    }
    companyInfo = json['company_info'] != null
        ? new CompanyInfo.fromJson(json['company_info'])
        : null;
    onboarding = json['onboarding'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.locations != null) {
      data['locations'] = this.locations.map((v) => v.toJson()).toList();
    }
    if (this.companyInfo != null) {
      data['company_info'] = this.companyInfo.toJson();
    }
    data['onboarding'] = this.onboarding;
    return data;
  }
}

class CompanyInfo {
  String name;
  String companyUuid;
  Payment payment;
  Sms sms;

  CompanyInfo({this.name, this.companyUuid, this.payment, this.sms});

  CompanyInfo.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    companyUuid = json['company_uuid'];
    payment =
        json['payment'] != null ? new Payment.fromJson(json['payment']) : null;
    sms = json['sms'] != null ? new Sms.fromJson(json['sms']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['company_uuid'] = this.companyUuid;
    if (this.payment != null) {
      data['payment'] = this.payment.toJson();
    }
    if (this.sms != null) {
      data['sms'] = this.sms.toJson();
    }
    return data;
  }
}

class Payment {
  bool subscriptionIsWorking;

  Payment({this.subscriptionIsWorking});

  Payment.fromJson(Map<String, dynamic> json) {
    subscriptionIsWorking = json['subscription_is_working'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subscription_is_working'] = this.subscriptionIsWorking;
    return data;
  }
}

class Sms {
  String smsCode;
  int smsCodeStatus;
  int smsCredits;
  int maxSmsCredits;

  Sms({this.smsCode, this.smsCodeStatus, this.smsCredits, this.maxSmsCredits});

  Sms.fromJson(Map<String, dynamic> json) {
    smsCode = json['sms_code'];
    smsCodeStatus = json['sms_code_status'];
    smsCredits = json['sms_credits'];
    maxSmsCredits = json['max_sms_credits'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sms_code'] = this.smsCode;
    data['sms_code_status'] = this.smsCodeStatus;
    data['sms_credits'] = this.smsCredits;
    data['max_sms_credits'] = this.maxSmsCredits;
    return data;
  }
}

class FoLocations {
  String name;
  String fbLocationId;
  FoLocationMetaData metaData;

  FoLocations({this.name, this.fbLocationId});

  FoLocations.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    fbLocationId = json['fb_location_id'];
    metaData = json['meta_data'] != null
        ? new FoLocationMetaData.fromJson(json['meta_data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['fb_location_id'] = this.fbLocationId;
    if (this.metaData != null) {
      data['meta_data'] = this.metaData.toJson();
    }
    return data;
  }
}

class FoLocationMetaData {
  double latitude;
  double longitude;

  FoLocationMetaData({this.latitude, this.longitude});

  FoLocationMetaData.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    return data;
  }
}
