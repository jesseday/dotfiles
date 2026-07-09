---
name: clarify-code
description: >-
  Review a code change (a diff or set of changed files) for reader-facing clarity —
  comment quality and naming — plus light simplicity, and either report findings or
  apply the fixes. Use this after writing or substantially editing code, before calling
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

1. **Comments** — apply clarify-doc's declutter method to the comments in the diff.
2. **Naming** — judge whether each new/renamed identifier tells the reader what it does
   or represents.
3. **Light simplicity** — obvious redundancy, dead code, needless indirection. Anything
   deeper is a `simplify` finding, noted and deferred.

## When to run it

- After writing or substantially editing code, as the last step before "ready for review."
- **Scale to the change.** On a large change or one that adds significant comments, run the
  full pass (ideally in a subagent). On a minor edit, a quick inline comment/name check is
  enough — don't spin up the whole apparatus.
- When explicitly asked to clarify code, clean up comments, or tighten names.

## Run it in a fresh-eyes subagent (preferred)

Naming and comment clarity suffer most from authorship bias — the writer reads past the
unclear name because they know what it means. Dispatch a subagent, give it the **file
paths or the diff** (`git diff` against the base), point it at this skill, and have it
return prioritized findings (or apply them, per mode). A clean-context reader is the whole
point; don't skip it on a large change.

---

## Lane 1 — Comments

Apply the `clarify-doc` Phase 1 declutter method, scoped to the comments in the diff. The
recurring failure modes (all worth a finding):

- **Restating one idea across nearby comments.** A concept explained on a type, then
  re-explained on each method/field. State it once, at its best home; trust the reader saw it.
- **Narrating mechanics the code shows.** "computed here and threaded through X and Y" when
  the calls are right there; naming the constructor a line above the call.
- **Motivation/history in the comment.** "for DIST-1234," "so the later refactor…," "we also
  considered…" — belongs in the PR/devlog, not the code.
- **Buried payoff.** The non-obvious fact arrives after a wind-up of obvious setup. Lead with it.
- **AI tells.** Em-dashes as connectors, hedging, throat-clearing. Prefer plain statements.

Keep genuine gotchas (magic-number annotations, load-bearing invariants like "not capped at
51," "this default is relied on by X"). Terseness is the goal, not deletion. Two-to-three
lines is usually plenty; five-plus is a smell.

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

Match the surrounding code's idioms (casing, prefixes, the `_uncached` convention, etc.).
Encode invariants in the name where it genuinely helps. Renames must stay behavior-preserving —
update all references.

## Lane 3 — Light simplicity

Only the cheap, local wins here; **defer anything structural to `simplify`** and say so:

- Dead code, unreferenced params/consts, leftover scaffolding.
- Duplicated literals/logic that a small helper or existing utility removes.
- Needless indirection: a wrapper that only forwards, an optional that's never nil, a
  branch that can't be taken.

If a finding wants a real restructuring (collapsing a mode, reshaping a type, deleting a
layer), note it as "→ simplify" and move on — don't do the heavy rework here.

---

## Modes

- **Review** (default) — don't edit; return findings, highest-impact first, each with the
  file:line, the problem in one line, and a concrete fix (the rename, the tightened comment,
  the deletion). Let the author decide.
- **Apply** — make the edits directly: rename with all references updated, rewrite the
  comment, delete the dead code. Then confirm the change still builds/formats
  (`gofumpt`/`go vet` in Go, the repo's equivalent elsewhere) and note what you changed and why.

Whichever mode: **show your reasoning about substance** — "renamed X→Y because the old name
said why not what"; "cut the second explanation of Z, the type doc already covers it." A
shorter, better-named diff without that reasoning is hard to trust.

## Boundaries with sibling skills

- **clarify-doc** — prose documents (EDDs, READMEs, specs). This skill is source code.
- **simplify** — deep structural cleanups (reuse, altitude, collapsing complexity). This skill
  defers to it.
- **code-review** — correctness/bugs. This skill is quality/readability only; it does not hunt
  for bugs.
