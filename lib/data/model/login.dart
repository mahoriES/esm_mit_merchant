class AuthInfo {
  String token;
  UserProfile userProfile;
  CompanyInfo companyInfo;
  int code;

  AuthInfo({this.token, this.userProfile, this.companyInfo, this.code});

  AuthInfo.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    userProfile = json['user_profile'] != null
        ? new UserProfile.fromJson(json['user_profile'])
        : null;
    companyInfo = json['company_info'] != null
        ? new CompanyInfo.fromJson(json['company_info'])
        : null;
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = this.token;
    if (this.userProfile != null) {
      data['user_profile'] = this.userProfile.toJson();
    }
    if (this.companyInfo != null) {
      data['company_info'] = this.companyInfo.toJson();
    }
    data['code'] = this.code;
    return data;
  }
}

class UserProfile {
  String email;
  String name;
  String userUuid;
  String phone;
  int userType;
  bool userActive;
  bool isMe;
  int userStatus;
  String photo;

  UserProfile(
      {this.email,
      this.name,
      this.userUuid,
      this.phone,
      this.userType,
      this.userActive,
      this.isMe,
      this.userStatus,
      this.photo});

  UserProfile.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    name = json['name'];
    userUuid = json['user_uuid'];
    phone = json['phone'];
    userType = json['user_type'];
    userActive = json['user_active'];
    isMe = json['is_me'];
    userStatus = json['user_status'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['name'] = this.name;
    data['user_uuid'] = this.userUuid;
    data['phone'] = this.phone;
    data['user_type'] = this.userType;
    data['user_active'] = this.userActive;
    data['is_me'] = this.isMe;
    data['user_status'] = this.userStatus;
    data['photo'] = this.photo;
    return data;
  }
}

class CompanyInfo {
  String name;
  String companyUuid;
  Payment payment;
  Sms sms;

  CompanyInfo({this.name, this.companyUuid, this.payment, this.sms});

  CompanyInfo.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    companyUuid = json['company_uuid'];
    payment =
        json['payment'] != null ? new Payment.fromJson(json['payment']) : null;
    sms = json['sms'] != null ? new Sms.fromJson(json['sms']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['company_uuid'] = this.companyUuid;
    if (this.payment != null) {
      data['payment'] = this.payment.toJson();
    }
    if (this.sms != null) {
      data['sms'] = this.sms.toJson();
    }
    return data;
  }
}

class Payment {
  bool subscriptionIsWorking;

  Payment({this.subscriptionIsWorking});

  Payment.fromJson(Map<String, dynamic> json) {
    subscriptionIsWorking = json['subscription_is_working'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subscription_is_working'] = this.subscriptionIsWorking;
    return data;
  }
}

class Sms {
  String smsCode;
  int smsCodeStatus;
  int smsCredits;
  int maxSmsCredits;

  Sms({this.smsCode, this.smsCodeStatus, this.smsCredits, this.maxSmsCredits});

  Sms.fromJson(Map<String, dynamic> json) {
    smsCode = json['sms_code'];
    smsCodeStatus = json['sms_code_status'];
    smsCredits = json['sms_credits'];
    maxSmsCredits = json['max_sms_credits'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sms_code'] = this.smsCode;
    data['sms_code_status'] = this.smsCodeStatus;
    data['sms_credits'] = this.smsCredits;
    data['max_sms_credits'] = this.maxSmsCredits;
    return data;
  }
}