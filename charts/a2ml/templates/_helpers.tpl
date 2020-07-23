{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "a2ml.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "a2ml.fullname" -}}
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
{{- define "a2ml.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "a2ml.labels" -}}
helm.sh/chart: {{ include "a2ml.chart" . }}
{{ include "a2ml.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Set default pod annotations if vault is enabled
*/}}
{{- define "a2ml.podAnnotations" -}}
{{- if .Values.podAnnotations }}
{{ .Values.podAnnotations }}
{{- end }}
{{- if .Values.vault.enabled }}
vault.hashicorp.com/agent-inject: "true"
vault.hashicorp.com/agent-inject-secret-azure-creds: "azure/creds/a2ml"
vault.hashicorp.com/agent-inject-template-azure-creds: |
  export AZURE_CREDENTIALS='{
    "subscription_id": "{{ .Values.vaultSubscriptionId }}",
    "directory_tenant_id": "{{ .Values.vaultTenantId }}",
  {{`{{- with secret "azure/creds/a2ml" -}}
    "application_client_id": "{{ .Data.client_id }}",
    "client_secret": "{{ .Data.client_secret}}"
  {{- end }}`}}
  }'
vault.hashicorp.com/role: "app"
{{- end }}
{{- end }}


{{/*
Selector labels
*/}}
{{- define "a2ml.selectorLabels" -}}
app.kubernetes.io/name: {{ include "a2ml.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "a2ml.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "a2ml.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Construct the `minio.fullname` of the minio sub-chart.
Used to discover the Service and Secret name created by the sub-chart.
*/}}
{{- define "a2ml.minio.fullname" -}}
{{- if .Values.minio.fullnameOverride -}}
{{- .Values.minio.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "minio" .Values.minio.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Construct the `a2ml.s3EndpointUrl` for a2ml workers.
*/}}
{{- define "a2ml.s3EndpointUrl" -}}
{{- printf "http://%s.%s.svc.%s:9000" (include "a2ml.minio.fullname" .) .Release.Namespace .Values.clusterDomain }}
{{- end -}}

{{/*
Construct the `etcd.fullname` of the etcd sub-chart.
Used to discover the Service and Secret name created by the sub-chart.
*/}}
{{- define "a2ml.etcd.fullname" -}}
{{- if .Values.etcd.fullnameOverride -}}
{{- .Values.etcd.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "etcd" .Values.etcd.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Construct the `vault.fullname` of the vault sub-chart.
Used to discover the Service and Secret name created by the sub-chart.
*/}}
{{- define "a2ml.vault.fullname" -}}
{{- if .Values.vault.fullnameOverride -}}
{{- .Values.vault.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "vault" .Values.vault.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}