# Search Obsidian notes for #retro tags within a date range
# Usage: retro [--from YYYY-MM-DD] [--to YYYY-MM-DD]
# Defaults: from = 1 month ago, to = today
# Examples:
#   retro                        # last month
#   retro --from 2026-03-01      # since March 1
#   retro --from 2026-02-01 --to 2026-02-28  # February only

function retro() {
  bunx zx ~/me/scripts/retro.mjs "$@"
}
