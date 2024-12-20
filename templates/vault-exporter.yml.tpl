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