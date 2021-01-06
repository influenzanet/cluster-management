kubectl delete deployment mongo logging study user-management participant-api management-api web-client messaging message-scheduler email-client --namespace=italy
kubectl delete pvc task-pv-claim --namespace=italy
kubectl delete pv task-pv-volume --namespace=italy
kubectl delete service email-client-service messaging-service messaging-scheduler-service mongo-atlas-service logging-service web-client-service study-service user-management-service management-api-service participant-api-service --namespace=italy
kubectl delete secrets jwt-collection case-mongodb-atlas --namespace=italy
kubectl delete secrets cert_case regcred
kubectl delete configmaps email-server-config web-env-config --namespace=italy
kubectl delete ingress case-ingress case-ingress-web --namespace=italy