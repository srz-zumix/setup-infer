#!/bin/bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TEST_DIR=$(mktemp -d)
trap 'rm -rf "${TEST_DIR}"' EXIT
mkdir "${TEST_DIR}/bin"

cat > "${TEST_DIR}/bin/curl" <<'EOF'
#!/bin/bash
set -euo pipefail
printf '%s\n' "$@" > "${TEST_CURL_ARGS}"
printf '%s' "${TEST_RELEASE_RESPONSE}"
exit "${TEST_CURL_EXIT:-0}"
EOF
chmod +x "${TEST_DIR}/bin/curl"

export PATH="${TEST_DIR}/bin:${PATH}"
export TEST_CURL_ARGS="${TEST_DIR}/curl-args"
export GITHUB_OUTPUT="${TEST_DIR}/output"
export INPUTS_GITHUB_TOKEN=""

resolve() {
  : > "${GITHUB_OUTPUT}"
  rm -f "${TEST_CURL_ARGS}"
  bash "${ROOT}/resolve.sh" > "${TEST_DIR}/log" 2>&1
}

assert_version() {
  if ! resolve; then
    cat "${TEST_DIR}/log" >&2
    exit 1
  fi
  diff -u <(printf 'version=%s\n' "$1") "${GITHUB_OUTPUT}"
}

assert_failure() {
  if resolve; then
    echo "Expected version resolution to fail." >&2
    exit 1
  fi
  test ! -s "${GITHUB_OUTPUT}"
  grep -Fq "::error::$1" "${TEST_DIR}/log"
}

export INPUTS_INFER_VERSION=latest
export TEST_RELEASE_RESPONSE='{"tag_name":"v1.3.0","name":"Infer v1.3.0","body":"Previous version v1.2.0"}'
assert_version v1.3.0
for arg in --fail --silent --show-error --location https://api.github.com/repos/meta/infer/releases/latest; do
  grep -Fxq -- "${arg}" "${TEST_CURL_ARGS}"
done
if grep -Fq Authorization "${TEST_CURL_ARGS}"; then
  echo "Unexpected authorization header without a token." >&2
  exit 1
fi

unset INPUTS_INFER_VERSION
assert_version v1.3.0

export INPUTS_INFER_VERSION=latest
export INPUTS_GITHUB_TOKEN=test-token
assert_version v1.3.0
grep -Fq 'Authorization: ' "${TEST_CURL_ARGS}"
grep -Fq test-token "${TEST_CURL_ARGS}"
export INPUTS_GITHUB_TOKEN=""

export TEST_RELEASE_RESPONSE='{
  "tag_name": "v1.2.0",
  "body": "Release v1.2.0"
}'
assert_version v1.2.0

for response in '{}' '{"tag_name":null}' '{"tag_name":""}' '{"tag_name":123}' '{"tag_name":"v"}' '{"tag_name":"v1.2.0 invalid"}' 'not JSON' '{"message":"Moved Permanently"}'; do
  export TEST_RELEASE_RESPONSE="${response}"
  assert_failure 'Failed to resolve a valid Infer version'
done

export TEST_CURL_EXIT=22
export TEST_RELEASE_RESPONSE='{"message":"API rate limit exceeded"}'
assert_failure 'Failed to fetch the latest Infer release'
unset TEST_CURL_EXIT

for version in v1.0.0 1.2.0; do
  export INPUTS_INFER_VERSION="${version}"
  assert_version "v${version#v}"
  test ! -e "${TEST_CURL_ARGS}"
done

export INPUTS_INFER_VERSION=v
assert_failure 'Failed to resolve a non-empty infer version'
test ! -e "${TEST_CURL_ARGS}"

echo "Resolver tests passed."
