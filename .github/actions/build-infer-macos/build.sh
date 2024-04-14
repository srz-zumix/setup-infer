#!/bin/bash
set -euox pipefail

INFER_TEMPDIR="${INPUTS_INFER_TEMPDIR:-}"
if [ -z "${INFER_TEMPDIR}" ]; then
  if [ -n "${RUNNER_TEMP}" ]; then
    INFER_TEMPDIR="${RUNNER_TEMP}"
  else
    INFER_TEMPDIR="$(mktemp -d)"
  fi
fi

INFER_INSTALLDIR="${RUNNER_TOOL_CACHE:-${INFER_TEMPDIR}}/infer"
# shellcheck disable=SC2206
BUILD_OPTIONS=(${INFER_BUILD_OPTIONS:-})

mkdir -p "${INFER_INSTALLDIR}"

VERSION_STR="${INPUTS_INFER_VERSION:-latest}"
VERSION_NUMBER="${VERSION_STR##v}"
VERSION="v${VERSION_NUMBER}"

build_infer() {
  if [ ! -f "${INFER_INSTALLDIR}/infer-${VERSION_NUMBER}/infer/bin/infer" ]; then
    cd "${INFER_INSTALLDIR}" || exit
    curl -sL "https://github.com/facebook/infer/archive/refs/tags/${VERSION}.tar.gz" | tar -zx
    cd "infer-${VERSION_NUMBER}" || exit
    BUILD_OPTIONS+=("-y")
    BUILD_OPTIONS+=("clang")
    ./build-infer.sh "${BUILD_OPTIONS[@]}"
  fi
  echo "${INFER_INSTALLDIR}/infer-${VERSION_NUMBER}/infer/bin" >>"${GITHUB_PATH}"
}

echo '::group::📖 Build infer ...'
build_infer
echo '::endgroup::'
