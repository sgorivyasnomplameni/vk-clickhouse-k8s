{{/* Базовое имя приложения */}}
{{- define "clickhouse.name" -}}
clickhouse
{{- end }}

{{/* Полное имя для ресурсов */}}
{{- define "clickhouse.fullname" -}}
{{ include "clickhouse.name" . }}
{{- end }}