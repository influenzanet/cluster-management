
# Running a kubernetes deployment

This guide will walk you through creating a Kubernetes deployment for the Influenzanet platform. It will walk you through creating individual images for each of the repositories and deploying them on to a running Kubernetes cluster.

## Dependencies

1. Docker images for each service must be built and hosted at your Dockerhub repository. See [influenzanet-setup-guide](https://github.com/influenzanet/influenzanet-setup-guide) for instructions on setting this up.

2. A cluster with Kubernetes installed.

## Creating a deployment of the docker hub images on a Kubernetes Cluster

### Dependencies

1. Kubernetes service running on a cluster

2. Ingress is enabled on the cluster.

3. A suitable domain name is present for the server.

4. A clone of this repository

   ```sh
   git clone https://github.com/influenzanet/cluster-management.git
   ```

### Set up

Before proceeding, configure the [influenzanet/values.yaml](./influenzanet/values.yaml) file to reflect the default values for all possible parameters of your deployment.

It's also possible to create an empty `yaml` file to be used to override the values in the [influenzanet/values.yaml](./influenzanet/values.yaml) (it's advised to store this file in a secure location since it will contain some sensitive values or to separate the sensitive values in an other overriding file). You can use several `yaml` files in cascade (using the -f option several times). For example one for the common config for the instance and one or several others for the production/deployment environments and yet one another for the secrets (this last can be stored in a secure location and the previous ones tracked with a VCS like git).

In the `values.yaml` file you will find the following configuration values:

1. namespace, domains, database prefix and back-end path configurations

    - `namespace`: the namespace under which each Kubernets component of Influenzanet will be registered, eg: `italy`
    - `domain`: the domain name hosting the platform, eg: `influweb.org`
    - `tlsDomains`: array of additional domain names redirected to the base domain, eg: `[influweb.org, influweb.it]`
    - `participantApiPath`: the path under which the participant API are served, eg: `/api`
    - `managementApiPath`: the path under which the management API are served, eg: `/admin`
    - `useRecaptcha`: if 'true', use Google Recaptcha for protecting the signup process, skip if 'false'
    - `dbNamePrefix`: prefix to use for the database instance (useful for multi tenant database scenarios)

1. ingress configuration

    - `enabled`: 'true' for enabling ingress configuration found in [ingress.yaml](./influenzanet/templates/ingress.yaml)
    - `name`: a name for the ingress template found in [ingress.yaml](./influenzanet/templates/ingress.yaml)
    - `simplfied`: 'true' for enabling a simplified ingress (requires an up to date version of [participant-webapp](https://github.com/influenzanet/participant-webapp)

1. TLS certificate configurations

    Using ACME Letsencrypt service

     - `acmeServer`:  URL for the ACME server issuing TLS certificates, eg: `https://acme-v02.api.letsencrypt.org/directory`

     - `clusterIssuer`: name assigned to the ACME server, eg: `letsencrypt`

     - `acmeEmail`: email associated to the ACME server, will receive maintenance communication from the acme server.

    Other modes

    `issuerType` can be used to switch to another certificate issuer type
      - 'ca' value will use a local CA. The value `CAIssuerSecretName` should contain the name of the secret containing the CA private key and certificate 
        You have to create it manually before using it in the cluster (this intended to be used only in dev mode)
      - 'none' won't create a certificate issuer

1. Secrets: JWT, Mongo credentials, recaptcha key

    **Caution**: chart version `v1.0` onward, the secrets are base64 encoded by the helm template, no need to manually encode them (specially `jwtKey`, `googleRecaptchaKey` and `studyGlobalSecret`)

    - `jwtKey`: base64 encoded key used for generating user authentication tokens, see [Generating a JWT key ](#generating-a-jwt-key ) for instructions on how to generate a key

    - `mongoUsername`: used to setup the mongo admin account

    - `mongoPassword`: password associated to the mongo admin account

    - `googleRecaptchaKey`: secret key associated to a Google recaptcha account, see [Generating a recaptcha key](#generating-a-recaptcha-key) for instructions on how to obtain a key

    - `studyGlobalSecret`: global secret used by [study-service](https://github.com/influenzanet/study-service)

1. Persistent volume configurations (for mongoDB service)

    Detailed information on these configuration values can be found in Kubernetes' documentation on [Persistent Volumes]( https://kubernetes.io/docs/concepts/storage/persistent-volumes/).

    - `createStorageClass`: 'true' for creating the `influenzanet-storage` storage class defined in [storageClass.yaml](./influenzanet/templates/storageClass.yaml), if you plan to use a default storageClass (eg: one from your cloud provider), set this value to 'false'

    Under the entry `svcMongoDb` you can specify the storage class to be used, eg: (values are the default values given as example, omit the `storageClass` an entry to use the default class from your cloud provider)

    ```yaml
    svcMongoDb:
      # the storage class used by Kubernetes when requesting storage for the
      # mongo database
      storageClass: influenzanet-storage
      # Access mode for the storage 
      accessModes:
        # By default the storage can only be accessed by one pod at time
        - ReadWriteOnce 
      # size allocated for the storage, 
      storageRequested: `50Gi` 
    ```

5. SMTP configurations for Email sending

    Specify default (`smtpServers`) and high priority (`smtpServers`) SMTP servers, for both entries you must specify:

    - `from`: what users see as the from address when receiving Influenzanet mails.
    - `sender`: email address of the sender (from can be a name as well)
    - `replyTo`: additional addresses to always send emails to (can be an empty array)
    - `servers`: array of SMTP servers specifying:
        - `host`: SMTP host
        - `port`: SMTP port
        - `auth`: contains the username and password credentials for the mailing service.

6. Microservice specific sections, containing configurations of the Kubernetes [deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) and [service](https://kubernetes.io/docs/concepts/services-networking/service/) for each of the microservices. This includes docker image paths for each microservice, environment variables, port configurations and persistent volume attachments if needed. The most important value you need to change for each microservice is the location of the Dockerhub image.

   Each microservice has its own entry in the values file and can be overridden:

   - `svcEmailClient`
   - `svcLogging`
   - `svcManagementApi`
   - `svcParticipantApi`
   - `svcUserManagement`
   - `svcMessaging`
   - `svcStudyService`
   - `SvcMessageScheduler`

   Each entry provides a set of parameters to configure the service under that particular service. The most important parameters are:
   
   - `image`: name of the image to use
   - `replicas`: number of replicas to use

   For example, to override the image and replicas use:
   
   ```yaml

   svcWebParticipant:
     image: myrepo/webparticipant-image:v1.2 # <docker image ref>
     replicas: 2 # Number of replicas to use for the service
   ```

   For some other services you will need to override some value for your deployment:

   ```yaml
   svcManagementApi:
     # Domains allowed to use the api (client side security)
     corsAllowOrigins: "http://youdomain.com,https://yourdomain.com"
   svcParticipantApi:
     # same as above 
     corsAllowOrigins: "http://youdomain.com,https://yourdomain.com"

   ```

   For the other parameters, refer to the default values in [influenzanet/values.yaml](./influenzanet/values.yaml) for each service.

#### Generating a JWT key

The script used to generate a JWT key is hosted in the [user-management-service](https://github.com/influenzanet/user-management-service) repository. To generate a key cd into the directory `tools/key-generator` and run:

``` sh
go run main.go
```
put this value into to the `jwtKey` field.

#### Generating a recaptcha key

To generate a Google recaptcha key pair follow these steps:

- login into a Google account

- navigate to https://www.google.com/recaptcha/about/

- click on the admin console, and then click the plus icon. Give a suitable label.

- select reCAPTCHA v2 and an invisible recaptcha badge in the options

- add the domain , ie: influweb.org

- click submit, this should generate two keys, a public key and  a secret key.

- the public key is the one to be used it in the REACT_APP_RECAPTCHA_SITEKEY field in your [participant-webapp](https://github.com/influenzanet/participant-webapp) configuration file.

- use the private key value in the `googleRecaptchaKey` value.

### Deployment Steps

Once the repository has been checked out into the server and your configuration is in place:

1. Run the deployment script `install_deps.sh` for the first time you set up the system.

2. To install/uninstall the base Influenzanet services from the cluster run:

``` sh
helm install influenzanet influenzanet / helm uninstall influenzanet
```

3. To uninstall the Influenzanet dependencies run `uninstall_deps.sh`

### Additional charts

Additional `helm` charts are available for several plug-in functionalities:

- [influenzanet-backups](./influenzanet-backups): chart for enabling scheduled `mongo` backups
- [influenzanet-restore](./influenzanet-restore): chart for restoring `mongo` backups
- [influenzanet-mailgun](./influenzanet-mailgun): chart for setting up mailgun [webhooks](https://www.mailgun.com/guides/your-guide-to-webhooks/)
- [influenzanet-maintenance](./influenzanet-maintenance): chart for enabling maintenance mode on the deployed Influenzanet platform

Each of the above charts depends on the base `influenzanet` chart and depends on the `values.yaml` contained therein, eg:

``` bash
helm install influenzanet-backups influenzanet-backups/ -f influenzanet/values.yaml
```

For further details see the `README.md` included in a specific subchart.

### Troubleshooting

1. Verify that the NGINX Ingress controller is running

  ```
  kubectl get pods -n kube-system
  ```

2. Check the status of the deployments by running the following commands:

  ```
  kubectl get deployments,services,pods --namespace=[influenzanet_namespace]
  ```

3. On GKE sometimes webhook creation might fail for nginx admission, to get past this error run the following:

  ```
  kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
  ```

4. Lets encrypt (which is used for certificate creation) has a duplicate certificate creation limit of 5 per week.  Check logs of the created certificate by running

  ```
  kubectl describe certificate <cert-name> -n [influenzanet_namespace]
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

7. In case the script `start.sh` or `install_start.sh` fails with an error: _"Failed to connect to Kubernetes cluster"_, ensure that you run the following in the google connect console.

  ```
  gcloud container clusters get-credentials influweb-italy-cluster --zone europe-west1-d --project infuweb-italy
  ```

  This will allow you to set the credentials to gain access to run the script.
  If this fails too, then try executing the instructions in the `install_start.sh` script manually in the terminal.
