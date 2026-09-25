# Boring Version — Framework Reference

Underlying frameworks for each review pass. Read on demand, not required for operation.

## Table of contents

1. [Value Engineering and FAST (Passes 1–2)](#value-engineering-and-fast)
2. [Gall's Law and evolutionary design (Pass 3)](#galls-law)
3. [MDL/BIC complexity penalty (Pass 4)](#complexity-penalty)
4. [TRIZ trimming and Ideal Final Result (Pass 5)](#triz-trimming)
5. [Axiomatic Design and Hickey's decomplecting (Pass 6)](#coupling-frameworks)
6. [Saltzer & Schroeder and agentic threat models (Pass 7)](#security-frameworks)
7. [Pre-mortems, additive bias, and debiasing (Pass 8)](#debiasing-frameworks)
8. [Software simplicity heuristics (cross-cutting)](#software-heuristics)
9. [Military planning principles (cross-cutting)](#military-planning)
10. [Known failure classes](#failure-classes)
11. [Evidentiary caveats](#caveats)

---

## Value Engineering and FAST

**Source:** SAVE International Job Plan methodology; Charles Bytheway's FAST diagram (1965).

**Core mechanism:** Express every function as an active verb + measurable noun (e.g., "cross
obstacle," not "be a concrete span"). This strips physicality and implementation detail,
revealing what the system actually *does* vs. what it *is made of*.

**FAST diagram:** Arranges functions on a HOW–WHY axis. Reading left-to-right answers "how?"
a function is achieved; right-to-left answers "why?" it exists. Functions that don't connect
to a "why?" chain back to the basic function are elimination candidates.

**Classification:** Basic functions (the reason the system exists from the user's view) vs.
secondary/supporting functions. Secondary functions that don't logically support a basic
function via the HOW–WHY test are the prime cost-saving targets.

**Application to spec review:** Restate each part of the plan as a verb-noun function. Identify
the 1–3 basic functions. Every component supporting only secondary or unjustified functions is
a candidate for removal.

---

## Gall's Law

**Source:** John Gall, *Systemantics* (1975, revised editions 1986, 2002).

**The law:** "A complex system that works is invariably found to have evolved from a simple
system that worked. A complex system designed from scratch never works and cannot be patched
up to make it work. You have to start over with a working simple system."

**Mechanism:** Argues for underspecification and incremental evolution. The boring baseline
pass exists because of this law — define the simple working system first, then evolve.

**Application:** Flag any plan that attempts to build the complex end-state directly without
defining a simple working intermediate. Recommend re-sequencing: ship the boring version first,
add complexity only when driven by observed need.

---

## Complexity penalty

**Sources:** Rissanen (Minimum Description Length), Schwarz (Bayesian Information Criterion),
Akaike (AIC); building on Kolmogorov complexity and Solomonoff induction.

**Core mechanism:** Model selection adds a penalty term for each parameter:
score = (lack of fit) + (complexity penalty). A more complex model must "pay for itself" in
improved fit. BIC penalizes each parameter by a factor growing with data size, consistently
favoring simpler models.

**Transfer to spec review:** Every added component, dependency, or abstraction is a "parameter"
that must reduce real "error" (satisfy a concrete requirement) by more than its complexity cost.
This is the rigorous backbone for the complexity-budget scoring in Pass 4.

**Multi-axis scoring (from adversarial review):** Visible component count alone is gameable.
Use multiple axes: moving parts, coupling points, privilege surfaces, hidden state, operational
dependencies, concept count (new ideas a maintainer must learn).

---

## TRIZ trimming

**Source:** Genrich Altshuller's TRIZ methodology; specifically Trimming (Inventive Principle #2)
and the Ideal Final Result (IFR).

**Ideality:** Ratio of benefits to (costs + harms). Systems evolve toward ideality.

**IFR:** Imagine the function being delivered with the component not existing at all — the desired
result achieved by itself. This thought experiment reveals when existing system parts or the
environment already provide the needed function.

**Trimming procedure:** For each component, ask:
1. Can the function be eliminated entirely?
2. Can an existing component in the system absorb it?
3. Can the supersystem (OS, runtime, stdlib, platform, existing dependency) absorb it?

**Adversarial caveat:** Trimming can push complexity into unmeasured areas (manual ops, external
services, environment assumptions). Every transferred function must have a named owner, tracked
operational cost, and rollback path.

**Rating:** The adversarial review rated TRIZ trimming as the "best single mechanism" for local
elimination of unnecessary components.

---

## Coupling frameworks

**Axiomatic Design — source:** Nam Pyo Suh, MIT (late 1970s onward).

**Axiom 1 (Independence):** Maintain the independence of functional requirements. Ideally each
FR is satisfied by exactly one design parameter without side effects on other FRs (uncoupled
design).

**Axiom 2 (Information):** Minimize the information content — among designs satisfying Axiom 1,
the one with the least information content (lowest complexity, highest probability of success)
is best.

**Application:** Build an FR × DP trace matrix. Off-diagonal entries indicate coupling. If
changing one FR's design parameter forces changes to another FR's implementation, the design
is coupled and should be refactored.

**Hickey's decomplecting — source:** Rich Hickey, "Simple Made Easy" (Strange Loop 2011).

**Key distinction:** Simple = "one fold/braid" (objective: how interleaved is it?). Easy =
"near at hand/familiar" (subjective). Complexity is not the number of parts but how tangled
they are.

**The verb:** "Complect" = to interleave or entwine. State complects value and time; objects
complect state, identity, and behavior. Separate classes that make deep assumptions about each
other are still complected.

**Application:** For each module/component, ask what other concerns it is braided with and
whether they could stand apart. Common tangles to look for: state+time, policy+mechanism,
schema+transport, configuration+code.

---

## Security frameworks

**Saltzer & Schroeder (1975) — source:** "The Protection of Information in Computer Systems."

**Economy of mechanism:** Keep the design as simple and small as possible. Simpler designs have
fewer places for latent flaws.

**Least privilege:** Every program and user should operate with the minimum privileges necessary.

**Least common mechanism:** Minimize mechanism shared across trust boundaries.

**Complete mediation:** Every access to every object must be checked for authority.

**Application to agentic systems (from adversarial review):** These principles map directly to
agent design: tool access should be tightly scoped (least privilege), trust boundaries should
not share infrastructure (least common mechanism), every tool call should be validated (complete
mediation), and controls should be simpler than the risks they mitigate (economy of mechanism).

**OWASP agentic guidance:** Remote/indirect prompt injection, RAG poisoning, tool manipulation,
and context poisoning are live risks. Separate instructions from external data, sanitize remote
content, validate outputs, constrain tools, use human-in-the-loop for irreversible actions.

---

## Debiasing frameworks

**Complexity bias:** Documented tendency to prefer elaborate solutions and equate complexity with
intelligence. Farris & Revlin (1989) cited as evidence of inherent bias toward complex hypotheses.

**Additive bias:** Adams et al. (Nature, 2021) showed people systematically default to adding
components rather than subtracting them, even when subtraction is objectively better. This is
why the subtractive forcing prompt is mandatory — subtraction must be explicitly prompted.

**IKEA effect:** Norton, Mochon & Ariely (Journal of Consumer Psychology, 2012). People
overvalue things they partially created. In engineering: teams over-value custom-built frameworks
over simpler off-the-shelf options. Debiasing prompt: "Would you choose this design if someone
else had built it and you had to maintain it?"

**Planning fallacy:** Kahneman & Tversky. Systematic underestimation of cost/time/scope from
the "inside view." Cure: reference-class forecasting (the "outside view") — base estimates on
the distribution of outcomes from similar past projects. Applied to scope: the inside view
inflates how much needs to be built.

**Bikeshedding (Parkinson's Law of Triviality):** Effort is inversely proportional to importance.
Simple, familiar parts attract gold-plating while genuinely complex decisions pass unscrutinized.

**Pre-mortem:** Gary Klein (HBR 2007). Assume the project has already failed, then generate
reasons. Mitchell, Russo & Pennington (1989) showed prospective hindsight increases correct
identification of failure reasons by 30%. Converts directly into a review prompt.

---

## Software heuristics

These are policy defaults and tiebreakers, not law. Use them to trigger justification demands.

**Choose Boring Technology (Dan McKinley, 2015):** Hard budget of ~3 "innovation tokens" —
novel technologies whose failure modes you don't understand. Every token costs in operational
overhead, debugging difficulty, and (for AI agents) reduced training-data reliability.

**Rule of Three (Fowler/Roberts):** Don't abstract until the third occurrence. First use is
concrete, second is duplicated (acceptable), third reveals the correct abstraction shape.
Premature abstraction is more expensive than duplication (Metz, "The Wrong Abstraction").

**Sandi Metz Rules:** Classes ≤100 lines, methods ≤5 lines, ≤4 parameters, controllers
instantiate one object. Numeric, lint-able. Rule Zero: break a rule only with explicit
justification your reviewer accepts.

**Worse Is Better (Gabriel, 1989):** Priority ordering: simplicity (especially implementation)
> correctness > consistency > completeness. Completeness sacrificed first. This is the
tie-break rule for the skill.

**Essential vs. accidental complexity (Brooks, 1986):** Essential complexity is inherent to the
problem. Accidental complexity is what we add via tools, frameworks, process. The review target
is accidental complexity. Essential complexity stays.

---

## Military planning

These provide the philosophical grounding for satisficing and minimal specification.

**Simplicity as Principle of War (ADP 3-0):** "Prepare clear, uncomplicated plans and concise
orders to ensure thorough understanding." The simple plan is the flexible plan.

**Commander's Intent / Auftragstaktik:** Specify the *what* and *why* (desired end state),
leave the *how* to the implementer. Over-specification of implementation detail is itself a
defect — it removes flexibility to choose the simplest mechanism.

**Satisficing over optimizing:** "A good plan violently executed now is better than a perfect
plan executed next week" (attributed to Patton). The Army's accelerated MDMP explicitly
forgoes the perfect COA for one that is suitable, feasible, and acceptable.

**OODA loop (Boyd):** Speed of iteration trades against completeness. The side that cycles
faster with simpler, good-enough decisions wins.

---

## Failure classes

The adversarial review identified three failure modes to defend against:

**1. Requirement laundering:** Optional, aesthetic, or speculative features get relabeled as
"requirements." Defense: trace every requirement to a human stakeholder or documented
constraint. Flag anything that says "we might need" or "for future flexibility."

**2. Function laundering:** The agent invents extra intermediate functions to justify extra
machinery. Defense: if two functions differ only by mechanism, merge them. Every secondary
function must name its parent basic function.

**3. Proxy gaming:** The agent optimizes a complexity metric superficially while hiding
complexity elsewhere (monolithic service, toolchain, external dependency, manual ops).
Defense: multi-axis scoring (moving parts, coupling, privilege, hidden state, ops burden,
concept count). Count transferred complexity, not just visible components.

---

## Caveats

**Evidentiary strength varies.** Saltzer & Schroeder, Axiomatic Design, MDL/BIC, and the
cognitive bias literature have strong empirical or formal foundations. "Worse Is Better,"
"Simple Made Easy," Choose Boring Technology, and Gall's Law are influential practitioner
arguments, not controlled research. Use them as design lenses, not proven laws.

**IKEA effect in engineering is an extrapolation.** The original studies used consumer products,
not engineering decisions. The "not invented here" application is reasonable but not a direct
empirical finding.

**Numeric thresholds are arbitrary by design.** Metz limits, innovation token budgets, and the
Rule of Three are deliberately round numbers meant to force a conversation. They should trigger
justification, not automatic rejection.

**Domain matters.** In regulated, safety-critical, or highly distributed systems, what looks
like "overbuild" from a local perspective may be the minimum acceptable structure from a
governance or reliability perspective. Non-functional requirements must be treated as potentially
basic functions, not dismissed as gold-plating.

**Simplicity and completeness genuinely trade off.** For safety-critical or regulatory contexts,
deliberate completeness may be correct. The skill surfaces the trade-off rather than silently
resolving it.

