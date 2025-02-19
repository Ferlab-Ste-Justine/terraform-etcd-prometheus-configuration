variable "terracd_jobs" {
  description = "List of terracd jobs"
  type = list(object({
    tag                      = string
    plan_interval_threshold  = number
    apply_interval_threshold = number
    unit                     = string
    alert_labels             = map(string)
  }))
  default = []

  validation {
    condition     = alltrue([for job in var.terracd_jobs: contains(["minute", "hour"], job.unit)])
    error_message = "Units for terracd_jobs must be 'minute' or 'hour'"
  }
}

variable "node_exporter_jobs" {
  description = "List of node exporter jobs"
  type = list(object({
    tag                        = string
    expected_count             = number
    memory_usage_threshold     = number
    cpu_usage_threshold        = number
    expected_disks_count       = number
    disk_space_usage_threshold = number
    disk_io_usage_threshold    = number
    alert_labels               = map(string)
  }))
  default = []
}

variable "blackbox_exporter_jobs" {
  description = "List of blackbox exporter jobs"
  type = list(object({
    tag                      = string
    unavailability_tolerance = string
    max_acceptable_latency   = number
    cert_renewal_window      = number
    has_tls                  = bool
    expect_recent_tls        = bool
    alert_labels             = map(string)
  }))
  default = []
}

variable "kubernetes_cluster_jobs" {
  description = "List of kubernetes cluster jobs"
  type = list(object({
    tag               = string
    expected_services = list(object({
      namespace            = string
      name                 = string
      expected_min_count   = number
      expected_start_delay = number
      alert_labels         = map(string)
    }))
  }))
  default = []
}

variable "minio_cluster_jobs" {
  description = "List of minio cluster jobs"
  type = list(object({
    tag = string
  }))
  default = []
}

variable "etcd_exporter_jobs" {
  description = "List of etcd exporter jobs"
  type = list(object({
    tag            = string
    members_count  = number
    max_learn_time = string
    max_db_size    = number
    alert_labels   = map(string)
  }))
  default = []
}

variable "patroni_exporter_jobs" {
  description = "List of patroni exporter jobs"
  type = list(object({
    tag                        = string
    members_count              = number
    synchronous_replication    = bool
    patroni_version            = string
    postgres_major_version     = number
    max_wal_divergence         = number
    alert_labels               = map(string)
  }))
  default = []
}

variable "vault_exporter_jobs" {
  description = "List of Vault exporter jobs"
  type = list(object({
    tag                       = string
    expected_unsealed_count   = number
    alert_labels              = map(string)
  }))
  default = []
}


variable "config" {
  description = "Content of your prometheus main configuration file."
  type = string
}

variable "fs_path" {
  description = "Local filesystem path where config files should be synchronized from."
  type = string
}

variable "etcd_key_prefix" {
  description = "Etcd prefix to sync configuration files in."
  type = string
}