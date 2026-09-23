# Oh My ZSH Plugins

Custom oh-my-zsh plugins, kept here for version control. Each plugin is
a directory holding `<name>.plugin.zsh` plus any script it runs.

To install one, symlink its directory into `~/.oh-my-zsh/custom/plugins`
and add its name to `plugins=(...)` in `~/.zshrc`.

For example

```bash
ln -s /path/to/this-repo/zsh-plugins/list-todos ~/.oh-my-zsh/custom/plugins/list-todos
```

```zsh
plugins=(git list-todos)
```
