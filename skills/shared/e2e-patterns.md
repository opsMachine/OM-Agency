# E2E Testing Patterns

Reference guide for end-to-end (E2E) testing using Playwright. Used by `implement` skill when writing browser-based tests.

## When to Use E2E Tests

E2E tests verify **user-facing behavior through the browser**. Use E2E when testing:

**User Interactions:**
- Clicks, form submissions, navigation
- Drag and drop, keyboard shortcuts
- Multi-step user flows (login → navigate → action → verify)

**Visual Feedback:**
- Modals, notifications, loading states
- Dynamic content rendering
- Client-side validation messages

**Frontend Behavior:**
- Client-side routing
- JavaScript-driven state changes
- Browser-specific features (localStorage, cookies)

**When NOT to use E2E:**
- Business logic testable at unit level
- API behavior testable at integration level
- Email delivery, mobile apps (use Manual test type)

---

## Decision Tree: Choosing Your Approach

```
Is it static HTML?
├─ Yes → Read HTML file directly to identify selectors
│         ├─ Success → Write Playwright script using selectors
│         └─ Fails/Incomplete → Treat as dynamic (below)
│
└─ No (dynamic webapp) → Is the server already running?
    ├─ No → Use helper script: python scripts/with_server.py
    │        Then write simplified Playwright script
    │
    └─ Yes → Use reconnaissance-then-action pattern:
        1. Navigate and wait for networkidle
        2. Take screenshot or inspect DOM
        3. Identify selectors from rendered state
        4. Execute actions with discovered selectors
```

---

## Reconnaissance-Then-Action Pattern

**Core principle:** Understand the current state before writing assertions.

### 1. Navigate and Wait

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)  # Always headless
    page = browser.new_page()
    page.goto('http://localhost:5173')
    page.wait_for_load_state('networkidle')  # CRITICAL: Wait for JS
```

**Common pitfall:**
- ❌ Don't inspect DOM before waiting for `networkidle` on dynamic apps
- ✅ Do wait for page to fully load before inspection

### 2. Reconnaissance (Inspect Rendered State)

```python
# Take screenshot to see current state
page.screenshot(path='/tmp/inspect.png', full_page=True)

# Get rendered HTML
content = page.content()

# Find all elements of a type
buttons = page.locator('button').all()
for button in buttons:
    print(f"Button text: {button.text_content()}")
```

### 3. Identify Selectors

From reconnaissance results, identify stable selectors:

**Preference order (most stable to least):**
1. `role=` - Semantic roles (button, link, textbox, etc.)
2. `text=` - Visible text content
3. `data-testid=` - Test-specific attributes
4. `id=` - Element IDs
5. CSS selectors - Class names, element types

**Example:**
```python
# Best: Semantic role + text
page.get_by_role('button', name='Submit')

# Good: Test ID
page.get_by_test_id('submit-button')

# Avoid: Brittle CSS selectors
page.locator('.btn.btn-primary.mt-4')  # Breaks when styling changes
```

### 4. Execute Actions

```python
# Click
page.get_by_role('button', name='Submit').click()

# Fill form
page.get_by_label('Email').fill('test@example.com')

# Wait for result
page.wait_for_selector('text=Success')

# Assert
assert page.get_by_text('Email sent').is_visible()
```

---

## Server Management with Helper Scripts

### Using with_server.py

**When to use:** E2E tests that need local dev server running.

**Location:** `skills/webapp-testing/scripts/with_server.py`

**Always run with `--help` first:**
```bash
python skills/webapp-testing/scripts/with_server.py --help
```

**Single server example:**
```bash
python skills/webapp-testing/scripts/with_server.py \
  --server "npm run dev" \
  --port 5173 \
  -- python your_e2e_test.py
```

**Multiple servers (backend + frontend):**
```bash
python skills/webapp-testing/scripts/with_server.py \
  --server "cd backend && python server.py" --port 3000 \
  --server "cd frontend && npm run dev" --port 5173 \
  -- python your_e2e_test.py
```

**Your test script (simplified - no server management):**
```python
from playwright.sync_api import sync_playwright

# Server already running and ready - just test
with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    page.goto('http://localhost:5173')  # Server ready
    page.wait_for_load_state('networkidle')

    # Your test logic here

    browser.close()
```

---

## E2E Test Structure

### Standard Test Template

```python
from playwright.sync_api import sync_playwright

def test_user_can_submit_form():
    """Test that user can submit contact form and see confirmation"""
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        # 1. Navigate
        page.goto('http://localhost:5173/contact')
        page.wait_for_load_state('networkidle')

        # 2. Reconnaissance (optional - for debugging)
        # page.screenshot(path='/tmp/before.png')

        # 3. Action
        page.get_by_label('Name').fill('Test User')
        page.get_by_label('Email').fill('test@example.com')
        page.get_by_label('Message').fill('Test message')
        page.get_by_role('button', name='Submit').click()

        # 4. Wait for result
        page.wait_for_selector('text=Message sent')

        # 5. Assert
        confirmation = page.get_by_text('Message sent successfully')
        assert confirmation.is_visible()

        browser.close()
```

### With Server Management

```python
# File: test_contact_form.py
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()

    page.goto('http://localhost:5173/contact')
    page.wait_for_load_state('networkidle')

    # Test logic...

    browser.close()
```

```bash
# Run with server:
python skills/webapp-testing/scripts/with_server.py \
  --server "npm run dev" --port 5173 \
  -- python test_contact_form.py
```

---

## Best Practices

### Always Do

- ✅ Use `sync_playwright()` for synchronous scripts
- ✅ Launch browser in headless mode: `headless=True`
- ✅ Wait for `networkidle` before inspecting dynamic pages
- ✅ Close browser when done: `browser.close()`
- ✅ Use descriptive selectors: `role=`, `text=`, or `data-testid=`
- ✅ Add explicit waits when needed: `page.wait_for_selector()`
- ✅ Take screenshots for debugging: `page.screenshot(path='/tmp/debug.png')`

### Never Do

- ❌ Don't use brittle CSS selectors (class names change)
- ❌ Don't skip `networkidle` wait on dynamic apps
- ❌ Don't hardcode delays: `time.sleep(2)` (use explicit waits)
- ❌ Don't inspect DOM before page loads
- ❌ Don't run in headed mode (`headless=False`) unless debugging

---

## Common Patterns

### Debugging: Capture Screenshots

```python
# Before action
page.screenshot(path='/tmp/before.png', full_page=True)

# After action
page.screenshot(path='/tmp/after.png', full_page=True)
```

### Debugging: Console Logs

```python
# Capture console messages
console_messages = []
page.on('console', lambda msg: console_messages.append(msg.text))

# ... run test ...

# Print captured logs
for msg in console_messages:
    print(f"Console: {msg}")
```

### Waiting for Dynamic Content

```python
# Wait for specific element
page.wait_for_selector('text=Data loaded', timeout=5000)

# Wait for network to be idle
page.wait_for_load_state('networkidle')

# Wait for specific timeout (use sparingly)
page.wait_for_timeout(1000)  # milliseconds
```

### Form Interactions

```python
# Text input
page.get_by_label('Email').fill('test@example.com')

# Checkbox
page.get_by_role('checkbox', name='Subscribe').check()

# Radio button
page.get_by_role('radio', name='Option A').click()

# Select dropdown
page.get_by_role('combobox', name='Country').select_option('US')
```

---

## Reference Examples

See `skills/webapp-testing/examples/` for working code:

- **element_discovery.py** - Discovering buttons, links, inputs on a page
- **static_html_automation.py** - Using file:// URLs for local HTML
- **console_logging.py** - Capturing console logs during automation

---

## When to Reference This Document

**From implement (Phase 1):** When acceptance criterion has Test Type = E2E, use:
- Decision tree to choose approach
- Reconnaissance-then-action pattern for test structure
- Helper scripts for server management
- Best practices for selectors and waits

**From implement (Phase 2):** When implementing code to pass E2E tests
