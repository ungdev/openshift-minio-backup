FROM frolvlad/alpine-glibc:latest

MAINTAINER "Christian d'Autume" <christian@dautume.fr>

ENV OC_VERSION "v3.10.0"
ENV OC_RELEASE "openshift-origin-client-tools-v3.10.0-dd10d17-linux-64bit"

RUN apk add --no-cache bash gawk sed grep bc coreutils curl gzip
# install the oc client tools
ADD https://github.com/openshift/origin/releases/download/$OC_VERSION/$OC_RELEASE.tar.gz /opt/oc/release.tar.gz
RUN apk add --no-cache ca-certificates
RUN tar --strip-components=1 -xzvf  /opt/oc/release.tar.gz -C /opt/oc/ && \
    mv /opt/oc/oc /usr/bin/ && \
    rm -rf /opt/oc

WORKDIR /app
ADD . /app/  

CMD sh backup-databases.sh
