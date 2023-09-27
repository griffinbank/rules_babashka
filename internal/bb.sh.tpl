#!/usr/bin/env bash

set -e

# --- begin runfiles.bash initialization v3 ---
# Copy-pasted from the Bazel Bash runfiles library v3.
set -uo pipefail; set +e; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v3 ---

export CLJ_CONFIG="%{repo_root}/.clojure"
export DEPS_CLJ_TOOLS_DIR="%{repo_root}/.deps.clj/ClojureTools"
export GITLIBS="%{repo_root}/.gitlibs"

"$(rlocation rules_babashka/bin/pkg/bb)" -Sdeps "{:mvn/local-repo \"%{repo_root}/.m2/repository\"}" "${@}"
