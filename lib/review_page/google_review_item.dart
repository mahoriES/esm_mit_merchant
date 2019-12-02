import 'package:flutter/material.dart';
import 'package:foore/data/bloc/onboarding_guard.dart';
import 'package:foore/data/constants/feedback.dart';
import 'package:foore/data/model/feedback.dart';
import 'package:foore/review_page/reply_gmb.dart';
import 'package:provider/provider.dart';
import '../app_translations.dart';
import 'review_page_helper.dart';

class GoogleItemWidget extends StatelessWidget {
  final FeedbackItem _feedbackItem;
  final bool isShowReplyButton;

  GoogleItemWidget(this._feedbackItem, {Key key, this.isShowReplyButton})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final onboardingGuardBloc = Provider.of<OnboardingGuardBloc>(context);
    var onReply = () {
      Navigator.pushNamed(
        context,
        ReplyGmb.routeName,
        arguments: this._feedbackItem,
      );
    };

    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          height: 1.0,
          color: Theme.of(context).dividerColor,
        ),
        SizedBox(
          height: 20.0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              StarDisplay(
                  value: GmbReviewHelper.getStarRating(this._feedbackItem)),
              Container(
                width: 80.0,
                child: Text(
                  onboardingGuardBloc
                      .getLocationNameById(this._feedbackItem.fbLocationId),
                  style: Theme.of(context).textTheme.caption,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    ReviewPageHelper.getCreatedTimeText(this._feedbackItem),
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ),
              Container(child: this.sourceLogo(this._feedbackItem))
            ],
          ),
        ),
        ListTile(
          title: Text(ReviewPageHelper.getNameText(this._feedbackItem)),
          subtitle: GmbReviewHelper.isShowGmbComment(this._feedbackItem)
              ? Text(GmbReviewHelper.getGmbCommentText(this._feedbackItem))
              : null,
        ),
        reply(this._feedbackItem, context),
        this.isShowReplyButton
            ? Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: ButtonTheme.bar(
                  child: ButtonBar(
                    children: <Widget>[
                      RaisedButton(
                        elevation: 0.0,
                        child: Text(
                          GmbReviewHelper.isShowGmbReply(this._feedbackItem)
                              ? AppTranslations.of(context)
                                  .text("review_page_button_edit_reply")
                              : AppTranslations.of(context)
                                  .text("review_page_button_reply"),
                          style: Theme.of(context).textTheme.button.copyWith(
                                color: Colors.white,
                              ),
                        ),
                        onPressed: onReply,
                      ),
                    ],
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  Widget sourceLogo(FeedbackItem feedbackItem) {
    if (feedbackItem.source ==
        FeedbackSource.CONST_FEEDBACK_SOURCE_GOOGLE_REVIEW) {
      return Image(
        width: 40.0,
        image: AssetImage('assets/googlelogo.png'),
      );
    }
    return null;
  }

  Widget reply(FeedbackItem feedbackItem, BuildContext context) {
    if (!this.isShowReplyButton) {
      return Container();
    }
    if (!GmbReviewHelper.isShowGmbReply(feedbackItem)) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: double.infinity,
        color: Color.fromRGBO(233, 233, 233, 0.50),
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              AppTranslations.of(context).text("review_page_reply_posted"),
              style: Theme.of(context).textTheme.caption,
            ),
            SizedBox(
              height: 8.0,
            ),
            Text(
              GmbReviewHelper.gmbReplyText(feedbackItem),
              style: Theme.of(context).textTheme.body1,
            ),
          ],
        ),
      ),
    );
  }
}

class StarDisplay extends StatelessWidget {
  final int value;
  const StarDisplay({Key key, this.value = 0})
      : assert(value != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < value ? Icons.star : Icons.star_border,
          size: 18.0,
          color: Color.fromARGB(255, 239, 206, 74),
        );
      }),
    );
  }
}
