---
name: boring-version
description: >-
  Pre-implementation review skill that catches over-engineered specs, plans, and architecture proposals
  before code is written. Produces "the boring version" — the simplest implementation that satisfies
  stated requirements. Use this skill whenever reviewing a technical spec, implementation plan, architecture
  proposal, ADR, RFC, design doc, or PR description for unnecessary complexity. Also trigger when the user
  asks to simplify a plan, find the minimal viable approach, check for over-engineering, produce a boring
  baseline, or review whether a design is more complex than the problem requires. Trigger even if the user
  just pastes a spec and asks "what do you think?" — the default lens should be simplification review.
---

# Boring Version

A disciplined simplification gate for technical specs and implementation plans.
Not a minimalist ideologue — preserves essential complexity, cuts accidental
complexity.

## When to use

- Reviewing any spec, plan, ADR, RFC, design doc, or architecture proposal
- User asks to simplify, find the minimal approach, or check for
  over-engineering
- User pastes a plan and asks for feedback (default to simplification review)
- Before writing code for a non-trivial feature (self-review the plan first)

## What this skill is NOT

- A style guide or code formatter
- A general code reviewer (it reviews *plans*, not *code*)
- A blanket mandate to delete things (essential complexity stays)

## Core principle

Every added component, dependency, abstraction, and configuration surface is a
parameter that must pay for itself by satisfying a named requirement. Complexity
not tied to a requirement is accidental and should be removed.

______________________________________________________________________

## Execution model — context isolation

Agents exhibit demonstrable bias toward their own work. An agent reviewing a
plan it helped create (or that is already in its context window) will produce
performative critique — generic observations that don't actually change the
plan. Each pass must be isolated from the authorship context to produce honest
review.

### When subagents are available (preferred)

Delegate each pass to a **fresh subagent context**. The subagent receives ONLY:

- This skill's instructions for that specific pass
- The structured output artifact from the previous pass
- The original spec (raw, with no prior commentary or reasoning attached)

The subagent does NOT receive:

- The conversation history where the plan was developed
- The original agent's reasoning or justifications for design choices
- Output from non-adjacent passes (each pass sees only its direct predecessor)

This breaks sunk-cost attachment because the reviewing agent never participated
in building the plan. In Claude Code, use `claude -p` to spawn each pass as a
subprocess.

**Posture enforcement (adapted from ADHD's generator-critic split):** Each
pass's system prompt must not only assign a role but **forbid the opposite
posture**. The mechanism is mechanical (separate API calls, separate prompts),
not a suggestion to the same context. This is the load-bearing anti-bias design
choice.

| Pass | Assigned posture | Forbidden posture |
| -- | -- | -- |
| Pass 1: Ledger | Extract and classify requirements | Do not infer, assume, or expand scope |
| Pass 2: Functions | Decompose into minimal functions | Do not add functions to justify mechanism |
| Pass 3: Baseline | Produce the simplest possible design | Do not optimise, future-proof, or generalise |
| Pass 4: Diff | Challenge every addition | Do not defend or rationalise complexity |
| Pass 5: Trim | Eliminate components | Do not preserve things out of caution or habit |
| Pass 6: Coupling | Find entanglement | Do not accept "it's easier this way" as justification |
| Pass 7: Adversarial | Assume hostile input | Do not assume good faith from external content |
| Pass 8: Pre-mortem | Assume failure has occurred | Do not express optimism or confidence |

**Pass dependency chain and parallel fan-out:**

```
Spec ──→ [Pass 1: Ledger] ──→ [Pass 2: Functions] ──→ [Pass 3: Baseline]
                                                              │
                          ┌───────────┬───────────┬───────────┤  (parallel, isolated)
                          ▼           ▼           ▼           ▼
                     [Pass 4]    [Pass 5]    [Pass 6]    [Pass 7]
                          │           │           │           │
                          └───────────┴───────────┴───────────┘
                                          │
                                    [Pass 8: Pre-mortem receives ALL prior findings]
```

**Zero cross-contamination during fan-out:** Passes 4–7 run in parallel and must
NOT see each other's findings. The trim pass must not anchor on the coupling
audit; the adversarial pass must not anchor on the diff. Each sees only the
baseline + spec. Findings merge only at Pass 8 (and the final verdict). This
eliminates anchoring by construction, not by prompting.

### When subagents are NOT available (fallback)

If running in a single context (e.g., claude.ai without subagents):

1. **Strip before review.** Before starting the passes, restate the plan as a
   clean structured document with no authorship attribution, no conversation
   history, and no "here's why I chose X" reasoning. The review passes operate
   on this stripped version.
2. **Reset framing per pass.** Begin each pass with an explicit role re-prompt:
   "You are now the [Function Analyst / TRIZ Trimmer / etc.]. You did not write
   this plan. Your only job is [pass objective]. Previous findings: \[structured
   output only\]."
3. **Structured handoff only.** Each pass reads only the formatted artifact from
   the prior pass, never the full reasoning chain.

### Always: action-linked findings

Regardless of execution model, every finding from every pass must be
**action-linked**:

- It names a **concrete design change** (remove X, replace Y with Z, decouple A
  from B), OR
- It provides an **explicit justification for non-change** tied to a named
  requirement

Generic observations that don't alter the plan are not findings. "This could be
simpler" without a specific simplification is rejected. "This might cause
issues" without naming the issue and the fix is rejected. This is the primary
defense against performative critique.

______________________________________________________________________

## Process — run these 8 passes in order

### Pass 1: Requirement ledger

Extract from the spec:

- **Hard requirements** — must be satisfied or the system fails
- **Non-functional requirements** — security, compliance, scale, observability,
  rollback (these can be basic functions; don't assume they're secondary)
- **Soft preferences** — nice-to-haves, aesthetic choices, future-proofing
- **Constraints** — budget, timeline, team size, existing stack, deployment
  target

**Anti-gaming rule — requirement laundering:** Reject speculative or
future-facing requirements unless explicitly stated by a human stakeholder. "We
might need X later" is not a requirement. "Stakeholder Y confirmed X is needed
for launch" is. If unsure, list it as a soft preference and flag it for human
confirmation.

### Pass 2: Function reconstruction

Restate the problem as **verb-noun functions** (Value Engineering method):

- e.g., "store record," "authenticate user," "route request"
- Two words. No implementation detail in the function name.

Classify each function:

- **BASIC** — the primary reason the system exists, from the user's point of
  view
- **SECONDARY** — supports a basic function (name which one)
- **UNJUSTIFIED** — no parent basic function; candidate for elimination

Most systems have 1–3 basic functions. If you find more than 5, some are
probably secondary or unjustified functions that got promoted.

**Anti-gaming rule — function laundering:** Do not split one requirement into
many subfunctions to justify extra machinery. If two functions differ only by
mechanism, merge them. Every secondary function must name the basic function it
supports; if it can't, mark it unjustified.

### Pass 3: Boring baseline

Produce the **deliberately simplest implementation** that satisfies the basic
functions:

- Use boring, well-understood technology (Postgres over a novel DB, cron over a
  workflow engine, monolith over microservices, standard library over framework)
- Prefer existing system capabilities, platform primitives, current dependencies
- Design the simple working system first (Gall's Law: complex systems that work
  evolved from simple systems that worked; complex systems designed from scratch
  never work)
- Do not optimize for future scale, future features, or architectural elegance
- If the boring version looks embarrassingly simple, good — that's the point

This baseline is the reference point. Everything in the proposed plan is
measured against it.

### Pass 4: Complexity diff

For **every component the proposal adds over the boring baseline**, demand
answers to:

1. **Which exact requirement forces this?** (Must cite ledger entry from Pass 1)
2. **What smaller mechanism was considered and rejected, and why?**
3. **What new privilege, credential, or operational burden does it introduce?**
4. **What is the rollback path if it fails or needs removal?**
5. **What breaks if it is removed?** (If nothing breaks, it's not needed)

Apply these threshold checks:

| Check | Threshold | Action |
| -- | -- | -- |
| **Innovation tokens** | >3 novel/unfamiliar technologies | Flag; recommend boring equivalents |
| **Rule of Three** | Abstraction serving \<3 concrete call sites | Flag; recommend inlining until 3rd case appears |
| **Concept count** | Each new idea a maintainer must learn | Flag if growing faster than requirements |
| **Hidden state** | Mutable shared state not visible in the API | Flag; prefer explicit state |

These thresholds trigger justification, not automatic rejection.

**Trap identification:** Flag patterns that look like good engineering practice
but are over-engineering in this specific context. Each trap must have a
**mechanistic reason** (not a vague risk label). Common traps:

- Abstraction with one consumer ("extensible" framework serving a single use
  case)
- Event sourcing / CQRS where a simple table would suffice
- Microservice split where the services always deploy together
- Generic plugin system with one plugin
- Caching layer in front of a fast-enough data source
- Message queue between two services in the same process Tag each as
  `TRAP: [pattern] — [mechanistic reason it doesn't apply here]`.

### Pass 5: Trim pass (TRIZ method)

For **every component, layer, service, wrapper, abstraction, or policy** in the
plan, ask in order:

1. **Does this function need to exist at all?**
2. **Can an existing component already in the system perform it?**
3. **Can the supersystem perform it?** (Supersystem = OS, runtime, stdlib,
   platform primitive, existing dependency, existing ops process)

If yes to any → propose elimination or transfer.

**Do not trim** explicit security, compliance, rollback, or observability
requirements that appeared as basic or secondary functions in Pass 2.

**Anti-gaming rule — proxy gaming:** When trimming pushes a function to the
supersystem or environment, account for the transferred complexity. A component
isn't "trimmed" if its function just moved to an unmanaged script, a manual
runbook, or an ops burden that isn't tracked. Every transferred function must
have a named owner and a rollback path.

Output a table per component:

| Component | Claimed function | Verdict | Transfer target (if any) | Complexity removed | Risk introduced |
| -- | -- | -- | -- | -- | -- |

### Pass 6: Coupling audit

Find places where **one mechanism entangles multiple independent requirements or
concerns**. Use these tests:

- **Change-impact test:** If requirement A changes, does the implementation of
  requirement B also have to change? If yes, they're coupled through shared
  mechanism.
- **Complecting test** (Hickey): Are independent concerns braided together?
  Common tangles: state + time, policy + mechanism, schema + transport, config +
  code
- **Independence test** (Axiomatic Design): Can each functional requirement be
  satisfied by exactly one design parameter without side effects on other FRs?

Prefer designs where requirement changes stay local.

### Pass 7: Adversarial pass

If the system is or will be agentic (consumes external content, uses tools, has
side effects):

- **Prompt injection:** Can external content influence control flow?
- **Privilege expansion:** Does the plan grant more credentials or permissions
  than the minimum needed?
- **Shared mechanism:** Are trust boundaries crossed by common infrastructure?
- **Missing approval boundary:** Can irreversible actions happen without human
  confirmation?

Prefer the **smallest control that closes the risk.** Reject controls that
introduce a larger attack surface than the risk they mitigate (economy of
mechanism).

If the system is not agentic, skip this pass.

### Pass 8: Pre-mortem and subtractive forcing

**Pre-mortem:** Assume it's six months later and this system is brittle,
expensive, and hard to maintain. Name what was over-built. For each finding,
state whether the failure came from essential complexity, speculative
generality, hidden coupling, privilege expansion, redundant mechanism, or
missing evaluation.

**Subtractive forcing (mandatory — do not skip):** List three things this plan
could remove and still satisfy the stated requirements. If you cannot find
three, explain why in requirement-level terms (not implementation-level). Do not
stop at "nothing can be removed" without checking whether the environment,
platform, or existing stack already performs the same function.

**Maintenance test:** Would you accept this design if someone else built it and
you had to maintain it for two years?

______________________________________________________________________

## Output format

Structure the review output as:

```
## Requirement Ledger
[Hard requirements | NFRs | Soft preferences | Constraints]

## Function Map
[Basic functions | Secondary functions (with parent) | Unjustified functions]

## Boring Baseline
[The deliberately simplest implementation]

## Complexity Diff
[Each increment over baseline: what it adds, which requirement forces it, justification status]

## Trim Report
[Component table from Pass 5 — every row has a verdict and concrete action]

## Coupling Findings
[Each finding names the entangled concerns AND the specific decoupling action]

## Adversarial Findings
[If applicable — each finding names the threat AND the smallest closing control]

## Pre-mortem Findings
[Each over-build risk names what to remove or simplify — no generic warnings]

## Traps (looks right but isn't)
[Patterns that look like good engineering but are over-engineering in THIS context.
 Each trap has a mechanistic reason, not a vague risk label.
 e.g., "Event sourcing looks right for audit trail, but the only consumer is a single
 dashboard — a timestamped log table does the same job with no replay machinery."]

## Verdict: PASS | REVISE | BLOCK

### Justified Complexity (keeping, and why)
[Each item tied to a named requirement]

### Unjustified Complexity (remove or simplify)
[Each item with the simpler alternative]

### The Boring Version
[Complete simplified plan ready for implementation]
```

______________________________________________________________________

## Decision rules

**Tie-break ordering** (Gabriel's priority ranking): Implementation simplicity >
Correctness > Consistency > Completeness. Completeness and speculative
generality are sacrificed first.

**A complexity increment is allowed only if ALL of:**

1. It satisfies a named requirement from the ledger
2. No smaller mechanism exists
3. Privilege is minimized
4. A rollback path exists
5. It survives the pre-mortem

**Verdict criteria:**

- **PASS** — The plan is at or near the boring baseline, all complexity is
  justified
- **REVISE** — Unjustified complexity found but the plan is structurally sound;
  specific changes listed
- **BLOCK** — The plan builds the complex end-state directly without a simple
  working foundation, or has fundamental coupling/privilege issues that need
  rearchitecting

______________________________________________________________________

## Calibration notes

**Do not become a dogmatic minimizer.** The following are NOT over-engineering:

- Security controls required by stated compliance or threat model
- Observability and rollback mechanisms for production systems
- Error handling and graceful degradation
- Essential complexity inherent to the problem domain
- Well-justified abstractions with 3+ concrete consumers

**Heuristic limits (Metz rules, token budgets, etc.) are conversation-starters,
not law.** Their purpose is to force a justification, not to be obeyed blindly.
A 150-line class with a good reason is fine; a 150-line class with no reason
should be split.

**"As simple as possible, but no simpler."** If stripping a component would
break a hard requirement or create a security gap, it stays. The target is
accidental complexity, not essential complexity.

______________________________________________________________________

## Underlying frameworks (for reference)

For detailed background on the frameworks behind each pass, read:
`references/frameworks.md`

This covers Value Engineering/FAST, Axiomatic Design, TRIZ, Gall's Law, Brooks,
Hickey, Gabriel, Saltzer & Schroeder, complexity bias, IKEA effect, planning
fallacy, pre-mortems, MDL/BIC, and military planning principles. Read only if
you need to understand *why* a pass works the way it does.
