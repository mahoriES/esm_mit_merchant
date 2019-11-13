import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/onboarding_guard.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/gmb_location.dart';
import 'package:foore/data/model/google_account.dart';
import 'package:rxdart/rxdart.dart';

import '../../router.dart';

class OnboardingBloc {
  final OnboardingState _onboardingState = new OnboardingState();
  final HttpService _httpService;
  final OnboardingGuardBloc _onboardingGuardBloc;

  BehaviorSubject<OnboardingState> _subjectOnboardingState;

  OnboardingBloc(this._httpService, this._onboardingGuardBloc) {
    this._subjectOnboardingState = new BehaviorSubject<OnboardingState>.seeded(
        _onboardingState); //initializes the subject with element already
  }

  Observable<OnboardingState> get onboardingStateObservable =>
      _subjectOnboardingState.stream;

  getData() {
    if (this._onboardingState.shouldFetch) {
      this._onboardingState.isLoading = true;
      this._onboardingState.isLoadingFailed = false;
      this._updateState();
      _httpService
          .foGet(
              'ui/helper/account/?verified&onboarding&google_account&gmb_locations&location_connections')
          .then((httpResponse) {
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
  }

  createStoreForGmbLocations(BuildContext context) {
    final gmbLocationIds =
        this._onboardingState.locations.takeWhile((location) {
      return location.isSelectedUi != null ? location.isSelectedUi : false;
    }).map((location) {
      return location.gmbLocationId;
    }).toList();

    if (this._onboardingState.isSubmitting == false &&
        gmbLocationIds.length > 0) {
      this._onboardingState.isSubmitting = true;
      this._updateState();
      var payload = CreateStorePayload(gmbLocationIds: gmbLocationIds);
      var payloadString = json.encode(payload.toJson());
      _httpService
          .foPost('gmb/create/store/', payloadString)
          .then((httpResponse) {
        print(httpResponse.statusCode);
        if (httpResponse.statusCode == 200 || httpResponse.statusCode == 202) {
          this._onboardingState.isSubmitting = false;
          this._onboardingGuardBloc.setOnboardingDone();
          Navigator.of(context).pushReplacementNamed(Router.homeRoute);
        } else {
          this._onboardingState.isSubmitting = false;
        }
        this._updateState();
      }).catchError((onError) {
        this._onboardingState.isSubmitting = false;
        this._updateState();
      });
    }
  }

  _updateState() {
    this._subjectOnboardingState.sink.add(this._onboardingState);
  }

  dispose() {
    this._subjectOnboardingState.close();
  }

  setLocationSelected(GmbLocation locationItem, bool isSelected) {
    locationItem.isSelectedUi = isSelected;
    this._updateState();
  }
}

class OnboardingState {
  bool isLoading;
  bool isLoadingFailed;
  UiHelperResponse response;
  bool isSubmitting;

  get shouldFetch => isLoading == false && response == null;

  List<GmbLocation> get locations =>
      response != null ? response.gmbLocations : [];

  get isShowLocationList =>
      locations.length != 0 && isLoading == false && isLoadingFailed == false;

  get _googleAccountState => response?.googleAccount?.state;

  get isShowInsufficientPermissions =>
      _googleAccountState != GoogleAccountState.loggedIn &&
      isLoading == false &&
      isLoadingFailed == false;

  get isShowNoGmbLocations =>
      locations.length == 0 && isLoading == false && isLoadingFailed == false;

  OnboardingState() {
    this.isLoading = false;
    this.isLoadingFailed = false;
    this.isSubmitting = false;
  }
}

class UiHelperResponse {
  GoogleAccount googleAccount;
  List<GmbLocation> gmbLocations;

  UiHelperResponse({
    this.googleAccount,
    this.gmbLocations,
  });

  UiHelperResponse.fromJson(Map<String, dynamic> json) {
    googleAccount = json['google_account'] != null
        ? new GoogleAccount.fromJson(json['google_account'])
        : null;
    gmbLocations = new List<GmbLocation>();
    if (json['gmb_locations'] != null) {
      json['gmb_locations'].forEach((v) {
        gmbLocations.add(new GmbLocation.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.googleAccount != null) {
      data['google_account'] = this.googleAccount.toJson();
    }
    if (this.gmbLocations != null) {
      data['gmb_locations'] = this.gmbLocations.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CreateStorePayload {
  List<String> gmbLocationIds;

  CreateStorePayload({
    this.gmbLocationIds,
  });

  CreateStorePayload.fromJson(Map<String, dynamic> json) {
    gmbLocationIds = json['gmb_location_ids'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['gmb_location_ids'] = this.gmbLocationIds;
    return data;
  }
}
