groups:
  - name: ${job.tag}-patroni-exporter-metrics
    rules:
      #${replace(job.tag, "-", " ")} patroni members count
      - record: ${replace(job.tag, "-", "_")}_patroni_members:up:count
        expr: sum by (job) (up{job="${job.tag}-patroni-exporter"})
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}PatroniMembersDown
        expr: ${replace(job.tag, "-", "_")}_patroni_members:up:count < ${job.members_count}
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "${title(replace(job.tag, "-", " "))} Patroni Member(s) Down"
          description: "Number of patroni members detected by job *{{ $labels.job }}* has dropped to *{{ $value }}*"
      #${replace(job.tag, "-", " ")} patroni members with running postgres count
      - record: ${replace(job.tag, "-", "_")}_patroni_members:postgres_running:count
        expr: sum by (job) (patroni_postgres_running{job="${job.tag}-patroni-exporter"})
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}PatroniMembersPostgresServiceDown
        expr: ${replace(job.tag, "-", "_")}_patroni_members:postgres_running:count < sum by (job) (up{job="${job.tag}-patroni-exporter"})
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "${title(replace(job.tag, "-", " "))} Patroni Member(s) Postgres Service Down"
          description: "Number of patroni members with a running postgres service detected by job *{{ $labels.job }}* has dropped to *{{ $value }}*"
      - record: ${replace(job.tag, "-", "_")}_patroni_members:postgres_runtime:minutes
        expr: (time() - patroni_postmaster_start_time{job="${job.tag}-patroni-exporter"}) / 60
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}PatroniMembersPostgresServiceRestarting
        expr: ${replace(job.tag, "-", "_")}_patroni_members:postgres_runtime:minutes < 5
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "${title(replace(job.tag, "-", " "))} Patroni Member(s) Postgres Service Restarting a Lot"
          description: "Instance *{{ $labels.instance }}* of job *{{ $labels.job }}* has been restarting its postgres service for some time. Its postgres service was last restarted *{{ $value }}* minutes ago"
      - record: ${replace(job.tag, "-", "_")}_patroni_members:primary:count
        expr: sum by (job) (patroni_primary{job="${job.tag}-patroni-exporter"})
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}PatroniPrimaryCountUnexpected
        expr: ${replace(job.tag, "-", "_")}_patroni_members:primary:count != 1
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "${title(replace(job.tag, "-", " "))} Patroni Primary Count Unexpected"
          description: "Expected patroni cluster of job *{{ $labels.job }}* to have 1 primary. It had *{{ $value }}*"
      - record: ${replace(job.tag, "-", "_")}_patroni_members:replica:count
        expr: sum by (job) (patroni_replica{job="${job.tag}-patroni-exporter"})
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}PatroniReplicaCountUnexpected
        expr: ${replace(job.tag, "-", "_")}_patroni_members:replica:count != ${job.members_count - 1}
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "${title(replace(job.tag, "-", " "))} Patroni Replica Count Unexpected"
          description: "Expected patroni cluster of job *{{ $labels.job }}* to have ${job.members_count - 1} replicas. It had *{{ $value }}*"
      - record: ${replace(job.tag, "-", "_")}_patroni_members:sync_standby:count
        expr: sum by (job) (patroni_sync_standby{job="${job.tag}-patroni-exporter"})
%{ if job.synchronous_replication ~}
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}PatroniSyncStandbyCountUnexpected
        expr: ${replace(job.tag, "-", "_")}_patroni_members:sync_standby:count != 1
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "${title(replace(job.tag, "-", " "))} Patroni Sync Standby Count Unexpected"
          description: "Expected patroni cluster of job *{{ $labels.job }}* to have 1 sync standby. It had *{{ $value }}*"
%{ endif ~}
      - record: ${replace(job.tag, "-", "_")}_patroni_members:is_streaming:count
        expr: sum by (job) (patroni_postgres_streaming{job="${job.tag}-patroni-exporter"})
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}PatroniStreamingCountUnexpected
        expr: ${replace(job.tag, "-", "_")}_patroni_members:is_streaming:count != ${job.members_count - 1}
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "${title(replace(job.tag, "-", " "))} Patroni Streaming Count Unexpected"
          description: "Expected patroni cluster of job *{{ $labels.job }}* to have ${job.members_count - 1} members that are streaming. It had *{{ $value }}*"
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}PatroniVersionUnexpected
        expr: patroni_version{job="${job.tag}-patroni-exporter"} != ${job.patroni_version}
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "${title(replace(job.tag, "-", " "))} Patroni Version Unexpected"
          description: "Expected patroni version of instance *{{ $labels.instance }}* of job *{{ $labels.job }}* to have version *${job.patroni_version}*. It had version *{{ $value }}*"
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}PatroniPostgresVersionUnexpected
        expr: floor(patroni_postgres_server_version{job="${job.tag}-patroni-exporter"} / 10000) != ${job.postgres_major_version}
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "${title(replace(job.tag, "-", " "))} Patroni Postgres Major Version Unexpected"
          description: "Expected postgres version of instance *{{ $labels.instance }}* of job *{{ $labels.job }}* to have major version *${job.postgres_major_version}*. It had version *{{ $value }}*"
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}PatroniPostgresTimelineInconsistent
        expr: min by (job) (patroni_postgres_timeline{job="${job.tag}-patroni-exporter"}) != max by (job) (patroni_postgres_timeline{job="${job.tag}-patroni-exporter"}) 
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "${title(replace(job.tag, "-", " "))} Patroni Postgres Timeline Divergence Detected"
          description: "Members of the patroni cluster for job *{{ $labels.job }}* have diverging timelines"
      - record: ${replace(job.tag, "-", "_")}_patroni_members:replicas_wal_divergence:megabytes
        expr: (max by (job) (patroni_xlog_received_location{job="${job.tag}-patroni-exporter"} != 0) - min by (job) (patroni_xlog_received_location{job="${job.tag}-patroni-exporter"} != 0)) / (1024*1024)
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}PatroniReplicasWalDivergenceHigh
        expr: ${replace(job.tag, "-", "_")}_patroni_members:replicas_wal_divergence:megabytes > ${job.max_wal_divergence}
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "${title(replace(job.tag, "-", " "))} Patroni Cluster Has High WAL Difference between replicas"
          description: "The wal size difference between the most up to date and least up to date postgres replicas for job *{{ $labels.job }}* is *{{ $value }}* MBs. This is greater than the *${job.max_wal_divergence}* MBs threshold."