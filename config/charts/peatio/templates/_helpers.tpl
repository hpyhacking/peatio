{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "env" -}}
- name: URL_HOST
  value: {{ first .Values.ingress.hosts }}
- name: URL_SCHEME
  value: http{{ if .Values.ingress.tls }}s{{ end }}
- name: DATABASE_HOST
  value: {{ default ((printf "%s-db" .Release.Name) .Values.db.host) }}
- name: DATABASE_USER
  value: {{ default "root" .Values.db.user }}
- name: RABBITMQ_HOST
  value: {{ default ((printf "%s-rabbitmq" .Release.Name) .Values.rabbitmq.host) }}
- name: RABBITMQ_PORT
  value: {{ default "5672" .Values.rabbitmq.port | quote }}
- name: REDIS_URL
  value: redis://{{ default ((printf "%s-redis" .Release.Name) .Values.redis.host) }}:{{ default "6379" .Values.redis.port }}
{{- range $key, $value := .Values.peatio.env }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end }}
- name: COOKIES_SECRET_KEY
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
{{- if .Values.redis.password }}
- name: RABBITMQ_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "fullname" . }}
      key: rabbitmqPassword
{{- end }}
{{- if .Values.redis.password }}
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "fullname" . }}
      key: redisPassword
{{- end }}
{{- end -}}