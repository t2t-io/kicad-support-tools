#!/bin/bash
#
set -e
cd $(dirname $0)/..

NAME=$(basename $(pwd))
VERSION=$(cat package.json | jq -r .version)

[ "true" == "${CLEANUP}" ] && docker images | grep ${NAME} | awk '{print $2}' | sort | xargs -I{} sh -c "docker rmi ${NAME}:{}"

echo "building ${NAME}:${VERSION} ..."
docker build ${@} -t ${NAME}:${VERSION} .
docker build ${@} -t ${NAME}:latest .