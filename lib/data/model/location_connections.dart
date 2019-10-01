class LocationConnections {
  String name;
  String fbLocationId;
  String gmbLocationId;
  int facebookPageId;
  String address;

  LocationConnections(
      {this.name,
      this.fbLocationId,
      this.gmbLocationId,
      this.facebookPageId,
      this.address});

  LocationConnections.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    fbLocationId = json['fb_location_id'];
    gmbLocationId = json['gmb_location_id'];
    facebookPageId = json['facebook_page_id'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['fb_location_id'] = this.fbLocationId;
    data['gmb_location_id'] = this.gmbLocationId;
    data['facebook_page_id'] = this.facebookPageId;
    data['address'] = this.address;
    return data;
  }
}
