class GoogleAccountState {
  static const loggedIn = 2;
  static const loggedOut = 3;
  static const loggedInsufficientPerm = 4;
  static const loggedAuthError = 6;
  static const disconnected = 8;
}

class GoogleAccount {
  GoogleProfile profile;
  int state;
  String created;

  GoogleAccount({this.profile, this.state, this.created});

  GoogleAccount.fromJson(Map<String, dynamic> json) {
    profile = json['profile'] != null
        ? new GoogleProfile.fromJson(json['profile'])
        : null;
    state = json['state'];
    created = json['created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.profile != null) {
      data['profile'] = this.profile.toJson();
    }
    data['state'] = this.state;
    data['created'] = this.created;
    return data;
  }
}

class GoogleProfile {
  String email;
  String name;
  String picture;

  GoogleProfile({this.email, this.name, this.picture});

  GoogleProfile.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    name = json['name'];
    picture = json['picture'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['name'] = this.name;
    data['picture'] = this.picture;
    return data;
  }
}
