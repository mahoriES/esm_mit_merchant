import 'package:foore/data/model/es_video_models/es_video_upload_url.dart';

class CreateVideoUploadPayload {
  SignedUrlInfo urlInfo;
  CreateVideoUploadPayload(this.urlInfo);

  Map<String, String> toJson() {
    return {
      'acl': this.urlInfo.fields.acl,
      'key': this.urlInfo.fields.key,
      'x-amz-algorithm': this.urlInfo.fields.xAmzAlgorithm,
      'x-amz-credential': this.urlInfo.fields.xAmzCredential,
      'x-amz-date': this.urlInfo.fields.xAmzDate,
      'policy': this.urlInfo.fields.policy,
      'x-amz-signature': this.urlInfo.fields.xAmzSignature,
    };
  }
}

class CreateVideoDetailsPayload {
  String title;
  String videoId;
  String videoUrl;
  String buisnessId;

  CreateVideoDetailsPayload(
    this.title,
    this.videoId,
    this.videoUrl,
    this.buisnessId,
  );

  Map<String, dynamic> toJson() {
    return {
      "post_type": "video",
      "title": this.title,
      "business_id": this.buisnessId,
      "content": {
        "video": {
          "video_id": this.videoId,
          "video_url": this.videoUrl,
        }
      }
    };
  }
}
