groups:
  - name: ${job.tag}-blackbox-metrics
    rules:
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}BlackboxExporterDown
        expr: up{job="${job.tag}-blackbox-exporter"} == 0
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "Blackbox Exporter Is Down For External Service Job ${title(replace(job.tag, "-", " "))}"
          description: "Blackbox exporter is down for job *${job.tag}*. Until it is restored, service outages will not cause alerts."
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}ExternalServiceUnavailable
        expr: probe_success{job="${job.tag}-blackbox-exporter"} == 0
        for: ${job.unavailability_tolerance}
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "External Service Unavailable For Job ${title(replace(job.tag, "-", " "))}"
          description: "External Service for job *${job.tag}* have been unavailable for at least ${job.unavailability_tolerance}."
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}ExternalServiceSlow
        expr: probe_duration_seconds{job="${job.tag}-blackbox-exporter"} > ${job.max_acceptable_latency}
        for: ${job.unavailability_tolerance}
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "External Service Slow For Blackbox Job ${title(replace(job.tag, "-", " "))}"
          description: "External Service for job *${job.tag}* have been slow for at least ${job.unavailability_tolerance}. Latency of last probe was *{{ $value }}* seconds."
%{ if job.has_tls ~}
      - record: ${replace(job.tag, "-", "_")}:cert_expiry:days
        expr: (probe_ssl_earliest_cert_expiry{job="${job.tag}-blackbox-exporter"} - time()) / (3600*24)
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}ExternalCertNotRenewed
        expr: ${replace(job.tag, "-", "_")}:cert_expiry:days < ${job.cert_renewal_window} 
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "External Service Certificate Not Renewed For Job ${title(replace(job.tag, "-", " "))}"
          description: "External service's certificate for job *${job.tag}* has not been renewed within the expected delay of *${job.cert_renewal_window}* days before expiration. It will expire in *{{ $value }}* days."
%{ if job.expect_recent_tls ~}
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}ExternalTlsVersionDated
        expr: |
          (
            1 
            - (probe_tls_version_info{job="${job.tag}-blackbox-exporter", version="TLS 1.3"} OR on() vector(0)) 
            - on() (1 - (probe_success{job="${job.tag}-blackbox-exporter"} OR on() vector(0)))
          ) == 1
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "External Service TLS Version Dated For Job ${title(replace(job.tag, "-", " "))}"
          description: "External service tls version for job *${job.tag}* is dated. Tls version 1.3 is expected."
%{ endif ~}
%{ endif ~}