import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:foore/widgets/empty_list.dart';
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
    Navigator.pushNamed(
      context,
      CheckInPage.routeName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.dehaze),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Text(
          AppTranslations.of(context).text("reviews_page_title"),
        ),
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
                  } else if (snapshot.data.items.length == 0) {
                    return EmptyList(
                      titleText: 'No reviews found',
                      subtitleText:
                          "Press 'Get reviews' to send review request to your customers.",
                    );
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
      floatingActionButton: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 25,
        ),
        onPressed: this.onGetReviews,
        child: Container(
          child: Text(
            AppTranslations.of(context).text("review_page_button_get_reviews"),
            style: Theme.of(context).textTheme.subhead.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
