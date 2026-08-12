---
name: clarify-code
description: >-
  Review a code change (a diff or set of changed files) for reader-facing clarity —
  comment quality and naming — plus light simplicity, and apply the fixes (or just report
  them, on request). Use this after writing or substantially editing code, before calling
  a change "ready for review," ESPECIALLY on large changes or when significant comments
  were added; and whenever asked to "clean up comments/names," "make this clearer,"
  "clarify the code," or "tighten the naming." Best run in a fresh-eyes subagent against
  the working diff. This is the CODE companion to clarify-doc (which is for prose/docs):
  clarify-doc declutters documents; clarify-code judges comments + names in source, and
  defers deep structural rework to the simplify skill. Do NOT use for bug-hunting (that
  is code-review) or for prose documents (that is clarify-doc).
---

# Clarify Code

## What this skill is for

Make a code change read well for the next person: **comments that carry only what the
reader needs, and names that say what a thing does or is — not why we wrote it.** It also
does a light simplicity pass, but hands genuinely structural rework to `simplify` and
bug-hunting to `code-review`.

Three lanes, in priority order:

1. **Comments** — cut the comments in the diff down to what the reader actually needs.
2. **Naming** — judge whether each new/renamed identifier tells the reader what it does
   or represents.
3. **Light simplicity** — obvious redundancy, dead code, needless indirection. Anything
   deeper is a `simplify` finding, noted and deferred.

This skill is self-contained — it needs no other skill installed to run.

## When to run it

- After writing or substantially editing code, as the last step before "ready for review."
- **Scale to the change.** On a large change or one that adds significant comments, run the
  full pass (ideally in a subagent). On a minor edit, a quick inline comment/name check is
  enough — don't spin up the whole apparatus.
- When explicitly asked to clarify code, clean up comments, or tighten names.

## What to review

If the user named files or pasted a diff, that's the scope. Otherwise take the first of
these that isn't empty, and say which one you used:

1. **Unstaged changes** — `git diff`. Work in progress is what the author is still holding
   in their head, so it's what they mean by "clean this up."
2. **Staged changes** — `git diff --cached`, when nothing is unstaged. The change is
   assembled and about to be committed.
3. **The branch against its base** — `git diff <base>...HEAD`, when the tree is clean.
   Nothing is in flight, so the change under review is the whole branch. Don't run this on
   the base branch itself — there's no change to review, so ask what to look at.

### Resolving `<base>`

**Don't assume `main`.** Stacked PRs and deploy branches are common here, and a stacked
branch's base is its parent, not the trunk. Diffing against `main` then drags in the
parent's changes, and you spend the review on code the author didn't write — the worst
outcome for a skill whose value is fresh-eyes attention.

**If the user named a branch, use it.** Otherwise work it out from git:

```bash
default=$(git symbolic-ref --short refs/remotes/origin/HEAD)   # e.g. origin/main
git branch --contains "$(git merge-base "$default" HEAD)"      # candidate bases
```

The merge base is where this line of work left the trunk; every branch containing that
commit sits between there and here. Drop the current branch from the list, then:

- **One candidate** — that's the base.
- **Several** — you're on a stack. Ask which one; don't pick. The parent is the tightest
  scope and usually right, but guessing wrong means reviewing someone else's commits.
- **None but the default** — the branch came straight off the trunk. Use the default.

Three-dot (`base...HEAD`) is deliberate: it diffs from the merge base, so commits that
landed on the base after branching don't show up as part of this change.

**Read the diff to find the scope; read the containing file to judge it.** A comment that
restates what a type doc already said, or a name that stutters against its package, is only
visible with the surrounding code in view. The *edit* stays inside the change; the
*analysis* doesn't. Findings about unchanged code are worth mentioning, but flag them as
pre-existing so the author can decide whether they're in scope.

## Run it in a fresh-eyes subagent (preferred)

Naming and comment clarity suffer most from authorship bias — the writer reads past the
unclear name because they know what it means. Dispatch a subagent, give it the resolved
scope from above (the file paths, or the exact diff command), point it at this skill, and
have it return prioritized findings (or apply them, per mode). A clean-context reader is
the whole point; don't skip it on a large change.

**Tell it what the code does. Don't tell it which parts of the design are settled.** Words
like "deliberately," "this was decided," or "worth preserving" redirect the reviewer into
defending the shape and explaining it in a comment — suppressing exactly the findings a
clean-context reader is there for. State the behavior and the constraints flatly, and let
the reviewer flag a design smell even when the decision is final; a smell it marks
"→ simplify" costs you one line to decline. Where the code makes a claim about something
outside the diff (a backend contract, a schema, another service's behavior), point the
subagent at that source and tell it to verify the claim rather than trust it.

---

## Lane 1 — Comments

### First, inventory what the comments know that the code doesn't

Before cutting anything, list the **load-bearing facts** in the comments in scope — the
things a reader could not recover by reading the code itself:

- invariants the types don't enforce ("not capped at 51," "this default is relied on by X")
- magic numbers and where they came from
- why a non-obvious approach was taken over the obvious one
- known gotchas, ordering requirements, and their consequences
- external contracts: callers, schemas, upstream behavior you can't see from here

This list is the safety net. Every cut gets checked against it: if a fact survives somewhere
in the change, cutting a *duplicate* statement of it is safe. If a cut would remove the only
place a fact appears, that's not decluttering — that's deleting knowledge. Keep it.

But load-bearing is not the same as true. Most comment bloat is accurate and still cuttable.
For each comment, ask: **would a competent reader misunderstand this code, or change it
wrongly, without this comment?** If they'd be fine, it's bulk — however correct it is.

### Then cut, by failure mode

- **Restating one idea across nearby comments.** A concept explained on a type, then
  re-explained on each method/field. State it once, at its best home; trust the reader saw it.
- **Narrating mechanics the code shows.** "computed here and threaded through X and Y" when
  the calls are right there; naming the constructor a line above the call.
- **Motivation/history in the comment.** "for DIST-1234," "so the later refactor…," "we also
  considered…" — belongs in the PR/devlog, not the code.
- **Buried payoff.** The non-obvious fact arrives after a wind-up of obvious setup. Lead with it.
- **Comment compensating for a bad name.** If the comment exists to explain what the
  identifier should have said, that's a Lane 2 finding. Fix the name and delete the comment.
- **AI tells.** Em-dashes as connectors, hedging, throat-clearing. Prefer plain statements.

Terseness is the goal, not deletion. Two-to-three lines is usually plenty; five-plus is a
smell.

### Last, verify the facts survived

Walk the inventory and confirm each load-bearing fact still appears somewhere — in a
comment, or now encoded in a name or type. This step is what separates decluttering from
damage. If one is gone, put it back, compressed.

## Lane 2 — Naming

**The test: does the name describe what the thing does or is, from the reader's side — not
why it exists or how we arrived at it?**

Flag and propose a rename when a name encodes:

- **Motivation or provenance** instead of behavior. `createProvenMasteryClasses` describes
  *why we trust the data* (it's "proven"); the reader needs *what it makes* —
  `createMasteryClasses`. Strip "proven," "new," "fixed," "temp," "v2," ticket refs, and
  "shared/common" when they describe our reasoning rather than the thing.
- **Vagueness.** `handle`, `process`, `data`, `doWork`, `manager` that don't say what is
  handled or produced. Name for the effect and its scope.
- **A lie or half-truth.** A `...ForAll` that only covers active users; a `get` that also
  writes. Name the actual scope (`...ForActiveUsers`) and the real effect.
- **Stutter / redundancy** with the package or receiver, against the codebase's conventions.
- **A type wider than the meaning.** For a field or variable, judge the name and the type
  *together* — the type is part of what the name promises. A `string` that is only ever
  empty or one of three fixed messages, an `int` that is only ever 0 or 1, an optional
  that is never absent: each is a naming finding even when the name itself is accurate.
  This lane is not only about functions.

Match the surrounding code's idioms (casing, prefixes, the `_uncached` convention, etc.).
Encode invariants in the name where it genuinely helps. Renames must stay behavior-preserving —
update all references.

## Lane 3 — Light simplicity

Only the cheap, local wins here; **defer anything structural to `simplify`** and say so:

- Dead code, unreferenced params/consts, leftover scaffolding.
- Duplicated literals/logic that a small helper or existing utility removes.
- Needless indirection: a wrapper that only forwards, an optional that's never nil, a
  branch that can't be taken.
- **A value doing two jobs** — a payload whose presence also serves as a flag. The tell is
  at the *use site*, not the declaration: `Boolean(x)`, `x || undefined`, `x !== ""`,
  `len(x) > 0` standing in for a mode. Read what the coercion means, not how many times
  the value is used; a single-use coercion is the same smell as a hundred. Split the flag
  from the payload. Cheap and local, so fix it here — don't defer it.

If a finding wants a real restructuring (collapsing a mode, reshaping a type, deleting a
layer), note it as "→ simplify" and move on — don't do the heavy rework here.

---

## Modes

- **Apply** (default) — make the edits directly: rewrite the comment, rename with all
  references updated, delete the dead code. Then confirm the change still builds/formats
  (`gofumpt`/`go vet` in Go, the repo's equivalent elsewhere) and note what you changed and why.
- **Review** — don't edit; return findings, highest-impact first, each with the file:line,
  the problem in one line, and a concrete fix. Use it when the user asks for findings, or
  when the change is someone else's to edit.

Apply is the default because the findings are small, local, and reversible by construction —
this skill defers everything structural to `simplify` — and because a reported-but-unapplied
finding is worse than no finding at all: it puts a defect the review has already named in
front of the next reader.

**A finding that the comment is factually wrong is never queued for approval.** If a comment
misstates what the code, a schema, or another service actually does, fix it in Apply *and* in
Review mode, and say you did. Inaccuracy is a correction, not a style preference.

**Two things stay reported even in Apply mode**, because a wrong guess costs more than the
round trip:

- A rename that crosses the diff's boundary — an exported symbol, a public API, an
  identifier with references outside the files under review.
- Anything marked "→ simplify," and any finding on PRE-EXISTING code outside the change.

Whichever mode: **show your reasoning about substance** — "renamed X→Y because the old name
said why not what"; "cut the second explanation of Z, the type doc already covers it." A
shorter, better-named diff without that reasoning is hard to trust. In Apply mode this
reasoning *is* the report; the author is reviewing your edits, not a list of suggestions.

## Boundaries with sibling skills

- **clarify-doc** — prose documents (EDDs, READMEs, specs). This skill is source code.
- **simplify** — deep structural cleanups (reuse, altitude, collapsing complexity). This skill
  defers to it.
- **code-review** — correctness/bugs. This skill is quality/readability only; it does not hunt
  for bugs.
