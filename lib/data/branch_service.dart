import 'dart:convert';

import 'package:foore/environments/environment.dart';
import 'package:http/http.dart' as http;
import 'package:foore/data/bloc/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BranchService {
  String _branchKey;

  String _branchDomain;

  String _referralUrl;

  final AuthBloc authBloc;

  static final branchData = BranchData(
      ogTitle: "More Google Reviews, More Customers",
      marketingTitle: "Foore - Get More Google Reviews - Apps on Google Play",
      ogDescription:
          "Use Foore app to promote your business for free and get new customers. Increase your visibility & your business.",
      ogImageUrl:
          "https://cdn.branch.io/branch-assets/1575132441899-og_image.jpeg");

  static final defaultPayload = BranchPayload(
    campaign: "Share",
    channel: "Referral",
    feature: "Whatsapp",
    type: 2,
  );

  BranchService(this.authBloc) {
    this._branchKey = Environment.branchKey;
    this._branchDomain = Environment.branchDomain;
  }

  clear() {
    this._referralUrl = null;
  }

  getReferralUrl() async {
    String referralCode = this.authBloc.authState.userReferralCode;
    String userUUid = this.authBloc.authState.userUUid;
    String userEmail = this.authBloc.authState.userEmail;
    if (referralCode == null) {
      return 'https://www.foore.in';
    }
    if (this._referralUrl != null) {
      return this._referralUrl;
    } else {
      try {
        String existingUrl = await getExistingReferralUrl(referralCode);
        if (existingUrl != null) {
          this._referralUrl = existingUrl;
          return existingUrl;
        } else {
          String generatedUrl =
              await generateReferralUrl(referralCode, userEmail, userUUid);
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

    print(httpResponse.statusCode);
    print(httpResponse.body);

    if (httpResponse.statusCode == 200) {
      return mayBeUrl;
    } else if (httpResponse.statusCode == 404) {
      return null;
    } else {
      throw 'Error';
    }
  }

  Future<bool> shouldShowSharePrompt() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var isShown = sharedPreferences.getBool('sharePromptShown') ?? false;
    if (!isShown) {
      await sharedPreferences.setBool('sharePromptShown', true);
    }
    return !isShown;
  }

  generateReferralUrl(
      String referralCode, String userEmail, String userUuid) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    String payload = json.encode(
        getBranchPayloadWithReferralCode(referralCode, userEmail, userUuid)
            .toJson());

    final httpResponse = await http.post('https://api.branch.io/v1/url',
        headers: requestHeaders, body: payload);

    print(httpResponse.statusCode);
    print(httpResponse.body);

    if (httpResponse.statusCode == 200) {
      return json.decode(httpResponse.body)['url'];
    } else {
      throw 'Error';
    }
  }

  BranchPayload getBranchPayloadWithReferralCode(
      String referralCode, String userEmail, String userUuid) {
    var email = userEmail ?? '';
    var uuid = userUuid ?? '';

    return BranchPayload(
        alias: referralCode,
        branchKey: this._branchKey,
        campaign: defaultPayload.campaign,
        channel: defaultPayload.channel,
        feature: defaultPayload.feature,
        data: branchData.copyWith(newMarketingTitle: email + ' ' + uuid),
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
  String ogTitle;
  String marketingTitle;
  String ogDescription;
  String ogImageUrl;

  BranchData({
    this.ogTitle,
    this.marketingTitle,
    this.ogDescription,
    this.ogImageUrl,
  });

  BranchData.fromJson(Map<String, dynamic> json) {
    ogTitle = json['\$og_title'];
    marketingTitle = json['\$marketing_title'];
    ogDescription = json['\$og_description'];
    ogImageUrl = json['\$og_image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['\$og_title'] = this.ogTitle;
    data['\$marketing_title'] = this.marketingTitle;
    data['\$og_description'] = this.ogDescription;
    data['\$og_image_url'] = this.ogImageUrl;
    return data;
  }

  BranchData copyWith({String newMarketingTitle}) {
    return BranchData(
      ogTitle: ogTitle,
      marketingTitle: newMarketingTitle,
      ogDescription: ogDescription,
      ogImageUrl: ogImageUrl,
    );
  }
}
