#!/bin/bash
# golangci-lint language-server wrapper for Zed.
#
# Why this exists: the golangci-lint-langserver matches issues to the open file
# by a path relative to the nearest go.mod. In this go.work monorepo the repo's
# .golangci.yml lives at the workspace root, so golangci-lint's default
# `relative-path-mode: cfg` reports paths relative to that root (e.g.
# admin-reports/pkg/spec/foo.go), which never matches the module-relative path
# the langserver expects (pkg/spec/foo.go) -> diagnostics silently dropped.
#
# Fix: derive a temp config from whatever .golangci.yml golangci-lint would
# normally discover, override `run.relative-path-mode: gomod` (config-only; no
# CLI flag exists), and enable `exhaustive`. Nothing is committed and the temp
# config is regenerated from the live config on every run, so it stays in sync.
#
# golangci-lint-langserver runs us with cwd = the module root and appends the
# target directory as the final argument, so config discovery works from "$@".
set -euo pipefail

GCL=/opt/homebrew/bin/golangci-lint
YQ=/opt/homebrew/bin/yq

base="$("$GCL" config path 2>/dev/null || true)"

# One stable temp file per discovered config, overwritten each run (no leak,
# survives the exec below).
key="$(printf '%s' "${base:-noconfig}" | /usr/bin/shasum | cut -c1-12)"
cfg="${TMPDIR:-/tmp}/gci-lsp-${key}.yml"

if [[ -n "$base" && -f "$base" ]]; then
  "$YQ" '.run.relative-path-mode = "gomod"
         | .linters.enable = (((.linters.enable // []) + ["exhaustive"]) | unique)' \
    "$base" >"$cfg"
else
  printf 'version: "2"\nrun:\n  relative-path-mode: gomod\nlinters:\n  enable:\n    - exhaustive\n' >"$cfg"
fi

exec "$GCL" run \
  --allow-parallel-runners \
  --config "$cfg" \
  --output.json.path stdout \
  --show-stats=false \
  --output.text.path= \
  "$@"
