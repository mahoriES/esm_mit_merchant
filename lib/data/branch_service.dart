import 'dart:convert';

import 'package:foore/environments/environment.dart';
import 'package:http/http.dart' as http;
import 'package:foore/data/bloc/auth.dart';

class BranchService {
  String _branchKey;

  String _branchDomain;

  String _referralUrl;

  static final branchData = BranchData(
      ogType: "website",
      canonicalUrl:
          "https://play.google.com/store/apps/details?id=in.foore.mobile&hl=en",
      ogTitle: "Foore - Get More Google Reviews - Apps on Google Play",
      marketingTitle: "Foore - Get More Google Reviews - Apps on Google Play",
      ogDescription:
          "Foore lets you collect customer reviews for free and improve your Google ranking & rating.\n\nGoogle reviews are crucial for local businesses with physical stores. Using the Foore app, business owners can automate their review collection process. Get more ",
      ogImageUrl:
          "https://cdn.branch.io/branch-assets/1574077806065-og_image.jpeg",
      androidUrl:
          "https://play.google.com/store/apps/details?id=in.foore.mobile&hl=en",
      iosUrl:
          "https://play.google.com/store/apps/details?id=in.foore.mobile&hl=en");

  static final defaultPayload = BranchPayload(
    campaign: "Test",
    channel: "Test 3",
    feature: "Test 2",
    type: 2,
  );

  BranchService(AuthBloc authBloc) {
    this._branchKey = Environment.branchKey;
    this._branchDomain = Environment.branchDomain;
  }

  getReferralUrl() async {
    String referralCode = '3rwrw';
    if (this._referralUrl != null) {
      return this._referralUrl;
    } else {
      try {
        String existingUrl = await getExistingReferralUrl(referralCode);
        if (existingUrl != null) {
          this._referralUrl = existingUrl;
          return existingUrl;
        } else {
          String generatedUrl = await generateReferralUrl(referralCode);
          this._referralUrl = generatedUrl;
          return generatedUrl;
        }
      } catch (err) {
        return 'https://www.foore.in';
      }
    }
  }

  getExistingReferralUrl(String referralCode) async {
    final mayBeUrl = this._branchDomain + '/$referralCode';
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    final httpResponse = await http.get(
        'https://api.branch.io/v1/url?url=$mayBeUrl&branch_key=$_branchKey',
        headers: requestHeaders);

    if (httpResponse.statusCode == 200) {
      return mayBeUrl;
    } else if (httpResponse.statusCode == 404) {
      return null;
    } else {
      throw 'Error';
    }
  }

  generateReferralUrl(String referralCode) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    String payload =
        json.encode(getBranchPayloadWithReferralCode(referralCode).toJson());

    final httpResponse = await http.post('https://api.branch.io/v1/url',
        headers: requestHeaders, body: payload);

    if (httpResponse.statusCode == 200) {
      return json.decode(httpResponse.body)['url'];
    } else {
      throw 'Error';
    }
  }

  BranchPayload getBranchPayloadWithReferralCode(String referralCode) {
    return BranchPayload(
        alias: referralCode,
        branchKey: this._branchKey,
        campaign: defaultPayload.campaign,
        channel: defaultPayload.channel,
        feature: defaultPayload.feature,
        type: 2);
  }

  Future<http.Response> get(url, {Map<String, String> headers}) =>
      http.get(url, headers: headers);
}

class BranchPayload {
  String branchKey;
  String campaign;
  String channel;
  String feature;
  String alias;
  int type;
  BranchData data;

  BranchPayload(
      {this.branchKey,
      this.campaign,
      this.channel,
      this.feature,
      this.alias,
      this.type,
      this.data});

  BranchPayload.fromJson(Map<String, dynamic> json) {
    branchKey = json['branch_key'];
    campaign = json['campaign'];
    channel = json['channel'];
    feature = json['feature'];
    alias = json['alias'];
    type = json['type'];
    data = json['data'] != null ? new BranchData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['branch_key'] = this.branchKey;
    data['campaign'] = this.campaign;
    data['channel'] = this.channel;
    data['feature'] = this.feature;
    data['alias'] = this.alias;
    data['type'] = this.type;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class BranchData {
  String ogType;
  String canonicalUrl;
  String ogTitle;
  String marketingTitle;
  String ogDescription;
  String ogImageUrl;
  String androidUrl;
  String iosUrl;

  BranchData(
      {this.ogType,
      this.canonicalUrl,
      this.ogTitle,
      this.marketingTitle,
      this.ogDescription,
      this.ogImageUrl,
      this.androidUrl,
      this.iosUrl});

  BranchData.fromJson(Map<String, dynamic> json) {
    ogType = json['\$og_type'];
    canonicalUrl = json['\$canonical_url'];
    ogTitle = json['\$og_title'];
    marketingTitle = json['\$marketing_title'];
    ogDescription = json['\$og_description'];
    ogImageUrl = json['\$og_image_url'];
    androidUrl = json['\$android_url'];
    iosUrl = json['\$ios_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['\$og_type'] = this.ogType;
    data['\$canonical_url'] = this.canonicalUrl;
    data['\$og_title'] = this.ogTitle;
    data['\$marketing_title'] = this.marketingTitle;
    data['\$og_description'] = this.ogDescription;
    data['\$og_image_url'] = this.ogImageUrl;
    data['\$android_url'] = this.androidUrl;
    data['\$ios_url'] = this.iosUrl;
    return data;
  }
}
