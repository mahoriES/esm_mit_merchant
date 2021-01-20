import 'package:foore/data/model/es_video_models/es_video_list.dart';

class EsCluster {
  String clusterId;
  String clusterName;
  String description;
  String clusterCode;
  Photo thumbnail;
  Photo introPhoto;

  EsCluster(
      {this.clusterId,
      this.clusterName,
      this.description,
      this.clusterCode,
      this.introPhoto,
      this.thumbnail});

  EsCluster.fromJson(Map<String, dynamic> json) {
    clusterId = json['cluster_id'];
    clusterName = json['cluster_name'];
    description = json['description'];
    clusterCode = json['cluster_code'];
    if (json['thumb'] != null && json['thumb'] is Map)
      thumbnail = Photo.fromJson(json['thumb']);
    if (json['intro'] != null && json['intro'] is Map )
      introPhoto = Photo.fromJson(json['intro']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cluster_id'] = this.clusterId;
    data['cluster_name'] = this.clusterName;
    data['description'] = this.description;
    data['cluster_code'] = this.clusterCode;
    if (data['intro'] != null)
      data['intro'] = this.introPhoto.toJson();
    if (data['thumb'] != null)
      data['thumb'] = this.thumbnail.toJson();
    return data;
  }
}
