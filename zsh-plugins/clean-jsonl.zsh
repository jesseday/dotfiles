# Strip non-JSON lines from a JSONL file
# Usage: clean-jsonl <input.json>
# Output: <input>-clean.json in the same directory

# Resolve the script from this plugin's repo root (works through a symlink).
typeset -g _clean_jsonl_script="${0:A:h:h}/scripts/clean-jsonl.mjs"

function clean-jsonl() {
  bunx zx "$_clean_jsonl_script" "$@"
}
