# influenzanet-backups

Install this chart to enable automatic `mongodb backups`.

``` bash
helm install influenzanet-backups influenzanet-backups/ -f influenzanet/values.yaml
```

# Configurable values

- `mongodbUri`: URI of the running `mongo` instance
- `storageClass`: storage class used when creating the PV claim
- `storageRequested`: storage space to request for the PV claim

By default, the backup job is run every day at midnight, this can be configured by changing the cronjob template [cronJob.yaml](./templates/cronJob.yaml).

By default, a backup job is not retried if it fails. In that case an error is logged on `stderr` and can be used to trigger an automatic alert on `GCE`.