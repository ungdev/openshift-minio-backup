# MOVED TO https://gitlab.com/ungdev/sia/openshift-minio-backup
# OpenShift Minio Backup - Docker Image

## Summary

- A :whale: Docker image used to backup database to minio file system

## Environnement variables

HOST: hostname of minio server
BUCKET: minio bucket name

## Service account creation

create the service account:

```
echo '{"apiVersion":"v1","kind":"ServiceAccount","metadata":{"name":"openshift-minio-backup"}}' | oc create -f -
```

Add the permission:

```
oc policy add-cluster-role-to-user backup-to-minio system:serviceaccount:`oc project -q`:openshift-minio-backup
```

Get the API Token associated with the service account:
```
SA_TOKEN=$(oc get sa/openshift-minio-backup --template='{{range .secrets}}{{printf "%s\n" .name}}{{end}}' | grep openshift-minio-backup-token |  tail -n 1)
API_TOKEN=$(oc get secrets ${SA_TOKEN} --template '{{.data.token}}' | base64 -d)
```
Echo the value for the configuration file or environment variable:

```
echo $API_TOKEN
```

## To build the Docker image

- Build the image using docker
```bash
$ docker build -t openshift-minio-backup .
```

## Contributing
File issues in GitHub to report bugs or issue a pull request to contribute.

Dockerfile based on https://github.com/e-bits/openshift-client work
