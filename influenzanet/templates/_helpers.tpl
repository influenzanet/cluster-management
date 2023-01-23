
{{- define "ref.MessagingService" -}}{{ template "ref.Service" .Values.svcMessaging }}{{- end -}}

{{- define "ref.StudyService" -}}{{ template "ref.Service" $.Values.svcStudyService }}
{{- end -}}

{{- define "ref.emailClientService" -}}{{ template "ref.Service" $.Values.svcEmailClient }}{{- end -}}

{{- define "ref.loggingService" -}}{{ template "ref.Service" $.Values.svcLogging }}{{- end -}}

{{- define "ref.UserManagement" -}}
{{ template "ref.Service" $.Values.svcUserManagement }}
{{- end -}}

{{- define "ref.Service" -}}{{- printf "%s:%d" .serviceName (int .containerPort) -}}{{- end -}}

{{- define "ingress.backend" -}}
{ service: { name: {{ .serviceName }}, port: { number: {{ .containerPort }} } } }
{{- end -}}