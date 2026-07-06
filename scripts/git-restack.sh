#!/usr/bin/env bash
# Rebase the current branch's base onto origin/main (or master), then
# rebase the current branch onto that base.
#
# Usage:
#   git restack                       # auto-detect base + trunk
#   git restack -b some/base          # override base
#   git restack -t master             # override trunk
#   git restack -b some/base -t main  # both
#   git restack -n                    # no intermediate base; rebase head onto trunk
#   git restack -y                    # skip the confirmation prompt
#
# Always prompts to confirm head/base/trunk before acting, unless -y is passed.
#
# Install as a git alias:
#   git config --global alias.restack '!~/me/scripts/git-restack.sh'

set -euo pipefail

base=""
trunk=""
assume_yes=0
no_base=0

usage() {
    sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'
    exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -b|--base)  base=$2; shift 2 ;;
        -t|--trunk) trunk=$2; shift 2 ;;
        -n|--no-base) no_base=1; shift ;;
        -y|--yes)   assume_yes=1; shift ;;
        -h|--help)  usage 0 ;;
        *) echo "error: unknown arg: $1" >&2; usage 1 ;;
    esac
done

head=$(git symbolic-ref --short HEAD)

# Detect trunk if not provided
if [[ -z "$trunk" ]]; then
    if git show-ref --verify --quiet refs/remotes/origin/main; then
        trunk=main
    elif git show-ref --verify --quiet refs/remotes/origin/master; then
        trunk=master
    else
        echo "error: neither origin/main nor origin/master exists; pass --trunk" >&2
        exit 1
    fi
fi

# Detect base: of all local branches whose tip is an ancestor of HEAD
# (excluding HEAD itself and trunk), pick the one closest to HEAD.
detect_base() {
    git for-each-ref --format='%(refname:short)' refs/heads/ \
    | while read -r b; do
        [[ "$b" == "$head" || "$b" == "$trunk" ]] && continue
        if git merge-base --is-ancestor "$b" HEAD 2>/dev/null; then
            dist=$(git rev-list --count "$b..HEAD")
            printf '%s\t%s\n' "$dist" "$b"
        fi
    done | sort -n | head -1 | cut -f2
}

if [[ "$head" == "$trunk" ]]; then
    echo "error: already on trunk ($trunk); nothing to restack" >&2
    exit 1
fi

if [[ $no_base -eq 0 && -z "$base" ]]; then
    base=$(detect_base || true)
fi

# If head is itself the base (e.g. running from a deploy branch), drop base
# and just rebase head onto trunk.
if [[ "$head" == "$base" ]]; then
    base=""
fi

if [[ $no_base -eq 1 ]]; then
    base=""
fi

if [[ -n "$base" ]]; then
    echo "==> head=$head  base=$base  trunk=$trunk"
else
    echo "==> head=$head  trunk=$trunk  (no intermediate base)"
fi
if [[ $assume_yes -eq 0 ]]; then
    read -rp "    proceed? [Y/n] " ans
    case "$ans" in
        n|N|no|No) echo "aborted"; exit 1 ;;
    esac
fi

echo "==> fetching origin/$trunk"
git fetch origin "$trunk"

echo "==> updating $trunk"
git checkout "$trunk"
git pull --rebase origin "$trunk"

if [[ -n "$base" ]]; then
    echo "==> rebasing $base onto $trunk"
    git checkout "$base"
    git rebase "$trunk"

    echo "==> rebasing $head onto $base"
    git checkout "$head"
    git rebase "$base"
else
    echo "==> rebasing $head onto $trunk"
    git checkout "$head"
    git rebase "$trunk"
fi

echo "==> done"
