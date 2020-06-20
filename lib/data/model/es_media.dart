import 'dart:io';

class EsUploadImageResponse {
  String photoId;
  String photoUrl;
  String contentType;

  EsUploadImageResponse({this.photoId, this.photoUrl, this.contentType});

  EsUploadImageResponse.fromJson(Map<String, dynamic> json) {
    photoId = json['photo_id'];
    photoUrl = json['photo_url'];
    contentType = json['content_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['photo_id'] = this.photoId;
    data['photo_url'] = this.photoUrl;
    data['content_type'] = this.contentType;
    return data;
  }
}

class EsUploadableFile {
  final File file;
  bool isUploadFailed = false;
  EsUploadableFile(this.file);
  setUploadFailed() {
    this.isUploadFailed = true;
  }
}
