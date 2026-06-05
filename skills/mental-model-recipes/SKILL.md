---
name: mental-model-recipes
description: >
  Applies the Cognitive Operations Architecture — structured thinking recipes built from
  lenses (what to notice), operations (what to do), and recipes (specific sequences for
  specific problems) — to user queries. This skill triggers on ALL user queries unless
  the query starts with "Answer:". Each exchange produces 4 NEW artifacts with
  incrementing turn numbers (never overwriting previous ones): (1) natural answer
  without the skill, (2) cognitive signature analysis, (3) recipe reasoning trace,
  (4) recipe-enhanced answer. Even for "Answer:" queries, gently suggests the full
  analysis if the query clearly involves decisions, strategy, diagnosis, problem-solving,
  innovation, persuasion, or any complex reasoning where the recipes would add
  significant value. Use this skill extremely broadly — when in doubt, use it.
---

# Mental Model Recipes

Apply the Cognitive Operations Architecture to produce deeper thinking than default reasoning.

## Response Modes

### Mode 1: Full Analysis (default — query does NOT start with "Answer:")

Create 4 NEW markdown artifacts and present them to the user.

**CRITICAL — Turn Numbering:** Every set of 4 artifacts must use a unique turn number so that previous artifacts are preserved (not overwritten). Track which turn you are on in the conversation. The first time this skill fires, use `01`. The second time, use `02`. And so on. Artifact filenames follow the pattern:

- `natural-answer-01.md`, `cognitive-signature-01.md`, `recipe-trace-01.md`, `recipe-answer-01.md`
- `natural-answer-02.md`, `cognitive-signature-02.md`, `recipe-trace-02.md`, `recipe-answer-02.md`
- ...and so on for each subsequent exchange.

NEVER reuse a turn number. NEVER use bare filenames without a turn number. If you are unsure what turn you are on, count the sets of artifacts already created in this conversation and increment by one.

**Artifact 1: `natural-answer-{NN}.md` — Baseline Answer**
The answer you would give if this skill did not exist. Direct, drawing on general knowledge and standard reasoning. No recipe influence. This is the control group.

**Artifact 2: `cognitive-signature-{NN}.md` — User's Cognitive Signature**
Analyze the user's default thinking patterns as revealed in THIS conversation only (not from memory or prior chats). Identify:
- **Default operations**: What does their mind do automatically? Look at how they framed their query.
- **Default lenses**: What do they naturally notice or emphasize?
- **Likely blind spots**: Which operations and lenses are absent from their framing?
- **Data confidence**: If early in the conversation with limited data, state this honestly. Still offer your best inference from the framing, word choice, and structure of their question — even a single query reveals which operations are active and which are absent.

Use the detection heuristics in the Cognitive Signature Analysis section below.

**Artifact 3: `recipe-trace-{NN}.md` — Reasoning Trace**
Show your full thinking process:
1. Which recipe you selected and why (including alternatives considered)
2. Each step of the recipe as executed
3. The specific operation, move, and lens applied at each step
4. What each step revealed — the actual insight produced
5. Any "abandon when surprised" moments encountered
6. How the recipe's output differs from the natural answer and why

**Artifact 4: `recipe-answer-{NN}.md` — Recipe-Enhanced Answer**
The answer produced by running the recipe. This must be QUALITATIVELY different from Artifact 1 — not a more polished version but a fundamentally reframed answer that reveals dimensions the natural answer could not access.

### Mode 2: Direct Answer (query starts with "Answer:")

Respond normally without artifacts or recipe processing. However, if the query clearly involves complex reasoning (decisions, strategy, diagnosis, stuck problems, high-stakes evaluation), append a brief note:

> 💡 *This seems like a question where the mental model recipes could surface dimensions you might not see otherwise. Want me to run the full analysis?*

---

## The Framework

### Three Types of Thinking Tools

**Lenses** tell you WHAT to notice. They direct attention to specific patterns in reality.
→ Full catalogue: `references/lenses-catalogue.md`

**Operations** tell you what to DO with what you notice. They are reasoning procedures that transform observations into specific types of insight.
→ Full reference: `references/operations-moves.md`

**Recipes** combine specific operations through specific lenses in a specific sequence, designed for a specific type of problem.
→ Full procedures split across six files:
  - `references/recipes-part1.md` (R1–R6: Strategic Decision-Making)
  - `references/recipes-part2.md` (R7–R11: Innovation & Creation)
  - `references/recipes-part3.md` (R12–R16: Diagnosis & Problem Solving)
  - `references/recipes-part4.md` (R17–R24: Risk & Uncertainty + Communication & Persuasion)
  - `references/recipes-part5.md` (R25–R32: Learning & Understanding + Execution & Implementation)
  - `references/recipes-part6.md` (R33–R40: Relationships & Negotiation + Personal Development + Systems & Organizational)

### The 9 Operations (Quick Reference)

Always keep these signature questions accessible — they are the core activation mechanism.

| # | Operation | Function | Signature Question |
|---|-----------|----------|--------------------|
| 1 | **First Principles** | DECONSTRUCT | "What would I believe about this with zero prior knowledge and only direct observation?" |
| 2 | **Falsification** | EVALUATE | "What evidence would prove this wrong? Does that evidence exist?" |
| 3 | **Analogical Reasoning** | GENERATE | "What field has already solved a structurally similar problem?" |
| 4 | **Abductive Reasoning** | GENERATE | "What would have to be true to make this observation non-surprising?" |
| 5 | **Counterfactual Analysis** | GENERATE | "What would change — and what wouldn't — if this one factor were different?" |
| 6 | **Dialectical Synthesis** | INTEGRATE | "What becomes visible ONLY when I take both sides seriously at the same time?" |
| 7 | **Systems Thinking** | INTEGRATE | "What does this connect to that nobody is tracking, and what feedback loops are operating invisibly?" |
| 8 | **Bayesian Updating** | EVALUATE | "Given this new evidence, precisely how much should my confidence change?" |
| 9 | **Perspective Simulation** | INTEGRATE | "What would the smartest, most informed advocate of this position say — and what do they see that I'm missing?" |

---

## Problem-Type → Recipe Mapping

Use this table to select the right recipe. The left column describes what the user is experiencing; match it to the recipe.

### Strategic Decision-Making (Can't choose)
| Signal in user's query | Recipe |
|------------------------|--------|
| Stuck for weeks, analysis getting sophisticated but no breakthroughs | **R1: Wrong-Problem Detector** |
| High-stakes choice, incomplete information, needs to decide | **R2: Decision Clarifier** |
| Knows WHAT to do, unsure HOW MUCH to commit | **R3: Bet Sizer** |
| Torn between doubling down and pivoting | **R4: Pivot Evaluator** |
| Right move identified, timing uncertain | **R5: Timing Optimizer** |
| Considering quitting something, can't tell if wisdom or weakness | **R6: Exit Strategist** |

### Innovation & Creation (Can't create)
| Signal | Recipe |
|--------|--------|
| Exhausted obvious approaches, needs genuine novelty | **R7: Innovation Engine** |
| Wants to produce new understanding, not just retrieve known knowledge | **R8: Knowledge Creation Engine** |
| Crowded space, needs to redefine the game | **R9: Category Creator** |
| Facing a "fixed" limitation, suspects it might be an advantage | **R10: Constraint Alchemist** |
| Conventional wisdom feels wrong but can't articulate why | **R11: Paradigm Breaker** |

### Diagnosis & Problem-Solving (Can't diagnose)
| Signal | Recipe |
|--------|--------|
| Suspects missing something, metrics look fine but gut says otherwise | **R12: Blind Spot Finder** |
| Same problem keeps returning despite repeated fixes | **R13: Root Cause Excavator** |
| Progress has plateaued, working harder but results flat | **R14: Stagnation Breaker** |
| Situation too tangled for anyone to see clearly, paralysis by analysis | **R15: Complexity Reducer** |
| Keeps falling into known bad pattern despite awareness | **R16: Pattern Interrupt** |

### Risk & Uncertainty (Can't predict)
| Signal | Recipe |
|--------|--------|
| Needs to prepare for unpredictable catastrophic events | **R17: Black Swan Preparedness Protocol** |
| Must decide now, key information won't arrive in time | **R18: Uncertainty Navigator** |
| Upside attractive but downside could be fatal | **R19: Downside Limiter** |
| Wants to build something that benefits from volatility | **R20: Antifragility Designer** |

### Communication & Persuasion (Can't persuade)
| Signal | Recipe |
|--------|--------|
| Has a position but it keeps failing to persuade | **R21: Argument Strengthener** |
| Understands deeply but can't make it land for audience | **R22: Audience Translator** |
| About to present to critical/skeptical audience | **R23: Objection Anticipator** |
| Has data/evidence but no compelling narrative | **R24: Narrative Constructor** |

### Learning & Understanding (Can't understand)
| Signal | Recipe |
|--------|--------|
| Expert does something brilliantly but can't explain how | **R25: Mental Model Extractor** |
| Needs functional competence in a new domain fast | **R26: Expertise Accelerator** |
| Suspects deep unexamined assumptions constrain thinking | **R27: Assumption Archaeologist** |
| Has expertise in Domain A, wants to apply to Domain B | **R28: Transfer Engine** |

### Execution & Implementation (Can't execute)
| Signal | Recipe |
|--------|--------|
| High effort but low throughput, something constraining the system | **R29: Bottleneck Finder** |
| Overwhelmed by complexity, needs simplest viable version | **R30: Minimum Viable Path** |
| About to implement major change, needs to anticipate cascading effects | **R31: Unintended Consequences Scanner** |
| Plan looks good on paper, nagging sense something will break | **R32: Implementation Stress Test** |

### Relationships & Negotiation (Can't align)
| Signal | Recipe |
|--------|--------|
| Entering a high-stakes negotiation | **R33: Negotiation Mapper** |
| Two parties locked in opposition, compromise rejected | **R34: Conflict Resolver** |
| Multiple parties with different priorities need to agree | **R35: Stakeholder Aligner** |

### Personal Development & Identity (Can't grow)
| Signal | Recipe |
|--------|--------|
| Outdated identity constraining growth | **R36: Identity Audit** |
| Mastered current level, competent but not growing | **R37: Growth Edge Finder** |
| Stated values and actual behavior in conflict | **R38: Values Clarifier** |

### Systems & Organizational (Can't change the system)
| Signal | Recipe |
|--------|--------|
| Smart people consistently doing counterproductive things | **R39: Incentive Auditor** |
| Good ideas keep dying inside the organization | **R40: Org Immune System Detector** |

---

## Recipe Selection Process

1. **Read the query.** What type of stuck is the user experiencing?
2. **Match to the mapping table.** If multiple recipes could apply, select the one matching the PRIMARY type of stuck. Note alternatives in Artifact 3.
3. **Read the full recipe** from the appropriate reference file:
   - `references/recipes-part1.md` for R1–R6
   - `references/recipes-part2.md` for R7–R11
   - `references/recipes-part3.md` for R12–R16
   - `references/recipes-part4.md` for R17–R24
   - `references/recipes-part5.md` for R25–R32
   - `references/recipes-part6.md` for R33–R40
   Check the "When NOT to use" conditions — if they apply, note this and use the simpler heuristic the recipe provides instead.
4. **Execute step by step.** For each step, read the relevant operation/move from `references/operations-moves.md` and the relevant lens from `references/lenses-catalogue.md` as needed. Do NOT read all reference files upfront.
5. **Watch for "abandon when surprised" signals** at each step. If triggered, follow the recipe's guidance.

### When No Recipe Fits Cleanly

Some queries don't map to a specific recipe but still benefit from the framework. In these cases:
- Identify the 2-3 most relevant operations
- Select appropriate lenses
- Construct an ad-hoc sequence and document your reasoning in Artifact 3
- This is valid — recipes are named sequences, but the operations work independently too

---

## Cognitive Signature Analysis

To generate Artifact 2, examine HOW the user framed their query. Each framing choice reveals which operations are active in their default thinking:

| What you observe in their query | Active operation |
|---------------------------------|-----------------|
| Broke the problem into foundational parts | First Principles |
| Mentioned parallels, analogies, "it's like..." | Analogical Reasoning |
| Asked "what if X were different?" | Counterfactual Analysis |
| Expressed skepticism, tried to poke holes | Falsification |
| Estimated likelihoods, expressed calibrated uncertainty | Bayesian Updating |
| Wondered "what would explain this?" | Abductive Reasoning |
| Mapped connections between things, mentioned ripple effects | Systems Thinking |
| Argued both sides, sought synthesis | Dialectical Synthesis |
| Tried to understand another's perspective | Perspective Simulation |

**Operations NOT represented in their framing are likely blind spots.** Do not list every missing operation — select the **2-3 operations most likely to be useful for the user's specific problem** and explain what each would reveal. The goal is actionable insight, not an exhaustive gap analysis.

**Data confidence levels:**
- Single query, early in chat → "Based on limited data (one query), here's what I can infer..." Still provide analysis but flag the constraint.
- Several exchanges → More confident signature with specific examples from the conversation.
- Extended conversation → Full signature with pattern evidence.

---

## Reference File Usage

Read these DURING recipe execution, not upfront:

| File | Contains | Read when |
|------|----------|-----------|
| `references/lenses-catalogue.md` | ~90 lenses across 10 categories with descriptions | A recipe step calls for a specific lens you need details on |
| `references/operations-moves.md` | 9 operations, 72 moves with full procedures | A recipe step calls for a specific operation/move you need to execute |
| `references/recipes-part1.md` | Recipes 1–6 (Strategic Decision-Making) | You've identified a recipe in the R1–R6 range to run |
| `references/recipes-part2.md` | Recipes 7–11 (Innovation & Creation) | You've identified a recipe in the R7–R11 range to run |
| `references/recipes-part3.md` | Recipes 12–16 (Diagnosis & Problem Solving) | You've identified a recipe in the R12–R16 range to run |
| `references/recipes-part4.md` | Recipes 17–24 (Risk & Uncertainty + Communication & Persuasion) | You've identified a recipe in the R17–R24 range to run |
| `references/recipes-part5.md` | Recipes 25–32 (Learning & Understanding + Execution & Implementation) | You've identified a recipe in the R25–R32 range to run |
| `references/recipes-part6.md` | Recipes 33–40 (Relationships & Negotiation + Personal Dev + Systems & Org) | You've identified a recipe in the R33–R40 range to run |

---

## Critical Reminders

- **4 NEW artifacts per exchange** — every non-"Answer:" query produces a fresh set of 4 artifacts with an incremented turn number (`-01`, `-02`, `-03`, ...). Never overwrite previous artifacts.
- **Artifact 4 must be qualitatively different from Artifact 1** — if the recipe didn't change the fundamental nature of the answer, something went wrong in execution. Re-examine.
- **Show your work in Artifact 3** — transparency about the thinking process is core to the value. The user learns the framework by watching it operate.
- **Cognitive signature should be specific and actionable**, not generic. "You tend toward First Principles thinking" is weak. "You decomposed this into parts before considering how the parts interact — suggesting Systems Thinking is underrepresented" is strong.
- **Honest about thin data** — don't overstate confidence in the cognitive signature when you have limited conversation history.
- **Read reference files lazily** — only when a recipe step requires specific lens/operation/move details. This keeps execution efficient.
- **When the recipe says "abandon when surprised"** — actually do it. The surprise is often more valuable than completing the recipe.
