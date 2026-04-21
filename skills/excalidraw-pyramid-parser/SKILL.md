---
name: excalidraw-pyramid-parser
description: Parse and iteratively refine .excalidraw strategic pyramid maps. Use whenever the user uploads a .excalidraw file, mentions a pyramid map, leverage map, strategy canvas, or asks "help me think through this", "what's missing", "where's the leverage". This is a multi-iteration strategic mapping methodology, not a one-shot parse — be prepared to facilitate restructuring across multiple rounds, push toward focus and granularity, and apply the patterns and discipline below.
---

# Excalidraw Pyramid Parser & Strategic Mapping Partner

*Last updated: 2026-04-21*

## What this skill does

Two-layer skill:

1. **Parser layer**: reads the `.excalidraw` JSON and reconstructs the node-and-arrow graph as structured text the AI can reason about
2. **Methodology layer**: facilitates iterative strategic mapping — knowing when to restructure, when to trim, when to add metrics, when to push for granularity, when to hold instead of resolve

The pyramid is not a static artifact. It's an iterative thinking tool that goes through several distinct phases (concept → structure → metric → granularity → daily activity). Each phase has different work to do. This skill knows the shape of that process.

---

## How to parse the file

### Step 1 — Extract active nodes

Read the `elements` array. For each element:
- Keep only elements where `"isDeleted": false`
- Keep only `type: "rectangle"` (or other shapes) that have a bound text child
- The label is on the child text element where `containerId` matches the shape's `id`
- Ignore freestanding text elements (those with no `containerId`) unless they are clearly section labels (e.g., "Container Layer (largely missing — current bottleneck)")

Build a node map: `{ id → label, x, y, color, dashed? }`

### Step 2 — Extract arrows

For each element with `type: "arrow"` and `isDeleted: false`:
- Read `startBinding.elementId` → source node
- Read `endBinding.elementId` → target node
- Arrow direction: `startBinding` → `endBinding` (arrowhead is at end)
- This means: source node **feeds into** target node

Build an edge list: `[ { from: label, to: label } ]`

### Step 3 — Infer hierarchy from Y position (loose)

Sort nodes by Y coordinate (lower Y = higher on canvas = higher in pyramid).

Cluster nodes by Y proximity (~50-100px) into tiers. **But hold tier inference loosely** — in mature diagrams, the visual layout may diverge from a strict tier structure. Use color, arrow direction, and node content as cross-checks.

### Step 4 — Detect cross-links

A cross-link is an arrow where:
- The source and target are not on adjacent levels, OR
- The source feeds multiple parents at different levels

Flag these explicitly — they represent shared leverage points and are strategically significant. Cross-link tactics often carry disproportionate weight (one tactic addressing 2 drivers does more work per unit of effort than 2 single-driver tactics).

### Step 5 — Note styling signals

- **Color** often encodes role (e.g., gold = vision, purple = criteria, blue = drivers, green = single-driver tactics, red = cross-link tactics, muted orange = container/operations layer)
- **Dashed strokes** often indicate placeholder / TBD / known gap
- **Sub-bullets inside a single node** indicate consolidated items that share inbound/outbound connections (e.g., "Client Fit" supercategory containing 4 sub-criteria)

---

## The iterative methodology

A pyramid map is built across multiple iterations. Don't try to get the final structure on first pass. Expect 3-6 iterations to reach focus.

### Typical iteration arc

1. **Round 1 (sketch)**: dump everything you're thinking about into nodes. Many items, many arrows, lots of cross-links. Probably visually messy. **This is correct for round 1** — it's a brain dump, not a design.
2. **Round 2 (structuring)**: identify what's missing (e.g., "what's the actual top-level goal?"), add or invert tiers. Often an additional level becomes necessary — above the current top (e.g., "life vision" above "company goals") or below the current bottom (e.g., "container/operations" beneath tactics).
3. **Round 3 (consolidation)**: notice items that share the same inbound/outbound connections — they can be combined into one node with sub-bullets. **This is the moment when complexity drops dramatically.** What looked like 6 criteria becomes 3-4. What looked like 4 separate drivers becomes 1 supercategory.
4. **Round 4 (metric injection)**: add metrics inside each node (`[metric: # leads/mo]`, `[metric: % passing all 4 sub-filters]`, `[metric: clients describe back accurately (qual)]`). This forces categorical clarification — productive vs expressive drivers become visible. Some "drivers" are revealed as enabling activities, not productive outputs.
5. **Round 5 (trim)**: remove weak arrows. Trimming produces more clarity than addition. **This is the first round where the diagram actually feels focused.**
6. **Round 6+ (granularity)**: add specific tactics and daily activities. The pyramid becomes a guide for what to actually do this week, not just a strategic abstraction.

### Sign you're ready to advance to the next round

- **Round 1 → 2**: "I keep adding things and they don't connect cleanly to a top goal" → time to define the goal and possibly add a tier above.
- **Round 2 → 3**: "I have nodes that all point to the same place via the same path" → time to consolidate.
- **Round 3 → 4**: "All my drivers feel equally important and I can't tell where to focus" → time to add metrics.
- **Round 4 → 5**: "The diagram is busy with arrows I don't need" → time to trim.
- **Round 5 → 6**: "The strategy is clear but I don't know what to do tomorrow" → time to go granular.

### Sign of a healthy iteration

After each iteration, the diagram should feel **more focused, not more comprehensive.** If iteration adds without removing, it's drifting. The goal is concentration, not coverage.

### The ultimate goal

**Get down to daily activities** so the pyramid can guide what to actually do this week. A pyramid that stops at the strategic-abstraction layer is unfinished. The user's framing: "this is where the real value starts to come in once we're getting to granular." Push gently toward granularity once the strategic structure is settled — but don't force it before consolidation/metric/trim work has happened.

---

## Patterns observed across iterations

### Initial complexity reduces through consolidation

Early versions seem complex because of an unstated need to combine items. **Things that share the same inbound and outbound connections belong in the same node.** They can be represented as sub-bullets in a single rectangle (an inline container/supercategory). The reduction in node count and arrow count after consolidation is often dramatic. Watch for this pattern as a signal that consolidation is overdue.

### Inverting levels creates clarity

Sometimes a node is at the wrong altitude. A "criterion" might really be a "driver of a higher criterion" (e.g., Articulable & referable was a top-level criterion in earlier versions, but it's actually a property that feeds Audience-condition match — it's a driver, not an outcome). When something doesn't fit cleanly at its current level, propose moving it.

### Metrics float to the top

Items with clear, quantitative outcome metrics tend to act as gravitational anchors at higher levels. They become criteria or top-level goals. Items that resist clean numerical metrics tend to fall into supporting roles (drivers or tactics). **This isn't a rule to enforce — it's an emergent pattern.** When a node resists a clear outcome metric, it often belongs at a different level than initially assumed.

### Quantitative and qualitative alternate

Levels often alternate in metric type. Quantitative outcome (revenue) → qualitative driver (positioning quality) → quantitative tactic (# leads) → qualitative skill (close craft). Don't try to make every level the same metric type. **The alternation is real and often correct.**

### Productive vs expressive drivers

Some drivers produce countable outputs (productive — quantitative metrics). Others exist to make a message land in others' minds (expressive — qualitative metrics only). The distinction is surfaced by the metric question:
- **Productive**: has a number metric. Keep iterating, measuring, refining.
- **Expressive**: only has qualitative descriptors. **Should be done-and-moved-on-from, not continuously iterated.** Iterating on expressive drivers is a category error — they don't get better through measurement, they get better by being deployed and observed.

### Cross-link tactics carry disproportionate weight

Tactics that feed multiple drivers do more work per unit of effort. They're often the highest-ROI items in the diagram. Surface them explicitly during analysis. If a cross-link tactic exists, prioritize it over single-driver tactics.

### Single points of failure

When one driver is the only feeder for a critical criterion, that's a structural vulnerability. Either accept and prioritize that driver explicitly, or surface what other driver should also feed the criterion. Single-input criteria are fragile.

### Container/operations is often missing AND orthogonal

A pure strategy pyramid often lacks the operating layer (review cadence, accountability, MVP measurement, iteration discipline, knowledge index). When this surfaces late, the natural move is to add a foundation tier. **But: container is structurally orthogonal to strategy** — it doesn't fit cleanly as a tier. It's a 4th dimension that 2D pyramids structurally can't carry without compromise. Solutions:
- Add as a foundation row with arrows pointing UP into the strategy nodes they enable (best for moderate complexity)
- Embed container items adjacent to the specific drivers they enable (good for high complexity; what advanced iterations often produce)
- Maintain a separate diagram (best when container becomes its own ongoing work)
- Annotate as a labeled background or matrix overlay

The container layer often only reveals itself after several iterations of strategic mapping when it becomes clear that strategy alone doesn't cause execution.

### Activities go vertical when the work is done well

Once the diagram is well-structured, activity-level nodes tend to cluster vertically rather than spread horizontally. **This isn't enforced — it's emergent.** Wide, busy diagrams are often a sign that consolidation hasn't happened yet. Don't try to force vertical layout; instead, look for what consolidation work would naturally produce verticality.

### Adding too many arrows early creates rework

It's tempting to draw every conceivable connection. But many "weak" arrows have to be removed in later rounds. **This rework is OK during exploration** — it's part of the process. But you can save iteration cycles by holding back from drawing speculative connections in the first place. If you can't articulate why an arrow exists, leave it out until you can.

### Audience portfolio framing (when relevant)

When the diagram has many doorways/intake points each serving different audiences, you're running a portfolio of audience experiments — not a single audience strategy. Naming it as such helps with strategic clarity. Portfolio management has its own discipline (narrowing triggers, signal density per segment, attention budget) distinct from single-audience commitment.

### Partner-mediated signal

If the diagram includes partnership doorways, note that the signal from those experiments is **partner-filtered, not raw audience signal.** Partner doorways and direct doorways answer different questions:
- Direct: "do end clients want this?"
- Partner: "does this partner want this and can they sell it to their network?"
Partner experiments can't substitute for direct audience signal even if they generate revenue.

### Conversion mechanics gap

Many strategy pyramids over-weight intake and qualification while under-weighting close mechanics (pricing, proposal, contract, onboarding). A 95/5 imbalance toward intake is common. **Flag this explicitly when you see it.** The "great upstream qualifying makes close easy" principle is partially true but doesn't replace close-mechanics work entirely. A placeholder driver for "Conversion mechanics (gap)" is honest representation.

---

## How to facilitate the conversation

### Hold early forms loosely

The first version of any diagram is wrong. Don't validate it as if it's the final. Note structural observations and propose iterations. The user's framing: "ultimately the goal of this is to bring focus."

### Trim discipline > addition discipline

When reviewing, look for what to **cut** before what to **add**. Removing weak arrows or merging redundant nodes produces more clarity than adding new ones. Cutting feels like loss; it's actually progress.

### The 4-part landing test

When the user proposes a reframe (new node, restructure, collapse, persona name), apply this test from positioning work:
- **Relief** — "I can stop trying to be something I'm not"
- **Clarity** — "this explains why X feels easy and Y feels hard"
- **Resistance** — "but I'm GOOD at the thing this discards"
- **Recognition** — "every successful case had this pattern"

A reframe is landing if all 4 are present. If any are missing, the reframe hasn't actually landed even if it sounds clean. Apply this to the user's restructures, not just yours.

### Don't resolve in brainstorm mode

When the user is in surfacing mode (generating possibilities, "let me share this with you"), don't push for decisions. When they're in resolution mode (picking among known options, "what should I do"), help narrow. Read the mode and match it. **"Let it sit"** is a valid disposition.

### The pyramid is diagnostic, not design

The diagram surfaces structural truths but doesn't produce the operating layer that makes work actually happen. Don't expect the diagram to do work it can't do. When the user asks "what should I do next" and the diagram has revealed a gap, the answer is often "build the operating container," not "iterate on the diagram more."

### Watch for the doc-in-drawer pattern

A pyramid that gets built and then never updated is a pyramid that's failing as a thinking tool. Periodically prompt for re-touch ("when did you last update this?", "does this still match how you're operating?"). Diagrams that don't live with the user become artifacts, not tools.

### Preserve prior versions

When making significant restructures, copy the current state to a versioned filename (e.g., `pyramid-v2-2026-04-20.excalidraw`) before modifying. This lets the user diff and see what changed across iterations, and protects against losing work that turns out to have been right.

---

## Output format

Produce this structure after parsing:

```
## Pyramid Map (Round N inferred)

**Top tier — [theme]:**
- [Node label] [color]

**Tier 2 — [theme]:**
- [Node A] → feeds [Goal]
- [Node B] → feeds [Goal]

**Tier 3 — [theme]:**
- [Node C] → feeds [Node A]
- [Node D] → feeds [Node A], [Node B]  ← cross-link

**Container / operations layer (if present):**
- [Container item X] → enables [Driver Y]

**Cross-links:**
- [Node D] feeds both [Node A] and [Node B] — shared lever

**Orphaned nodes (no connections):**
- [Node X] — not yet connected
```

Then immediately follow with strategic analysis (see below).

---

## Strategic analysis to run after parsing

### Iteration phase inference

Estimate which round the diagram appears to be in (sketch / structuring / consolidation / metric / trim / granularity). Surface what the next move would likely be:
- Many nodes, many arrows, no clear top → Round 1; needs goal definition
- Multiple parallel paths to same goal → Round 2; consider tier addition or inversion
- Items sharing inbound/outbound → Round 3; consolidation candidate
- All drivers feel equal weight → Round 4; metric injection needed
- Diagram busy with arrows → Round 5; trim candidates
- Strategic structure clear but no daily actions → Round 6; granularity needed

### Coverage gaps
- Are there levels with only one node? Single points of failure.
- Are there nodes at the bottom with no path to the top goal? Dead ends.
- Is the goal node fed by enough drivers to be robust?
- Are there major outcome dimensions missing (e.g., operational stability, articulability, audience)?

### Leverage concentration
- Which nodes have the most arrows pointing to them? High-leverage nodes — worth prioritizing.
- Which nodes have arrows coming in but none going out? Leaf nodes — are they actionable enough?
- Which nodes have most arrows leaving them? High-fan-out drivers — might be where strategic concentration is.

### Productive vs expressive driver audit
For each driver, ask: does it have a quantitative metric?
- If qualitative-only, label as expressive and note it should be done-and-moved-on, not iterated.
- If unmetered entirely, propose what its metric would be — the answer reveals its true nature.

### Cross-link significance
- Cross-links are shared levers. Flag them: "Node X contributes to both A and B — high-ROI node to develop."

### Consolidation candidates
- Nodes that share inbound and outbound connections are conceptually one thing. Flag them as candidates for combining into a single supercategory node with sub-bullets.

### Single-point-of-failure check
- For each criterion, count its inbound drivers. If only 1, flag as structural vulnerability.

### Container layer presence
- Does the diagram have an operating-container layer (review cadence, measurement, accountability, iteration discipline)?
- If missing, flag as a gap that often kills strategy execution even when strategy is correct.

### Daily activity presence
- Are there nodes representing concrete weekly/daily actions?
- If not, the strategy hasn't reached operational altitude yet. The pyramid is incomplete in the most important sense.

### Audience portfolio check (when applicable)
- If multiple intake nodes exist, list which audience each addresses.
- If audiences vary, flag as portfolio (not single strategy) and note narrowing-trigger question.

### Conversion-mechanics audit
- Count nodes/arrows on the intake/qualification side vs the close/conversion side.
- If the imbalance is severe (e.g., 90/10), flag the convert-side gap explicitly.

### Completeness prompt
End with 1-3 questions to help the user fill gaps:
- "What drives [underfed node]?"
- "How would you know if [goal] is achieved — is there a measurement node missing?"
- "Node X seems isolated — is it connected to something off-canvas?"
- "What's the next iteration round this diagram is asking for?"

---

## Tone and mode

- This is a strategic thinking tool, not a data extraction exercise
- Be direct: name what's strong, name what's weak, name what's missing
- Don't pad — if the map is clean, say so
- Be honest about iteration phase: it's OK to say "this is round 1 — we're not trying to make it perfect, we're trying to get everything visible"
- Surface meta-observations about the iteration process itself, not just the content
- When the user is letting something sit, don't push
- When the user proposes a reframe, apply the 4-part landing test, then react

---

## Example multi-iteration arc

### Round 1 user prompt: "Here's my map, what do you think?"
- Parse the diagram
- Note its iteration phase (likely sketch)
- Don't critique structure as if it's final
- Surface obvious structural questions (where's the goal? what level of abstraction is this?)
- Suggest consolidation candidates only if very clear

### Round 3 user prompt: "I restructured. Now what?"
- Re-parse
- Compare to prior version — note what changed and what insights emerged from the change itself
- Identify what's still missing (often: metrics)
- Push toward the next iteration

### Round 5+ user prompt: "I'm done with the strategic frame, what's next?"
- Confirm whether they're really at frame-level or still iterating
- If genuinely settled, push toward granularity
- The container layer is often the missing piece at this point
- Once container is built, push toward daily-activity layer

---

## Notes on Excalidraw JSON quirks

- Deleted elements have `"isDeleted": true` — always filter these out
- A shape may have multiple text children in the JSON from edit history — only the non-deleted one with matching `containerId` is the real label
- Arrow `points` array encodes relative coordinates — ignore for topology, use `startBinding`/`endBinding` for graph structure
- Y axis increases downward in Excalidraw canvas coordinates (standard screen coords) — so lower Y = higher on visual canvas = higher in pyramid
- Multiple cross-links visually crowd the diagram — when this happens, look for consolidation opportunities (the items being cross-linked may want to be combined)
- Container/operating-layer items often look orthogonal in the layout (no clean tier home) — that's a real structural feature, not a layout problem
- Standalone text elements (no `containerId`) are sometimes section headers (e.g., "Container Layer (largely missing)") — preserve them; they encode the user's annotations about the diagram itself
- Dashed strokes (`strokeStyle: "dashed"`) often mark placeholder / TBD / known-gap nodes — read them as honest acknowledgments, not weakness
- Sub-bullet text inside a single node (e.g., "- Audience clarity / - Forcing-event match / ...") indicates a consolidated supercategory — treat these sub-items as conceptually distinct but structurally bound
