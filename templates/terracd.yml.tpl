groups:
  - name: ${job.tag}-terracd-metrics
    rules:
%{ if job.unit == "minute" ~}
      #${replace(job.tag, "-", " ")} elapsed time since last plan
      - record: ${replace(job.tag, "-", "_")}:successful_plan_interval:minutes
        expr: (time() - (max by(job ) (terracd_timestamp_seconds{job="${job.tag}", command=~"apply|plan", result="success"}) OR on() vector(0))) / 60 
      #${replace(job.tag, "-", " ")} elapsed time since apply
      - record: ${replace(job.tag, "-", "_")}:successful_apply_interval:minutes
        expr: (time() - (terracd_timestamp_seconds{job="${job.tag}", command="apply", result="success"} OR on() vector(0))) / 60 
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}LastPlanTooLongAgo
        expr: ${replace(job.tag, "-", "_")}:successful_plan_interval:minutes > ${job.plan_interval_threshold}
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "Too Long Since Last Successful Plan For Job ${title(replace(job.tag, "-", " "))}"
          description: "Last successful plan for job *${job.tag}* was *{{ $value }}* minutes ago"
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}LastApplyTooLongAgo
        expr: ${replace(job.tag, "-", "_")}:successful_apply_interval:minutes > ${job.apply_interval_threshold}
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "Too Long Since Last Successful Apply For Job ${title(replace(job.tag, "-", " "))}"
          description: "Last successful apply for job *${job.tag}* was *{{ $value }}* minutes ago"
%{ else ~}
      #${replace(job.tag, "-", " ")} elapsed time since last plan
      - record: ${replace(job.tag, "-", "_")}:successful_plan_interval:hours
        expr: (time() - (max by(job ) (terracd_timestamp_seconds{job="${job.tag}", command=~"apply|plan", result="success"}) OR on() vector(0))) / 3600 
      #${replace(job.tag, "-", " ")} elapsed time since apply
      - record: ${replace(job.tag, "-", "_")}:successful_apply_interval:hours
        expr: (time() - (terracd_timestamp_seconds{job="${job.tag}", command="apply", result="success"} OR on() vector(0))) / 3600
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}LastPlanTooLongAgo
        expr: ${replace(job.tag, "-", "_")}:successful_plan_interval:hours > ${job.plan_interval_threshold}
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "Too Long Since Last Successful Plan For Job ${title(replace(job.tag, "-", " "))}"
          description: "Last successful plan for job *${job.tag}* was *{{ $value }}* hours ago"
      - alert: ${replace(title(replace(job.tag, "-", " ")), " ", "")}LastApplyTooLongAgo
        expr: ${replace(job.tag, "-", "_")}:successful_apply_interval:hours > ${job.apply_interval_threshold}
        for: 15m
%{ if length(job.alert_labels) > 0 ~}
        labels:
%{ for key, val in job.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "Too Long Since Last Successful Apply For Job ${title(replace(job.tag, "-", " "))}"
          description: "Last successful apply for job *${job.tag}* was *{{ $value }}* hours ago"
%{ endif ~}