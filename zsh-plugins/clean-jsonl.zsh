# Strip non-JSON lines from a JSONL file
# Usage: clean-jsonl <input.json>
# Output: <input>-clean.json in the same directory

function clean-jsonl() {
  bunx zx ~/me/scripts/clean-jsonl.mjs "$@"
}
