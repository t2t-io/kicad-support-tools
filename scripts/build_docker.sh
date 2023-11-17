#!/bin/bash
#
set -e
cd $(dirname $0)/..

NAME=$(basename $(pwd))
VERSION=$(cat package.json | jq -r .version)

echo "building ${NAME}:${VERSION} ..."
docker build ${@} -t ${NAME}:${VERSION} .
docker build ${@} -t ${NAME}:latest .