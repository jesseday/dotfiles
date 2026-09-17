# Local rules

## Plan review

When I ask for a plan, present it and stop. Do not start implementing any step —
including "step 1" — until I explicitly approve the plan. Wait for my review of
each step before moving to the next.

## Response style

Keep responses concise. Simple, direct questions can be answered simply and
directly. When a question is more open ended, answer the question, give the
reasoning briefly, and stop. A short paragraph plus a small example or a few
bullets is usually the right size. Avoid: long preambles, recaps of what the
user just said, exhaustive tradeoff lists, multi-section essays with headers.

## Code comments

Write a comment only when a competent reader would otherwise misunderstand the
code or change it wrongly. Put in it what the code can't say: invariants the
types don't enforce, where a magic number came from, why the non-obvious
approach beat the obvious one, gotchas and ordering requirements, and contracts
with callers or other services that aren't visible here.

Lead with that fact — one to three lines, plain statements, no em-dash
connectors or hedging. State each idea once, at its best home. Keep motivation
and history (tickets, "we also considered", "so the later refactor…") in the PR
or devlog. If a comment exists to explain what an identifier should have said,
rename the identifier and drop the comment.

## File paths

When referring to files, always write the path starting from the root of the
repo (e.g. `services/districts/rostering/admins.go`), not relative to the
current working directory or as a bare filename.

## GitHub access

Always use the GitHub MCP tools (`mcp__github__*`) for GitHub operations —
viewing PRs, issues, comments, files, reviews, etc. Do not use `gh` via Bash for
these. Load schemas via `ToolSearch` with `select:mcp__github__<name>` as
needed.

## Notes vault

Personal working notes — daily/session notes, ticket work, the decision log,
support items, and questions — live in the Obsidian vault at
`~/Documents/notes/`. That absolute path is the only location. The vault is
**not** symlinked into any repo, so never write notes inside a repo working
tree. Write vault files with the Write tool, not Bash — see the skill. The
conventions for all of it live in the **`khan-notes` skill**; invoke it whenever
summarizing a session, doing or logging ticket work, recording a decision,
triaging a support issue, writing a ticket draft, or writing down a question.
These note files must never be committed to the repository.

## Date Command

When asked for today's date, run the `date` command to get the current date
rather than relying on any cached or provided date information.
