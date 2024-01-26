groups:
  - name: ${cluster.tag}-minio-metrics
    rules:
      #${replace(cluster.tag, "-", " ")} minio nodes metrics
      - record: ${replace(cluster.tag, "-", "_")}_minio:offline_nodes:count
        expr: avg_over_time(minio_cluster_nodes_offline_total{cluster="${cluster.tag}"}[5m])
      #${replace(cluster.tag, "-", " ")} minio drives metrics
      - record: ${replace(cluster.tag, "-", "_")}_minio:offline_drives:count
        expr: avg_over_time(minio_cluster_drive_offline_total{cluster="${cluster.tag}"}[5m])
