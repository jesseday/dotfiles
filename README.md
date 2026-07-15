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
# Clone the repository
git clone git@github.com:jesseday/dotfiles.git ~/me/public
cd ~/me/public

# install the git del alias
git config --global alias.del '!'"$HOME/me/public/scripts/git-delete-branches.sh"

# Symlink zsh-plugins
ln -s ~/me/public/zsh-plugins ~/.oh-my-zsh/custom/plugins

# Symlink claude skills
ln -s ~/me/public/skills ~/.claude/skills
```
