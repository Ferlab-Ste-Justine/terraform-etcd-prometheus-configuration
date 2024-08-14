resource "local_file" "node_exporter_confs" {
  for_each        = { for node_exporter_job in var.node_exporter_jobs : node_exporter_job.tag => node_exporter_job }
  content         = templatefile(
    "${path.module}/templates/node-exporter.yml.tpl",
    {
      job = each.value
    }
  )
  file_permission = "0600"
  filename        = "${var.fs_path}/rules/${each.value.tag}-node-exporter.yml"
}

resource "local_file" "terracd_confs" {
  for_each        = { for terracd_job in var.terracd_jobs : terracd_job.tag => terracd_job }
  content         = templatefile(
    "${path.module}/templates/terracd.yml.tpl",
    {
      job = each.value
    }
  )
  file_permission = "0600"
  filename        = "${var.fs_path}/rules/${each.value.tag}-terracd.yml"
}

resource "local_file" "kubernetes_confs" {
  for_each        = { for kubernetes_cluster_job in var.kubernetes_cluster_jobs : kubernetes_cluster_job.tag => kubernetes_cluster_job }
  content         = templatefile(
    "${path.module}/templates/kubernetes.yml.tpl",
    {
      cluster = each.value
    }
  )
  file_permission = "0600"
  filename        = "${var.fs_path}/rules/${each.value.tag}-kubernetes.yml"
}

resource "local_file" "minio_confs" {
  for_each        = { for minio_cluster_job in var.minio_cluster_jobs : minio_cluster_job.tag => minio_cluster_job }
  content         = templatefile(
    "${path.module}/templates/minio.yml.tpl",
    {
      cluster = each.value
    }
  )
  file_permission = "0600"
  filename        = "${var.fs_path}/rules/${each.value.tag}-minio.yml"
}

resource "local_file" "blackbox_exporter_confs" {
  for_each        = { for blackbox_exporter_job in var.blackbox_exporter_jobs : blackbox_exporter_job.tag => blackbox_exporter_job }
  content         = templatefile(
    "${path.module}/templates/blackbox-exporter.yml.tpl",
    {
      job = each.value
    }
  )
  file_permission = "0600"
  filename        = "${var.fs_path}/rules/${each.value.tag}-blackbox-exporter.yml"
}

resource "local_file" "etcd_exporter_confs" {
  for_each        = { for etcd_exporter_job in var.etcd_exporter_jobs : etcd_exporter_job.tag => etcd_exporter_job }
  content         = templatefile(
    "${path.module}/templates/etcd-exporter.yml.tpl",
    {
      job = each.value
    }
  )
  file_permission = "0600"
  filename        = "${var.fs_path}/rules/${each.value.tag}-etcd-exporter.yml"
}

locals {
  parsed_config = yamldecode(var.config)
  rule_files = concat(
    contains(keys(local.parsed_config), "rule_files") ? local.parsed_config.rule_files : [],
    [for node_exporter_job in var.node_exporter_jobs: "rules/${node_exporter_job.tag}-node-exporter.yml"],
    [for blackbox_exporter_job in var.blackbox_exporter_jobs: "rules/${blackbox_exporter_job.tag}-blackbox-exporter.yml"],
    [for terracd_job in var.terracd_jobs: "rules/${terracd_job.tag}-terracd.yml"],
    [for kubernetes_cluster_job in var.kubernetes_cluster_jobs: "rules/${kubernetes_cluster_job.tag}-kubernetes.yml"],
    [for minio_cluster_job in var.minio_cluster_jobs: "rules/${minio_cluster_job.tag}-minio.yml"],
    [for etcd_exporter_job in var.etcd_exporter_jobs: "rules/${etcd_exporter_job.tag}-etcd-exporter.yml"]
  )
}

resource "local_file" "prometheus_conf" {
  content         = yamlencode(merge(local.parsed_config, {rule_files=local.rule_files}))
  file_permission = "0600"
  filename        = "${var.fs_path}/prometheus.yml"
}

resource "etcd_synchronized_directory" "prometheus_confs" {
    directory = var.fs_path
    key_prefix = var.etcd_key_prefix
    source = "directory"
    recurrence = "onchange"

    depends_on = [
      local_file.prometheus_conf,
      local_file.node_exporter_confs,
      local_file.terracd_confs
    ]
}