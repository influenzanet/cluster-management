 
# Running a kubernetes deployment - CASE

This guide will walk you through creating a Kubernetes deployment for CASE - Survey System. It will walk you through creating individual images for each of the repositories and deploying them on to a running kubernetes cluster.

## Dependencies

0. Ensure make is installed
1. Docker is installed
2. Docker daemon is running
3. kubernetes is installed on a cluster

This guide consists of two sections:

-  **Building Images & Uploading to Docker Hub**: This section will help you check out code locally, create a docker image and upload it onto docker hub.

-  **Creating a deployment of the docker hub images on a Kubernetes Cluster**: Asa explained, this will guide you in creating a fresh deployment on a requisitioned cluster running kubernetes.

**If you wish to use pre-existing docker images instead of recreating your own skip ahead of the first section to the deployment section (Section 2)**

## Section 1: Building Images & Uploading to Docker Hub

### Dependencies

0. Ensure make is installed
1. Docker is installed
2. Docker daemon is running
3. Appropriate push access to the docker hub repository
4. Pull Permissions on all relevant Influenza Net repositories

### Build Steps
1. Run build_docker.sh
2. Docker might require sudo permissions to complete the build.
3. Enter the credentials for the docker repository if asked.
4. For building the web app, enter into the cloned web-app directory
5. Create a new .env.local file and enter the required env variables mentioned in the repository for web-app
6. Re-run the build_docker.sh
----------------

## Section 2: **Creating a deployment of the docker hub images on a Kubernetes Cluster**

### Dependencies

0. Kubernetes service running on a cluster
1. Clone the repository by running the command: ``` git clone https://github.com/influenzanet/cluster-management.git```
2. Ingress is enabled on the cluster.
3. A suitable domain name is present for the server.
  
### Set up

 Before proceeding ensure the values are correct within the files

1. secrets/secrets.yaml : Here we configure secrets such as database passwords/ jwt / (recaptcha keys in base64)
2. configmaps/email-config.yaml: Here we need to update the contents of the SMTP server as well as the high priority SMTP server used for mailing.
3. Under the folder deployment, files representing each of the micro services are located (*-deployment.yaml files). Here edit the files to reflect the correct values for each of the environment variables. For example: Setting the value of the cors allowed origins field in both participant and management api deployment files.
4. Update the files in the inginx-ngress folder to reflect the domain name to be used.
5. Update the domain name in the deployment files. (currently set to 'case.com')

### Deployment Steps
Once the repository has been checked out into the server:
1. Set up the environment variables, domain information, deployment files, and secrets as mentioned in the previous section.
2. Run the deployment script install_start.sh for the first time you set up the system.
3. To stop and clean up run stop.sh (this removes everything except for already created certificates)
3. To run the system after the initial set up, run start.sh. (prevents unnecessary reinstallation of nginx ingress & certificate manager)
4. Manual deletion of nginx ingress controller/ certificates / certificate manager is required.

### Troubleshooting

1. When deploying on minikube enable the NGINX Ingress controller by running the following command:
	```
	minikube addons enable ingress
	```
2. Verify that the NGINX Ingress controller is running
	```
	kubectl get pods -n kube-system
	```
3. Check the status of the deployments by running the following commands:
	```
	kubectl get deployments,services,pods --namespace=case
	
	```
4. On GKE sometimes webhook creation might fail for nginx admission, to get past this error run the following:
	```
	kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
	```
5. Lets encrypt (which is used for certificate creation) has a duplicate certificate creation limit of 5 per week. 
	```
	check logs of the created certificate by runnning
	kubectl describe certificate <cert-name> -n case
	```
6. In case of errors in mail sending, you might have to edit the nginx ingress controller deployment and add the following ports
	```

        - containerPort: 465
          name: smtpssl
          protocol: TCP
        - containerPort: 587
          name: smtpauth
          protocol: TCP
	```

	and to the nginx controller service the following: 
	```
		- name: smtp
			port: 587
			protocol: TCP
			targetPort: 587
		- name: smtpssl
			port: 465
			protocol: TCP
			targetPort: 465
	```