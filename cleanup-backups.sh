#!/usr/bin/env bash
# List the config backups left by setup.sh (and earlier manual migrations),
# show whether each still matches the repo copy, and delete them on confirm.
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd -P)"

# "<config dir>|<repo dir it's linked from>"
PAIRS=(
  "$HOME/.config/zed|$REPO/zed"
  "$HOME/Library/Application Support/com.mitchellh.ghostty|$REPO/ghostty"
)

backups=()
for pair in "${PAIRS[@]}"; do
  dir="${pair%%|*}" repo_dir="${pair#*|}"
  [ -d "$dir" ] || continue
  while IFS= read -r -d '' f; do
    name="$(basename "$f")"
    repo_file="$repo_dir/${name%%.bak-*}"
    if [ ! -e "$repo_file" ]; then
      status='\033[33mno repo copy\033[0m'
    elif cmp -s "$f" "$repo_file"; then
      status='\033[32msame as repo\033[0m'
    else
      status="\033[33mdiffers\033[0m  (diff \"$f\" \"$repo_file\")"
    fi
    printf "  %s\n    $status\n" "$f"
    backups+=("$f")
  done < <(find "$dir" -maxdepth 2 -type f \( -name '*.bak-*' -o -path '*/backup-*/*' \) -print0)
done

if [ ${#backups[@]} -eq 0 ]; then
  echo "No backups found."
  exit 0
fi

printf 'Delete these %d backups? [y/N] ' "${#backups[@]}"
read -r answer
[ "$answer" = y ] || [ "$answer" = Y ] || { echo "Nothing deleted."; exit 0; }

rm -- "${backups[@]}"
# Remove backup-* directories left empty.
for pair in "${PAIRS[@]}"; do
  dir="${pair%%|*}"
  [ -d "$dir" ] && find "$dir" -maxdepth 1 -type d -name 'backup-*' -empty -delete
done
echo "Deleted ${#backups[@]} backups."
