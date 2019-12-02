import 'package:flutter/material.dart';
import 'package:foore/data/bloc/onboarding_guard.dart';
import 'package:foore/data/constants/feedback.dart';
import 'package:foore/data/model/feedback.dart';
import 'package:provider/provider.dart';
import 'review_page_helper.dart';

class NpsFeedbackItemWidget extends StatelessWidget {
  final FeedbackItem _feedbackItem;

  NpsFeedbackItemWidget(this._feedbackItem, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final onboardingGuardBloc = Provider.of<OnboardingGuardBloc>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          contentPadding: EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
          title: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 8.0,
                backgroundColor: this.npsScoreColor(this._feedbackItem),
                child: Text(
                  NpsFeedbackHelper.getScoreText(this._feedbackItem),
                  style: TextStyle(
                      fontSize: 8.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              SizedBox(
                width: 4.0,
              ),
              Container(
                width: 120,
                child: Text(
                  onboardingGuardBloc
                      .getLocationNameById(this._feedbackItem.fbLocationId),
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .copyWith(fontSize: 10.0),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          leading: CircleAvatar(
            child: Icon(Icons.person),
            backgroundColor: Colors.blueGrey,
          ),
          subtitle: Container(
            child: Text(
              ReviewPageHelper.getCreatedTimeText(this._feedbackItem),
              style: Theme.of(context).textTheme.caption,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: Container(child: this.sourceLogo(this._feedbackItem)),
        ),
        Container(
          padding: EdgeInsets.only(left: 70.0, right: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(ReviewPageHelper.getNameText(this._feedbackItem),
                  style: Theme.of(context)
                      .textTheme
                      .body1
                      .copyWith(fontWeight: FontWeight.w600)),
              SizedBox(
                height: 4.0,
              ),
              Container(
                child: this._feedbackItem.comment != null
                    ? Text(NpsFeedbackHelper.getCommentText(this._feedbackItem))
                    : null,
              ),
            ],
          ),
        )
      ],
    );
  }

  Color npsScoreColor(FeedbackItem feedbackItem) {
    var npsRespondent = NpsFeedbackHelper.getNpsRespondent(feedbackItem);

    if (npsRespondent == NpsFeedbackHelper.DETRACTOR) {
      return Colors.red;
    } else if (npsRespondent == NpsFeedbackHelper.PASSIVE) {
      return Colors.orange;
    } else if (npsRespondent == NpsFeedbackHelper.PROMOTER) {
      return Colors.green;
    }
    return Colors.black54;
  }

  Widget sourceLogo(FeedbackItem feedbackItem) {
    if (feedbackItem.source == FeedbackSource.CONST_FEEDBACK_SOURCE_URL) {
      return Image(
        width: 20.0,
        image: AssetImage('assets/logo-black.png'),
      );
    } else if (feedbackItem.source ==
        FeedbackSource.CONST_FEEDBACK_SOURCE_MESSENGER) {
      return Image(
        width: 15.0,
        image: AssetImage('assets/messengerlogo.png'),
      );
    }
    return null;
  }
}
