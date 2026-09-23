#!/usr/bin/env bash
# Link this repo's config into place. Safe to re-run: existing correct
# links are left alone, and anything else already at a target is skipped
# with a warning rather than overwritten.
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd -P)"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

ok()   { printf '  \033[32mok\033[0m    %s\n' "$*"; }
add()  { printf '  \033[36madded\033[0m %s\n' "$*"; }
warn() { printf '  \033[33mwarn\033[0m  %s\n' "$*"; }

# link <src> <dst>
link() {
  local src=$1 dst=$2
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    ok "$dst"
  elif [ -e "$dst" ] || [ -L "$dst" ]; then
    warn "$dst already exists, skipping"
  else
    ln -s "$src" "$dst"
    add "$dst -> $src"
  fi
}

# link_or_backup <src> <dst>: like link, but a real file at dst (e.g. a
# default config the app created on first launch) is backed up, not skipped.
link_or_backup() {
  local src=$1 dst=$2 backup
  if [ -f "$dst" ] && [ ! -L "$dst" ]; then
    backup="$dst.bak-$(date +%Y%m%d-%H%M%S)"
    mv "$dst" "$backup"
    add "backed up $dst to $backup"
  fi
  link "$src" "$dst"
}

# link_each <src_dir> <dst_dir> <glob>: link each matching entry of src_dir
# into dst_dir. If dst_dir is itself a link to src_dir, there's nothing to do.
link_each() {
  local src_dir=$1 dst_dir=$2 glob=$3 entry
  if [ "$(cd "$dst_dir" 2>/dev/null && pwd -P)" = "$src_dir" ]; then
    ok "$dst_dir (linked to $src_dir)"
    return
  fi
  mkdir -p "$dst_dir"
  for entry in "$src_dir"/$glob; do
    [ -e "$entry" ] || continue
    link "${entry%/}" "$dst_dir/$(basename "$entry")"
  done
}

echo "Requirements"
[ -d "$HOME/.oh-my-zsh" ] && ok "oh-my-zsh" || warn "oh-my-zsh not installed"
for cmd in git rg nvim bun fzf jq yq golangci-lint; do
  command -v "$cmd" >/dev/null && ok "$cmd" || warn "$cmd not installed"
done
if command -v mdformat >/dev/null; then
  ok "mdformat"
else
  warn "mdformat not installed, run:"
  echo "        uv tool install mdformat --with mdformat-frontmatter --with mdformat-config \\"
  echo "          --with mdformat-gfm --with mdformat-gofmt --with mdformat-shfmt \\"
  echo "          --with mdformat-tables --with mdformat-toc --with taplo --with wcwidth"
fi

echo "zsh plugins"
link_each "$REPO/zsh-plugins" "$ZSH_CUSTOM/plugins" '*/'

echo "zsh themes"
link_each "$REPO/zsh-themes" "$ZSH_CUSTOM/themes" '*.zsh-theme'

echo "Claude skills"
link_each "$REPO/skills" "$HOME/.claude/skills" '*/'

echo "Zed"
mkdir -p "$HOME/.config/zed"
for f in settings.json keymap.json gci-lsp.sh; do
  link_or_backup "$REPO/zed/$f" "$HOME/.config/zed/$f"
done

echo "Ghostty"
ghostty_dir="$HOME/Library/Application Support/com.mitchellh.ghostty"
mkdir -p "$ghostty_dir"
link_or_backup "$REPO/ghostty/config.ghostty" "$ghostty_dir/config.ghostty"

echo "~/.zshrc"
zshrc_line="source $REPO/config/.zshrc.local"
if grep -q 'config/\.zshrc\.local' "$HOME/.zshrc" 2>/dev/null; then
  ok "sources .zshrc.local"
else
  printf '\n%s\n' "$zshrc_line" >> "$HOME/.zshrc"
  add "$zshrc_line"
fi

# plugins=(...) must be set before oh-my-zsh loads, so it can't live in
# .zshrc.local. Report what's missing rather than editing it.
enabled="$(grep -E '^[[:space:]]*plugins=\(' "$HOME/.zshrc" 2>/dev/null || true)"
for dir in "$REPO"/zsh-plugins/*/; do
  name="$(basename "$dir")"
  if [[ " ${enabled//[()=]/ } " == *" $name "* ]]; then
    ok "plugin $name enabled"
  else
    warn "plugin $name not in plugins=(...) in ~/.zshrc"
  fi
done

echo "~/.gitconfig"
gitconfig_path="$REPO/config/.gitconfig.local"
if git config --global --get-all include.path 2>/dev/null | grep -q 'config/\.gitconfig\.local'; then
  ok "includes .gitconfig.local"
else
  git config --global --add include.path "$gitconfig_path"
  add "include.path = $gitconfig_path"
fi
