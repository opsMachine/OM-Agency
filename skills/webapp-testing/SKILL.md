---
name: webapp-testing
description: Toolkit for interacting with and testing local web applications using Playwright. Supports verifying frontend functionality, debugging UI behavior, capturing browser screenshots, and viewing browser logs.
license: Complete terms in LICENSE.txt
---

# Web Application Testing Toolkit

**This is a toolkit, not a workflow skill.** It provides helper scripts and examples for E2E testing with Playwright.

**Used by:** `implement` skill (test and implementation phases)
**Primary reference:** See `shared/e2e-patterns.md` for complete E2E testing patterns and guidance.

---

## Contents

**Helper Scripts:**
- `scripts/with_server.py` - Manages dev server lifecycle (supports multiple servers)

**Examples:**
- `examples/element_discovery.py` - Discovering elements on a page
- `examples/static_html_automation.py` - Testing static HTML files
- `examples/console_logging.py` - Capturing browser console logs

**Always run scripts with `--help` first.** DO NOT read the source unless absolutely necessary. These scripts are designed as black-box utilities.

## Quick Start

**For complete E2E testing guidance:** See `shared/e2e-patterns.md`

**For project-specific patterns:** See `.claude/primitives/testing-conventions.md`

---

## When to Use This Toolkit

**During TDD workflow:**
- TDD skills reference these helpers automatically when writing E2E tests
- You typically won't invoke this skill directly

**For ad-hoc browser automation:**
- Debugging frontend issues
- Capturing screenshots of current state
- Testing browser behavior outside TDD workflow

---

## Helper Scripts

### with_server.py - Server Lifecycle Management

Manages dev server startup/shutdown for E2E tests. Run `--help` for full usage:

**Single server:**
```bash
python scripts/with_server.py --server "npm run dev" --port 5173 -- python your_automation.py
```

**Multiple servers (e.g., backend + frontend):**
```bash
python scripts/with_server.py \
  --server "cd backend && python server.py" --port 3000 \
  --server "cd frontend && npm run dev" --port 5173 \
  -- python your_automation.py
```

To create an automation script, include only Playwright logic (servers are managed automatically):
```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True) # Always launch chromium in headless mode
    page = browser.new_page()
    page.goto('http://localhost:5173') # Server already running and ready
    page.wait_for_load_state('networkidle') # CRITICAL: Wait for JS to execute
    # ... your automation logic
    browser.close()
```

---

## Examples

Working code samples for common E2E scenarios:

- **`examples/element_discovery.py`** - Discovering buttons, links, and inputs on a page
- **`examples/static_html_automation.py`** - Using file:// URLs for local HTML
- **`examples/console_logging.py`** - Capturing console logs during automation

Use these as starting points for E2E tests.

---

## Integration with TDD Workflow

**This toolkit is referenced by:**

1. **implement** (Phase 1) - When writing E2E tests from spec criteria (uses `with_server.py` and patterns)
2. **implement** (Phase 2) - When implementing code to pass E2E tests

**You don't need to invoke this skill directly.** The implement skill uses it automatically.

---

## For More Information

**Complete E2E patterns:** `shared/e2e-patterns.md`
**Project-specific patterns:** `.claude/primitives/testing-conventions.md`
**Test planning guidance:** `shared/test-planning.md`