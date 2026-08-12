---
name: clarify-doc
description: >-
  Make a long, dense document clearer and lighter to read by coordinating a multi-phase
  editing pass: declutter its structure and volume, tighten its sentences, strip AI-isms,
  then re-check with fresh eyes. Use this whenever a doc "feels overwhelming," is "too
  long," "too dense," "hard to skim," "repeats itself," has "walls of text," or when
  someone wants an EDD / design doc / spec / report / RFC / README polished, clarified,
  tightened, or edited for a busy reader. Trigger even if the user just says "clarify
  this," "polish this doc," "tighten this," or "this is a lot." Owns the whole editing
  pipeline and delegates the sentence-level and AI-ism phases to the appropriate skills.
optional-dependencies:
  - name: writing-clearly-and-concisely
    url: https://www.skills.sh/obra/the-elements-of-style/writing-clearly-and-concisely
    used-for: phase 2 deep pass
  - name: avoid-ai-writing
    url: https://www.skills.sh/conorbronsdon/avoid-ai-writing/avoid-ai-writing
    used-for: phase 3 deep pass
---

# Clarify Doc

## What this skill is for

Some documents are exhausting to read: too long, repetitive, buried, and dressed in
machine-sounding prose. Fixing that well takes more than one kind of edit, and the edits
interfere with each other if you do them in the wrong order or let them overlap. This
skill **coordinates** the whole job as an ordered pipeline and owns the hardest phase
(decluttering structure and volume) directly.

**The goal: a document the author still recognizes as theirs, that a busy reader can now
actually get through — lighter, clearer, and free of AI tells, without losing substance.**

Reducing effort is the goal; deleting information is not. A doc that's half the length but
missing a decision, a constraint, or a rationale is a failure, not a win.

## The pipeline

Run these phases in order. The order is not arbitrary — it follows **blast radius**, so a
phase never runs before a phase that could delete its input.

```
1. Declutter        structure, volume, redundancy          (this skill — see Phase 1)
2. Tighten          sentence-level clarity and concision    (checklist below, or escalate)
3. AI-writing check tone / AI tells / formatting            (checklist below, or escalate)
4. Fresh-eyes review declutter review over the FULL doc      (this skill, in a subagent)
   └─ if phase 4 finds real cuts or restructuring:
      apply them, then re-run phases 2 and 3 (full-doc), then phase 4 again,
      until the review comes back clean.
```

### Phases 2 and 3: run light by default, escalate deliberately

Two installable skills do phases 2 and 3 more thoroughly than the checklists below, and
both are expensive in context:

| Phase | Deep pass | Cost |
|-------|-----------|------|
| 2 — Tighten | [`writing-clearly-and-concisely`](https://www.skills.sh/obra/the-elements-of-style/writing-clearly-and-concisely) | thin index; its `elements-of-style.md` reference is ~12k tokens |
| 3 — AI check | [`avoid-ai-writing`](https://www.skills.sh/conorbronsdon/avoid-ai-writing/avoid-ai-writing) | ~15k tokens on load, unconditionally |

**Default to the checklists below.** They catch most of what the deep passes catch, at
roughly no context cost, and they let this skill run standalone.

**Escalate to the deep pass** when the doc is high-stakes or external-facing, when the
checklist pass keeps finding problems (a sign the prose needs more than a sweep), or when
the user asks for a Strunk pass / a real AI-ism audit by name.

**When you escalate, do it in a subagent.** Hand the fresh agent the *file path* and the
skill name, tell it to edit in place and report what it changed. The 12–15k tokens then
land in a throwaway context instead of yours — which is what makes escalation affordable
at all. Escalate inline only if no subagent capability exists.

If a deep-pass skill isn't installed, the checklist *is* the phase. Don't skip the phase
and don't block on installing anything.

### Why this order

- **Declutter first.** It deletes whole sentences and sections. Polishing a sentence you're
  about to cut is wasted work, so structure comes before wording.
- **Tighten before the AI check.** Tightening rewords surviving sentences; the AI check then
  verifies the *final* wording carries no tells. They nearly commute, so don't agonize over
  it — but letting the tone gate see the finished wording is the better call.
- **Fresh-eyes review last.** A reader with no memory of the doc catches accumulated overload
  that anyone who just edited it reads straight past. This is the highest-signal check in the
  pipeline; never skip it.

## Keep the phases from fighting each other

The phases overlap at the edges and will oscillate if you don't hold the boundaries:

- **Declutter owns whole sentences and sections** — what should exist at all, and in what
  order. Redundancy, bloat, buried points, bad structure.
- **Tighten owns wording *within a kept sentence*** — active voice, needless words, tangled
  clauses. It assumes the sentence should exist.
- **AI check owns tells and tone** — hollow phrasing, hedging, em-dashes, bold overuse,
  formatting tics.

When you're in one phase, stay in its lane. If you notice a problem that belongs to another
phase, note it and let that phase handle it — don't silently do all three at once, or the
edit becomes an unreviewable rewrite.

## Global vs. local checks (this governs the recheck loop)

The single most important distinction in the pipeline:

- **Redundancy and additivity are GLOBAL properties.** Whether a passage duplicates another,
  or earns its place, depends on the *rest of the doc*. A change to §3 can create a duplicate
  in §7. You cannot judge this from the changed region alone.
- **Sentence clarity and AI tells are LOCAL.** A wordy sentence is wordy on its own; an
  em-dash is a tell regardless of what §7 says.

Two consequences:

1. **Separate edit locality from analysis locality.** The *edit* that fixes redundancy may
   be one line, but the *analysis* that finds it must always read the whole document. Never
   scope the declutter/redundancy check to a diff, even when the triggering change was tiny.
2. **Every recheck reads the full current doc — never a diff.** Don't build the loop around
   "what changed." You won't always have version control or a memory of the edits, and a
   fresh reader shouldn't need one. Point the reviewer at the *file path* so it re-derives
   duplication from the current state, independent of how the doc got there.

## Delegate the fresh-eyes review to a subagent

**Run phase 4 in a subagent whenever one is available** (the Task/Agent tool). Dispatch a
fresh agent, give it the **file path** (not pasted contents, so it reads the current state),
point it at this skill's Phase 1 method, and tell it to review — not edit — and return
prioritized findings as its final message.

This matters for two reasons that compound:

- **No authorship bias.** A clean-context reader catches overload the editor reads past. This
  is most valuable right after *you* decluttered — your own bias is exactly what the fresh
  reader doesn't share.
- **No dependence on knowing the diff.** Because the subagent reads the whole current file, it
  doesn't need version control or a memory of what changed. It just re-evaluates what's there.
  That's strictly more robust than any diff-based recheck when you can't trust that you know
  what changed.

Tell it to be honest: a section that's genuinely fine should be reported as fine, not padded
with invented nits. If no subagent capability exists, do the review inline, but read the full
file fresh first.

Phases 2 and 3 can also run in subagents, and it helps (a fresh reader spots a clunky
sentence faster), but they carry less risk because their checks are local — the "did I just
create a duplicate?" failure mode is unique to the global declutter check.

---

# Phase 1 — Declutter (the method this skill owns)

Work in this order. The first step is what keeps you honest.

## 1. Inventory the substance first (do not skip this)

Before cutting anything, read the whole document and build a list of its **distinct
substantive points** — the things a reader would be worse off not knowing:

- decisions and the reasoning behind them
- constraints, requirements, assumptions
- concrete facts: numbers, names, dates, APIs, tradeoffs
- open questions and risks
- anything the author clearly fought to get right

This inventory is your safety net. Everything you cut later gets checked against it: if a
substantive point survives somewhere in the doc, cutting its *duplicate* is safe. If a cut
would remove the *only* place a point appears, that's not decluttering — that's data loss.
Keep it.

But substance is what the reader *needs*, not everything that's true. Most of what bloats
a doc is accurate and still cuttable: parenthetical clarifications, defensive "we also
considered…" hedges, belt-and-suspenders detail, mechanics that explain *how* something
works when the doc only needs to record *that* it works and what was decided. For each
passage, ask: **would the reader be unable to understand or act on a decision without
this?** If they'd be fine, it's bulk — however correct it is. This test is what lets you
cut boldly without losing anything that matters. Protecting substance is not the same as
protecting words; keep the former, spend the latter freely.

For a large doc, write the inventory down (a scratch list is fine). For a short one, hold
it in your head — but still do it.

## 2. Find the redundancy

Redundancy is the cheapest, safest length to remove, because by definition the information
survives elsewhere. Look for:

- **Cross-section repetition** — the same decision or context explained in the intro, again
  in the design section, again in the summary. Keep the *best single* statement (usually the
  one closest to where the reader needs it), and cut or cross-reference the others.
- **Restated context** — re-explaining something the reader was told a page ago. Trust the
  reader's memory; link back instead of repeating.
- **Preview/echo padding** — a section that says what it's about to say, says it, then
  summarizes what it just said. Keep the saying; usually cut the preview and echo.
- **Example pile-up** — three examples where one carries the point. Keep the clearest;
  the others are reassurance, not information.

## 3. Find the overwhelm

These are the things that make a doc *feel* heavy even when each part is fine:

- **Buried conclusions** — the point arrives at the end of a long paragraph or section.
  The reader shouldn't have to mine for it.
- **Undifferentiated walls** — a long section with no internal structure, where skimming
  is impossible because every sentence looks equally important.
- **Altitude mixing** — high-level decisions tangled together with deep implementation
  detail in the same breath, so a reader who wants the overview has to read the weeds too.
- **Flat emphasis** — nothing signals what matters most, so everything reads as equally
  urgent (which is exhausting).
- **Parenthetical pile-up** — asides in parens, several to a paragraph. A few clarify; a
  *habit* of them fragments the read and signals the author couldn't decide whether the
  info belonged in the sentence, in a footnote, or nowhere. Treat frequent parentheticals
  as a smell. Fold the ones that carry real weight into the sentence; cut the rest. If an
  aside is important but keeps breaking the flow, it usually wants to be its own sentence.
- **Non-additive headings and labels** — a heading or bold label that only asserts
  importance ("(the primary driver)") or names a filler bucket ("Other considerations")
  instead of telling the reader what's in the section. If the content proves the point, the
  label is dead weight; cut it or rename it to say something specific. Test each heading and
  each bold lead: does it add to the reader's understanding, or just decorate?

## 4. Apply the moves

Match the move to what you found. These reduce reading effort without losing content:

- **Lead with the answer (BLUF).** Put each section's conclusion in its first sentence.
  Detail follows for those who want it; skimmers get the point for free. This single move
  does more for overwhelm than any amount of cutting.
- **Make topic sentences carry the point.** A reader skimming only the first line of each
  paragraph should get the gist of the section. If they wouldn't, fix the first lines.
- **Cut over-detail — don't just relocate it.** The tempting move is to shove deep detail
  into a sub-bullet or appendix so nothing is "lost." Resist it. Relocating weeds into a
  labeled sub-bullet isn't decluttering — it's the same weeds with a signpost, and the
  sub-bullet becomes its own little wall the reader still has to process. Reach for
  relocation *only* when the detail is genuinely a reference someone will return to
  (a schema, a full API surface, a runbook step). If it's mechanics explaining *how* when
  the doc only needs *that* it works and what was decided, cut it to a sentence or drop it.
  Compression is the default; layering is the exception.
- **Convert genuinely list-like prose to a list or table.** If a paragraph is really
  "here are five options / steps / fields" wearing prose clothing, a table or list is far
  faster to scan. Caveat: don't bulletize reasoning or narrative — an argument that flows
  loses its logic as fragments. Lists are for parallel items, not for thinking.
- **Signpost.** Make headings say what's actually in the section (and, for the reader
  deciding whether to read it, *why it matters*). "Rejected alternatives" beats "Other
  approaches."
- **Cut throat-clearing.** Opening windup ("It is worth noting that, before we discuss the
  details, it's important to understand..."), and closing filler that adds no new point.
- **Merge thin sections.** Three half-paragraph sections that belong together read as more
  work than one coherent section. Fewer, denser sections often feel *lighter*, not heavier,
  because there are fewer context switches.

## 5. Verify substance survived

Before you're done, walk your step-1 inventory and confirm each point still appears
somewhere. This is the step that separates decluttering from damage. If anything's gone,
put it back (compressed or relocated, but present).

---

# Phase 2 — Tighten (light pass)

Sentence-level only: assume each surviving sentence should exist, and make it carry its
point with less work from the reader. Eight rules cover most of it:

1. **Use active voice.** "The worker retries the job," not "the job is retried by the worker."
2. **Omit needless words.** Cut "the fact that," "in order to," "it is important to note
   that," "there is/are … that." Most sentences lose 20% with no loss of meaning.
3. **Put statements in positive form.** "Fails on empty input" beats "does not succeed
   unless input is non-empty."
4. **Be concrete and specific.** "Under 200 ms at p99" beats "performant."
5. **Keep related words together.** A modifier stranded from what it modifies makes the
   reader re-parse the sentence.
6. **Put the emphatic word last.** The end of a sentence is the position of stress; don't
   spend it on a trailing qualifier.
7. **Start each paragraph with its topic sentence.** Someone skimming first lines should
   get the section.
8. **Vary sentence structure.** A run of same-length, same-shape sentences reads as flat
   even when each one is fine.

Escalate to `writing-clearly-and-concisely` (in a subagent) when the prose is stiff enough
that this sweep keeps finding the same problems, or when the doc is external-facing.

# Phase 3 — AI-writing check (light pass)

Tone and tells, not meaning. Work through the doc looking for:

- **Em-dashes used as all-purpose connectors.** One or two per doc reads as voice; one per
  paragraph reads as machine. Recast as periods, commas, or colons.
- **The "not just X, but Y" / "isn't about X — it's about Y" frame**, and rule-of-three
  lists that pad rather than enumerate.
- **Hedging stacks**: "may potentially," "could possibly help to," "generally tends to."
  Commit or cut.
- **Throat-clearing openers**: "It's worth noting that," "In today's landscape," "Let's
  dive in."
- **Hollow intensifiers**: "crucial," "vital," "robust," "seamless," "powerful,"
  "game-changing," "leverage" as a verb.
- **Summary sentences that restate the paragraph** they just ended without adding anything.
- **Bold overuse.** If several phrases per paragraph are bold, none of them are emphasis.
- **Uniform bullet lists** where every item is the same length and shape — a tell that the
  structure was imposed rather than found.
- **Symmetry for its own sake**: parallel section shapes that force real content into a
  template it doesn't fit.

Preserve the author's voice. An informal aside or a deliberate fragment is not a tell —
it's a person. Only flag what reads as generated.

Escalate to `avoid-ai-writing` (in a subagent, edit mode) for a full audit when the doc
is going out under someone's name, or when the user asks for the AI-ism pass by name.

---

## Modes

Default to matching how the user asked. If unclear, ask which they want.

- **Full pipeline** (default when they say "clarify this doc," "polish this," "tighten
  this," "make it readable," or hand you a finished doc to clean) — run all four phases in
  order, then the recheck loop. This is edit-in-place: change the file directly with
  targeted edits, preserving the author's voice and wording where it works. Don't touch
  quoted material, code blocks, or others' text. After each phase, briefly report what you
  changed and why.
- **Single phase** — if the user names one ("just declutter this," "run the AI check,"
  "give it a Strunk pass"), run only that phase. Naming a phase by its deep-pass identity
  ("a real Strunk pass," "a full AI-ism audit") is a request to escalate; a plain "tighten
  this up" is not.
- **Review only** (when they ask "what would you cut," "where's it dragging," or the doc is
  someone else's finished work) — don't edit. Run the Phase 4 fresh-eyes review and return a
  prioritized list of findings with a specific fix for each, highest-impact first. Let the
  author decide.

Whichever mode: **show your reasoning about substance.** The author's biggest fear when
someone shortens their doc is that a hard-won point got tossed. Earning trust means saying
"I cut the second explanation of X in §4 because §2 already covers it," not just returning
a shorter file.

## Calibration — how aggressive to be

Read the room. A dense internal EDD for expert peers can lose more scaffolding than a doc
for a mixed audience that needs the ramp-up.

**Default to bolder cuts than feel comfortable.** The common failure in practice is timid
editing: a pass that only dedupes and relocates, leaving the doc nearly as heavy as it
started, then reports a long list of "fixes" that changed little. If your changes are
mostly cross-references and new sub-bullets, you haven't finished — go back and apply the
necessity test (does the reader *need* this?) to the detail you left standing. The author
asked you to make the doc lighter; a 5% reduction wasn't the ask.

Signs you were too timid (the more likely failure):

- Your changes are almost all dedupe and relocation; little was actually removed.
- Detail moved to a sub-bullet or appendix that no reader will return to — it should have
  been cut.
- You kept accurate-but-unnecessary mechanics because they were correct, not because they
  served the reader.
- The doc is meaningfully the same length when you're done.

Signs you've gone too far (the rarer failure, still worth watching):

- The doc now reads as a terse outline that lost the author's reasoning and voice.
- A reader would have to ask a question the original doc answered.
- Nuance became a bullet and lost its qualifications.
- It's shorter but feels *hollow* — which lowers trust in the content.

## Example findings (review mode)

**Example 1 — cross-section redundancy**
Finding: The rationale for choosing Postgres over DynamoDB appears in the Summary (§1),
the Data Model section (§4), and Rejected Alternatives (§7). §7 is the natural home.
Fix: Keep the full argument in §7; in §1 and §4, state the decision in one line and link
to §7. Saves ~2 paragraphs, and the reader stops re-reading the same case.

**Example 2 — buried conclusion + wall**
Finding: §5 ("Rollout") is a 9-sentence paragraph; the actual plan (phased, behind a flag,
2 weeks) is in sentences 6–8. A skimmer sees a wall and the plan is hidden.
Fix: Lead with "Rollout is phased behind a flag over ~2 weeks." Move the risk discussion
that precedes it into a short "Rollout risks" sub-bullet. Same content, scannable.

**Example 3 — over-detail that should be cut, not relocated**
Finding: §3 spends a paragraph on token-refresh mechanics — the refresh cycle step by
step — when the decision the doc needs to record is just "auth uses short-lived tokens
with silent refresh." The mechanics belong in the code, not the design doc.
Fix: Cut the paragraph down to that one-line decision. Don't move it to an appendix — no
reader of *this* doc needs the step-by-step. If a real reference need exists, link to the
code. Saves a paragraph and the section now reads at one altitude.

**Example 4 — parenthetical pile-up**
Finding: §2 packs five parenthetical asides into three sentences (`(one Get per district)`,
`(both together)`, `(why: see below)`, …). Each is minor; together they make every
sentence stutter and hide which detail actually matters.
Fix: Fold the one or two that carry real information into the sentence; delete the rest.
The section reads in one pass instead of lurching between main clause and aside.
