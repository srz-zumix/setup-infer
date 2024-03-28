#!/bin/bash
set -euox pipefail

VERSION="${INPUTS_INFER_VERSION:-latest}"

if [ "${VERSION}" == 'latest' ] ; then
  VERSION=$(curl --retry 3 -s https://api.github.com/repos/facebook/infer/releases/latest | grep "tag_name" | grep -o "v[0-9.]*" || true)
  if [ -z "${VERSION}" ]; then
    echo "::error:: Failed to get latest version from GitHub API"
    exit 1
  fi
fi

echo "version=${VERSION}" >> "${GITHUB_OUTPUT}"
