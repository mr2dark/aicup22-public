#!/bin/bash
set -euo pipefail

SOLUTION_ARCHIVE_COMPILED="$1"
shift 1

HOST=${1:-127.0.0.1}
PORT=${2:-31001}
TOKEN=${3:-0000000000000000}

echo "Arguments: HOST: $HOST, PORT: $PORT, TOKEN: $TOKEN"

if [ "$HOST" = "localhost" ]; then
  echo "Replacing 'localhost' to 'host.docker.internal'"
  HOST="host.docker.internal"
fi

CONTAINER_RUNNER="${CONTAINER_RUNNER:-docker}"
CONTAINER_BUILDER="${CONTAINER_BUILDER:-${CONTAINER_RUNNER}}"
CONTAINER_FILES=(Dockerfile entrypoint.sh)

LANG_CODE="$(basename "$(pwd)")"
echo "LANG_CODE: ${LANG_CODE}"

CONTAINER_IMAGE_NAME="aicup2022-${LANG_CODE}:latest"

# PROJECT_NAME must match PROJECT_NAME value from `entrypoint.sh`
PROJECT_NAME="${PROJECT_NAME:-ai_cup_22}"
MOUNT_POINT="/opt/mount-point"
SOLUTION_CODE_PATH="/opt/client/solution"

export WORKDIR="${WORKDIR:-$(mktemp -d /tmp/aicup2022_run.XXXXXX)}"
echo "Run working dir is ${WORKDIR}"
mkdir -p "${WORKDIR}/solution"
mkdir -p "${WORKDIR}/tmp"
cp "${SOLUTION_ARCHIVE_COMPILED}" "${WORKDIR}/solution_artifact"
cp "${CONTAINER_FILES[@]}" "${WORKDIR}/solution"
"${CONTAINER_RUNNER}" run -it --rm \
    --memory=1g \
    --cpus=1 \
    --add-host=host.docker.internal:host-gateway \
    --net=host \
    -e MOUNT_POINT="${MOUNT_POINT}" \
    -e WORLD_NAME="${HOST}" \
    -e PORT="${PORT}" \
    -e SECRET_TOKEN="${TOKEN}" \
    --mount type=bind,source="${WORKDIR}/solution_artifact",target="${MOUNT_POINT}" \
    --mount type=bind,source="${WORKDIR}/solution",target="${SOLUTION_CODE_PATH}" \
    --mount type=bind,source="${WORKDIR}/tmp",target="/tmp" \
  "${CONTAINER_IMAGE_NAME}" bash -c "printenv > /tmp/env; time bash entrypoint.sh 2> /tmp/stderr | tee /tmp/stdout"

echo "You can find run files at: ${WORKDIR}/tmp"
