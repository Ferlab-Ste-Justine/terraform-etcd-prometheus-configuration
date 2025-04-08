# About

This terraform module performs some adjustments on a prometheus configuration and syncs it with an etcd key prefix.

It is meant to:
  - Be compatible with the way we operate prometheus, by continuously updating its configuration at runtime against the content of an etcd key prefix:
    - https://github.com/Ferlab-Ste-Justine/terraform-openstack-prometheus-server
    - https://github.com/Ferlab-Ste-Justine/terraform-libvirt-prometheus-server
  - Make some repetitive boilerplate prometheus rules/alerts configurations more dry
  - Be flexible enough to support unmanaged configuration outside the boilerplate that it manages

# Inputs

- **config**: This should be the value of the entrypoint **prometheus.yml** configuration file which will be generated from this value. The module will add some **rule_files** entries for the rule files it generates and otherwise will leave the content as is.
- **etcd_key_prefix**: Etcd prefix where the processed prometheus configuration will be synchronized.
- **prometheus_target_alert_labels**: Alert labels to set for prometheus target rules. Defaults to none.
- **node_exporter_jobs**: List of node exporter jobs to generate boilerplate for. Each entry should take the following keys:
  - **tag**: Tag for the node exporter job. Is should consist of words separated by dashes. The job is expected to be called `<tag>-node-exporter`
  - **expected_count**: Expected number of instances associated with the job
  - **memory_usage_threshold**: Maximum memory usage as a percentage (ex: 90). An alert will be triggered if this threshold is crossed for 15 minutes of more.
  - **cpu_usage_threshold**: Maximum cpu usage as a percentage (ex: 90). An alert will be triggered if this threshold is crossed for 15 minutes of more.
  - **expected_disks_count**: Expected number of disks (ex: 2). An alert will be triggered if the number of disks doesn't match. Can be set to -1 to disable the alert.
  - **disk_space_usage_threshold**: Maximum disk space usage as a percentage (ex: 90). An alert will be triggered if this threshold is crossed for 15 minutes of more.
  - **disk_io_usage_threshold**: Maximum disk io usage as a percentage (ex: 90). An alert will be triggered if this threshold is crossed for 15 minutes of more.
  - **alert_labels**: Map of string keys and values corresponding to labels to add to all the jobs' alerts.
- **blackbox_exporter_jobs**: List of blackbox tcp/http exporter jobs to generate boilerplate for. Each entry should take the following keys:
  - **tag**: Tag for the blackbox exporter job. Is should consist of words separated by dashes. The job is expected to be called `<tag>-blackbox-exporter`
  - **unavailability_tolerance**: Duration the service can be unavailable before an alert triggers. The format of the duration is a string formated as prometheus expects in the **for** field of alert rules.
  - **max_acceptable_latency**: Duration in seconds indicating the maximum acceptable response time for the service. If the service continuously takes longer than this to respond for an interval of time longer than **unavailability_tolerance**, a slow service alert will be triggered.
  - **cert_renewal_window**: Delay in days indicating the expected renewal window for the tls certificate provided by the service. If the certificate the service provides expires within a delay shorter than this window, an alert will be triggered to indicate the certificate wasn't renewed properly.
  - **has_tls**: Boolean indicating whether the service expects a tls connection. If false, alerts for the cert renewal window and tls version will not be set.
  - **expect_recent_tls**: Boolean indicating whether the service is expected to use tls version 1.3. If set to true and the service uses a version of tls older than 1.3, an alert will be triggered.
  - **alert_labels**: Map of string keys and values corresponding to labels to add to all the jobs' alerts.
- **terracd_jobs**: List of terracd jobs to generate boilerplate for. Each entry should take the following keys:
  - **tag**: Tag for the terracd job. It should correspond to the job name.
  - **plan_interval_threshold**: Interval threshold after which an alert will be triggered if a **plan** or **apply** command did not run successfully. Used to diagnose a broken or non-running pipeline.
  - **apply_interval_threshold**: Interval threshold after which an alert will be triggered if an **apply** command did not run successfully. Used to detect a pipeline that was left in **plan** and never put back on **apply**.
  - **unit**: Base time unit to use (**minute** or **hour**) that will affect how the thresholds are interepreted and how the rules are processed (to be either in minutes or hours)
  - **alert_labels**: Map of string keys and values corresponding to labels to add to all the jobs' alerts.
- **kubernetes_cluster_jobs**: List of kubernetes cluster jobs to generate boilerplate for. Each entry should take the following key:
  - **tag**: Tag for the kubernetes cluster job. It should correspond to the cluster name.
  - **expected_services**: List of expected deployments that should have a certain number of long running instances. Each entry should have the following keys:
    - **namespace**: Namespace where the service is expected to run
    - **name**: Name of the service. It should match the k8 deployment name.
    - **expected_min_count**: Minimum expected number of instances that should be running.
    - **expected_start_delay**: Expected delay before an instance is started. Running instances that have been around for less than that delay won't be considered running.
    - **alert_labels**: Extra labels to add to alerts triggered for the service.
- **minio_cluster_jobs**: List of minio cluster jobs to generate boilerplate for. Each entry should take the following key:
  - **tag**: Tag for the minio cluster job. It should correspond to the cluster name.
- **etcd_exporter_jobs**: List of etcd exporter jobs to generate boilerplate for. Each entry should take the following keys:
  - **tag**: Tag for the etcd exporter job. Is should consist of words separated by dashes. The job is expected to be called `<tag>-etcd-exporter`
  - **members_count**: Expected number of etcd members associated with the job
  - **max_learn_time**: Max expected time for an etcd learner to catchup. 
  - **max_db_size**: Maximum expected data size (note that etcd has its own limit if 8GiB)
  - **alert_labels**: Map of string keys and values corresponding to labels to add to all the jobs' alerts.
- **patroni_exporter_jobs**: List of patroni exporter jobs to generate boilerplate for. Each entry should take the following keys:
  - **tag**: Tag for the patroni exporter job. Is should consist of words separated by dashes. The job is expected to be called `<tag>-patroni-exporter`
  - **members_count**: Expected number of patroni members associated with the job
  - **synchronous_replication**: Whether the patroni cluster is set with synchronous replication or not. If true, an alert will be triggered if a sync standby node is not detected.
  - **patroni_version**: Expected patroni version in semver notation (ex: `4.0.4`). Alternatively, a single major version number can be passed (ex: `4`) if you don't care about fine version granularity.
  - **postgres_version**: Expected postgres version in semver notation (ex: `14.0.15`). Alternatively, a single major version number can be passed (ex: `14`) if you don't care about fine version granularity.
  - **max_wal_divergence**: Max expected WAL divergence between the most up to date and least up to date replica in megabytes. An alert will be triggered if the WAL difference between replicas is greater than this threshold.
  - **alert_labels**: Map of string keys and values corresponding to labels to add to all the jobs' alerts.
- **vault_exporter_jobs**: List of Vault telemetry jobs to generate boilerplate for. Each entry should take the following keys:
  - **tag**: Tag for the Vault telemetry job. It should correspond to the job name.
  - **expected_unsealed_count**: Expected number of unsealed Vault nodes in the cluster. An alert will be triggered if the number of unsealed nodes drops below this value.
  - **alert_labels**: Map of string keys and values corresponding to labels to add to all the jobs' alerts.
  
# Example

For a usage example, see: https://github.com/Ferlab-Ste-Justine/kvm-dev-orchestrations/blob/main/prometheus/prometheus-configs.tf