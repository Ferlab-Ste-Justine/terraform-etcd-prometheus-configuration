groups:
  - name: ${job.tag}-vault-exporter-metrics
    rules:
      # ${replace(job.tag, "-", " ")} Vault unsealed nodes count
      - record: ${replace(job.tag, "-", "_")}:vault_unsealed_nodes:count
        expr: sum(vault_core_unsealed{job="${job.tag}-vault-exporter"})

      # Alert if any Vault node is sealed
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}VaultNodeSealed
        expr: ${replace(job.tag, "-", "_")}:vault_unsealed_nodes:count < ${job.expected_unsealed_count}
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "${title(replace(job.tag, "-", " "))} Vault Node(s) Sealed"
          description: "Number of unsealed nodes in Vault cluster *{{ $labels.job }}* has dropped to *{{ $value }}*."

      # ${replace(job.tag, "-", " ")} Active requests
      - record: ${replace(job.tag, "-", "_")}:vault_active_requests:count
        expr: sum(vault_core_in_flight_requests{job="${job.tag}-vault-exporter"})

      # Alert if active requests exceed threshold
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}VaultHighActiveRequests
        expr: ${replace(job.tag, "-", "_")}:vault_active_requests:count > ${job.active_request_threshold}
        for: 10m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "${title(replace(job.tag, "-", " "))} Vault High Active Requests"
          description: "Vault cluster *{{ $labels.job }}* has too many active requests: *{{ $value }}*."

      # ${replace(job.tag, "-", " ")} Lease metrics
      - record: ${replace(job.tag, "-", "_")}:vault_lease_count:current
        expr: sum(vault_expire_num_leases{job="${job.tag}-vault-exporter"})

      # Alert if lease count is too low
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}VaultLowLeaseCount
        expr: ${replace(job.tag, "-", "_")}:vault_lease_count:current < ${job.lease_threshold}
        for: 10m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "${title(replace(job.tag, "-", " "))} Vault Lease Count Low"
          description: "Lease count in Vault cluster *{{ $labels.job }}* is too low: *{{ $value }}*."
