# Lists TODO items grouped by their text content
# Usage: list-todos [name]
# Examples:
#   list-todos          # searches for TODO(jesse)
#   list-todos DIST-6744
#   list-todos jesseday

function list-todos() {
  local NAME="${1:-jesse}"

  # Use ripgrep to find all TODO(NAME) items, extract file and todo text
  # Format: lowercase_key|original_text|file
  rg "TODO\($NAME\):?\s*(.*)" --no-heading -o -r '$1' --with-filename --line-number \
    | while IFS=: read -r file line todo_text; do
        # Normalize whitespace and trim
        todo_text=$(echo "$todo_text" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        # Create lowercase key for case-insensitive grouping, strip trailing punctuation
        todo_lower=$(echo "$todo_text" | tr '[:upper:]' '[:lower:]' | sed 's/[.?!,;:]*$//')
        echo "${todo_lower}|${todo_text}|${file}:${line}"
      done \
    | sort -t'|' -k1,1 \
    | awk -F'|' '
      {
        key = $1
        todo = $2
        file = $3
        if (key != prev_key) {
          if (prev_key != "") print ""
          print "## " todo
          prev_key = key
        }
        print "- " file
      }
    '
}

alias lt="list-todos"
