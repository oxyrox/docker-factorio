#!/usr/bin/env bash
set -e
VERSION=$1

if [ -z ${VERSION} ]
then
    echo "Packages an arbitrary Factorio release."
    echo
    echo "Usage: $0 0.15.34"
    exit 1
fi

LOCAL_FILENAME=factorio_headless_x64_${VERSION}.tar.xz
DOWNLOAD_URL=https://www.factorio.com/get-download/${VERSION}/headless/linux64

# Attempt to grab the requested release.
wget  ${DOWNLOAD_URL} -O ${LOCAL_FILENAME} || rm -f ${LOCAL_FILENAME}

if [ $? -ne 0 ]
then
    exit 1
fi

docker build --build-arg factorio_version=${VERSION} \
    -t quay.io/oxyrox/factorio-k8s:${VERSION} .
docker run --rm -it quay.io/oxyrox/factorio-k8s:${VERSION}

while true; do
    read -p "Publish the built image? (y/n) " yn
    case $yn in
        [Yy]* )
            docker push quay.io/oxyrox/factorio-k8s:${VERSION}
            break;;
        [Nn]* )
            exit;;
        * )
            echo "Please answer y or n.";;
    esac
done
