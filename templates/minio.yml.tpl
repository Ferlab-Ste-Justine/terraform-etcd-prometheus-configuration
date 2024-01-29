groups:
  - name: ${cluster.tag}-minio-metrics
    rules:
      #${replace(cluster.tag, "-", " ")} minio nodes metrics
      - record: ${replace(cluster.tag, "-", "_")}_minio:offline_nodes:count
        expr: minio_cluster_nodes_offline_total{cluster="${cluster.tag}"}
      #${replace(cluster.tag, "-", " ")} minio drives metrics
      - record: ${replace(cluster.tag, "-", "_")}_minio:offline_drives:count
        expr: minio_cluster_drive_offline_total{cluster="${cluster.tag}"} or minio_cluster_disk_offline_total{cluster="${cluster.tag}"}
