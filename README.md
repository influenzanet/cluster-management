

# Running a kubernetes deployment - CASE
This guide will walk you through creating a Kubernetes deployment for CASE - Survey System. It will walk you through creating individual images for each of the repositories and deploying them on to a running kubernetes cluster.
## Dependencies
0. Ensure make is installed
1. Docker is installed
2. Docker daemon is running
3. kubernetes is installed on a cluster

This guide consists of two sections: 

 - **Building Images & Uploading to Docker Hub**: This section will help you check out code locally, create a docker image and upload it onto docker hub.
 - **Creating a deployment of the docker hub images on a Kubernetes Cluster**: Asa explained, this will guide you in creating a fresh deployment on a requisitioned cluster running kubernetes.

**If you wish to use pre-existing docker images instead of recreating your own skip ahead of the first section  to the deployment section (Section 2)**

## Section 1: Building Images & Uploading to Docker Hub

### Dependencies
0. Ensure make is installed
1. Docker is installed
2. Docker daemon is running
3. Appropriate push access to the docker hub repository
4. Pull Permissions on all relevant Influenza Net repositories

### Web-client

##### Clone the repository:
Run the command: 

    git clone https://github.com/influenzanet/web-client-nl.git

##### Build Docker Images: 

Run the dockerfile by moving to the root folder of the web-client repository and running the command:

    make docker

This should create a tagged image for the repository with the name: github.com/influenzanet/web-client:$(VERSION) where $(VERSION)  represents the release number.

##### Upload the built images to Docker hub:

To create a new tag locally run the command:

    docker tag github.com/influenzanet/web-client:v0.21.6 sajeeth1009/web-client-image:v0.21.6

Note: the version specified here is an example version. The first parameter refers to the local image tag and the second refers to the image tag to be pushed on to docker hub,
Next push this created image on to the docker hub using the following command:

    docker push sajeeth1009/web-client-image:v0.21.6

Note: This might require a login (since this docker hub repo is private due to Nl specific content) and additional permissions to push to this repo. All other repositories are public and do not require a login.

### User Management Service
##### Clone the repository:
Run the command: 

    git clone https://github.com/influenzanet/user-management-service.git

##### Build Docker Images: 
Run the dockerfile by moving to the root folder of the user-management repository and running the command:

    make docker

This should create a tagged image for the repository with the name: github.com/influenzanet/user-management-service:$(VERSION) where $(VERSION)  represents the release number.

##### Upload the built images to Docker hub:

To create a new tag locally run the command:

    docker tag github.com/influenzanet/user-management-service:v0.18.4 sajeeth1009/user-management-image:v0.18.4

Note: the version specified here is an example version. The first parameter refers to the local image tag and the second refers to the image tag to be pushed on to docker hub,
Next push this created image on to the docker hub using the following command:

    docker push sajeeth1009/user-management-image:v0.18.4

### Study Service
##### Clone the repository:
Run the command: 

    git clone https://github.com/influenzanet/study-service.git

##### Build Docker Images: 

Run the dockerfile by moving to the root folder of the study-service repository and running the command:

    make docker

This should create a tagged image for the repository with the name: github.com/influenzanet/study-service:$(VERSION) where $(VERSION)  represents the release number.

##### Upload the built images to Docker hub:

To create a new tag locally run the command:

    docker tag github.com/influenzanet/study-service:v0.13.2 sajeeth1009/study-service-image:v0.13.2

Note: the version specified here is an example version. The first parameter refers to the local image tag and the second refers to the image tag to be pushed on to docker hub,
Next push this created image on to the docker hub using the following command:

    docker push sajeeth1009/study-service-image:v0.13.2

### API Gateway
##### Clone the repository:
Run the command: 

    git clone https://github.com/influenzanet/api-gateway.git

##### Build Docker Images: 

Run the dockerfile by moving to the root folder of the study-service repository and running the command:

    make docker-participant-api
    make docker-management-api

This should create two tagged images for the repository with the names: github.com/influenzanet/participant-api:$(VERSION) and github.com/influenzanet/management-api:(VERSION)  where $(VERSION)  represents the release number.

##### Upload the built images to Docker hub:

To create a new tag locally run the command:

    docker tag github.com/influenzanet/participant-api:v0.12.1 sajeeth1009/participant-api-image:v0.12.1
    docker tag github.com/influenzanet/management-api:v0.12.1 sajeeth1009/management-api-image:v0.12.1

Note: the version specified here is an example version. The first parameter refers to the local image tag and the second refers to the image tag to be pushed on to docker hub,
Next push this created image on to the docker hub using the following command:

    docker push sajeeth1009/participant-api-image:v0.12.1
    docker push sajeeth1009/management-api-image:v0.12.1

### Messaging Service
##### Clone the repository:
Run the command: 

    git clone https://github.com/influenzanet/messaging-service.git

##### Build Docker Images: 

Run the dockerfile by moving to the root folder of the study-service repository and running the command:

    make docker-email-client
    make docker-message-scheduler
    make docker-messaging-service

This should create two tagged images for the repository with the names: github.com/influenzanet/messaging-service:$(VERSION), github.com/influenzanet/message-scheduler:(VERSION) and github.com/influenzanet/email-client-service:(VERSION) where $(VERSION) represents the release number.

##### Upload the built images to Docker hub:

To create a new tag locally run the command:

    docker tag github.com/influenzanet/messaging-service:v0.8.3 sajeeth1009/messaging-service-image:v0.8.3
    docker tag github.com/influenzanet/message-scheduler:v0.8.3 sajeeth1009/message-scheduler-image:v0.8.3
    docker tag github.com/influenzanet/email-client-service:v0.8.3 sajeeth1009/email-client-service-image:v0.8.3

Note: the version specified here is an example version. The first parameter refers to the local image tag and the second refers to the image tag to be pushed on to docker hub,
Next push this created image on to the docker hub using the following command:

    docker push sajeeth1009/messaging-service-image:v0.8.3
    docker push sajeeth1009/message-scheduler-image:v0.8.3
    docker push sajeeth1009/email-client-service-image:v0.8.3

### Logging Service
##### Clone the repository:
Run the command: 

    git clone https://github.com/influenzanet/logging-service.git

##### Build Docker Images: 

Run the dockerfile by moving to the root folder of the study-service repository and running the command:

    make docker

This should create a tagged image for the repository with the name: github.com/influenzanet/logging-service:$(VERSION) where $(VERSION)  represents the release number.

##### Upload the built images to Docker hub:

To create a new tag locally run the command:

    docker tag github.com/influenzanet/logging-service:v0.1.0 sajeeth1009/logging-service-image:v0.1.0

Note: the version specified here is an example version. The first parameter refers to the local image tag and the second refers to the image tag to be pushed on to docker hub,
Next push this created image on to the docker hub using the following command:

    docker push sajeeth1009/logging-service-image:v0.1.0

----------------
## Section 2: **Creating a deployment of the docker hub images on a Kubernetes Cluster**
### Dependencies
0. Kubernetes service running on a cluster
1. 

### Deployment Steps
Check out the kubernetes deployment repositories from the github repo by running the following command

    git clone *INSERT REPO HERE*




#### 1. Web-client
Navigate to the web-client-deployment.yaml file.

    cd deployments
    vi web-client-deployment.yaml


## Enable the Ingress controller[](https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/#enable-the-ingress-controller)

1.  To enable the NGINX Ingress controller, run the following command:
    
    ```shell
    minikube addons enable ingress
    
    ```
    
2.  Verify that the NGINX Ingress controller is running
    
    ```shell
    kubectl get pods -n kube-system
    ```

