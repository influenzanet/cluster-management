# influenzanet-restore

Chart for restoring `mongo` backups. After installing the chart:

``` bash
helm install influenzanet-restore influenzanet-restore/ -f influenzanet/values.yaml
```

run a shell, eg:

``` bash
kubectl exec -ti deployments/mongo-restore bash -n italy
```

and navigate to the backups path `/data/backups`. Use `mongorestore` to restore your db. When you're done remember to uninstall this chart:

``` bash
helm uninstall influenzanet-restore
```

otherwise scheduled backup jobs will be unable to mount the backups storage.
