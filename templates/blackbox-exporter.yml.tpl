groups:
  - name: ${job.tag}-blackbox-metrics
    rules:
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}ServiceUnavailable
        expr: probe_success{job="${job.tag}-blackbox-exporter"} == 0
        for: ${job.unavailability_tolerance}
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "Service unavailable For Job ${title(replace(job.tag, "-", " "))}"
          description: "Service for job *${job.tag}* have been unavailable for at least ${job.unavailability_tolerance}."
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}ServiceSlow
        expr: probe_duration_seconds{job="${job.tag}-blackbox-exporter"} > ${job.max_acceptable_latency}
        for: ${job.unavailability_tolerance}
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "Service Slow For Job ${title(replace(job.tag, "-", " "))}"
          description: "Service for job *${job.tag}* have been slow for at least ${job.unavailability_tolerance}. Latency of last probe was *{{ $value }}* seconds."
%{ if job.has_tls ~}
      - record: ${replace(job.tag, "-", "_")}:cert_expiry:days
        expr: (probe_ssl_earliest_cert_expiry{job="${job.tag}-blackbox-exporter"} - time()) / (3600*24)
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}CertNotRenewed
        expr: ${replace(job.tag, "-", "_")}:cert_expiry:days < ${job.cert_renewal_window} 
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "Certificate Not Renewed For Job ${title(replace(job.tag, "-", " "))}"
          description: "Certificate job *${job.tag}* service has not been renewed within the expected delay of *${job.cert_renewal_window}* days before expiration. It will expire in *{{ $value }}* days."
%{ if job.expect_recent_tls ~}
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}TlsVersionDated
        expr: probe_tls_version_info{job="${job.tag}-blackbox-exporter", version="TLS 1.3"} OR on() vector(0) == 0
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "TLS Version Dated For Job ${title(replace(job.tag, "-", " "))}"
          description: "Tls version for job *${job.tag}* service is dated. Tls version 1.3 is expected."
%{ endif ~}
%{ endif ~}