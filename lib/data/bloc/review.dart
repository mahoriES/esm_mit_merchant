import 'dart:convert';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/feedback.dart';
import 'package:rxdart/rxdart.dart';

class ReviewBloc {
  final ReviewState _reviewState = new ReviewState();
  final  HttpService _httpService;

  BehaviorSubject<ReviewState> _subjectReviewState;


  ReviewBloc(this._httpService) {
    this._subjectReviewState = new BehaviorSubject<ReviewState>.seeded(
        _reviewState); //initializes the subject with element already
  }

  Observable<ReviewState> get reviewStateObservable =>
      _subjectReviewState.stream;

  getFeedbacks() {
    this._reviewState.isLoading = true;
    this._reviewState.isLoadingFailed = false;
    this._updateState();
    _httpService
        .foPost('segment/feedback/',
            '{"segment_info":{"top_operator":"and","condition_params_info":[]}}')
        .then((httpResponse) {
      if (httpResponse.statusCode == 200) {
        this._reviewState.response =
            FeedbackResponse.fromJson(json.decode(httpResponse.body));
        this._reviewState.items = this._reviewState.response.results;
        this._reviewState.isLoadingFailed = false;
        this._reviewState.isLoading = false;
      } else {
        this._reviewState.isLoadingFailed = true;
        this._reviewState.isLoading = false;
      }
      this._updateState();
    }).catchError((onError) {
      this._reviewState.isLoadingFailed = true;
      this._reviewState.isLoading = false;
      this._updateState();
    });
  }

  loadMore() {
    if (this._reviewState.response != null &&
        !this._reviewState.isLoadingMore) {
      this._reviewState.isLoadingMore = true;
      this._reviewState.isLoadingMoreFailed = false;
      this._updateState();
      _httpService
          .foPostUrl(this._reviewState.response.next,
              '{"segment_info":{"top_operator":"and","condition_params_info":[]}}')
          .then((httpResponse) {
        if (httpResponse.statusCode == 200) {
          print(httpResponse.body);
          this._reviewState.response =
              FeedbackResponse.fromJson(json.decode(httpResponse.body));
          this._reviewState.items.addAll(this._reviewState.response.results);
          this._reviewState.isLoadingMoreFailed = false;
          this._reviewState.isLoadingMore = false;
        } else {
          this._reviewState.isLoadingMoreFailed = true;
          this._reviewState.isLoadingMore = false;
        }
        this._updateState();
      }).catchError((err) {
        this._reviewState.isLoadingMoreFailed = true;
        this._reviewState.isLoadingMore = false;
        this._updateState();
      });
    }
  }

  _updateState() {
    this._subjectReviewState.sink.add(this._reviewState);
  }

  dispose() {
    this._subjectReviewState.close();
  }
}

class ReviewState {
  bool isLoading = false;
  bool isLoadingFailed = false;
  bool isLoadingMore = false;
  bool isLoadingMoreFailed = false;
  List<FeedbackItem> items = new List<FeedbackItem>();
  FeedbackResponse response;
  ReviewState() {
    this.isLoading = false;
    this.isLoadingFailed = false;
  }
}

class FeedbackResponse {
  int count;
  String next;
  String previous;
  List<FeedbackItem> results;

  FeedbackResponse({this.count, this.next, this.previous, this.results});

  FeedbackResponse.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    results = new List<FeedbackItem>();
    if (json['results'] != null) {
      json['results'].forEach((v) {
        results.add(new FeedbackItem.fromJson(v));
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
