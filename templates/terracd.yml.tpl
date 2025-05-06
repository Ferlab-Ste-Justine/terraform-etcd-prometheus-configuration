groups:
  - name: ${job.tag}-terracd-metrics
    rules:
      #${replace(job.tag, "-", " ")} elapsed time since last command
      - record: ${replace(job.tag, "-", "_")}:run_interval:${job.unit}s
        expr: (time() - (${job.command_timestamp_metric}{job="${job.tag}"} OR on() vector(0))) / ${job.time_dividor}  
      #${replace(job.tag, "-", " ")} elapsed time since last apply
      - record: ${replace(job.tag, "-", "_")}:apply_interval:${job.unit}s
        expr: (time() - (${job.command_timestamp_metric}{job="${job.tag}", command="apply"} OR on() vector(0))) / ${job.time_dividor}
      #${replace(job.tag, "-", " ")} elapsed time since last failed plan
      - record: ${replace(job.tag, "-", "_")}:failed_plan_interval:${job.unit}s
        expr: (time() - ${job.command_timestamp_metric}{job="${job.tag}", command="plan", result="failure"}) / ${job.time_dividor}
      #${replace(job.tag, "-", " ")} elapsed time since last failed apply
      - record: ${replace(job.tag, "-", "_")}:failed_apply_interval:${job.unit}s
        expr: (time() - ${job.command_timestamp_metric}{job="${job.tag}", command="apply", result="failure"}) / ${job.time_dividor}
      #${replace(job.tag, "-", " ")} elapsed time since last failed destroy
      - record: ${replace(job.tag, "-", "_")}:failed_destroy_interval:${job.unit}s
        expr: (time() - ${job.command_timestamp_metric}{job="${job.tag}", command="destroy", result="failure"}) / ${job.time_dividor}
      #${replace(job.tag, "-", " ")} elapsed time since last use of provider
      - record: ${replace(job.tag, "-", "_")}:provider_use_interval:${job.unit}s
        expr: (time() - terracd_provider_use_timestamp_seconds{job="${job.tag}"}) / ${job.time_dividor}
      #${replace(job.tag, "-", " ")} elapsed time since last use of recently used provider
      - record: ${replace(job.tag, "-", "_")}:recent_provider_use_interval:${job.unit}s
        expr: ${replace(job.tag, "-", "_")}:provider_use_interval:${job.unit}s <= ${job.provider_use_time_frame}
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}LastCommandTooLongAgo
        expr: ${replace(job.tag, "-", "_")}:run_interval:${job.unit}s > ${job.run_interval_threshold}
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "Too Long Since Last Command For Job ${title(replace(job.tag, "-", " "))}"
          description: "Last command for job *${job.tag}* was *{{ $value }}* ${job.unit}s ago"
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}LastApplyTooLongAgo
        expr: ${replace(job.tag, "-", "_")}:apply_interval:${job.unit}s > ${job.apply_interval_threshold}
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "Too Long Since Last Apply For Job ${title(replace(job.tag, "-", " "))}"
          description: "Last apply for job *${job.tag}* was *{{ $value }}* ${job.unit}s ago"
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}PlanCommandFailedForTooLong
        expr: ${replace(job.tag, "-", "_")}:failed_plan_interval:${job.unit}s < ${job.failure_time_frame}
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "Plan Command For Job ${title(replace(job.tag, "-", " "))} Has Been Failing For Too Long"
          description: "Plan command for job *${job.tag}* has been failing for a while. Last plan failed *{{ $value }}* ${job.unit}s ago."
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}ApplyCommandFailedForTooLong
        expr: ${replace(job.tag, "-", "_")}:failed_apply_interval:${job.unit}s < ${job.failure_time_frame}
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "Apply Command For Job ${title(replace(job.tag, "-", " "))} Has Been Failing For Too Long"
          description: "Apply command for job *${job.tag}* has been failing for a while. Last apply failed *{{ $value }}* ${job.unit}s ago."
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}DestroyCommandFailedForTooLong
        expr: ${replace(job.tag, "-", "_")}:failed_destroy_interval:${job.unit}s < ${job.failure_time_frame}
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "Destroy Command For Job ${title(replace(job.tag, "-", " "))} Has Been Failing For Too Long"
          description: "Destroy command for job *${job.tag}* has been failing for a while. Last destroy failed *{{ $value }}* ${job.unit}s ago."