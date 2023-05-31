
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

{{- define "check.deployed.image" -}}
{{- $current_deployment := lookup "apps/v1" "Deployment" .namespace .name -}}
{{- if $current_deployment -}}
    {{- $helm_image := (get $current_deployment.spec.template.metadata.annotations "helmImage") -}}
    {{- $current_image := (index $current_deployment.spec.template.spec.containers 0).image }}
    {{- if $helm_image -}}
        {{- if and (not (eq $helm_image $current_image)) (not (eq $current_image .image)) -}}
        {{- fail (print "Deployed image and chart image do not match: " $current_image " != " .image)  -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
{{- end -}}