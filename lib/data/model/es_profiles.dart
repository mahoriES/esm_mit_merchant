class EsGetProfilesResponse {
  EsProfile customer;
  EsProfile merchant;

  EsGetProfilesResponse({this.customer, this.merchant});

  EsGetProfilesResponse.fromJson(Map<String, dynamic> json) {
    customer = json['CUSTOMER'] != null
        ? new EsProfile.fromJson(json['CUSTOMER'])
        : null;
    merchant = json['MERCHANT'] != null
        ? new EsProfile.fromJson(json['MERCHANT'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.customer != null) {
      data['CUSTOMER'] = this.customer.toJson();
    }
    if (this.merchant != null) {
      data['MERCHANT'] = this.merchant.toJson();
    }
    return data;
  }
}

class EsProfile {
  EsProfileData data;
  String token;
  String role;

  EsProfile({this.data, this.token, this.role});

  EsProfile.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new EsProfileData.fromJson(json['data']) : null;
    token = json['token'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    data['token'] = this.token;
    data['role'] = this.role;
    return data;
  }
}

class EsProfileData {
  String profilePic;
  String profileName;
  String created;
  String modified;
  bool isSuspended;

  EsProfileData(
      {this.profilePic,
      this.profileName,
      this.created,
      this.modified,
      this.isSuspended});

  EsProfileData.fromJson(Map<String, dynamic> json) {
    profilePic = json['profile_pic'];
    profileName = json['profile_name'];
    created = json['created'];
    modified = json['modified'];
    isSuspended = json['is_suspended'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['profile_pic'] = this.profilePic;
    data['profile_name'] = this.profileName;
    data['created'] = this.created;
    data['modified'] = this.modified;
    data['is_suspended'] = this.isSuspended;
    return data;
  }
}