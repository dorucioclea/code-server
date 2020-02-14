#!/usr/bin/env bash

set -euo pipefail

function package() {
  local target
  target=$(uname | tr '[:upper:]' '[:lower:]')
  if [[ $target == "linux" ]]; then
    # Alpine's ldd doesn't have a version flag but if you use an invalid flag
    # (like --version) it outputs the version to stderr and exits with 1.
    local ldd_output
    ldd_output=$(ldd --version 2>&1 || true)
    if echo "$ldd_output" | grep -iq musl; then
      target="alpine"
    fi
  fi

  local arch
  arch="$(uname -m)"

  echo -n "Creating release..."

  cp "$(command -v node)" ./build
  cp README.md ./build
  cp LICENSE ./build
  cp ./lib/vscode/ThirdPartyNotices.txt ./build
  cp ./scripts/code-server.sh ./build/code-server

  local archive_name="code-server-$code_server_version-$target-$arch"
  mkdir -p release

  mv ./build ./code-server
  local ext
  if [[ $target == "linux" ]] ; then
    ext=".tar.gz"
    tar -czf "release/$archive_name$ext" ./code-server
  else
    ext=".zip"
    zip -r "release/$archive_name$ext" ./code-server
  fi
  mv ./code-server ./build

  echo "done ($archive_name)"

  mkdir -p "./release-upload/$code_server_version"
  cp "./release/$archive_name$ext" "./release-upload/$code_server_version/$target-$arch.tar.gz"
  mkdir -p "./release-upload/latest"
  cp "./release/$archive_name$ext" "./release-upload/latest/$target-$arch.tar.gz"
}

# This script assumes that yarn has already ran.
function build() {
  export VERSION=$code_server_version

  # Always minify and package on tags since that's when releases are pushed.
  if [[ -n ${DRONE_TAG:-} || -n ${TRAVIS_TAG:-} ]] ; then
    export MINIFY="true"
  fi

  yarn build
}

function main() {
  cd "$(dirname "${0}")/.."

  local code_server_version=${VERSION:-${TRAVIS_TAG:-${DRONE_TAG:-}}}
  if [[ -z $code_server_version ]] ; then
    code_server_version=$(grep version ./package.json | head -1 | awk -F: '{ print $2 }' | sed 's/[",]//g' | tr -d '[:space:]')
  fi

  build

  if [[ -n ${DRONE_TAG:-} || -n ${TRAVIS_TAG:-} ]] ; then
    package
  fi
}

main "$@"
