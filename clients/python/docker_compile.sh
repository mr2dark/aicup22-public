#!/bin/bash
set -euo pipefail

SOLUTION_ARCHIVE="$1"
[ -f "${SOLUTION_ARCHIVE}" ] || echo "Argument must be a path to solution archive file"
SOLUTION_ARCHIVE_COMPILED="${2:-"${SOLUTION_ARCHIVE}.compiled"}"

CONTAINER_BUILDER="${CONTAINER_BUILDER:-docker}"
CONTAINER_RUNNER="${CONTAINER_RUNNER:-${CONTAINER_BUILDER}}"
CONTAINER_FILES=(Dockerfile entrypoint.sh)

LANG_CODE="$(basename "$(pwd)")"
echo "LANG_CODE: ${LANG_CODE}"

CONTAINER_IMAGE_NAME="aicup2022-${LANG_CODE}:latest"

# PROJECT_NAME must match PROJECT_NAME value from `entrypoint.sh`
PROJECT_NAME="${PROJECT_NAME:-ai_cup_22}"
MOUNT_POINT="/opt/mount-point"
SOLUTION_CODE_PATH="/opt/client/solution"

CONTAINER_IMAGE_ID="$("${CONTAINER_RUNNER}" image ls -q "${CONTAINER_IMAGE_NAME}")"
if [ -z "${CONTAINER_IMAGE_ID}" ]; then
  export WORKDIR="$(mktemp -d /tmp/aicup2022_build.XXXXXX)"
  mkdir -p "${WORKDIR}"
  cp "${CONTAINER_FILES[@]}" "${WORKDIR}/"
  pushd "${WORKDIR}"
  "${CONTAINER_BUILDER}" build -t "${CONTAINER_IMAGE_NAME}" .
  popd
  rm -rf "${WORKDIR}"
fi

export WORKDIR="$(mktemp -d /tmp/aicup2022_compile.XXXXXX)"
echo "Compile working dir is ${WORKDIR}"
mkdir -p "${WORKDIR}/solution"
mkdir -p "${WORKDIR}/compile_logs"
mkdir -p "${WORKDIR}/tmp"
cp "${SOLUTION_ARCHIVE}" "${WORKDIR}/archive.zip"
cp "${CONTAINER_FILES[@]}" "${WORKDIR}/solution"
"${CONTAINER_RUNNER}" run -it --rm \
    -e COMPILE="True" \
    -e ZIPPED="True" \
    -e MOUNT_POINT="${MOUNT_POINT}" \
    -e SOLUTION_CODE_PATH="${SOLUTION_CODE_PATH}" \
    -e COMPILE_LOG_LOCATION="/compile_logs/compile_result.json" \
    --mount type=bind,source="${WORKDIR}/archive.zip",target="${MOUNT_POINT}" \
    --mount type=bind,source="${WORKDIR}/solution",target="${SOLUTION_CODE_PATH}" \
    --mount type=bind,source="${WORKDIR}/compile_logs",target="/compile_logs" \
    --mount type=bind,source="${WORKDIR}/tmp",target="/tmp" \
  "${CONTAINER_IMAGE_NAME}" \
  | tee "${WORKDIR}/compile_logs/compile.log"

echo "You can find compilation log files: ${WORKDIR}/compile_logs"
cp "${WORKDIR}/tmp/${PROJECT_NAME}.zip" "${SOLUTION_ARCHIVE_COMPILED}"
echo "You can find the compiled artifact at: ${SOLUTION_ARCHIVE_COMPILED}"
