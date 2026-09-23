# Strip non-JSON lines from a JSONL file
# Usage: clean-jsonl <input.json>
# Output: <input>-clean.json in the same directory

# Resolve the script next to this plugin (works through a symlink).
typeset -g _clean_jsonl_script="${0:A:h}/clean-jsonl.mjs"

function clean-jsonl() {
  bunx zx "$_clean_jsonl_script" "$@"
}
