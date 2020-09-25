class VideoUploadUrlResponse {
  VideoMeta videoMeta;
  SignedUrlInfo signedUrlInfo;

  VideoUploadUrlResponse({this.videoMeta, this.signedUrlInfo});

  VideoUploadUrlResponse.fromJson(Map<String, dynamic> json) {
    videoMeta = json['video_meta'] != null
        ? new VideoMeta.fromJson(json['video_meta'])
        : null;
    signedUrlInfo = json['signed_url_info'] != null
        ? new SignedUrlInfo.fromJson(json['signed_url_info'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.videoMeta != null) {
      data['video_meta'] = this.videoMeta.toJson();
    }
    if (this.signedUrlInfo != null) {
      data['signed_url_info'] = this.signedUrlInfo.toJson();
    }
    return data;
  }
}

class VideoMeta {
  String videoId;
  String videoUrl;
  int videoHeight;
  int videoWidth;
  int videoDuration;

  VideoMeta(
      {this.videoId,
      this.videoUrl,
      this.videoHeight,
      this.videoWidth,
      this.videoDuration});

  VideoMeta.fromJson(Map<String, dynamic> json) {
    videoId = json['video_id'];
    videoUrl = json['video_url'];
    videoHeight = json['video_height'];
    videoWidth = json['video_width'];
    videoDuration = json['video_duration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['video_id'] = this.videoId;
    data['video_url'] = this.videoUrl;
    data['video_height'] = this.videoHeight;
    data['video_width'] = this.videoWidth;
    data['video_duration'] = this.videoDuration;
    return data;
  }
}

class SignedUrlInfo {
  String url;
  Fields fields;

  SignedUrlInfo({this.url, this.fields});

  SignedUrlInfo.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    fields =
        json['fields'] != null ? new Fields.fromJson(json['fields']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    if (this.fields != null) {
      data['fields'] = this.fields.toJson();
    }
    return data;
  }
}

class Fields {
  String acl;
  String key;
  String xAmzAlgorithm;
  String xAmzCredential;
  String xAmzDate;
  String policy;
  String xAmzSignature;

  Fields(
      {this.acl,
      this.key,
      this.xAmzAlgorithm,
      this.xAmzCredential,
      this.xAmzDate,
      this.policy,
      this.xAmzSignature});

  Fields.fromJson(Map<String, dynamic> json) {
    acl = json['acl'];
    key = json['key'];
    xAmzAlgorithm = json['x-amz-algorithm'];
    xAmzCredential = json['x-amz-credential'];
    xAmzDate = json['x-amz-date'];
    policy = json['policy'];
    xAmzSignature = json['x-amz-signature'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['acl'] = this.acl;
    data['key'] = this.key;
    data['x-amz-algorithm'] = this.xAmzAlgorithm;
    data['x-amz-credential'] = this.xAmzCredential;
    data['x-amz-date'] = this.xAmzDate;
    data['policy'] = this.policy;
    data['x-amz-signature'] = this.xAmzSignature;
    return data;
  }
}
