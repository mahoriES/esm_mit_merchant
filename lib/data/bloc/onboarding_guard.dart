import 'dart:convert';
import 'package:foore/data/bloc/analytics.dart';
import 'package:foore/data/http_service.dart';
import 'package:rxdart/rxdart.dart';

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
        .foGet('ui/helper/account/?onboarding&locations')
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
}

class OnboardingGuardState {
  bool isLoading;
  bool isLoadingFailed;
  UiHelperResponse response;
  get onboarding => response?.onboarding;
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

  UiHelperResponse({this.onboarding});

  UiHelperResponse.fromJson(Map<String, dynamic> json) {
    locations = new List<FoLocations>();
    if (json['locations'] != null) {
      json['locations'].forEach((v) {
        locations.add(new FoLocations.fromJson(v));
      });
    }
    onboarding = json['onboarding'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.locations != null) {
      data['locations'] = this.locations.map((v) => v.toJson()).toList();
    }
    data['onboarding'] = this.onboarding;
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
