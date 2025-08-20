groups:
  - name: heartbeat
    rules:
      - alert: Heartbeat
        expr: hour() == ${heartbeat.hour} and minute() == ${heartbeat.minute}
        for: 0m
%{ if length(heartbeat.alert_labels) > 0 ~}
        labels:
%{ for key, val in heartbeat.alert_labels ~}
          ${key}: "${val}"
%{ endfor ~}
%{ endif ~}
        annotations:
          summary: "Heartbeat"
          description: "Daily heartbeat to assure alerts are working properly end-to-end scheduled around ${heartbeat.hour}:${heartbeat.minute} UTC time"