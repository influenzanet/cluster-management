
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

Before proceeding, configure the `influenzanet/values.yaml` file to reflect the defaults values for all possible parameters of your deployment. 

It's also possible to create an empty yaml file to be used to override the values in the influenzanet/values.yaml (it's advised to store this file in a secure location since it will contains some sensitive values or to separate the sensitive values in an other overriding file). You can use several yaml in cascade (using the -f option several times). For example one for the common config for the instance and one or several for the deployment environment and one another for the secrets (this last can be stored in a secure location and the previous ones tracked with a VCS like git).

When installing/updating the helm chart you can pass the option -f with the path of your yaml file, it will be used to override the values. You can pass several times this option with different to cascade the overrides. This can be useful if you use several settings with common parameters, for example production and dev environment.
A last file can contains only the secrets and some others the non sensitive override allowing to store them in a vcs

In the `values.yaml` file you will find the following configuration values:

1. namespace, domain and back-end path configurations

    - `namespace`: the namespace under which each Kubernets component of Influenzanet will be registered, eg: `italy`
    - `domain`: the domain name hosting the platform, eg: `influweb.org`
    - `tlsDomains`: array of additional domain names redirected to the base domain, eg: `[influweb.org, influweb.it]`
    - `participantApiPath`: the path under which the participant API are served, eg: `/api`
    - `managementApiPath`: the path under which the management API are served, eg: `/admin`
    - `useRecaptcha`: use Recaptcha for signup if 'true', skip if 'false'
    - `dbNamePrefix`: Prefix to use for instance database (to enable multi tenant database)

Under the ingress entry

```yaml
ingress:
  simplified: true # Use simplified ingress version

```

1. TLS certificate configurations

Using ACME Letsencrypt service

 - `acmeServer`:  URL for the ACME server issuing TLS certificates, eg: `https://acme-v02.api.letsencrypt.org/directory`

 - `clusterIssuer`: name assigned to the ACME server, eg: `letsencrypt`

 - `acmeEmail`: email associated to the ACME server, will receive maintenance communication from the acme server.

Other modes

`issuerType` can be used to switch to another certificate issuer type
  - 'ca' value will use a local CA. The value `CAIssuerSecretName` should contains the name of the secret containing the CA private key and certificate 
    You have to create it manually before to use it in the cluster (this intented to be only for dev mode)
  - 'none' wont create certificate issuer

1. Secrets: JWT, Mongo credentials, recaptcha key

**Caution** From 1.0 the secrets are base64 encoded by the helm template, no need to manually encode them (specially jwtKey, googleRecaptchaKey )

    - `jwtKey`: base64 encoded key used for generating user authentication tokens, see [Generating a JWT key ](#generating-a-jwt-key ) for instructions on how to generate a key

    - `mongoUsername`: used to setup the mongo admin account

    - `mongoPassword`: password associated to the mongo admin account

    - `googleRecaptchaKey`:  secret key associated to a Google recaptcha account, see [Generating a recaptcha key](#generating-a-recaptcha-key) for instructions on how to obtain a key

    - `studyGlobalSecret` : base64 encoded value of global secret for study service 

1. Persistent volume configurations (for mongoDB service)

    Detailed information on these configuration values can be found in Kubernetes' documentation on [Persistent Volumes]( https://kubernetes.io/docs/concepts/storage/persistent-volumes/).

    - `createStorageClass` : if you use already existing storageClass (provided by a cloud provider, set this value to false)

  Under the entry svcMongoDb (values are the default values given as example. Omit an entry to use the default)

  ```yaml
  svcMongoDb:
    storageClass: influenzanet-storage # the storage class used by Kubernetes when requesting storage for the mongo database
    accessModes: # Access mode for the storage 
      - ReadWriteOnce  # By default the storage can only be accessed by one pod at time
    storageRequested: `50Gi` # size allocated for the storage, 
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

6. Microservice specific sections, containing configurations of the Kubernetes [deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) and [service](https://kubernetes.io/docs/concepts/services-networking/service/) for each of the microservices. This includes docker image paths for each microservice, environment variables, port configurations and persistent volume attachments if needed. The most important value you need to change for each microservice is the location of the Dockerhub image:

Each microservice has its own entry in the values file and can be overridden:

- svcEmailClient
- svcLogging
- svcManagementApi
- svcParticipantApi
- svcUserManagement
- svcMessaging
- svcStudyService
- SvcMessageScheduler

Each provides a set of parameters to configure the service under the service name entry

Most common parameters are:
 - image: name of the image to use
 - replicas: number of replicas to use

For example to override the image and replicas uses 
```yaml

svcWebParticipant:
  image: myrepo/webparticipant-image:v1.2 # <docker image ref>
  replicas: 2 # Number of replicas to use for the service
```

For some services you will need to override value for your deployment

```yaml
svcManagementApi:
 corsAllowOrigins: "http://youdomain.com,https://yourdomain.com" # Domains allowed to use the api (client side security)

svcParticipantApi:
  corsAllowOrigins: "http://youdomain.com,https://yourdomain.com" # idem 

```

For the others parameters, see in values.yml for each service
#### Generating a JWT key

The script used to generate a JWT key is hosted in the [user-management-service](https://github.com/influenzanet/user-management-service) repository. To generate a key cd into the directory `tools/key-generator` and run:

``` sh
go run main.go
```
put this value into to the `jwtKey` field.

** Warning ** the step with base64 tool is not needed any more (the jwtKey provided by the tool is already a base64 encoded value)

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

1. Run the deployment script `install_start.sh` for the first time you set up the system.

2. To stop and clean-up the Influenzanet services from the cluster run `stop.sh`

3. To reinstall the Influenzanet services platform after a clean-up, only run `start.sh` (prevents unnecessary re-installation of nginx ingress & certificate manager)

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
