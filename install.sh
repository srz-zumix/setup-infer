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
mkdir -p "${INFER_INSTALLDIR}"

install_osx() {
    if [ ! -f "${INFER_INSTALLDIR}/infer-osx-${VERSION}/bin/infer" ]; then
      cd "${INFER_INSTALLDIR}" || exit
      (curl -sL "https://github.com/facebook/infer/releases/download/${VERSION}/infer-osx-${VERSION}.tar.xz" | tar -xvJ) || \
        echo "installed=false" >> "${GITHUB_OUTPUT}"
    fi
    if [ -f "${INFER_INSTALLDIR}/infer-osx-${VERSION}/bin/infer" ]; then
      echo "${INFER_INSTALLDIR}/infer-osx-${VERSION}/bin" >>"${GITHUB_PATH}"
      echo "installed=true" >> "${GITHUB_OUTPUT}"
    fi
}

install_linux() {
    if [ ! -f "${INFER_INSTALLDIR}/infer-linux64-${VERSION}/bin/infer" ]; then
      cd "${INFER_INSTALLDIR}" || exit
      curl -sL "https://github.com/facebook/infer/releases/download/${VERSION}/infer-linux64-${VERSION}.tar.xz" | tar -xJ
    fi
    echo "${INFER_INSTALLDIR}/infer-linux64-${VERSION}/bin" >>"${GITHUB_PATH}"
    echo "installed=true" >> "${GITHUB_OUTPUT}"
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
