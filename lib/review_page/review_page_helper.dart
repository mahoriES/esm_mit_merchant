import 'package:intl/intl.dart';
import 'package:foore/data/constants/feedback.dart';
import 'package:foore/data/model/feedback.dart';

class ReviewPageHelper {
  static bool isFeedbackNps(FeedbackItem feedbackItem) =>
      feedbackItem.source == FeedbackSource.CONST_FEEDBACK_SOURCE_URL ||
      feedbackItem.source == FeedbackSource.CONST_FEEDBACK_SOURCE_MESSENGER;

  static bool isFeedbackGoogleReview(FeedbackItem feedbackItem) =>
      feedbackItem.source == FeedbackSource.CONST_FEEDBACK_SOURCE_GOOGLE_REVIEW;

  static String getNameText(FeedbackItem feedbackItem) {
    return feedbackItem.name != null ? feedbackItem.name : '';
  }

  static String getCreatedTimeText(FeedbackItem feedbackItem) {
    var lastInteractionDate = DateTime.parse(feedbackItem.created);
    var formatter = new DateFormat('MMM dd, yyyy, hh:mm a');
    String timeText = formatter.format(lastInteractionDate);
    return timeText;
  }
}

class GmbReviewHelper {
  static bool isShowGmbComment(FeedbackItem feedbackItem) {
    if (feedbackItem.gmbReview == null) {
      return false;
    }
    return feedbackItem.gmbReview.comment != null;
  }

  static String getGmbCommentText(FeedbackItem feedbackItem) {
    if (feedbackItem.gmbReview == null) {
      return '';
    }
    return feedbackItem.gmbReview.comment != null
        ? feedbackItem.gmbReview.comment
        : '';
  }

  static bool isShowGmbReply(FeedbackItem feedbackItem) {
    if (feedbackItem.gmbReview == null) {
      return false;
    }
    if (feedbackItem.gmbReview.reviewReply == null) {
      return false;
    }
    return feedbackItem.gmbReview.reviewReply.comment != null;
  }

  static String gmbReplyText(FeedbackItem feedbackItem) {
    return feedbackItem.gmbReview.reviewReply.comment != null
        ? feedbackItem.gmbReview.reviewReply.comment
        : '';
  }

  static String getReplyButtonText(FeedbackItem feedbackItem) {
    if (isShowGmbReply(feedbackItem)) {
      return 'Edit reply';
    }
    return 'Reply';
  }

  static int getStarRating(FeedbackItem feedbackItem) {
    if (feedbackItem.gmbReview == null) {
      return 0;
    }
    switch (feedbackItem.gmbReview.starRating) {
      case StarRating.ONE:
        return 1;
      case StarRating.TWO:
        return 2;
      case StarRating.THREE:
        return 3;
      case StarRating.FOUR:
        return 4;
      case StarRating.FIVE:
        return 5;
    }
    return 0;
  }
}

class NpsFeedbackHelper {
  static const PROMOTER = 'Promoter';
  static const DETRACTOR = 'Detractor';
  static const PASSIVE = 'Passive';
  static const NPS_RATING_1 = 1;
  static const NPS_RATING_2 = 2;
  static const NPS_RATING_3 = 3;
  static const NPS_RATING_4 = 4;
  static const NPS_RATING_5 = 5;
  static const NPS_RATING_6 = 6;
  static const NPS_RATING_7 = 7;
  static const NPS_RATING_8 = 8;
  static const NPS_RATING_9 = 9;
  static const NPS_RATING_10 = 10;

  static String getNpsRespondent(FeedbackItem feedbackItem) {
    if (feedbackItem.score == NPS_RATING_1 ||
        feedbackItem.score == NPS_RATING_2 ||
        feedbackItem.score == NPS_RATING_3 ||
        feedbackItem.score == NPS_RATING_4 ||
        feedbackItem.score == NPS_RATING_5 ||
        feedbackItem.score == NPS_RATING_6) {
      return DETRACTOR;
    } else if (feedbackItem.score == NPS_RATING_7 ||
        feedbackItem.score == NPS_RATING_8) {
      return PASSIVE;
    } else if (feedbackItem.score == NPS_RATING_9 ||
        feedbackItem.score == NPS_RATING_10) {
      return PROMOTER;
    }
    return '';
  }

  static String getNpsRespondentText(FeedbackItem feedbackItem) {
    return getNpsRespondent(feedbackItem);
  }

  static String getScoreText(FeedbackItem feedbackItem) {
    return feedbackItem.score.toString();
  }

  static String getCommentText(FeedbackItem feedbackItem) {
    return feedbackItem.comment != null ? feedbackItem.comment : '';
  }
}
