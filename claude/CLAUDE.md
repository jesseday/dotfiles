# Local rules

## Plan review

When I ask for a plan, present it and stop. Do not start implementing any step — including "step 1" — until I explicitly approve the plan. Wait for my review of each step before moving to the next.

## Response style

Keep responses concise but not terse. Answer the question, give the reasoning briefly, and stop. A short paragraph plus a small example or a few bullets is usually the right size. Avoid: long preambles, recaps of what the user just said, exhaustive tradeoff lists, multi-section essays with headers. Avoid the opposite extreme too — one-line answers that drop useful context. Expand to long form only when the user asks for it or the topic genuinely needs it.

## File paths

When referring to files, always write the path starting from the root of the repo (e.g. `src/server/auth/session.go`), not relative to the current working directory or as a bare filename.

## GitHub access

Always use the GitHub MCP tools (`mcp__github__*`) for GitHub operations — viewing PRs, issues, comments, files, reviews, etc. Do not use `gh` via Bash for these. Load schemas via `ToolSearch` with `select:mcp__github__<name>` as needed.

## Date Command

When asked for today's date, run the `date` command to get the current date rather than relying on any cached or provided date information.
