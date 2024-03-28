#!/bin/bash
set -euox pipefail

VERSION="${INPUTS_INFER_VERSION:-latest}"

resolve_version() {
  for i in {1..5}; do
    VERSION=$(curl --retry 3 -s https://api.github.com/repos/facebook/infer/releases/latest | grep "tag_name" | grep -o "v[0-9.]*" || true)
    if [ -n "${VERSION}" ]; then
      return
    fi
    echo "Attempt ${i} failed"
  done
  echo "::error:: Failed to get latest version from GitHub API"
  exit 1
}

if [ "${VERSION}" == 'latest' ] ; then
  echo '::group::📖 Resolve infer version ...'
  resolve_version
  echo '::endgroup::'
fi

echo "version=${VERSION}" >> "${GITHUB_OUTPUT}"
