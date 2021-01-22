import 'dart:convert';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:foore/data/constants/es_api_path.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_clusters.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:circles/circles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EsSelectCircleBloc {
  EsSelectCircleState _esSelectCircleState = EsSelectCircleState();
  final circleSearchTextFieldController = TextEditingController();

  BehaviorSubject<EsSelectCircleState> _subjectEsSelectCircleState;

  final HttpService httpService;

  Observable<EsSelectCircleState> get selectCircleObservable =>
      _subjectEsSelectCircleState.stream;

  EsSelectCircleBloc(this.httpService) {
    this._subjectEsSelectCircleState =
        BehaviorSubject<EsSelectCircleState>.seeded(_esSelectCircleState);
  }

  void onTapLocationAction() async {
    await AppSettings.openLocationSettings();
    getNearbyCircles();
  }

  void setCurrentUserAsAdvanced() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(SharedPreferencesKeys.isAdvancedUser, true);
  }

  Future<bool> isAdvancedUser() async {
    bool _isAdvancedUser;
    final prefs = await SharedPreferences.getInstance();
    try {
      final bool isAdvancedUser =
          prefs.getBool(SharedPreferencesKeys.isAdvancedUser);
      _isAdvancedUser = isAdvancedUser ?? false;
    } catch (e) {
      _isAdvancedUser = false;
      prefs.setBool(SharedPreferencesKeys.isAdvancedUser, false);
    }
    return _isAdvancedUser;
  }

  void setCirclesAsSelected(String circleCode) {
    final List<EsCluster> circles = [
      ..._esSelectCircleState.searchResultsCircles??<EsCluster>[],
      ..._esSelectCircleState.nearbyCircles??<EsCluster>[],
      ..._esSelectCircleState.trendingCircles??<EsCluster>[]
    ].toList();
    final index = circles.indexWhere((element) => element.clusterCode==circleCode);
    if (index > -1) {
      _esSelectCircleState.selectedCircle = circles[index];
      _updateState();
    }
  }

  void getNearbyCircles() async {
    bool serviceEnabled;
    LocationPermission permission;

    this._esSelectCircleState.nearbyCirclesLoading = LoadingStatus.LOADING;
    _updateState();

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      this._esSelectCircleState.locationEnabled = false;
      this._esSelectCircleState.nearbyCirclesLoading = LoadingStatus.SUCCESS;
      _updateState();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      this._esSelectCircleState.locationEnabled = false;
      this._esSelectCircleState.nearbyCirclesLoading = LoadingStatus.SUCCESS;
      _updateState();
      return;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        this._esSelectCircleState.locationEnabled = false;
        this._esSelectCircleState.nearbyCirclesLoading = LoadingStatus.SUCCESS;
        _updateState();
        return;
      }
    }
    Position _position = await Geolocator.getCurrentPosition()
        .timeout(const Duration(seconds: 20));
    if (_position != null &&
        _position.latitude != null &&
        _position.longitude != null) {
      try {
        final response = await this.httpService.esGet(EsApiPaths.getClusters,
            queryParams: {
              'lat': _position.latitude.toString(),
              'lon': _position.longitude.toString()
            });
        if (response.statusCode == 200) {
          final List<EsCluster> nearbyCircles = [];
          jsonDecode(response.body)?.forEach((item) {
            final nearbyCircle = EsCluster.fromJson(item);
            if (_esSelectCircleState.savedCircles.isEmpty ||
                _esSelectCircleState.savedCircles.indexWhere((element) =>
                        element.clusterId == nearbyCircle.clusterId) ==
                    -1) nearbyCircles.add(nearbyCircle);
          });
          this._esSelectCircleState.nearbyCircles = nearbyCircles;
        }
      } catch (e, stackTrace) {
        FirebaseCrashlytics.instance.recordError(e, stackTrace);
      }
    }
    this._esSelectCircleState.locationEnabled = true;
    this._esSelectCircleState.nearbyCirclesLoading = LoadingStatus.SUCCESS;
    _updateState();
  }

  void getTrendingCircles() async {
    final response = await this.httpService.esGet(EsApiPaths.getClusters,
        queryParams: {'trending': true.toString()});
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<EsCluster> trendingCircles = [];
      jsonDecode(response.body)?.forEach((item) {
        trendingCircles.add(EsCluster.fromJson(item));
      });
      this._esSelectCircleState.trendingCircles = trendingCircles;
      _updateState();
    }
  }

  void getSearchResultsCircles() async {
    if (this._esSelectCircleState.searchResultsLoading == LoadingStatus.LOADING)
      return;
    this._esSelectCircleState.searchResultsLoading = LoadingStatus.LOADING;
    this._esSelectCircleState.searchResultsCircles = [];
    _updateState();
    final response = await this.httpService.esGet(EsApiPaths.getClusters,
        queryParams: {'search_query': circleSearchTextFieldController.text});
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<EsCluster> searchResultsCircles = [];
      jsonDecode(response.body)?.forEach((item) {
        searchResultsCircles.add(EsCluster.fromJson(item));
      });
      this._esSelectCircleState.searchResultsCircles = searchResultsCircles;
    }
    this._esSelectCircleState.searchResultsLoading = LoadingStatus.SUCCESS;
    _updateState();
  }

  void dispose() {
    this._subjectEsSelectCircleState.close();
    this.circleSearchTextFieldController.dispose();
  }

  void _updateState() {
    if (!this._subjectEsSelectCircleState.isClosed) {
      this._subjectEsSelectCircleState.sink.add(this._esSelectCircleState);
    }
  }
}

class EsSelectCircleState {
  List<EsCluster> nearbyCircles;
  List<EsCluster> savedCircles;
  List<EsCluster> trendingCircles;
  List<EsCluster> searchResultsCircles;
  EsCluster selectedCircle;
  LoadingStatus nearbyCirclesLoading;
  LoadingStatus savedCirclesLoading;
  LoadingStatus searchResultsLoading;
  bool locationEnabled;

  EsSelectCircleState() {
    nearbyCircles = [];
    savedCircles = [];
    trendingCircles = [];
    searchResultsCircles = [];
    selectedCircle = null;
    nearbyCirclesLoading = LoadingStatus.INITIAL;
    savedCirclesLoading = LoadingStatus.INITIAL;
    searchResultsLoading = LoadingStatus.INITIAL;
    locationEnabled = true;
  }
}

extension CircleTile on List<EsCluster> {
  List<CircleTileType> toCircleTileList() {
    return this
        .map((circle) => CircleTileType(
            circleCode: circle.clusterCode,
            circleId: circle.clusterId,
            imageUrl: circle.thumbnail?.photoUrl ?? '',
            isSelected: false,
            circleName: circle.clusterName,
            circleDescription: circle.description))
        .toList();
  }
}

enum LoadingStatus { LOADING, SUCCESS, INITIAL }

class SharedPreferencesKeys {
  static const String isAdvancedUser = "isAdvancedUser";
}
