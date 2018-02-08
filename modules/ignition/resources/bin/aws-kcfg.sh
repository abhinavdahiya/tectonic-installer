#!/bin/bash
set -e
set -o pipefail

if [ "$#" -ne "2" ]; then
    echo "Usage: $0 location destination"
    exit 1
fi

token_generate() {
    # shellcheck disable=SC2086,SC2154,SC2016
    /usr/bin/docker run \
        quay.io/abhinavdahiya/aws-authenticator:dev \
        token \
        -i ${cluster_name}
}

export USERTOKEN=$(token_generate)
/opt/s3-puller.sh $1 $2
sed -i "s/##USERTOKEN##/$USERTOKEN/" $2


