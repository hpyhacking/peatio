{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Expands image name.
*/}}
{{- define "image" -}}
{{- printf "%s:%s" .Values.image.repository .Values.image.tag -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Bitcoin RPC URL.
*/}}
{{- define "rpc" -}}
{{- printf "http://%s:%s@%s:%s" .Values.bitcoind.rpc_user .Values.bitcoind.rpc_password .Values.bitcoind.rpc_host .Values.bitcoind.rpc_port -}}
{{- end -}}

{{/*
Environment for database migration job.
It is pre-install hook, so we don't have secrets created yet and we need to use plain password.
*/}}
{{- define "prepare-db-env" -}}
- name: RAILS_ENV
  value: production
- name: DATABASE_HOST
  value: {{ .Values.db.host }}
- name: DATABASE_USER
  value: {{ default "root" .Values.db.user }}
- name: COOKIES_SECRET_KEY
  value: ""
{{- if .Values.db.password }}
- name: DATABASE_PASS
  value: {{ .Values.db.password }}
{{- end }}
{{- end -}}

{{/*
Environment for peatio container
*/}}
{{- define "env" -}}
- name: RAILS_ENV
  value: production
- name: PORT
  value: {{ .Values.service.internalPort | quote }}
- name: URL_HOST
  value: {{ .Values.ingress.host }}
- name: URL_SCHEME
  value: http{{ if .Values.ingress.tls }}s{{ end }}
- name: DATABASE_HOST
  value: {{ .Values.db.host }}
- name: DATABASE_USER
  value: {{ default "root" .Values.db.user }}
- name: RABBITMQ_HOST
  value: {{ .Values.rabbitmq.host }}
- name: RABBITMQ_PORT
  value: {{ default "5672" .Values.rabbitmq.port | quote }}
- name: RABBITMQ_USER
  value: {{ default "user" .Values.rabbitmq.user }}
- name: REDIS_URL
  value: redis://:{{ .Values.redis.password }}@{{ .Values.redis.host }}:{{ default "6379" .Values.redis.port }}
{{- range $key, $value := .Values.peatio.env }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end }}
- name: REDIS_PASSWORD
  value: {{ .Values.redis.password }}
- name: SECRET_KEY_BASE
  valueFrom:
    secretKeyRef:
      name: {{ template "fullname" . }}
      key: cookiesSecretKey
- name: JWT_SHARED_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ template "fullname" . }}
      key: jwtSharedSecretKey
{{- if .Values.db.password }}
- name: DATABASE_PASS
  valueFrom:
    secretKeyRef:
      name: {{ template "fullname" . }}
      key: dbPassword
{{- end }}
{{- if .Values.rabbitmq.password }}
- name: RABBITMQ_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "fullname" . }}
      key: rabbitmqPassword
{{- end }}
{{- end -}}
