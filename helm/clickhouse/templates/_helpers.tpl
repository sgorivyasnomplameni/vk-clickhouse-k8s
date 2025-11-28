{{/* Базовое имя приложения */}}
{{- define "clickhouse.name" -}}
clickhouse
{{- end }}

{{/* Полное имя для ресурсов Helm */}}
{{- define "clickhouse.fullname" -}}
{{ printf "%s" (include "clickhouse.name" .) }}
{{- end }}