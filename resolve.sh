#!/bin/bash
set -euo pipefail

VERSION_STR="${INPUTS_INFER_VERSION:-latest}"

resolve_version() {
    AUTH_OPTION=()
    if [ -n "${INPUTS_GITHUB_TOKEN:-}" ]; then
      AUTH_OPTION=(--header "Authorization: Bearer ${INPUTS_GITHUB_TOKEN:-}")
    fi
    local release
    if ! release=$(curl --retry 3 "${AUTH_OPTION[@]}" --fail --silent --show-error --location https://api.github.com/repos/meta/infer/releases/latest); then
      echo "::error::Failed to fetch the latest Infer release." >&2
      return 1
    fi
    if ! VERSION_STR=$(jq -er '.tag_name | strings | select(test("^v[0-9]+\\.[0-9]+\\.[0-9]+$"))' <<< "${release}"); then
      echo "::error::Failed to resolve a valid Infer version from the latest release." >&2
      return 1
    fi
}

if [ "${VERSION_STR}" == 'latest' ] ; then
  echo '::group::📖 Resolve infer version ...'
  resolve_version
  echo "Resolved infer version: ${VERSION_STR}"
  echo '::endgroup::'
fi

VERSION_NUMBER="${VERSION_STR##v}"
if [ -z "${VERSION_NUMBER}" ]; then
  echo "::error::Failed to resolve a non-empty infer version." >&2
  exit 1
fi

VERSION="v${VERSION_NUMBER}"
echo "version=${VERSION}" >> "${GITHUB_OUTPUT}"
