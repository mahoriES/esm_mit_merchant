import 'package:flutter/material.dart';
import 'package:foore/data/constants/feedback.dart';
import 'package:foore/data/model/feedback.dart';
import 'review_page_helper.dart';

class NpsFeedbackItemWidget extends StatelessWidget {
  final FeedbackItem _feedbackItem;

  NpsFeedbackItemWidget(this._feedbackItem, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          height: 1.0,
          color: Color.fromRGBO(233, 233, 233, 0.50),
        ),
        SizedBox(
          height: 20.0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: this.npsScoreColor(this._feedbackItem),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(
                      NpsFeedbackHelper.getScoreText(this._feedbackItem),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                NpsFeedbackHelper.getNpsRespondent(this._feedbackItem),
                style: TextStyle(
                  fontSize: 12.0,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    ReviewPageHelper.getCreatedTimeText(this._feedbackItem),
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
              Container(child: this.sourceLogo(this._feedbackItem))
            ],
          ),
        ),
        ListTile(
          title: Text(ReviewPageHelper.getNameText(this._feedbackItem)),
          subtitle: this._feedbackItem.comment != null
              ? Text(NpsFeedbackHelper.getCommentText(this._feedbackItem))
              : null,
        ),
      ],
    );
  }

  Color npsScoreColor(FeedbackItem feedbackItem) {
    var npsRespondent = NpsFeedbackHelper.getNpsRespondent(feedbackItem);

    if (npsRespondent == NpsFeedbackHelper.DETRACTOR) {
      return Colors.red;
    } else if (npsRespondent == NpsFeedbackHelper.PASSIVE) {
      return Colors.yellow;
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

  Widget reply() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        color: Color.fromRGBO(233, 233, 233, 0.50),
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Your reply has beeb posted on Google',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.black45,
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            Text(
              'Contrary to popular belief, Lorem Ipsum is not simply random text.',
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
