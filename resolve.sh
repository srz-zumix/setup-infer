#!/bin/bash
set -euo pipefail

VERSION_STR="${INPUTS_INFER_VERSION:-latest}"

resolve_version() {
  for i in {1..5}; do
    VERSION_STR=$(curl --retry 3 -s https://api.github.com/repos/facebook/infer/releases/latest | grep "tag_name" | grep -o "v[0-9.]*" || true)
    if [ -n "${VERSION_STR}" ]; then
      return
    fi
    echo "Attempt ${i} failed"
  done
  echo "::error:: Failed to get latest version from GitHub API"
  exit 1
}

if [ "${VERSION_STR}" == 'latest' ] ; then
  echo '::group::📖 Resolve infer version ...'
  resolve_version
  echo '::endgroup::'
fi

VERSION_NUMBER="${VERSION_STR##v}"
VERSION="v${VERSION_NUMBER}"
echo "version=${VERSION}" >> "${GITHUB_OUTPUT}"
