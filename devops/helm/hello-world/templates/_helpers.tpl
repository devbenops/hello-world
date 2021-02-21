
{{/*
Expand the name of the chart.
*/}}
{{- define "appName" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Common labels
*/}}
{{- define "app.labels" -}}
{{- if .Values.deployment -}}
component: {{ .Values.deployment.labels.component }}
environment: {{ .Values.deployment.labels.environment }}
release: {{ .Release.Name }}
{{- else -}}
component: {{ .Values.cronjob.labels.component }}
environment: {{ .Values.cronjob.labels.environment }}
release: {{ .Release.Name }}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for deployment/cronjob
*/}}
{{- define "app.apiVersion" -}}
{{- if .Values.deployment -}}
{{- print "apps/v1" -}}
{{- else -}}
{{- print "batch/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate kind for deployment/cronjob
*/}}
{{- define "app.kind" -}}
{{- if .Values.deployment -}}
{{- print "Deployment" -}}
{{- else -}}
{{- print "CronJob" -}}
{{- end -}}
{{- end -}}
