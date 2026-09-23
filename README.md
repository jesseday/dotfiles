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

### Symlinks

```bash
# Clone the repository
git clone git@github.com:jesseday/dotfiles.git ~/me/public
cd ~/me/public

# Symlink each zsh plugin, then add its name to plugins=(...) in ~/.zshrc
for p in ~/me/public/zsh-plugins/*/; do
  ln -s "${p%/}" ~/.oh-my-zsh/custom/plugins/
done
ln -s ~/me/public/zsh-themes ~/.oh-my-zsh/custom/themes

# Symlink claude skills
ln -s ~/me/public/skills ~/.claude/skills
```

### Source .zshrc.local

- `.zshrc.local` will source aliases and other config.
- In `~/.zshrc` add the following line

```bash
source ~/me/public/config/.zshrc.local
```

### Include .gitconfig.local

- in `~/.gitconfig`, include `.gitconfig.local`

```
[include]
  path = ~/me/public/config/.gitconfig.local
```
