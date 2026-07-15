#!/usr/bin/env bash
# Interactively select local git branches with fzf and delete them in bulk.
#
# Shows a multi-select fzf list of local branches (with a preview of each
# branch's last few commits). Selected branches are force-deleted with
# `git branch -D`. The current branch and the protected branches (master,
# main) are never shown and can never be deleted.
#
# Usage:
#   git delete-branches            # pick branches, confirm, delete
#   git delete-branches -y         # skip the confirmation prompt
#   git delete-branches -h         # show this help
#
# Install as a git alias:
#   git config --global alias.delete-branches '!/path/to/this-repo/scripts/git-delete-branches.sh'

set -euo pipefail

assume_yes=false

while getopts ":yh" opt; do
    case "$opt" in
        y) assume_yes=true ;;
        h)
            sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        \?)
            echo "Unknown option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

if ! command -v fzf >/dev/null 2>&1; then
    echo "error: fzf is not installed or not on PATH" >&2
    exit 1
fi

if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "error: not inside a git repository" >&2
    exit 1
fi

# Branches we must never delete: the current branch plus master/main.
current="$(git symbolic-ref --quiet --short HEAD || true)"

protected_re='^(master|main)$'

# List local branch names, dropping the current branch and protected ones.
candidates="$(
    git for-each-ref --format='%(refname:short)' refs/heads/ \
        | grep -vE "$protected_re" \
        | { [ -n "$current" ] && grep -vxF "$current" || cat; }
)"

if [ -z "$candidates" ]; then
    echo "No deletable branches (only the current/protected branches exist)."
    exit 0
fi

# Let the user pick branches to delete.
selected="$(
    printf '%s\n' "$candidates" \
        | fzf --multi \
              --prompt='delete branches> ' \
              --header='TAB to select, ENTER to confirm, ESC to cancel' \
              --preview='git log -n 3 --color=always --stat {}' \
        || true
)"

if [ -z "$selected" ]; then
    echo "Nothing selected; no branches deleted."
    exit 0
fi

echo "Branches to delete:"
printf '  %s\n' $selected

if [ "$assume_yes" = false ]; then
    printf 'Delete these branches? [y/N] '
    read -r reply
    case "$reply" in
        [yY] | [yY][eE][sS]) ;;
        *)
            echo "Aborted."
            exit 0
            ;;
    esac
fi

printf '%s\n' $selected | xargs -n 1 git branch -D
