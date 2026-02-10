---
name: skill-writer
description: Guide users through creating Agent Skills for Claude Code. Use when the user wants to create, write, author, or design a new Skill, or needs help with SKILL.md files, frontmatter, or skill structure.
---

# Skill Writer

This Skill helps you create well-structured Agent Skills for Claude Code that follow best practices and validation requirements.

## When to use this Skill

Use this Skill when:
- Creating a new Agent Skill
- Writing or updating SKILL.md files
- Designing skill structure and frontmatter
- Troubleshooting skill discovery issues
- Converting existing prompts or workflows into Skills

## Instructions

### Step 1: Determine Skill scope

First, understand what the Skill should do:

1. **Ask clarifying questions**:
   - What specific capability should this Skill provide?
   - When should Claude use this Skill?
   - What tools or resources does it need?
   - Is this for personal use or team sharing?

2. **Keep it focused**: One Skill = one capability
   - Good: "PDF form filling", "Excel data analysis"
   - Too broad: "Document processing", "Data tools"

### Step 2: Choose Skill location

Determine where to create the Skill:

**Personal Skills** (`~/.claude/skills/`):
- Individual workflows and preferences
- Experimental Skills
- Personal productivity tools

**Project Skills** (`.claude/skills/`):
- Team workflows and conventions
- Project-specific expertise
- Shared utilities (committed to git)

### Step 3: Create Skill structure

Create the directory and files:

```bash
# Personal
mkdir -p ~/.claude/skills/skill-name

# Project
mkdir -p .claude/skills/skill-name
```

For multi-file Skills:
```
skill-name/
├── SKILL.md (required)
├── reference.md (optional)
├── examples.md (optional)
├── scripts/
│   └── helper.py (optional)
└── templates/
    └── template.txt (optional)
```

### Step 4: Write SKILL.md frontmatter

Create YAML frontmatter with required fields:

```yaml
---
name: skill-name
description: Brief description of what this does and when to use it
---
```

**Field requirements**:

- **name**:
  - Lowercase letters, numbers, hyphens only
  - Max 64 characters
  - Must match directory name
  - Good: `pdf-processor`, `git-commit-helper`
  - Bad: `PDF_Processor`, `Git Commits!`

- **description**:
  - Max 1024 characters
  - Include BOTH what it does AND when to use it
  - Use specific trigger words users would say
  - Mention file types, operations, and context

**Optional frontmatter fields**:

- **allowed-tools**: Restrict tool access (comma-separated list)
  ```yaml
  allowed-tools: Read, Grep, Glob
  ```
  Use for:
  - Read-only Skills
  - Security-sensitive workflows
  - Limited-scope operations

- **contract**: Structured metadata for workflow chaining. Required for any skill that participates in the workflow system (see [Writing Contracts](#writing-contracts) below).
  ```yaml
  contract:
    tags: [tag1, tag2]
    state_source: spec | security_plan
    inputs:
      params:
        - name: spec_path
          required: true
      gates:
        - field: "Test Plan.status"
          value: "Planned"
    outputs:
      mutates:
        - field: "Test Plan.status"
          sets_to: "Tests Written"
      side_effects: ["Comments GitHub issue"]
    next: [implement-to-pass]
    human_gate: false
  ```

### Step 5: Write effective descriptions

The description is critical for Claude to discover your Skill.

**Formula**: `[What it does] + [When to use it] + [Key triggers]`

**Examples**:

✅ **Good**:
```yaml
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

✅ **Good**:
```yaml
description: Analyze Excel spreadsheets, create pivot tables, and generate charts. Use when working with Excel files, spreadsheets, or analyzing tabular data in .xlsx format.
```

❌ **Too vague**:
```yaml
description: Helps with documents
description: For data analysis
```

**Tips**:
- Include specific file extensions (.pdf, .xlsx, .json)
- Mention common user phrases ("analyze", "extract", "generate")
- List concrete operations (not generic verbs)
- Add context clues ("Use when...", "For...")

### Step 6: Structure the Skill content

Use clear Markdown sections:

```markdown
# Skill Name

Brief overview of what this Skill does.

## Quick start

Provide a simple example to get started immediately.

## Instructions

Step-by-step guidance for Claude:
1. First step with clear action
2. Second step with expected outcome
3. Handle edge cases

## Examples

Show concrete usage examples with code or commands.

## Best practices

- Key conventions to follow
- Common pitfalls to avoid
- When to use vs. not use

## Requirements

List any dependencies or prerequisites:
```bash
pip install package-name
```

## Advanced usage

For complex scenarios, see [reference.md](reference.md).
```

### Step 7: Add supporting files (optional)

Create additional files for progressive disclosure:

**reference.md**: Detailed API docs, advanced options
**examples.md**: Extended examples and use cases
**scripts/**: Helper scripts and utilities
**templates/**: File templates or boilerplate

Reference them from SKILL.md:
```markdown
For advanced usage, see [reference.md](reference.md).

Run the helper script:
\`\`\`bash
python scripts/helper.py input.txt
\`\`\`
```

### Step 8: Validate the Skill

Check these requirements:

✅ **File structure**:
- [ ] SKILL.md exists in correct location
- [ ] Directory name matches frontmatter `name`

✅ **YAML frontmatter**:
- [ ] Opening `---` on line 1
- [ ] Closing `---` before content
- [ ] Valid YAML (no tabs, correct indentation)
- [ ] `name` follows naming rules
- [ ] `description` is specific and < 1024 chars

✅ **Content quality**:
- [ ] Clear instructions for Claude
- [ ] Concrete examples provided
- [ ] Edge cases handled
- [ ] Dependencies listed (if any)

✅ **Testing**:
- [ ] Description matches user questions
- [ ] Skill activates on relevant queries
- [ ] Instructions are clear and actionable

### Step 9: Test the Skill

1. **Restart Claude Code** (if running) to load the Skill

2. **Ask relevant questions** that match the description:
   ```
   Can you help me extract text from this PDF?
   ```

3. **Verify activation**: Claude should use the Skill automatically

4. **Check behavior**: Confirm Claude follows the instructions correctly

### Step 10: Debug if needed

If Claude doesn't use the Skill:

1. **Make description more specific**:
   - Add trigger words
   - Include file types
   - Mention common user phrases

2. **Check file location**:
   ```bash
   ls ~/.claude/skills/skill-name/SKILL.md
   ls .claude/skills/skill-name/SKILL.md
   ```

3. **Validate YAML**:
   ```bash
   cat SKILL.md | head -n 10
   ```

4. **Run debug mode**:
   ```bash
   claude --debug
   ```

## Common patterns

### Read-only Skill

```yaml
---
name: code-reader
description: Read and analyze code without making changes. Use for code review, understanding codebases, or documentation.
allowed-tools: Read, Grep, Glob
---
```

### Script-based Skill

```yaml
---
name: data-processor
description: Process CSV and JSON data files with Python scripts. Use when analyzing data files or transforming datasets.
---

# Data Processor

## Instructions

1. Use the processing script:
\`\`\`bash
python scripts/process.py input.csv --output results.json
\`\`\`

2. Validate output with:
\`\`\`bash
python scripts/validate.py results.json
\`\`\`
```

### Multi-file Skill with progressive disclosure

```yaml
---
name: api-designer
description: Design REST APIs following best practices. Use when creating API endpoints, designing routes, or planning API architecture.
---

# API Designer

Quick start: See [examples.md](examples.md)

Detailed reference: See [reference.md](reference.md)

## Instructions

1. Gather requirements
2. Design endpoints (see examples.md)
3. Document with OpenAPI spec
4. Review against best practices (see reference.md)
```

## Writing Contracts

If your skill participates in the workflow system (feature path, bug path, security path), add a `contract:` block to frontmatter. The contract is what makes chaining programmatic — the `workflow-router` reads contracts to build decision trees and a manager agent uses them to auto-chain skills.

### Contract fields

```yaml
contract:
  tags: [tag1, tag2]           # Capability tags. Used for discovery (see Tag Lookup in workflow-router).
                               # Common: intake, tdd, implementation, testing, security, github, closure
  state_source: spec           # Which artifact holds this skill's state. Values: spec | security_plan
  inputs:
    params:                    # Explicit arguments the skill requires
      - name: spec_path
        required: true
    gates:                     # State conditions that must be true BEFORE this skill runs.
      - field: "status"        # Field path inside the state artifact
        value: "Approved"      # Must equal this value. Router checks this before allowing invocation.
  outputs:
    mutates:                   # State fields this skill WRITES. Router uses this to know what gates will be satisfied next.
      - field: "Test Plan.status"
        sets_to: "Tests Written"
    side_effects: []           # Transparency: list non-state side effects (e.g. "Comments GitHub issue")
  next: [skill-name]           # Skills that are valid to run AFTER this one. Router presents these as options.
  human_gate: false            # If true: workflow pauses for human approval AFTER this skill completes.
                               # The skill AFTER the gate is not invoked until the human says go.
```

### When to use shared primitives

**Read `DESIGN.md` first** to understand the shared/ vs primitives/ architecture.

If your skill needs general methodology that applies to ANY project, reference existing shared docs or propose creating a new one:

**Existing shared docs:**
```markdown
> See shared/github-ops.md for posting comments and updating project status.
> See shared/spec-io.md for reading acceptance criteria and updating Test Plan status.
> See shared/e2e-patterns.md for E2E testing patterns (Playwright, reconnaissance-then-action).
> See shared/test-planning.md for test granularity framework (when to combine vs split tests).
```

**When to create a NEW shared doc:**
- Pattern applies to ANY project (not project-specific)
- Used by multiple skills (avoid duplication)
- Methodology, not facts (facts go in primitives/)
- Examples: testing methodology, deployment patterns, code review checklists

**When to reference primitives instead:**
- Project-specific conventions: `primitives/testing-conventions.md`
- Project facts: `primitives/stack.md`
- See `DESIGN.md` → "Why Shared vs Primitives" for the decision rule

Keep your step headers (e.g. "Step 7: Update GitHub Issue") so the skill's flow is readable. Replace only the implementation details under those steps with the reference.

### Example: a complete workflow skill frontmatter

```yaml
---
name: plan-tests
description: "Create a test plan for an approved spec..."
contract:
  tags: [tdd, test-planning]
  state_source: spec
  inputs:
    params:
      - name: spec_path
        required: true
    gates:
      - field: "status"
        value: "Approved"
  outputs:
    mutates:
      - field: "Test Plan.status"
        sets_to: "Planned"
    side_effects: []
  next: [write-failing-test]
  human_gate: false
---
```

## Best practices for Skill authors

1. **One Skill, one purpose**: Don't create mega-Skills
2. **Specific descriptions**: Include trigger words users will say
3. **Clear instructions**: Write for Claude, not humans
4. **Concrete examples**: Show real code, not pseudocode
5. **List dependencies**: Mention required packages in description
6. **Test with teammates**: Verify activation and clarity
7. **Version your Skills**: Document changes in content
8. **Use progressive disclosure**: Put advanced details in separate files
9. **Add a contract**: If your skill is part of the workflow, declare its contract. See [Writing Contracts](#writing-contracts) above.
10. **Use shared primitives**: Don't re-implement GitHub ops or spec reading. Reference `shared/github-ops.md` and `shared/spec-io.md`.

## Validation checklist

Before finalizing a Skill, verify:

- [ ] Name is lowercase, hyphens only, max 64 chars
- [ ] Description is specific and < 1024 chars
- [ ] Description includes "what" and "when"
- [ ] YAML frontmatter is valid
- [ ] Instructions are step-by-step
- [ ] Examples are concrete and realistic
- [ ] Dependencies are documented
- [ ] File paths use forward slashes
- [ ] Skill activates on relevant queries
- [ ] Claude follows instructions correctly

## Troubleshooting

**Skill doesn't activate**:
- Make description more specific with trigger words
- Include file types and operations in description
- Add "Use when..." clause with user phrases

**Multiple Skills conflict**:
- Make descriptions more distinct
- Use different trigger words
- Narrow the scope of each Skill

**Skill has errors**:
- Check YAML syntax (no tabs, proper indentation)
- Verify file paths (use forward slashes)
- Ensure scripts have execute permissions
- List all dependencies

## Examples

See the documentation for complete examples:
- Simple single-file Skill (commit-helper)
- Skill with tool permissions (code-reviewer)
- Multi-file Skill (pdf-processing)

## Output format

When creating a Skill, I will:

1. Ask clarifying questions about scope and requirements
2. Suggest a Skill name and location
3. Create the SKILL.md file with proper frontmatter
4. Include clear instructions and examples
5. Add supporting files if needed
6. Provide testing instructions
7. Validate against all requirements

The result will be a complete, working Skill that follows all best practices and validation rules.
