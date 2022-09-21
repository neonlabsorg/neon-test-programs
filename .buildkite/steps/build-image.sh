#!/bin/bash
set -euo pipefail

source .buildkite/steps/revision.sh

docker build -t neonlabsorg/test_invoke_neon:${REVISION} .
