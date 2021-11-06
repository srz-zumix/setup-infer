#!/bin/bash

VERSION="${INFER_VERSION:-latest}"

source "${GITHUB_ACTION_PATH}/utils.sh"

TEMP="${INFER_TEMPDIR}"
if [ -z "${TEMP}" ]; then
  if [ -n "${RUNNER_TEMP}" ]; then
    TEMP="${RUNNER_TEMP}"
  else
    TEMP="$(mktemp -d)"
  fi
fi

if [ "${VERSION}" == 'latest' ] ; then
  VERSION=$(curl -s https://api.github.com/repos/facebook/infer/releases/latest | grep "tag_name" | grep -o "v[0-9.]*")
fi

install_osx() {
    brew install infer
}

install_linux() {
    cd "${TEMP}"
    curl -sL "https://github.com/facebook/infer/releases/download/${VERSION}/infer-linux64-${VERSION}.tar.xz" | tar xvJ
    echo "${TEMP}/infer-linux64-${VERSION}/bin" >>"${GITHUB_PATH}"
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
echo '::group:::blue_book: Installing infer ...'
install
echo '::endgroup::'
