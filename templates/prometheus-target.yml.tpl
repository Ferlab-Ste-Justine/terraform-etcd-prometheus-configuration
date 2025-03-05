groups:
  - name: prometheus-target-metrics
    rules:
      - alert: PrometheusTargetDown
        expr: up == 0
        for: 15m
%{ if length(alert_labels) > 0 ~}
        labels:
%{ for key, val in alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: Prometheus Target(s) Down
          description: "Target is down for instance *{{ $labels.instance }}* of job *{{ $labels.job }}*"
      - alert: PrometheusTargetEmpty
        expr: prometheus_sd_discovered_targets == 0
        for: 15m
%{ if length(alert_labels) > 0 ~}
        labels:
%{ for key, val in alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: Prometheus Target(s) Empty
          description: "No target exists for config *{{ $labels.config }}*"
      - alert: PrometheusTargetScrapingSlow
        expr: prometheus_target_interval_length_seconds{quantile="0.9"} / on (interval, instance, job) prometheus_target_interval_length_seconds{quantile="0.5"} > 1.05
        for: 15m
%{ if length(alert_labels) > 0 ~}
        labels:
%{ for key, val in alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: Prometheus Target(s) Scraping Slow
          description: "Instance *{{ $labels.instance }}* is scraping target(s) slower than requested interval of *{{ $labels.interval }}*"
