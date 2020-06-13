class EsGetOtpResponse {
  String phone;
  String token;

  EsGetOtpResponse({this.phone, this.token});

  EsGetOtpResponse.fromJson(Map<String, dynamic> json) {
    phone = json['phone'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['phone'] = this.phone;
    data['token'] = this.token;
    return data;
  }
}

class EsGetTokenPayload {
  String phone;
  String token;
  String thirdPartyId;

  EsGetTokenPayload({this.phone, this.token, this.thirdPartyId});

  EsGetTokenPayload.fromJson(Map<String, dynamic> json) {
    phone = json['phone'];
    token = json['token'];
    thirdPartyId = json['third_party_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['phone'] = this.phone;
    data['token'] = this.token;
    data['third_party_id'] = this.thirdPartyId;
    return data;
  }
}

class EsAuthData {
  String token;
  EsUser user;

  EsAuthData({this.token, this.user});

  EsAuthData.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    user = json['user'] != null ? new EsUser.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = this.token;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    return data;
  }
}

class EsUser {
  String phone;
  bool isActive;
  String userId;

  EsUser({this.phone, this.isActive, this.userId});

  EsUser.fromJson(Map<String, dynamic> json) {
    phone = json['phone'];
    isActive = json['is_active'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['phone'] = this.phone;
    data['is_active'] = this.isActive;
    data['user_id'] = this.userId;
    return data;
  }
}

class EsSignUpPayload {
  String phone;
  String thirdPartyId;

  EsSignUpPayload({this.phone, this.thirdPartyId});

  EsSignUpPayload.fromJson(Map<String, dynamic> json) {
    phone = json['phone'];
    thirdPartyId = json['third_party_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['phone'] = this.phone;
    data['third_party_id'] = this.thirdPartyId;
    return data;
  }
}
