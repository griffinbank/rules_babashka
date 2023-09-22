#!/usr/bin/env bash

set -e

# From stackoverflow.com
SOURCE="${BASH_SOURCE[0]}"
# Resolve $SOURCE until the file is no longer a symlink
while [ -h "${SOURCE}" ]; do
  DIR="$(cd -P "$(dirname "${SOURCE}" )" >/dev/null && pwd)"
  SOURCE="$(readlink "${SOURCE}")"
  # if $SOURCE was a relative symlink, we need to resolve it relative to the
  # path where the symlink file was located.
  [[ ${SOURCE} != /* ]] && SOURCE="${DIR}/${SOURCE}"
done
SCRIPT_DIR="$(cd -P "$( dirname "${SOURCE}" )" >/dev/null && pwd)"
RAW_BINARY_PATH="$(realpath "${SCRIPT_DIR}/../%{raw_binary}")"

export CLJ_CONFIG="%{repo_root}/.clojure"
export DEPS_CLJ_TOOLS_DIR="%{repo_root}/.deps.clj/ClojureTools"
export GITLIBS="%{repo_root}/.gitlibs"

"${RAW_BINARY_PATH}" "${@}"
