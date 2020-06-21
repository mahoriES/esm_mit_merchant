import 'dart:io';

import 'package:uuid/uuid.dart';

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
  String id;
  bool isUploadFailed = false;
  EsUploadableFile(this.file);
  setUploadFailed() {
    this.isUploadFailed = true;
    this.id = Uuid().v1();
  }
}
