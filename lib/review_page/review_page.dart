import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foore/check_in_page/check_in_page.dart';
import 'package:foore/data/bloc/review.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/feedback.dart';
import 'package:foore/review_page/nps_feedback_item.dart';
import 'package:foore/review_page/review_page_helper.dart';

import '../app_translations.dart';
import 'google_review_item.dart';

class ReviewPage extends StatefulWidget {
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  ReviewBloc _reviewBloc;

  @override
  void didChangeDependencies() {
    final httpService = Provider.of<HttpService>(context);
    if (this._reviewBloc == null) {
      this._reviewBloc = ReviewBloc(httpService);
      this._reviewBloc.getFeedbacks();
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    this._reviewBloc.dispose();
    super.dispose();
  }

  onGetReviews() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => CheckInPage(),
          fullscreenDialog: true,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        textTheme: Typography.blackMountainView,
        iconTheme: IconThemeData.fallback(),
        leading: IconButton(
          icon: Icon(Icons.dehaze),
          color: Colors.black54,
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Text(
          AppTranslations.of(context).text("reviews_page_title"),
          style: TextStyle(
            color: Colors.black54,
            fontSize: 24.0,
            letterSpacing: 1.1,
          ),
        ),
        elevation: 0.0,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: RaisedButton(
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(50.0),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 12,
                ),
                color: Colors.blue,
                onPressed: this.onGetReviews,
                child: Container(
                  child: Text(
                    AppTranslations.of(context)
                        .text("review_page_button_get_reviews"),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 0,
          ),
          child: StreamBuilder<ReviewState>(
              stream: _reviewBloc.reviewStateObservable,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.data.isLoadingFailed) {
                    return Text('Loading Failed');
                  }
                  return FeedbackListWidget(
                      snapshot.data.items, this._reviewBloc);
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              }),
        ),
      ),
    );
  }
}

class FeedbackListWidget extends StatelessWidget {
  final List<FeedbackItem> _feedbackItems;
  final ReviewBloc _reviewBloc;

  FeedbackListWidget(this._feedbackItems, this._reviewBloc);

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        print('onNotification');
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          print('onNotification: load more');
          this._reviewBloc.loadMore();
        }
        return false;
      },
      child: ListView(
          children: this._feedbackItems.map((item) {
        return feedbackItemWidget(feedbackItem: item);
      }).toList()),
    );
  }

  Widget feedbackItemWidget({FeedbackItem feedbackItem}) {
    if (ReviewPageHelper.isFeedbackNps(feedbackItem)) {
      return NpsFeedbackItemWidget(feedbackItem);
    } else if (ReviewPageHelper.isFeedbackGoogleReview(feedbackItem)) {
      return GoogleItemWidget(
        feedbackItem,
        isShowReplyButton: true,
      );
    }
    return null;
  }
}
