# Test Planning Guide

Reference for planning test coverage and granularity. Used by plan-tests skill.

## Test Granularity Framework

How to decide when to combine acceptance criteria into one test vs splitting into multiple tests.

### Combine into ONE Test When:

**Same function call, different assertions:**
- Criteria verify different aspects of the same behavior
- Example: "returns 200 status" + "includes user data in response" = **one test**

```typescript
it('returns user data successfully', async () => {
  const response = await getUser(userId)
  expect(response.status).toBe(200)        // Criterion #1
  expect(response.data.email).toBeDefined() // Criterion #2
})
```

**Happy path of single user flow:**
- Testing successful completion of multi-step process
- Example: "login succeeds" + "redirects to dashboard" = **one test**

```typescript
it('logs in and redirects to dashboard', async () => {
  await login('user@example.com', 'password')
  expect(auth.isAuthenticated).toBe(true)      // Criterion #1
  expect(router.currentPath).toBe('/dashboard') // Criterion #2
})
```

**Setup is identical and expensive:**
- Database seeding, server startup, complex fixtures
- Avoids redundant setup overhead

```typescript
it('processes order with payment and inventory', async () => {
  await seedDatabase(complexOrderData) // Expensive setup

  const result = await processOrder(orderId)

  expect(result.paymentStatus).toBe('charged')    // Criterion #1
  expect(result.inventoryUpdated).toBe(true)      // Criterion #2
  expect(result.emailSent).toBe(true)             // Criterion #3
})
```

### Split into SEPARATE Tests When:

**Different inputs (including edge cases):**
- Valid vs invalid inputs
- Different scenarios or branches

```typescript
// SPLIT: Different inputs
it('accepts valid email format', async () => {
  const result = await validateEmail('user@example.com')
  expect(result.valid).toBe(true)
})

it('rejects invalid email format', async () => {
  const result = await validateEmail('not-an-email')
  expect(result.valid).toBe(false)
  expect(result.error).toMatch(/invalid.*format/i)
})
```

**Different code paths:**
- Success vs error handling
- Different branches or conditions

```typescript
// SPLIT: Different code paths
it('creates user when email is unique', async () => {
  const user = await createUser({ email: 'new@example.com' })
  expect(user.id).toBeDefined()
})

it('returns error when email already exists', async () => {
  await createUser({ email: 'existing@example.com' })
  const result = await createUser({ email: 'existing@example.com' })
  expect(result.error).toMatch(/email.*exists/i)
})
```

**One failure shouldn't block debugging the other:**
- Independent behaviors that can fail separately
- Makes debugging easier (clear failure signal)

```typescript
// SPLIT: Independent operations
it('creates order record in database', async () => {
  const order = await createOrder(orderData)
  const dbOrder = await db.orders.findById(order.id)
  expect(dbOrder).toBeDefined()
})

it('sends order confirmation email', async () => {
  await createOrder(orderData)
  expect(emailQueue).toHaveLength(1)
  expect(emailQueue[0].subject).toMatch(/order.*confirmation/i)
})
```

**Different test types (unit vs integration vs E2E):**
- Each test type serves different purpose

```typescript
// Unit test
it('formats price correctly', () => {
  expect(formatPrice(1234.56)).toBe('$1,234.56')
})

// Integration test
it('calculates total with tax from database', async () => {
  const total = await calculateTotal(orderId)
  expect(total.tax).toBeDefined()
})

// E2E test (different file, different approach)
// See shared/e2e-patterns.md
```

---

## Decision Flowchart

```
Are you testing the same function call?
├─ Yes → Are the inputs the same?
│   ├─ Yes → Are you just checking different assertions?
│   │   ├─ Yes → COMBINE into one test
│   │   └─ No → SPLIT (different behaviors)
│   └─ No → SPLIT (different scenarios)
└─ No → SPLIT (different functions)

Special case: Is setup very expensive (database seeding, etc.)?
└─ Consider combining if criteria share exact setup
   But: Only if test failure is still clear
```

---

## Grouping by Test Location

Where tests live in the codebase.

### Expand Before Create

**Always prefer expanding existing test files** over creating new ones:

✅ **Expand when:**
- Testing same module/component/function
- Can reuse existing setup (beforeAll, fixtures)
- Related behavior (similar domain)

❌ **Create new file when:**
- New module being added
- Completely different domain
- Different test setup requirements (unit vs integration)

### Test File Naming Conventions

**Unit tests:** `[module-name].test.ts`
- Located near the code: `src/utils/validation.test.ts`
- Tests pure functions, business logic

**Integration tests:** `[feature-name].integration.test.ts`
- Located in test directory: `test/integration/auth.integration.test.ts`
- Tests database, API endpoints, service interactions

**E2E tests:** `[user-flow].e2e.test.ts` or `[flow].e2e.py`
- Located in test directory: `test/e2e/checkout-flow.e2e.py`
- Tests user-facing behavior through browser

---

## Test Planning Checklist

Before finalizing test plan, verify:

- [ ] Every Unit/Integration/E2E criterion has a planned test
- [ ] No test file created when existing file could be expanded
- [ ] Related criteria grouped into single tests where appropriate
- [ ] Different inputs/paths split into separate tests
- [ ] Manual criteria listed for QA, not planned as automated tests
- [ ] Test file locations match project conventions
- [ ] Expected failures are specific (not just "test will fail")

---

## Common Anti-Patterns

### Anti-Pattern: One Test Per Criterion (Over-Testing)

❌ **BAD** - Creates unnecessary tests:
```
Criterion #1: "Returns 200 status"
Criterion #2: "Includes user email"
Criterion #3: "Includes user name"

Plan: 3 separate tests (one per criterion)
```

✅ **GOOD** - Combines related assertions:
```
Criterion #1, #2, #3: "Returns complete user data"

Plan: 1 test with 3 assertions
```

### Anti-Pattern: Test Knows Implementation

❌ **BAD** - Test coupled to implementation details:
```
Test: "calls validateEmail helper function"
Assert: expect(validateEmail).toHaveBeenCalled()
```

✅ **GOOD** - Test verifies behavior:
```
Test: "rejects invalid email format"
Assert: expect(response.error).toMatch(/invalid.*email/i)
```

### Anti-Pattern: Creating New File for Every Feature

❌ **BAD** - File proliferation:
```
src/test/send-email.test.ts
src/test/send-email-validation.test.ts
src/test/send-email-queue.test.ts
src/test/send-email-error-handling.test.ts
```

✅ **GOOD** - Expand existing file:
```
src/test/send-email.test.ts
  - Validation tests
  - Queue tests
  - Error handling tests
```

Only create new file if:
- Different test type (unit vs integration)
- Completely different module
- Original file is very large (>500 lines)

---

## Examples by Test Type

### Unit Test Planning

**Acceptance Criteria:**
1. [Unit] Validates email format
2. [Unit] Rejects emails without @ symbol
3. [Unit] Accepts valid email formats

**Test Plan:**
| Test | Criteria | Rationale |
|------|----------|-----------|
| `it('accepts valid email formats')` | #1, #3 | Same function, valid inputs |
| `it('rejects invalid email formats')` | #1, #2 | Same function, invalid inputs |

### Integration Test Planning

**Acceptance Criteria:**
1. [Integration] Stores replyTo in email queue
2. [Integration] Associates replyTo with authenticated user
3. [Integration] Returns error if user not found

**Test Plan:**
| Test | Criteria | Rationale |
|------|----------|-----------|
| `it('stores replyTo with user context')` | #1, #2 | Success path, same flow |
| `it('returns error for invalid user')` | #3 | Error path, different behavior |

### E2E Test Planning

**Acceptance Criteria:**
1. [E2E] User can click reply button
2. [E2E] Modal opens with email form
3. [E2E] Form pre-fills sender's email
4. [E2E] User can send reply

**Test Plan:**
| Test | Criteria | Rationale |
|------|----------|-----------|
| `it('user can reply via modal')` | #1, #2, #3, #4 | Single user flow, happy path |

**See `shared/e2e-patterns.md` for E2E implementation details.**

---

## When to Reference This Document

**From plan-tests (Step 4):** Use granularity framework and decision flowchart to map criteria to tests.

**When reviewing test plans:** Check against anti-patterns and checklist.
