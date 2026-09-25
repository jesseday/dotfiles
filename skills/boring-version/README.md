# Boring Version

A pre-implementation **simplification-review skill** for coding agents (Claude Code, and any
agent runtime that loads Markdown skills). It reviews a spec, plan, ADR, RFC, or design doc
**before code is written** and produces *the boring version* — the simplest implementation that
still satisfies the stated requirements.

It is **not** a minimalist ideologue. It preserves essential complexity and cuts accidental
complexity — the components, dependencies, abstractions, and config surfaces that aren't tied
to a named requirement.

## Why

Two well-documented biases make agents (and people) over-build:

1. **Complexity bias / the IKEA effect** — we over-value mechanism we created and reach for
   clever architecture over boring, proven primitives.
2. **Authorship attachment** — an agent reviewing a plan it helped write produces *performative*
   critique: generic "this could be simpler" observations that never actually change the plan.

Boring Version is built to defeat both. Every finding must be **action-linked** (name a concrete
change, or justify non-change against a named requirement — generic observations are rejected),
and the review runs as **eight isolated passes**, each with an assigned posture *and an explicitly
forbidden posture*, so the reviewer can't rationalise the complexity back in.

## How it works

The skill runs eight passes. Passes 1→3 are sequential; 4–7 fan out in parallel with **zero
cross-contamination** (each sees only the boring baseline + the raw spec, never each other's
findings); pass 8 merges everything.

| Pass | Does | Forbidden posture |
|---|---|---|
| 1. Requirement ledger | Extract & classify hard/NFR/soft/constraints | Inferring or expanding scope |
| 2. Function reconstruction | Restate as verb-noun functions, classify basic/secondary/unjustified | Splitting one need into many to justify machinery |
| 3. Boring baseline | The deliberately simplest design (Gall's Law) | Optimising / future-proofing |
| 4. Complexity diff | Make every addition over baseline pay for itself | Defending complexity |
| 5. Trim (TRIZ) | Eliminate or transfer functions to the supersystem | Keeping things "just in case" |
| 6. Coupling audit | Find entangled concerns (Hickey's complecting) | Accepting "it's easier this way" |
| 7. Adversarial | Injection / privilege / trust-boundary review (agentic systems) | Assuming good-faith input |
| 8. Pre-mortem + subtractive forcing | Assume it failed; name what to remove | Optimism |

Output is a structured report ending in a **PASS / REVISE / BLOCK** verdict and a ready-to-build
*Boring Version* of the plan.

When subagents are available the passes run as fresh isolated contexts (in Claude Code, via
`claude -p` subprocesses); otherwise there's a single-context fallback that strips authorship and
re-prompts the role per pass.

## Files

- **`SKILL.md`** — the skill itself (this is all you need to run it).
- **`references/frameworks.md`** — optional background on the methods behind each pass: Value
  Engineering / FAST, TRIZ, Gall's Law, Axiomatic Design, Brooks, Hickey, Gabriel, Saltzer &
  Schroeder, MDL/BIC, pre-mortems, and the relevant cognitive biases. Read only if you want to
  know *why* a pass works the way it does.

## Install (Claude Code)

User-level skills live in `~/.claude/skills/<name>/`. Install with:

```bash
git clone https://github.com/<you>/boring-version.git
mkdir -p ~/.claude/skills/boring-version
cp boring-version/SKILL.md ~/.claude/skills/boring-version/SKILL.md
cp -r boring-version/references ~/.claude/skills/boring-version/references
```

Or as a one-liner from a clone:

```bash
DEST=~/.claude/skills/boring-version
mkdir -p "$DEST" && cp SKILL.md "$DEST/" && cp -r references "$DEST/"
```

Skills load at session start, so start a new Claude Code session afterwards. For a **project-level**
install instead, use `.claude/skills/boring-version/` inside the repo.

## Use

- Invoke directly: `/boring-version`
- Or just paste a spec / plan / ADR and ask "what do you think?" — the skill's default lens is
  simplification review, so it triggers automatically.

It's most valuable run on a plan *before* implementation — including self-review of your own plan
before you start writing code.
