class SequenceResponse {
  int count;
  String next;
  String previous;
  List<SequenceItem> results;

  SequenceResponse({this.count, this.next, this.previous, this.results});

  SequenceResponse.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      results = new List<SequenceItem>();
      json['results'].forEach((v) {
        results.add(new SequenceItem.fromJson(v));
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

class SequenceItem {
  String sequenceId;
  String sequenceName;
  String ownerUserId;
  String created;
  int sentMessageCount;
  int scheduledMessageCount;
  int clickedLinkCount;
  int generatedLinkCount;
  bool isSelectedUi;

  SequenceItem(
      {this.sequenceId,
      this.sequenceName,
      this.ownerUserId,
      this.created,
      this.sentMessageCount,
      this.scheduledMessageCount,
      this.clickedLinkCount,
      this.generatedLinkCount});

  SequenceItem.fromJson(Map<String, dynamic> json) {
    sequenceId = json['sequence_id'];
    sequenceName = json['sequence_name'];
    ownerUserId = json['owner_user_id'];
    created = json['created'];
    sentMessageCount = json['sent_message_count'];
    scheduledMessageCount = json['scheduled_message_count'];
    clickedLinkCount = json['clicked_link_count'];
    generatedLinkCount = json['generated_link_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sequence_id'] = this.sequenceId;
    data['sequence_name'] = this.sequenceName;
    data['owner_user_id'] = this.ownerUserId;
    data['created'] = this.created;
    data['sent_message_count'] = this.sentMessageCount;
    data['scheduled_message_count'] = this.scheduledMessageCount;
    data['clicked_link_count'] = this.clickedLinkCount;
    data['generated_link_count'] = this.generatedLinkCount;
    return data;
  }
}