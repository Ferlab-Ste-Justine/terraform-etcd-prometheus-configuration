# About

This terraform module performs some adjustments on a prometheus configuration and syncs it with an etcd key prefix.

It is meant to:
  - Be compatible with the way we operate prometheus, by continuously updating its configuration at runtime against the content of an etcd key prefix:
    - https://github.com/Ferlab-Ste-Justine/terraform-openstack-prometheus-server
    - https://github.com/Ferlab-Ste-Justine/terraform-libvirt-prometheus-server
  - Make some repetitive boilerplate prometheus rules/alerts configurations more dry
  - Be flexible enough to support unmanaged configuration outside the boilerplate that it manages

Currently, the two kinds of boilerplate that are supported:
- Node exporter rules and alerts for vms (number of hosts detected, cpu, ram, disks)
- Terracd jobs metrics and alerts (to get the interval since the last plan/apply and a threshold value that will trigger an alert)

# Inputs

- **config**: This should be the value of the entrypoint **prometheus.yml** configuration file which will be generated from this value. The module will add some **rule_files** entries for the rule files it generates and otherwise will leave the content as is.
- **fs_path**: Path where the prometheus configuration will be generated prior to synchronizting it with etcd. Beyond generating the **prometheus.yml** file there, boilerplate rule files will be generated in the **rules** subdirectory.
- **etcd_key_prefix**: Etcd prefix where the processed prometheus configuration will be synchronized.
- **node_exporter_jobs**: List of node exporter jobs to generate boilerplate for. Each entry should take the following keys:
  - **tag**: Tag for the node exporte job. Is should consist of words separated by dashes. The job is expected to be called `<tag>-node-exporter`
  - **expected_count**: Expected number of instances associated with the job
  - **memory_usage_threshold**: Maximum memory usage as a percentage (ex: 90). An alert will be triggered if this threshold is crossed for 15 minutes of more.
  - **cpu_usage_threshold**: Maximum cpu usage as a percentage (ex: 90). An alert will be triggered if this threshold is crossed for 15 minutes of more.
  - **disk_space_usage_threshold**: Maximum disk space usage as a percentage (ex: 90). An alert will be triggered if this threshold is crossed for 15 minutes of more.
  - **disk_io_usage_threshold**: Maximum disk io usage as a percentage (ex: 90). An alert will be triggered if this threshold is crossed for 15 minutes of more.
  - **alert_labels**: Map of string keys and values corresponding to labels to add to all the jobs' alerts.
- **terracd_jobs**: List of terracd jobs to generate boilerplate for. Each entry should take the following keys:
  - **tag**: Tag for the terracd job. It should correspond to the job name.
  - **plan_interval_threshold**: Interval threshold after which an alert will be triggered if a **plan** or **apply** command did not run successfully. Used to diagnose a broken or non-running pipeline.
  - **apply_interval_threshold**: Interval threshold after which an alert will be triggered if an **apply** command did not run successfully. Used to detect a pipeline that was left in **plan** and never put back on **apply**.
  - **unit**: Base time unit to use (**minute** or **hour**) that will affect how the thresholds are interepreted and how the rules are processed (to be either in minutes or hours)
  - **alert_labels**: Map of string keys and values corresponding to labels to add to all the jobs' alerts.

# Example

For a usage example, see: https://github.com/Ferlab-Ste-Justine/kvm-dev-orchestrations/blob/main/prometheus/prometheus-configs.tf