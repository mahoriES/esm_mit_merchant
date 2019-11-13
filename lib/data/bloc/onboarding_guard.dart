import 'dart:convert';
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
    _httpService.foGet('ui/helper/account/?onboarding').then((httpResponse) {
      if (httpResponse.statusCode == 200) {
        this._onboardingState.response =
            UiHelperResponse.fromJson(json.decode(httpResponse.body));
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

  UiHelperResponse({this.onboarding});

  UiHelperResponse.fromJson(Map<String, dynamic> json) {
    onboarding = json['onboarding'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['onboarding'] = this.onboarding;
    return data;
  }
}
