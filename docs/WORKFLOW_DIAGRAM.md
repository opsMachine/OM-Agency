# Workflow System — Visual Map

> Generated from `workflow-router/SKILL.md` and all skill contracts. Keep in sync when paths change.

---

## Master Overview

All four entry points, how they converge, and where they terminate. Human gates are hexagons.

```mermaid
flowchart TD
    %% Entry points
    FEAT([Feature Request]) --> interview
    BUG([Bug Report]) --> triage
    SEC([Security Concern]) --> audit1
    META([Skill System Edit]) --> meta

    %% Feature path
    interview["/interview\n(direct)"] --> specDraft["Spec: Draft"]
    specDraft --> specReview["spec-review"]
    specReview --> gateA{{"Gate A\nApprove spec?\nTDD or Direct?"}}

    gateA -- "Revise" --> specEdit["Manager edits spec"]
    specEdit --> specReview
    gateA -- "Re-interview" --> interview
    gateA -- "TDD" --> planTests["plan-tests"]
    gateA -- "Direct" --> implDirect["implement-direct"]

    planTests --> writeFailing["write-failing-test"]
    writeFailing --> implToPass["implement-to-pass"]
    implToPass --> gateB{{"Gate B\nReview PR"}}
    implDirect --> gateB

    gateB -- "Code fix" --> implFix["Re-implement"]
    implFix --> gateB
    gateB -- "Spec issue" --> gateA
    gateB -- "Approved" --> qaHandoff["qa-handoff"]
    qaHandoff --> DONE([Done])
    DONE -. "QA failure\n→ new bug report" .-> BUG

    %% Bug path
    triage["Manager Triage\n(gather context)"] --> diagnose["diagnose\n(sub-agent)"]
    diagnose --> complexity{"Simple or\nComplex?"}
    complexity -- "Simple\n(Approved)" --> approved["Spec: Approved"]
    complexity -- "Complex\n(Draft)" --> specDraft

    approved --> choosePath{{"Choose path:\nTDD or Direct?"}}
    choosePath -- "TDD" --> planTests
    choosePath -- "Direct" --> implDirect

    %% Security path
    audit1["1-security-audit"] --> audit2["2-security-critique"]
    audit2 --> gateC{{"Gate C\nReview backlog"}}
    gateC -- "Reprioritize" --> audit2
    gateC -- "Proceed" --> loopCheck{"Pending\nitems?"}
    loopCheck -- "No" --> SECDONE([Security Done])
    loopCheck -- "Yes" --> secSpec["3-security-spec"]
    secSpec --> secFix["4-security-fix"]
    secFix --> loopCheck

    %% Meta path
    meta["Meta Path\n(manager direct)"] --> metaDone([OPERATIONAL_SYSTEM.md\nupdated])

    %% Styling
    classDef gate fill:#f9a825,stroke:#f57f17,color:#000,font-weight:bold
    classDef entry fill:#4fc3f7,stroke:#0288d1,color:#000
    classDef terminal fill:#81c784,stroke:#388e3c,color:#000
    classDef skill fill:#fff,stroke:#333

    class gateA,gateB,gateC,choosePath gate
    class FEAT,BUG,SEC,META entry
    class DONE,SECDONE,metaDone terminal
```

---

## Feature Path — Detail

Two branches (TDD and Direct) from a single approval gate. TDD is a locked sequence.

```mermaid
flowchart TD
    start([Feature Request]) --> hasSpec{"Spec\nexists?"}
    hasSpec -- "No" --> interview["/interview\n(direct, with human)"]
    hasSpec -- "Yes" --> checkStatus

    interview --> specCreated["Spec created\nStatus: Draft"]
    specCreated --> checkStatus{"Spec\nstatus?"}

    checkStatus -- "Draft" --> specReview["spec-review\n(sub-agent)"]
    checkStatus -- "Approved" --> gateAskip

    specReview --> gateA{{"GATE A\nSpec review findings\npresented to human"}}

    gateA -- "Revise\n(manager edits)" --> specReview
    gateA -- "Re-interview" --> interview
    gateA -- "Approve + TDD" --> tddPath
    gateA -- "Approve + Direct" --> directPath

    gateAskip{{"Choose:\nTDD or Direct?"}} -- "TDD" --> tddPath
    gateAskip -- "Direct" --> directPath

    %% TDD Branch
    subgraph TDD ["TDD Path (locked sequence)"]
        tddPath["plan-tests"] --> hasPlan{"Test Plan\nstatus?"}
        hasPlan -- "Planned" --> writeFail["write-failing-test"]
        hasPlan -- "Tests Written" --> implPass
        writeFail --> testsRan{"Tests ran\nand failed?"}
        testsRan -- "Yes" --> implPass["implement-to-pass"]
        testsRan -- "BLOCKED" --> fixBlocker["Fix infra blocker\nbefore proceeding"]
        fixBlocker --> writeFail
        implPass --> gateB
    end

    %% Direct Branch
    subgraph Direct ["Direct Path"]
        directPath["implement-direct"] --> gateB
    end

    %% Gate B
    gateB{{"GATE B\nHuman reviews PR\n+ satisfaction assessment"}}
    gateB -- "Code fix" --> reimpl["Re-implement\n(with feedback)"]
    reimpl --> gateB
    gateB -- "Spec issue" --> gateA
    gateB -- "Approved" --> qa["qa-handoff"]
    qa --> done([Done])
    done -. "QA failure?\nRe-enters as\nbug report" .-> bugEntry([Bug Path])

    classDef gate fill:#f9a825,stroke:#f57f17,color:#000,font-weight:bold
    classDef terminal fill:#81c784,stroke:#388e3c,color:#000
    class gateA,gateAskip,gateB gate
    class done,bugEntry terminal
```

---

## Bug Path — Detail

Manager triages, sub-agent investigates, complexity determines routing. Both branches converge into the Feature implementation paths.

```mermaid
flowchart TD
    start([Bug Reported]) --> hasIssue{"GitHub\nissue?"}
    hasIssue -- "Yes" --> readIssue["Read issue\n(dispatch read)"]
    hasIssue -- "No" --> askHuman

    readIssue --> askHuman["Manager asks human:\n- Actual behavior\n- Expected behavior\n- Reproduction steps\n- When started\n- Environment"]

    askHuman --> checkpoint["Triage Checkpoint\n(structured output)"]
    checkpoint --> dispatch["Dispatch diagnose\nsub-agent"]

    dispatch --> diagnose["diagnose investigates:\n1. Hypothesize\n2. Verify (evidence)\n3. Confirm or revise\n4. Impact analysis\n5. Complexity assessment"]

    diagnose --> specWritten["Bug spec written"]
    specWritten --> complexity{"Complexity?"}

    complexity -- "Simple" --> approved["Status: Approved\n(skip review)"]
    complexity -- "Complex" --> draft["Status: Draft"]

    draft --> specReview["spec-review\n(sub-agent)"]
    specReview --> gateA{{"GATE A\nReview complex bug\nimpact + approach"}}
    gateA -- "Revise" --> revise["Manager updates spec"]
    revise --> specReview
    gateA -- "Approve" --> chooseImpl

    approved --> chooseImpl{{"Choose:\nTDD or Direct?"}}

    chooseImpl -- "TDD" --> featureTDD(["Feature TDD Path\n(plan → red → green)"])
    chooseImpl -- "Direct" --> featureDirect(["Feature Direct Path\n(implement-direct)"])

    classDef gate fill:#f9a825,stroke:#f57f17,color:#000,font-weight:bold
    classDef converge fill:#ce93d8,stroke:#7b1fa2,color:#000
    class gateA,chooseImpl gate
    class featureTDD,featureDirect converge
```

---

## Security Path — Detail

4-phase pipeline with a fix loop. Isolated from feature/bug paths (uses SECURITY_PLAN.md, not specs).

```mermaid
flowchart TD
    start([Security Audit]) --> phase1["1-security-audit\nScan codebase\nCreate SECURITY_PLAN.md"]
    phase1 --> phase2["2-security-critique\nRed team review\nRemove false positives\nRank by exploitability"]

    phase2 --> gateC{{"GATE C\nHuman reviews\nranked backlog"}}
    gateC -- "Reprioritize" --> phase2
    gateC -- "Looks right" --> loop

    loop{"Pending\nitems in\nbacklog?"}
    loop -- "No" --> done([Security Complete])
    loop -- "Yes" --> phase3["3-security-spec\nPick top item\nWrite failing test"]

    phase3 --> phase4["4-security-fix\nImplement fix\nVerify test passes\nMark item DONE"]
    phase4 --> loop

    classDef gate fill:#f9a825,stroke:#f57f17,color:#000,font-weight:bold
    classDef terminal fill:#81c784,stroke:#388e3c,color:#000
    class gateC gate
    class done terminal
```

---

## Status State Machines

Three independent status tracks. Each is a strict progression — no skipping or reordering.

### Spec Status

```mermaid
stateDiagram-v2
    [*] --> Draft : interview creates\nor diagnose (complex)
    [*] --> Approved : diagnose (simple)
    Draft --> Approved : human approves\n(after spec-review + Gate A)
    Draft --> Draft : revise
    Approved --> Implemented : implement-direct\nor implement-to-pass
    Implemented --> [*]
```

### Test Plan Status

```mermaid
stateDiagram-v2
    [*] --> Planned : plan-tests
    Planned --> TestsWritten : write-failing-test\n(tests must actually run)
    Planned --> BLOCKED : infra issue\n(e.g. runtime not in PATH)
    BLOCKED --> Planned : fix blocker
    TestsWritten --> Passing : implement-to-pass
    Passing --> [*]

    note right of TestsWritten : Tests ran and failed correctly
```

### GitHub Issue Status

```mermaid
stateDiagram-v2
    [*] --> Backlog : issue created
    Backlog --> Ready : spec approved\nor diagnose complete
    Ready --> InProgress : user starts work
    InProgress --> InReview : implementation done\n+ PR opened
    InReview --> QA : qa-handoff
    QA --> Done : user merges
    Done --> [*]
```

---

## Observations

What jumps out from seeing the system visually.

### Solid

- **Bug → Feature convergence** is clean. Both paths arrive at "Approved spec → choose TDD or Direct" — same implementation skills, same gates. No special bug-specific implementation path needed.
- **Security isolation** is airtight. Completely separate state machine, no accidental crossover.
- **Human gates** are well-placed: after design (A), after implementation (B), after security triage (C). No automation runs without approval at the right moment.
- **TDD sequence** is locked and verified — the BLOCKED state prevents false advancement.

### Gaps & Opportunities

1. ~~**"Revise" at Gate A is underspecified.**~~ **Addressed.** Gate A now has separate "Revise" (manager edits spec, re-dispatches spec-review) and "Re-interview" (full restart) options. Feature path is now consistent with bug path, which already had this pattern.

2. **No dedicated refactor path.** Diagnosis flags code smell → complex bug → spec-review → Gate A. But "fix the bug" and "address the underlying code smell" are different scopes. The human has to manually scope down at Gate A. A refactor could be a separate spec/issue rather than bundled into the bug fix.

3. ~~**Gate B "changes needed" is a black box.**~~ **Addressed.** Gate B now asks "what kind of change?" and routes to code fix (re-implement), re-test, or spec issue (back to Gate A).

4. **No pre-interview path.** Feature starts at `interview` which expects you to know what you want. There's no brainstorm/discovery/exploration phase for "I have a vague idea." The user has to do that thinking externally before entering the system.

5. **Meta Path has no quality gate.** Features get spec-review, security gets critique, but skill system edits go straight from "make changes" to "update OPERATIONAL_SYSTEM.md." For a solo founder this is fine (you are the gate), but worth noting the asymmetry.

6. ~~**qa-handoff is terminal but there's no "QA failed" re-entry.**~~ **Addressed.** QA failures re-enter as new bug reports through the Bug Path. Now explicit in diagrams (dashed re-entry edge) and workflow-router constraints.

7. **No "skip" affordance.** The human can redirect the manager at any time, but there's no explicit "skip spec-review" or "skip tests" shortcut. The manager protocol says workflow steps are flexible, but the decision trees don't show skip edges.
