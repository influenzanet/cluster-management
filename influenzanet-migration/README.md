# influenzanet-migration

Install this chart to invite users from the old platform.  

## Dependencies

In order for the migration to work, you need to copy the users.json file containing the list of users to be invited to the volume `migration-pv`. 

## Configurations

- `admin_scripts_image`: image name and version of the admin scripts to use 

- `management_api_url`: management api url inside the cluster

- `participant_api_url`: participant api url inside the cluser

- `user_credentials`: email and password of the user accessing the apis

- `language`: two letter iso name for the preferred language that will be assigned to users being migrated 

- `use2FA`: boolean indicating whether or not using the two factors authentication  

- `skipEmptyProfiles`: boolean indicating whether or not skipping empty profiles

- `studyKeys`: list of study keys to be assigned to users being migrated

- `schedule`: crontab like syntax for the job scheduler

## Install

``` bash
helm install influenzanet-migration influenzanet-migration -f influenzanet/values.yaml
```