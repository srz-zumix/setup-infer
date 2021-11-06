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

install_osx() {
    brew install infer
}

install_linux() {
    cd "${TEMP}"
    curl -sL "https://github.com/facebook/infer/releases/download/${INFER_VERSION}/infer-linux64-${INFER_VERSION}.tar.xz" | tar xvJ
    echo "${TEMP}/infer-linux64-${INFER_VERSION}/bin" >>"${GITHUB_PATH}"
}

install_windows() {
    echo "windows is not supported"
    exit 1
}

install() {
    if is_osx; then
        install_osx()
    fi
    if is_linux; then
        install_linux()
    fi
    if is_windows; then
        install_windows()
    fi
}
echo '::group:::blue_book: Installing infer ...'
install()
echo '::endgroup::'
