#!/bin/bash
set -euo pipefail

VERSION_STR="${INPUTS_INFER_VERSION:-latest}"

resolve_version() {
    AUTH_OPTION=()
    if [ -n "${INPUTS_GITHUB_TOKEN:-}" ]; then
      AUTH_OPTION=(--header "Authorization: Bearer ${INPUTS_GITHUB_TOKEN:-}")
    else
      if [ "${GITHUB_SERVER_URL}" == "https://github.com" ]; then
        AUTH_OPTION=(--header "Authorization: Bearer ${GITHUB_TOKEN:-}")
      fi
    fi
    VERSION_STR=$(curl --retry 3 "${AUTH_OPTION[@]}" -s https://api.github.com/repos/facebook/infer/releases/latest | grep "tag_name" | grep -o "v[0-9.]*" || true)
}

if [ "${VERSION_STR}" == 'latest' ] ; then
  echo '::group::📖 Resolve infer version ...'
  resolve_version
  echo '::endgroup::'
fi

VERSION_NUMBER="${VERSION_STR##v}"
VERSION="v${VERSION_NUMBER}"
echo "version=${VERSION}" >> "${GITHUB_OUTPUT}"
