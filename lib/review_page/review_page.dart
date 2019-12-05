import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/auth.dart';
import 'package:foore/share_page/share_page.dart';
import 'package:foore/widgets/empty_list.dart';
import 'package:foore/widgets/something_went_wrong.dart';
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

  onGetReviews() async {
    bool isDone = await CheckInPage.open(context);
    final authBloc = Provider.of<AuthBloc>(context);
    if (isDone == true) {
      bool shouldShowSharePage = await authBloc.shouldShowSharePrompt();
      if (shouldShowSharePage) {
        Navigator.of(context).pushNamed(SharePage.routeName);
      }
    }
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
                    return SomethingWentWrong(
                      onRetry: this._reviewBloc.getFeedbacks,
                    );
                  } else if (snapshot.data.items.length == 0) {
                    return EmptyList(
                      titleText: 'No reviews found',
                      subtitleText:
                          "Press 'Get reviews' to send review request to your customers.",
                    );
                  }
                  return FeedbackListWidget(snapshot.data.items,
                      this._reviewBloc, snapshot.data.isLoadingMore);
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              }),
        ),
      ),
      floatingActionButton: Transform.translate(
        offset: Offset(0, -15),
        child: RaisedButton(
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
              AppTranslations.of(context)
                  .text("review_page_button_get_reviews"),
              style: Theme.of(context).textTheme.subhead.copyWith(
                    color: Colors.white,
                  ),
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
  final bool _isLoadingMore;

  FeedbackListWidget(
      this._feedbackItems, this._reviewBloc, this._isLoadingMore);

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          this._reviewBloc.loadMore();
        }
        return false;
      },
      child: ListView.builder(
          padding: EdgeInsets.only(bottom: 72),
          itemCount: this._feedbackItems.length + 1,
          itemBuilder: (context, index) {
            if (this._feedbackItems.length == index) {
              if (this._isLoadingMore) {
                return Container(
                  margin: EdgeInsets.all(4.0),
                  height: 36,
                  width: 36,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                return Container();
              }
            }
            return feedbackItemWidget(feedbackItem: this._feedbackItems[index]);
          }),
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
