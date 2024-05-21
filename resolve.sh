#!/bin/bash
set -euo pipefail

VERSION_STR="${INPUTS_INFER_VERSION:-latest}"

resolve_version() {
    AUTH_OPTION=()
    if [ -n "${INPUTS_GITHUB_TOKEN:-}" ]; then
      AUTH_OPTION=(--header "Authorization: Bearer ${INPUTS_GITHUB_TOKEN:-}")
    fi
    VERSION_STR=$(curl --retry 3 "${AUTH_OPTION[@]}" -s https://api.github.com/repos/facebook/infer/releases/latest | grep "tag_name" | grep -o "v[0-9.]*" || true)
}

if [ "${VERSION_STR}" == 'latest' ] ; then
  echo '::group::📖 Resolve infer version ...'
  resolve_version
  echo "Resolved infer version: ${VERSION_STR}"
  echo '::endgroup::'
fi

VERSION_NUMBER="${VERSION_STR##v}"
VERSION="v${VERSION_NUMBER}"
echo "version=${VERSION}" >> "${GITHUB_OUTPUT}"
