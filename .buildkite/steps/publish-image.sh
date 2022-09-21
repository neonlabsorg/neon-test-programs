#!/bin/bash
set -euo pipefail

source .buildkite/steps/revision.sh

docker images

docker login -u $DHUBU -p $DHUBP

if [[ ${BUILDKITE_BRANCH} == "master" ]]; then
    TAG=stable
elif [[ ${BUILDKITE_BRANCH} == "develop" ]]; then
    TAG=latest
else
    TAG=${BUILDKITE_BRANCH}
fi

docker pull neonlabsorg/test_invoke_neon:${REVISION}
docker tag neonlabsorg/test_invoke_neon:${REVISION} neonlabsorg/test_invoke_neon:${TAG}
docker push neonlabsorg/test_invoke_neon:${TAG}
