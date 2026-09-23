# Run `golangci-lint fmt` from anywhere in a Go repo, locating .golangci.yml
# at the git repo root (handles go.work multi-module layouts, where you'd
# otherwise type --config=../.golangci.yml).
#
# Usage: gcfmt [paths...]
#
#   gcfmt                 # format the whole repo (./...)
#   gcfmt ./pkg/...       # format a package tree
#   gcfmt a.go b.go       # format specific files
#   gcfmt -h              # golangci-lint fmt's help (flags are passed through)
function gcfmt() {
    local root config
    root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
        echo "gcfmt: not in a git repo" >&2
        return 1
    }
    config="$root/.golangci.yml"
    golangci-lint fmt --config="$config" "${@:-./...}"
}
