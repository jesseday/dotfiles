# Configuration files

Updated version of laptop configuration. To use them, symlink
scripts and rc files as needed. See README files in subdirectories for
more details.

## Requirements

This is not an exhaustive list

- [oh-my-zsh](https://ohmyz.sh/)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [git](https://formulae.brew.sh/formula/git)
- [nvim](https://github.com/jesseday/kickstart.nvim)
- [bun](https://bun.com/)
- [fzf](https://github.com/junegunn/fzf)

## Installing

Assuming the above are already installed. Read their documentation for
installation instructions.

```bash
git clone git@github.com:jesseday/dotfiles.git ~/me/public
~/me/public/setup.sh
```

`setup.sh` is safe to re-run. It:

- Symlinks each zsh plugin, theme, and Claude skill into place,
  skipping anything that already exists.
- Adds `source .../config/.zshrc.local` to `~/.zshrc` if missing.
  `.zshrc.local` puts `bin/` on PATH and sources the aliases.
- Adds `config/.gitconfig.local` to `~/.gitconfig` as an include if missing.
- Warns about missing requirements and about plugins not listed in
  `plugins=(...)` in `~/.zshrc`. Add those by hand, since `plugins`
  has to be set before oh-my-zsh loads.
