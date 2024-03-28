#!/bin/bash
set -euox pipefail

VERSION="${INPUTS_INFER_VERSION:-latest}"

source "${GITHUB_ACTION_PATH}/utils.sh"

INFER_TEMPDIR="${INPUTS_INFER_TEMPDIR:-}"
if [ -z "${INFER_TEMPDIR}" ]; then
  if [ -n "${RUNNER_TEMP}" ]; then
    INFER_TEMPDIR="${RUNNER_TEMP}"
  else
    INFER_TEMPDIR="$(mktemp -d)"
  fi
fi

INFER_INSTALLDIR="${RUNNER_TOOL_CACHE:-${INFER_TEMPDIR}}/infer"

mkdir -p "${INFER_INSTALLDIR}"

if [ "${VERSION}" == 'latest' ] ; then
  VERSION=$(curl --retry 3 -s https://api.github.com/repos/facebook/infer/releases/latest | grep "tag_name" | grep -o "v[0-9.]*")
  if [ -z "${VERSION}" ]; then
    echo "::error:: Failed to get latest version from GitHub API"
    exit 1
  fi
fi

install_osx() {
    if [ ! -f "${INFER_INSTALLDIR}/${VERSION}/infer/bin/infer" ]; then
      cd "${INFER_INSTALLDIR}/" || exit
      curl -sL "https://github.com/facebook/infer/archive/refs/tags/${VERSION}.tar.gz" | tar -zxv
      sh "./infer-${VERSION}/build-infer.sh" clang
    fi
    echo "${INFER_INSTALLDIR}/infer-${VERSION}/infer/bin" >>"${GITHUB_PATH}"
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
echo "version=${VERSION}" >> "${GITHUB_OUTPUT}"
echo '::endgroup::'
