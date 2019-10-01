class LocationItem {
  String name;
  String fbLocationId;

  LocationItem({this.name, this.fbLocationId});

  LocationItem.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    fbLocationId = json['fb_location_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['fb_location_id'] = this.fbLocationId;
    return data;
  }
}