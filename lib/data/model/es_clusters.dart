class EsCluster {
  String clusterId;
  String clusterName;
  String description;
  String clusterCode;

  EsCluster(
      {this.clusterId, this.clusterName, this.description, this.clusterCode});

  EsCluster.fromJson(Map<String, dynamic> json) {
    clusterId = json['cluster_id'];
    clusterName = json['cluster_name'];
    description = json['description'];
    clusterCode = json['cluster_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cluster_id'] = this.clusterId;
    data['cluster_name'] = this.clusterName;
    data['description'] = this.description;
    data['cluster_code'] = this.clusterCode;
    return data;
  }
}