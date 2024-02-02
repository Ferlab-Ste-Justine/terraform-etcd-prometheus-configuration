groups:
  - name: ${job.tag}-node-exporter-metrics
    rules:
      #${replace(job.tag, "-", " ")} hosts count
      - record: ${replace(job.tag, "-", "_")}:up:count
        expr: sum by (job) (up{job="${job.tag}-node-exporter"})
      - alert: Some${replace(title(replace(job.tag, "-", " ")), " ", "")}Down
        expr: ${replace(job.tag, "-", "_")}:up:count < ${job.expected_count}
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "${title(replace(job.tag, "-", " "))} Machine(s) Down"
          description: "Number of machine instances detected by job *{{ $labels.job }}* has dropped to *{{ $value }}*"
      #${replace(job.tag, "-", " ")} hosts memory metrics
      - record: ${replace(job.tag, "-", "_")}:total_memory:gigabytes
        expr: node_memory_MemTotal_bytes{job="${job.tag}-node-exporter"} / 1024 / 1024 / 1024     
      - record: ${replace(job.tag, "-", "_")}:memory_usage:percentage
        expr: (1 - (node_memory_MemFree_bytes{job="${job.tag}-node-exporter"} / node_memory_MemTotal_bytes{job="${job.tag}-node-exporter"}))*100
      - record: ${replace(job.tag, "-", "_")}:reserved_memory_ratio:percentage
        expr: (1 - (node_memory_MemAvailable_bytes{job="${job.tag}-node-exporter"} / node_memory_MemTotal_bytes{job="${job.tag}-node-exporter"}))*100
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}MemoryUsageHigh
        expr: ${replace(job.tag, "-", "_")}:reserved_memory_ratio:percentage > ${job.memory_usage_threshold}
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "${title(replace(job.tag, "-", " "))} Machine(s) High Memory Usage"
          description: "Instance *{{ $labels.instance }}* of job *{{ $labels.job }}* has reserved *{{ $value }}*% of available memory"
      #${replace(job.tag, "-", " ")} hosts CPU metrics
      - record: ${replace(job.tag, "-", "_")}:cpu_cores:count
        expr: count without(mode, cpu) (node_cpu_seconds_total{job="${job.tag}-node-exporter", mode="idle"})
      - record: ${replace(job.tag, "-", "_")}:cpu_usage:percentage
        expr: (sum without(cpu, mode) (rate(node_cpu_seconds_total{job="${job.tag}-node-exporter", mode!="idle"}[5m]))) / (sum without(cpu, mode) (rate(node_cpu_seconds_total{job="${job.tag}-node-exporter"}[5m]))) * 100
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}CPUUsageHigh
        expr: ${replace(job.tag, "-", "_")}:cpu_usage:percentage > ${job.cpu_usage_threshold}
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "${title(replace(job.tag, "-", " "))} Machine(s) High CPU Usage"
          description: "Instance *{{ $labels.instance }}* of job *{{ $labels.job }}* has been running on high CPU for a while. Currently at *{{ $value }}*% usage"
      #${replace(job.tag, "-", " ")} hosts filesystem metrics
      - record: ${replace(job.tag, "-", "_")}:disks:count
        expr: count without (device, major, minor, serial, path, model, revision) (node_disk_info{device=~"sd.|vd.",job="${job.tag}-node-exporter"})
%{ if job.expected_disks_count >= 0 ~}
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}DiskCountMismatch
        expr: ${replace(job.tag, "-", "_")}:disks:count != ${job.expected_disks_count}
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "${title(replace(job.tag, "-", " "))} Number of Disks Unexpected"
          description: "Instance *{{ $labels.instance }}* of job *{{ $labels.job }}* has *{{ $value }}* disks. Expected *${job.expected_disks_count}*."
%{ endif ~}
      - record: ${replace(job.tag, "-", "_")}:filesystem_size:gigabytes
        expr: node_filesystem_size_bytes{job="${job.tag}-node-exporter", fstype="ext4"} / 1024 / 1024 / 1024
      - record: ${replace(job.tag, "-", "_")}:filesystem_space_usage_ratio:percentage
        expr: (1 - node_filesystem_avail_bytes{job="${job.tag}-node-exporter", fstype="ext4"} / node_filesystem_size_bytes{job="${job.tag}-node-exporter", fstype="ext4"}) * 100
      - record: ${replace(job.tag, "-", "_")}:disks_io_usage:percentage
        expr: rate(node_disk_io_time_seconds_total{job="${job.tag}-node-exporter", device=~"vd.|sd."}[5m]) * 100
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}DiskSpaceUsageHigh
        expr: ${replace(job.tag, "-", "_")}:filesystem_space_usage_ratio:percentage > ${job.disk_space_usage_threshold}
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "${title(replace(job.tag, "-", " "))} Machine(s) High Disk Space Usage"
          description: "Instance *{{ $labels.instance }}* of job *{{ $labels.job }}* has disk space usage *{{ $value }}*% for device *{{ $labels.device }}*"
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}DiskIoUsageHigh
        expr: ${replace(job.tag, "-", "_")}:disks_io_usage:percentage > ${job.disk_io_usage_threshold}
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "${title(replace(job.tag, "-", " "))} Machine(s) High Disk Io Usage"
          description: "Instance *{{ $labels.instance }}* of job *{{ $labels.job }}* has been running high io on device *{{ $labels.device }}* for a while. Current io at *{{ $value }}*%"