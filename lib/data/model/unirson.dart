class UnirsonItem {
  String unirsonId;
  String fullName;
  String countryPhone;
  String lastInteraction;

  UnirsonItem(
      {this.unirsonId,
      this.fullName,
      this.countryPhone,
      this.lastInteraction,
      });

  UnirsonItem.fromJson(Map<String, dynamic> json) {
    unirsonId = json['unirson_id'];
    fullName = json['full_name'];
    countryPhone = json['country_phone'];
    lastInteraction = json['last_interaction'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['unirson_id'] = this.unirsonId;
    data['full_name'] = this.fullName;
    data['country_phone'] = this.countryPhone;
    data['last_interaction'] = this.lastInteraction;
    return data;
  }
}
