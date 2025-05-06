locals {
  parsed_config = yamldecode(var.config)
  rule_files = concat(
    contains(keys(local.parsed_config), "rule_files") ? local.parsed_config.rule_files : [],
    ["rules/prometheus-target.yml"],
    [for node_exporter_job in var.node_exporter_jobs: "rules/${node_exporter_job.tag}-node-exporter.yml"],
    [for blackbox_exporter_job in var.blackbox_exporter_jobs: "rules/${blackbox_exporter_job.tag}-blackbox-exporter.yml"],
    [for terracd_job in var.terracd_jobs: "rules/${terracd_job.tag}-terracd.yml"],
    [for kubernetes_cluster_job in var.kubernetes_cluster_jobs: "rules/${kubernetes_cluster_job.tag}-kubernetes.yml"],
    [for minio_cluster_job in var.minio_cluster_jobs: "rules/${minio_cluster_job.tag}-minio.yml"],
    [for etcd_exporter_job in var.etcd_exporter_jobs: "rules/${etcd_exporter_job.tag}-etcd-exporter.yml"],
    [for patroni_exporter_job in var.patroni_exporter_jobs: "rules/${patroni_exporter_job.tag}-patroni-exporter.yml"],
    [for vault_exporter_job in var.vault_exporter_jobs: "rules/${vault_exporter_job.tag}-vault-exporter.yml"]
  )
}

resource "etcd_key_prefix" "prometheus_confs" {
  prefix = var.etcd_key_prefix
  clear_on_deletion = true
  
  dynamic "keys" {
    for_each = var.node_exporter_jobs
    content {
      key = "rules/${keys.value.tag}-node-exporter.yml"
      value = templatefile(
        "${path.module}/templates/node-exporter.yml.tpl",
        {
          job = keys.value
        }
      )
    }
  }

  dynamic "keys" {
    for_each = var.terracd_jobs
    content {
      key = "rules/${keys.value.tag}-terracd.yml"
      value = templatefile(
        "${path.module}/templates/terracd.yml.tpl",
        {
          job = {
            tag                      = keys.value.tag
            run_interval_threshold   = keys.value.run_interval_threshold
            apply_interval_threshold = keys.value.apply_interval_threshold
            failure_time_frame       = keys.value.failure_time_frame
            provider_use_time_frame  = keys.value.provider_use_time_frame
            unit                     = keys.value.unit
            time_dividor             = keys.value.unit == "minute" ? 60 : 3600
            alert_labels             = keys.value.alert_labels
            command_timestamp_metric = keys.value.legacy_names ? "terracd_timestamp_seconds" : "terracd_command_timestamp_seconds"
          }
        }
      )
    }
  }

  dynamic "keys" {
    for_each = var.kubernetes_cluster_jobs
    content {
      key = "rules/${keys.value.tag}-kubernetes.yml"
      value = templatefile(
        "${path.module}/templates/kubernetes.yml.tpl",
        {
          cluster = keys.value
        }
      )
    }
  }

  dynamic "keys" {
    for_each = var.kubernetes_cluster_jobs
    content {
      key = "rules/${keys.value.tag}-kubernetes.yml"
      value = templatefile(
        "${path.module}/templates/kubernetes.yml.tpl",
        {
          cluster = keys.value
        }
      )
    }
  }

  dynamic "keys" {
    for_each = var.minio_cluster_jobs
    content {
      key = "rules/${keys.value.tag}-minio.yml"
      value = templatefile(
        "${path.module}/templates/minio.yml.tpl",
        {
          cluster = keys.value
        }
      )
    }
  }

  dynamic "keys" {
    for_each = var.blackbox_exporter_jobs
    content {
      key = "rules/${keys.value.tag}-blackbox-exporter.yml"
      value = templatefile(
        "${path.module}/templates/blackbox-exporter.yml.tpl",
        {
          job = keys.value
        }
      )
    }
  }

  dynamic "keys" {
    for_each = var.etcd_exporter_jobs
    content {
      key = "rules/${keys.value.tag}-etcd-exporter.yml"
      value = templatefile(
        "${path.module}/templates/etcd-exporter.yml.tpl",
        {
          job = keys.value
        }
      )
    }
  }

  dynamic "keys" {
    for_each = var.patroni_exporter_jobs
    content {
      key = "rules/${keys.value.tag}-patroni-exporter.yml"
      value = templatefile(
        "${path.module}/templates/patroni-exporter.yml.tpl",
        {
          job = {
            tag                     = keys.value.tag
            members_count           = keys.value.members_count
            synchronous_replication = keys.value.synchronous_replication
            max_wal_divergence      = keys.value.max_wal_divergence
            patroni_version         = length(split(".", keys.value.patroni_version)) > 1 ? join("", [for idx, val in split(".", keys.value.patroni_version): length(val) == 1 && idx != 0 ? "0${val}" : val]) : keys.value.patroni_version
            patroni_full_version    = length(split(".", keys.value.patroni_version)) > 1
            postgres_version        = length(split(".", keys.value.postgres_version)) > 1 ? join("", [for idx, val in split(".", keys.value.postgres_version): length(val) == 1 && idx != 0 ? "0${val}" : val]) : keys.value.postgres_version
            postgres_full_version   = length(split(".", keys.value.postgres_version)) > 1
            alert_labels            = keys.value.alert_labels
          }
        }
      )
    }
  }

  dynamic "keys" {
    for_each = var.vault_exporter_jobs
    content {
      key = "rules/${keys.value.tag}-vault-exporter.yml"
      value = templatefile(
        "${path.module}/templates/vault-exporter.yml.tpl",
        {
          job = keys.value
        }
      )
    }
  }

  keys {
    key = "rules/prometheus-target.yml"
    value = templatefile(
      "${path.module}/templates/prometheus-target.yml.tpl",
      {
        alert_labels = var.prometheus_target_alert_labels
      }
    )
  }

  keys {
    key = "prometheus.yml"
    value = yamlencode(merge(local.parsed_config, {rule_files=local.rule_files}))
  }
}