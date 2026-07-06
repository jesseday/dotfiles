# Lists TODO items grouped by their text content
# Usage: list-todos [options] [name]
# Run `list-todos --help` for all options

function list-todos() {
  bunx zx ~/me/scripts/list-todos.mjs "$@"
}

alias lt="list-todos"
