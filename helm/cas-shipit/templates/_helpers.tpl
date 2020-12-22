{{/*
Expand the name of the chart.
*/}}
{{- define "cas-shipit.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cas-shipit.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "cas-shipit.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cas-shipit.labels" -}}
helm.sh/chart: {{ include "cas-shipit.chart" . }}
{{ include "cas-shipit.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cas-shipit.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cas-shipit.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "cas-shipit.host" -}}
{{ include "cas-shipit.fullname" . }}.{{ .Values.route.clusterHost }}
{{- end }}

{{/*
Environment variables required by the shipit container
*/}}
{{- define "cas-shipit.envVariables" -}}
- name: SECRET_KEY_BASE
  valueFrom:
    secretKeyRef:
      name: {{ include "cas-shipit.fullname" . }}
      key: secret_key_base
- name: RAILS_LOG_TO_STDOUT
  value: "true"
- name: RAILS_SERVE_STATIC_FILES
  value: "true"
- name: SHIPIT_HOST
  value: {{ include "cas-shipit.host" . }}
- name: REDIS_HOST
  value: {{ include "cas-shipit.fullname" . }}-redis-master
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "cas-shipit.fullname" . }}-redis
      key: redis-password
- name: GITHUB_APP_ID
  valueFrom:
    secretKeyRef:
      name: {{ include "cas-shipit.fullname" . }}
      key: github_app_id
- name: GITHUB_INSTALLATION_ID
  valueFrom:
    secretKeyRef:
      name: {{ include "cas-shipit.fullname" . }}
      key: github_installation_id
- name: GITHUB_PRIVATE_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "cas-shipit.fullname" . }}
      key: github_private_key
- name: GITHUB_OAUTH_ID
  valueFrom:
    secretKeyRef:
      name: {{ include "cas-shipit.fullname" . }}
      key: github_oauth_id
- name: GITHUB_OAUTH_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ include "cas-shipit.fullname" . }}
      key: github_oauth_secret
- name: GITHUB_OAUTH_TEAM
  valueFrom:
    secretKeyRef:
      name: {{ include "cas-shipit.fullname" . }}
      key: github_oauth_team
- name: PGHOST
  value: {{ include "cas-shipit.fullname" . }}-patroni
- name: PGUSER
  value: postgres
- name: PGDATABASE
  value: postgres
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "cas-shipit.fullname" . }}-patroni
      key: password-superuser
- name: AIRFLOW_NAMESPACE
  valueFrom:
    secretKeyRef:
      name: cas-namespaces
      key: airflow-namespace
- name: GGIRCS_NAMESPACE
  valueFrom:
    secretKeyRef:
      name: cas-namespaces
      key: ggircs-namespace
- name: CIIP_NAMESPACE
  valueFrom:
    secretKeyRef:
      name: cas-namespaces
      key: ciip-namespace
{{- end }}