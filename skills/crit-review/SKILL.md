---
name: crit-review
description: Address review comments from a crit code review. Use whenever a prompt hands you crit review comments to work through — including when it says "the review finished with N unresolved comments" and pastes comment JSON inline (objects with id/path/start_line/body), when it points to a ~/.crit/reviews/<id>/review.json file, and/or when it tells you to reply with `crit comment --reply-to <id> --author <name>` and then run `crit` or `crit --session <id>`. Also use when asked to read, triage, address, or reply to crit comments / a crit review round.
allowed-tools: Bash(python3 /Users/jesseday/.claude/skills/crit-review/scripts/show_review.py:*), Bash(crit comment:*), Bash(crit:*)
---

# Crit Review Response

Use this skill to work through a round of [crit] code-review comments: read the
review JSON, address each open comment in the code, reply to each one, and
advance to the next round.

A crit round hands you a prompt in one of two shapes:

- **Inline comments (current format):** "The review finished with N unresolved
  comments." followed by a JSON array of comment objects
  (`id`/`path`/`start_line`/`end_line`/`body`/`anchor`/…) pasted directly into
  the prompt, then: reply with
  `crit comment --reply-to <comment-id> --author <your-name> "<explanation>"`,
  and "When you're done, run: `crit --session <id>`".
- **File reference (older format):** "Review comments are in
  /Users/jesseday/.crit/reviews/<id>/review.json …", same reply command, and
  "When done run: `crit`".

Either way the workflow is the same: read every open comment, address each in
the code, reply to each, then advance the round.

## Sandbox mode — how replies get written

The `crit` daemon writes to `~/.crit`, which is **outside the writable sandbox in
this environment**, so `crit comment` and `crit` cannot be run from a tool call
here (and `dangerouslyDisableSandbox` is disabled by policy).

**Default behavior in this environment:** do NOT try to run `crit comment` or
`crit`. Instead, after making the code changes, **output the exact
`crit comment` commands in one copy-pasteable block for the user to run from
their own terminal**, and **skip the final `crit`** (the user runs it, or asks
you to ignore it). Still do all the reading, triage, editing, and verification
yourself — only the writing-back step is handed off.

If you are ever in an environment where `crit` *can* run (sandbox disabled /
different setup), run the commands yourself as Steps 4–5 describe instead of
printing them.

## Step 1 — Read the comments

**If the prompt pasted the comments inline** (current format — a JSON array of
comment objects in the message), work from those directly; that is the
authoritative list of open comments for this round. You can skip the script.

**If the prompt only gave a `review.json` path (or nothing)**, don't write an
inline JSON parser — use the bundled script, which prints every open comment
grouped by file with its id, location, body, anchor, and full reply thread:

```bash
python3 scripts/show_review.py [REVIEW_JSON]
```

- Pass the `review.json` path from the crit prompt. If you omit it, the script
  defaults to the most recently updated `~/.crit/reviews/*/review.json`.
- `--all` also shows already-resolved comments (use when chasing a follow-up on
  a resolved thread).
- `--ids` prints just the open comment ids (handy for scripting).

Run it from the skill's base directory (the path is given when the skill loads),
e.g. `python3 <base-dir>/scripts/show_review.py <path>`.

> The script only reads the file, so it runs fine in the sandbox.

## Step 2 — Triage each open comment

For every comment the script prints (resolved != true):

1. **Read its `replies` thread first.** If you have already replied, the
   reviewer may be following up *conversationally* rather than requesting a new
   code change — answer the follow-up, don't redo the work. A fresh comment with
   no replies is a new request. Note the reviewer's own follow-up replies can add
   *new* requirements on top of the original comment — fold those in too.
2. Decide whether it needs a **code change** or is a **question** to answer:
   - Code change → make the edit at the comment's file + `start_line`/`end_line`.
   - Question → answer it directly in the reply; change code only if the answer
     reveals an actual problem.
   - A `suggestion` block (```suggestion) is a proposed replacement for the
     anchored text — apply it (adapting as needed) unless it's wrong.
3. If a comment proposes a behavior change you're unsure about, surface the
   trade-off to the user rather than deciding unilaterally.

## Step 3 — Verify

After making code changes, build and run the affected tests/lints before
replying, so each reply can state that it passed (match the repo's tooling, e.g.
`go build` + `go test` / `go vet` in a Go service). Report failures honestly in
the reply rather than claiming success. (For non-code files like design docs,
there's nothing to build — just make sure the edit reads cleanly.)

## Step 4 — Reply to every comment

Reply to each comment you addressed, citing what you did. The correct command
form is:

```bash
crit comment --reply-to <comment-id> --author Claude "<explanation>"
```

- Use `--author Claude`.
- Keep the explanation specific: name the function/file changed or give the
  direct answer. Avoid shell pitfalls in the quoted text — no backticks (command
  substitution) and no `$`; write plain prose.

**In this sandboxed environment (default):** don't run these. Print them all in a
single fenced block so the user can paste and run them at once, e.g.:

```bash
crit comment --reply-to c_abc123 --author Claude "Removed the location filters from the frontend task list."
crit comment --reply-to c_def456 --author Claude "Applied the suggestion and added the follow-up tasks."
```

## Step 5 — Advance the round

When every open comment has a reply, the round is advanced by running the
command the prompt gave — `crit --session <id>` in the current format, or bare
`crit` in the older one:

```bash
crit --session <id>
```

**In this sandboxed environment (default):** do NOT run this and do NOT include
it in the block you output — leave advancing the round to the user (the prompt's
"When you're done, run: …" line is theirs to act on). If a comment raised a
decision that's genuinely the user's to make, surface it rather than resolving
it unilaterally.

\[crit\]: a local code-review tool whose daemon stores reviews under `~/.crit/reviews/`.
