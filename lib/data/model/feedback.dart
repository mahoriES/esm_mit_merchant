class FeedbackItem {
  int feedbackId;
  String fbLocationId;
  String unirsonId;
  int score;
  String created;
  String name;
  String comment;
  int source;
  GmbReview gmbReview;
  int resolutionStatus;
  String resolutionTime;
  String resolutionOwnerId;
  String ticketId;

  FeedbackItem(
      {this.feedbackId,
      this.fbLocationId,
      this.unirsonId,
      this.score,
      this.created,
      this.name,
      this.comment,
      this.source,
      this.gmbReview,
      this.resolutionStatus,
      this.resolutionTime,
      this.resolutionOwnerId,
      this.ticketId});

  FeedbackItem.fromJson(Map<String, dynamic> json) {
    feedbackId = json['feedback_id'];
    fbLocationId = json['fb_location_id'];
    unirsonId = json['unirson_id'];
    score = json['score'];
    created = json['created'];
    name = json['name'];
    comment = json['comment'];
    source = json['source'];
    gmbReview = json['gmb_review'] != null
        ? new GmbReview.fromJson(json['gmb_review'])
        : null;
    resolutionStatus = json['resolution_status'];
    resolutionTime = json['resolution_time'];
    resolutionOwnerId = json['resolution_owner_id'];
    ticketId = json['ticket_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['feedback_id'] = this.feedbackId;
    data['fb_location_id'] = this.fbLocationId;
    data['unirson_id'] = this.unirsonId;
    data['score'] = this.score;
    data['created'] = this.created;
    data['name'] = this.name;
    data['comment'] = this.comment;
    data['source'] = this.source;
    if (this.gmbReview != null) {
      data['gmb_review'] = this.gmbReview.toJson();
    }
    data['resolution_status'] = this.resolutionStatus;
    data['resolution_time'] = this.resolutionTime;
    data['resolution_owner_id'] = this.resolutionOwnerId;
    data['ticket_id'] = this.ticketId;
    return data;
  }
}

class GmbReview {
  String starRating;
  ReviewReply reviewReply;
  String createDatetime;
  String updateDatetime;
  String reviewerPicture;
  String comment;

  GmbReview(
      {this.starRating,
      this.reviewReply,
      this.createDatetime,
      this.updateDatetime,
      this.reviewerPicture,
      this.comment});

  GmbReview.fromJson(Map<String, dynamic> json) {
    starRating = json['star_rating'];
    reviewReply = json['review_reply'] != null
        ? new ReviewReply.fromJson(json['review_reply'])
        : null;
    createDatetime = json['create_datetime'];
    updateDatetime = json['update_datetime'];
    reviewerPicture = json['reviewer_picture'];
    comment = json['comment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['star_rating'] = this.starRating;
    if (this.reviewReply != null) {
      data['review_reply'] = this.reviewReply.toJson();
    }
    data['create_datetime'] = this.createDatetime;
    data['update_datetime'] = this.updateDatetime;
    data['reviewer_picture'] = this.reviewerPicture;
    data['comment'] = this.comment;
    return data;
  }
}

class ReviewReply {
  String comment;
  String updateTime;

  ReviewReply({this.comment, this.updateTime});

  ReviewReply.fromJson(Map<String, dynamic> json) {
    comment = json['comment'];
    updateTime = json['updateTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['comment'] = this.comment;
    data['updateTime'] = this.updateTime;
    return data;
  }
}

class GmbReplyPayload {
  int feedbackId;
  String reply;

  GmbReplyPayload({this.feedbackId, this.reply});

  GmbReplyPayload.fromJson(Map<String, dynamic> json) {
    feedbackId = json['feedback_id'];
    reply = json['reply'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['feedback_id'] = this.feedbackId;
    data['reply'] = this.reply;
    return data;
  }
}
