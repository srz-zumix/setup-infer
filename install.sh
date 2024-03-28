#!/bin/bash
set -euox pipefail

source "${GITHUB_ACTION_PATH:-.}/utils.sh"
source "${GITHUB_ACTION_PATH:-.}/resolve.sh"

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

install_osx() {
    VERSION_NUMBER="${VERSION##v}"
    if [ ! -f "${INFER_INSTALLDIR}/infer-${VERSION_NUMBER}/infer/bin/infer" ]; then
      cd "${INFER_INSTALLDIR}" || exit
      curl -sL "https://github.com/facebook/infer/archive/refs/tags/${VERSION}.tar.gz" | tar -zxv
      cd "infer-${VERSION_NUMBER}" || exit
      BUILD_OPTIONS+=("clnag")
      sh "./build-infer.sh" "${BUILD_OPTIONS[@]}"
    fi
    echo "${INFER_INSTALLDIR}/infer-${VERSION_NUMBER}/infer/bin" >>"${GITHUB_PATH}"
}

install_linux() {
    if [ ! -f "${INFER_INSTALLDIR}/infer-linux64-${VERSION}/bin/infer" ]; then
      cd "${INFER_INSTALLDIR}" || exit
      curl -sL "https://github.com/facebook/infer/releases/download/${VERSION}/infer-linux64-${VERSION}.tar.xz" | tar -xvJ
    fi
    echo "${INFER_INSTALLDIR}/infer-linux64-${VERSION}/bin" >>"${GITHUB_PATH}"
}

install_windows() {
    echo "windows is not supported"
    exit 1
}

install() {
    if is_osx; then
        install_osx
    fi
    if is_linux; then
        install_linux
    fi
    if is_windows; then
        install_windows
    fi
}
echo '::group::📖 Installing infer ...'
install
echo '::endgroup::'
