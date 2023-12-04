groups:
  - name: ${cluster.tag}-kubernetes-metrics
    rules:
      #${replace(cluster.tag, "-", " ")} kubernetes pods status metrics
      - record: ${replace(cluster.tag, "-", "_")}_kubernetes:pods_ready:percentage
        expr: 100 * sum by (namespace) (kube_pod_status_phase{phase=~"Running|Succeeded", cluster="${cluster.tag}"}) / sum by (namespace) (kube_pod_status_phase)
      #${replace(cluster.tag, "-", " ")} kubernetes containers CPU metrics
      - record: ${replace(cluster.tag, "-", "_")}_kubernetes:containers_cpu_requests:percentage
        expr: 100 * max by (namespace, pod, container) (rate(container_cpu_usage_seconds_total[5m]) / on (namespace, pod, container) group_left kube_pod_container_resource_requests{resource="cpu", cluster="${cluster.tag}"})
      - record: ${replace(cluster.tag, "-", "_")}_kubernetes:containers_cpu_limits:percentage
        expr: 100 * max by (namespace, pod, container) (rate(container_cpu_usage_seconds_total[5m]) / on (namespace, pod, container) group_left kube_pod_container_resource_limits{resource="cpu", cluster="${cluster.tag}"})
      - record: ${replace(cluster.tag, "-", "_")}_kubernetes:containers_cpu_requests:missing
        expr: sum by (namespace, pod, container)(kube_pod_container_info{container!="", cluster="${cluster.tag}"}) unless sum by (namespace, pod, container)(kube_pod_container_resource_requests{resource="cpu"})
      - record: ${replace(cluster.tag, "-", "_")}_kubernetes:containers_cpu_limits:missing
        expr: sum by (namespace, pod, container)(kube_pod_container_info{container!="", cluster="${cluster.tag}"}) unless sum by (namespace, pod, container)(kube_pod_container_resource_limits{resource="cpu"})
      #${replace(cluster.tag, "-", " ")} kubernetes containers memory metrics
      - record: ${replace(cluster.tag, "-", "_")}_kubernetes:containers_memory_requests:percentage
        expr: 100 * max by (namespace, pod, container) (container_memory_working_set_bytes / on (namespace, pod, container) group_left kube_pod_container_resource_requests{resource="memory", cluster="${cluster.tag}"})
      - record: ${replace(cluster.tag, "-", "_")}_kubernetes:containers_memory_limits:percentage
        expr: 100 * max by (namespace, pod, container) (container_memory_working_set_bytes / on (namespace, pod, container) group_left kube_pod_container_resource_limits{resource="memory", cluster="${cluster.tag}"})
      - record: ${replace(cluster.tag, "-", "_")}_kubernetes:containers_memory_requests:missing
        expr: sum by (namespace, pod, container)(kube_pod_container_info{container!="", cluster="${cluster.tag}"}) unless sum by (namespace, pod, container)(kube_pod_container_resource_requests{resource="memory"})
      - record: ${replace(cluster.tag, "-", "_")}_kubernetes:containers_memory_limits:missing
        expr: sum by (namespace, pod, container)(kube_pod_container_info{container!="", cluster="${cluster.tag}"}) unless sum by (namespace, pod, container)(kube_pod_container_resource_limits{resource="memory"})
