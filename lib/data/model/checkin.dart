class CheckInPayload {
  String unirsonId;
  String locationId;
  String phoneTo;
  String fullName;
  List<String> seqIds;
  int reviewSeq;

  CheckInPayload(
      {this.unirsonId,
      this.locationId,
      this.seqIds,
      this.reviewSeq,
      this.phoneTo,
      this.fullName});

  CheckInPayload.fromJson(Map<String, dynamic> json) {
    unirsonId = json['unirson_id'];
    locationId = json['location_id'];
    seqIds = json['seq_ids'].cast<String>();
    reviewSeq = json['review_seq'];
    phoneTo = json['phone_to'];
    fullName = json['full_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['unirson_id'] = this.unirsonId;
    data['location_id'] = this.locationId;
    data['seq_ids'] = this.seqIds;
    data['review_seq'] = this.reviewSeq;
    data['phone_to'] = this.phoneTo;
    data['full_name'] = this.fullName;
    return data;
  }
}

class CheckInItem {
  String checkinId;
  String unirsonId;
  String fbLocationId;
  String created;
  String checkinBy;

  CheckInItem(
      {this.checkinId,
      this.unirsonId,
      this.fbLocationId,
      this.created,
      this.checkinBy});

  CheckInItem.fromJson(Map<String, dynamic> json) {
    checkinId = json['checkin_id'];
    unirsonId = json['unirson_id'];
    fbLocationId = json['fb_location_id'];
    created = json['created'];
    checkinBy = json['checkin_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['checkin_id'] = this.checkinId;
    data['unirson_id'] = this.unirsonId;
    data['fb_location_id'] = this.fbLocationId;
    data['created'] = this.created;
    data['checkin_by'] = this.checkinBy;
    return data;
  }
}
///////////////
class BulkCheckInPayload {
  List<ContactInfo> contactInfos;
  String locationId;
  List<String> seqIds;
  int reviewSeq;

  BulkCheckInPayload(
      {this.contactInfos, this.locationId, this.seqIds, this.reviewSeq});

  BulkCheckInPayload.fromJson(Map<String, dynamic> json) {
    if (json['contact_infos'] != null) {
      contactInfos = new List<ContactInfo>();
      json['contact_infos'].forEach((v) {
        contactInfos.add(new ContactInfo.fromJson(v));
      });
    }
    locationId = json['location_id'];
    seqIds = json['seq_ids'].cast<String>();
    reviewSeq = json['review_seq'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.contactInfos != null) {
      data['contact_infos'] = this.contactInfos.map((v) => v.toJson()).toList();
    }
    data['location_id'] = this.locationId;
    data['seq_ids'] = this.seqIds;
    data['review_seq'] = this.reviewSeq;
    return data;
  }
}

class ContactInfo {
  String phoneNum;
  String fullName;

  ContactInfo({this.phoneNum, this.fullName});

  ContactInfo.fromJson(Map<String, dynamic> json) {
    phoneNum = json['phone_num'];
    fullName = json['full_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['phone_num'] = this.phoneNum;
    data['full_name'] = this.fullName;
    return data;
  }
}
