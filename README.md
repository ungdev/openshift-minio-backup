# OpenShift Minio Backup - Docker Image

## Summary

- A :whale: Docker image used to backup database to minio file system

## Environnement variables

HOST: hostname of minio server
BUCKET: minio bucket name

## To build the Docker image

- Build the image using docker
```bash
$ docker build -t openshift-minio-backup .
```

## Contributing
File issues in GitHub to report bugs or issue a pull request to contribute.

Dockerfile based on https://github.com/e-bits/openshift-client work