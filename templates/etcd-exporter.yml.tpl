groups:
  - name: ${job.tag}-etcd-exporter-metrics
    rules:
      #${replace(job.tag, "-", " ")} etcd members count
      - record: ${replace(job.tag, "-", "_")}_etcd_members:up:count
        expr: sum by (job) (up{job="${job.tag}-etcd-exporter"})
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}EtcdMembersDown
        expr: ${replace(job.tag, "-", "_")}_etcd_members:up:count < ${job.members_count}
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "${title(replace(job.tag, "-", " "))} Etcd Member(s) Down"
          description: "Number of etcd members detected by job *{{ $labels.job }}* has dropped to *{{ $value }}*"
      - record: ${replace(job.tag, "-", "_")}_etcd_members:has_leader:count
        expr: sum by (job) (etcd_server_has_leader{job="${job.tag}-etcd-exporter"})
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}EtcdMembersLeaderless
        expr: ${replace(job.tag, "-", "_")}_etcd_members:has_leader:count < ${job.members_count}
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "${title(replace(job.tag, "-", " "))} Etcd Member(s) Leaderless"
          description: "Number of etcd members that have a leader detected by job *{{ $labels.job }}* has dropped to *{{ $value }}*"
      - record: ${replace(job.tag, "-", "_")}_etcd_members:is_leader:count
        expr: sum by (job) (etcd_server_is_leader{job="${job.tag}-etcd-exporter"})
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}EtcdLeaderCountNot1
        expr: ${replace(job.tag, "-", "_")}_etcd_members:is_leader:count != 1
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "${title(replace(job.tag, "-", " "))} Etcd Cluster Does Not Have 1 Leader"
          description: "Expected 1 etcd member to report it is leader in job *{{ $labels.job }}* and instead there are *{{ $value }}*"
      - record: ${replace(job.tag, "-", "_")}_etcd_members:is_learner:count
        expr: sum by (job) (etcd_server_is_learner{job="${job.tag}-etcd-exporter"})
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}EtcdLearningTooLong
        expr: ${replace(job.tag, "-", "_")}_etcd_members:is_learner:count > 0
        for: ${job.max_learn_time}
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "${title(replace(job.tag, "-", " "))} Etcd Members Learning Takes Too Long"
          description: "Etcd member(s) in job *{{ $labels.job }}* learning for longer than tolerated delay of *${job.max_learn_time}*"
      - record: ${replace(job.tag, "-", "_")}_etcd_cluster:leadership_changes_seen:rate1m
        expr: max by (job) (rate(etcd_server_leader_changes_seen_total{job="${job.tag}-etcd-exporter"}[1m]))
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}EtcdLeaderChangesTooOften
        expr: ${replace(job.tag, "-", "_")}_etcd_cluster:leadership_changes_seen:rate1m > 0
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "${title(replace(job.tag, "-", " "))} Etcd Cluster Changes Leader Too Often"
          description: "Etcd cluster for job *{{ $labels.job }}* has changed leader at least once a minute for some time"
      - record: ${replace(job.tag, "-", "_")}_etcd_members:db_total_size_in_gigibytes:max
        expr: max by (job) (etcd_mvcc_db_total_size_in_bytes{job="${job.tag}-etcd-exporter"} / 1024 / 1024 / 1024)
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}EtcdDbSizeTooBig
        expr: ${replace(job.tag, "-", "_")}_etcd_members:db_total_size_in_gigibytes:max > (${job.max_db_size} * 0.9)
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "${title(replace(job.tag, "-", " "))} Etcd Cluster Db Is Getting Too Big"
          description: "Etcd cluster for job *{{ $labels.job }}* has db size of *{{ $value }}*GiB which is at least 90% of the *${job.max_db_size}*GiB maximum"
      - record: ${replace(job.tag, "-", "_")}_etcd_cluster:etcd_versions:count
        expr: count by (job) (max by (job, server_version) (etcd_server_version{job="${job.tag}-etcd-exporter"}))
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}EtcdInconsistentVersions
        expr: ${replace(job.tag, "-", "_")}_etcd_cluster:etcd_versions:count > 1
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "${title(replace(job.tag, "-", " "))} Etcd Members Have Inconsistent Versions"
          description: "Etcd members for job *{{ $labels.job }}* have *{{ $value }}* different etcd versions."
      - record: ${replace(job.tag, "-", "_")}_etcd_cluster:requests:rate1m
        expr: sum by (job) (max by (grpc_method, grpc_service, grpc_type, job) (rate(grpc_server_msg_received_total{job="${job.tag}-etcd-exporter"}[1m])))