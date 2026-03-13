# Local rules

## Obsidian CLI

The Obsidian CLI is available at `/Applications/Obsidian.app/Contents/MacOS/Obsidian`. The vault name is `notes` and lives at `~/Documents/notes/`.

Use it for file operations within the vault, especially:
- `Obsidian move path="from.md" to="folder/to.md"` — moves files and **auto-updates all wiki-links**
- `Obsidian backlinks file="name"` or `path="folder/file.md"` — check what links to a file
- `Obsidian search query="text"` — search vault contents
- `Obsidian unresolved` — find broken links
- `Obsidian create path="folder/file.md" content="..."` — create files in the vault (auto-creates parent directories)
- `Obsidian read path="folder/file.md"` — read file contents

Filter out startup noise with `2>&1 | grep -v "Loading\|installer"`.

Always prefer `Obsidian move` over manual `mv` when moving files in the vault to preserve link integrity.

## Session Notes

When asked to summarize a session or interaction, there are two types of summaries:

### Daily Note
- Location: `~/Documents/notes/daily/YYYY-MM-DD.md`
- This is the user's own daily note. **Never delete or modify existing content** unless specifically asked.
- When asked to update the daily note, **append** to the relevant sections:

#### `## Notes` section
Format for each item:
```
**TICKET-ID or short description**
https://khanacademy.atlassian.net/browse/TICKET-ID

- high level note
- high level note
```
Only include the URL line for ticketed work.

#### `## Related` section
Link to the detailed ticket summary using Obsidian link syntax:
```
[[tickets/DIST-xxxx/summary#section heading]]
```
The section heading is usually today's date (e.g., `## 2026-03-03`), matching the most recently created heading in the ticket summary file.

#### `## For Tomorrow` section
Only update when the user specifically asks. Uses checkbox format:
```
- [ ] Something to do
```

### General Rules
- When asked to write a summary of today's work, first run the `date` command to determine the current date
- Write notes in markdown format
- Use clear headings, bullet points, and code references as appropriate

### Reviewing Previous Days
When asked to review "yesterday's notes", "recent notes", or what was worked on a given day:
1. Read the daily note for that date (`~/Documents/notes/daily/YYYY-MM-DD.md`)
2. Follow any Obsidian links in the `## Related` section — these use the format `[[path#section]]` and resolve to files in the vault. Read the linked file and jump to the referenced section heading.

These notes files should never be committed to the repository.

## Ticket Work (Research-Plan-Implement)

All ticket work artifacts live in `~/Documents/notes/tickets/` (symlinked from `notes/tickets/` in the repo). Each ticket gets its own directory with flexible artifacts — not every file is required for every ticket.

### Directory structure

**Standalone ticket:**
```
tickets/DIST-xxxx/
├── research.md        # exploration, requirements, system analysis, open questions
├── plan.md            # implementation approach and technical design
├── plan-review.md     # AI self-review of plan (optional, for complex work)
├── devlog.md          # running log during implementation
├── code-review.md     # AI self-review of implementation (optional, for complex work)
├── summary.md         # final summary: what was done, decisions, next steps
└── pr.md              # PR description (optional)
```

**Epic with child tickets:**
```
tickets/DIST-xxxx-short-name/
├── edd.md             # epic design doc / requirements
├── ticket-drafts.md   # ticket breakdown drafts
├── summary.md         # epic-level summary
├── DIST-yyyy/         # child ticket (same structure as standalone)
│   ├── research.md
│   ├── plan.md
│   └── summary.md
└── DIST-zzzz/
    └── ...
```

Use the epic pattern (`DIST-xxxx-short-name/`) when a parent ticket has multiple child tickets. The short name helps identify the epic at a glance.

### When to create which files

**Small bug fix / simple change:** just `devlog.md` or `summary.md`
**Medium feature:** `plan.md` → `devlog.md` → `summary.md`
**Complex feature:** `research.md` → `plan.md` → `plan-review.md` → `devlog.md` → `code-review.md` → `summary.md`

### Artifact details

#### research.md
Written before committing to an approach. Covers:
- Requirements (original request + context)
- System architecture (related components, data flow, constraints)
- Prior art and open questions
- Exploration of possible approaches

#### plan.md
Written after research decisions are made. Covers:
- Summary, motivation, goals, non-goals
- Technical design and implementation approach
- Key files to modify, order of operations
- Alternatives considered

#### plan-review.md
AI self-review of the plan. Flags concerns as High/Medium/Low. Recommends whether the plan is ready for human review or needs revision.

#### devlog.md
Append-only log written **during** implementation (not after). Use date headings (e.g., `## 2026-03-11`). Captures:
- What was done
- Tricky parts and how they were resolved
- Decisions made during implementation
- Deviations from the plan

#### code-review.md
AI self-review of the implementation against the plan. Flags issues as High/Medium/Low. Recommends whether the code is ready for human review.

#### summary.md
Final summary for the ticket. Uses date headings (e.g., `## 2026-03-11`) when appending across multiple sessions. Covers what was worked on, key decisions, code references, open questions, and next steps.

#### pr.md
Optional PR description with summary, architecture diagram (mermaid), decisions list, code walkthrough, and testing instructions.

### Workflow with human checkpoints

1. **Research** — Write `research.md`. If complex, write `plan-review.md` for self-review. Pause for human review.
2. **Plan** — Write `plan.md`. If complex, write `plan-review.md`. Pause for human review.
3. **Implement** — Implement the plan. Write `devlog.md` as you go. If complex, write `code-review.md`. Pause for human review.
4. **Summarize** — Write or update `summary.md`.

The user does not need to explicitly invoke each phase — use judgment based on task complexity. For simple tasks, just do the work and write a devlog. For complex tasks, offer to start with research.

### Creating a new ticket directory
Use `Obsidian create` which auto-creates parent directories:
```bash
Obsidian create path="tickets/DIST-xxxx/research.md" content="# Research: [Title]"
```

### Legacy files
- Date-based summaries (non-ticket) remain in `~/Documents/notes/ai-summaries/`
- `notes/summaries/` symlink still points to `ai-summaries/` for those files

## Questions

When asked to "write down a question" or similar:
- The notes directory contains a symlink called `questions` pointing to a questions directory
- Create a new file in `notes/questions/` named `NNNN. [brief-question].md` (4-digit number with leading zeros, e.g., `0001. why-does-auth-fail.md`)
- Increment the number based on existing files to maintain order
- Use the template file in the questions directory as the format for new questions
- If we have just discovered the answer during the session, include the answer in the file as well

These question files should never be committed to the repository.

## Support Log

When asked to triage, log, or track a support issue (e.g., a production error, log cleanup item, or internal support request):

### Creating a support item
- Location: `~/Documents/notes/support/`
- Filename: `YYYY-MM-DD.N.md` where N is an incrementing number for that day (e.g., `2026-03-10.1.md`, `2026-03-10.2.md`)
- Check existing files to determine the next number for the day
- Use the template at `~/Documents/notes/support/template.md` for the format

### Frontmatter fields
```yaml
---
status: open        # open | pending | resolved | wontfix
type:               # log-cleanup | support-request | bug | tech-debt
service:            # e.g., districts, admin-reports
repo:               # webapp | frontend | districts-jobs
jira:               # full Jira URL if a ticket exists, empty otherwise
pr:                 # full PR URL if code is up, empty otherwise
description:        # one-line summary
---
```

### Status lifecycle
- `open` — identified but no fix written
- `pending` — fix written but PR not yet merged
- `resolved` — PR merged and deployed

### Sections
- `## Summary` — what's happening
- `## Root Cause` — analysis of why
- `## Fix` — what was done or TBD
- `## Notes` — additional context, links to related items using `[[YYYY-MM-DD.N]]`

### Daily note integration
When creating support items, also add a line to the `## Support` section of the daily note (`~/Documents/notes/daily/YYYY-MM-DD.md`):
```
- [[2026-03-10.1]] - Brief description (status)
```

### Dataview base file
The directory has `0000. Support Log.base` for Obsidian's database view. Do not modify unless asked.

These support files should never be committed to the repository.

## Ticket Drafts

When writing ticket/story drafts, do not include point estimates (story points). The user handles estimation separately.

## Date Command

When asked for today's date, run the `date` command to get the current date rather than relying on any cached or provided date information.
