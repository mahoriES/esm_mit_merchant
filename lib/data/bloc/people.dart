import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/unirson.dart';
import 'package:rxdart/rxdart.dart';

class PeopleBloc {
  final PeopleState _peopleState = new PeopleState();
  final HttpService _httpService;

  String searchText = '';

  BehaviorSubject<PeopleState> _subjectPeopleState;

  onSearchTextChanged(TextEditingController controller) {
    this.searchText = controller.text != null ? controller.text : '';
    this.getPeopleFromSearch();
  }

  PeopleBloc(this._httpService) {
    this._subjectPeopleState =
        new BehaviorSubject<PeopleState>.seeded(_peopleState);
  }

  Observable<PeopleState> get peopleStateObservable =>
      _subjectPeopleState.stream;

  getPeopleFromSearch() {
    this._peopleState.isLoading = true;
    this._peopleState.response = null;
    this._updateState();
    _httpService
        .foGet('unirson/all/search/?search_key=${this.searchText}')
        .then((httpResponse) {
      if (httpResponse.statusCode == 200) {
        this._peopleState.isLoadingFailed = false;
        this._peopleState.isLoading = false;
        this._peopleState.response =
            UnirsonItemResponse.fromJson(json.decode(httpResponse.body));
        this._peopleState.items = this._peopleState.response.results;
      } else {
        this._peopleState.isLoadingFailed = true;
        this._peopleState.isLoading = false;
      }
      this._updateState();
    }).catchError((onError) {
      this._peopleState.isLoadingFailed = true;
      this._peopleState.isLoading = false;
      this._updateState();
    });
  }

  loadMore() {
    if (this._peopleState.response == null || this._reviewState.isLoadingMore) {
      return;
    }
    if (this._peopleState.response.next == null) {
      return;
    }
    this._peopleState.isLoadingMore = true;
    this._peopleState.isLoadingMoreFailed = false;
    this._updateState();
    _httpService.foGetUrl(this._peopleState.response.next).then((httpResponse) {
      if (httpResponse.statusCode == 200) {
        print(httpResponse.body);
        this._peopleState.response =
            UnirsonItemResponse.fromJson(json.decode(httpResponse.body));
        this._peopleState.items.addAll(this._peopleState.response.results);
        this._peopleState.isLoadingMoreFailed = false;
        this._peopleState.isLoadingMore = false;
      } else {
        this._peopleState.isLoadingMoreFailed = true;
        this._peopleState.isLoadingMore = false;
      }
      this._updateState();
    }).catchError((err) {
      this._peopleState.isLoadingMoreFailed = true;
      this._peopleState.isLoadingMore = false;
      this._updateState();
    });
  }

  _updateState() {
    this._subjectPeopleState.sink.add(this._peopleState);
  }

  dispose() {
    this._subjectPeopleState.close();
  }
}

class PeopleState {
  bool isLoading = false;
  UnirsonItemResponse response;
  List<UnirsonItem> items = new List<UnirsonItem>();
  bool isLoadingFailed = false;
  bool isLoadingMore;
  bool isLoadingMoreFailed;
  PeopleState() {
    this.isLoading = false;
    this.isLoadingFailed = false;
    this.isLoadingMore = false;
    this.isLoadingMoreFailed = false;
  }
}

class UnirsonItemResponse {
  int count;
  String next;
  String previous;
  List<UnirsonItem> results;

  UnirsonItemResponse({this.count, this.next, this.previous, this.results});

  UnirsonItemResponse.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    results = new List<UnirsonItem>();
    if (json['results'] != null) {
      json['results'].forEach((v) {
        results.add(new UnirsonItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    data['next'] = this.next;
    data['previous'] = this.previous;
    if (this.results != null) {
      data['results'] = this.results.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
