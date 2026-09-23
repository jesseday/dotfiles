# Lists TODO items grouped by their text content
# Usage: list-todos [options] [name]
# Run `list-todos --help` for all options

# Resolve the script next to this plugin (works through a symlink).
typeset -g _list_todos_script="${0:A:h}/list-todos.mjs"

function list-todos() {
  bunx zx "$_list_todos_script" "$@"
}

alias lt="list-todos"
