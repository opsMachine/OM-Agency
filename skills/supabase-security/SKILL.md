---
name: supabase-security
description: "Supabase security best practices and patterns. Use when working with Supabase projects, creating tables, writing RLS policies, edge functions, or reviewing Supabase code. Invoke with '/supabase-security' or when asked about Supabase security."
---

# Supabase Security Best Practices

Reference guide for secure Supabase development. Consult this when creating tables, writing policies, implementing edge functions, or reviewing code that uses Supabase.

## When to Use

Use this skill when:
- Creating new database tables
- Writing or reviewing RLS policies
- Implementing edge functions
- Reviewing Supabase client code
- Debugging auth/authorization issues
- User asks about Supabase security

## Quick Reference: The Big Rules

1. **RLS is mandatory** - Every table must have RLS enabled
2. **Anon key is public** - Treat it as exposed; never trust it alone
3. **Service role is dangerous** - Use only in trusted server contexts
4. **Verify JWTs in edge functions** - Don't trust headers blindly
5. **Least privilege** - Expose only what's needed

---

## Row Level Security (RLS)

### Rule: Every Table Must Have RLS

```sql
-- ALWAYS do this for new tables
ALTER TABLE my_table ENABLE ROW LEVEL SECURITY;

-- Then add policies (see patterns below)
```

**If RLS is not enabled, the table is PUBLIC to anyone with the anon key.**

### Common RLS Patterns

#### 1. User Can Only See Their Own Data
```sql
CREATE POLICY "Users can view own data"
ON my_table FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own data"
ON my_table FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own data"
ON my_table FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own data"
ON my_table FOR DELETE
USING (auth.uid() = user_id);
```

#### 2. Team/Organization Shared Access
```sql
-- Users can see data belonging to their team
CREATE POLICY "Team members can view team data"
ON my_table FOR SELECT
USING (
  team_id IN (
    SELECT team_id FROM team_members
    WHERE user_id = auth.uid()
  )
);
```

#### 3. Admin-Only Access
```sql
CREATE POLICY "Only admins can access"
ON admin_table FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM user_profiles
    WHERE id = auth.uid() AND role_id = 'admin'
  )
);
```

#### 4. Public Read, Authenticated Write
```sql
CREATE POLICY "Anyone can read"
ON public_content FOR SELECT
USING (true);

CREATE POLICY "Authenticated users can insert"
ON public_content FOR INSERT
WITH CHECK (auth.uid() IS NOT NULL);
```

#### 5. Row-Level with Column Check
```sql
-- Only see published items, or your own drafts
CREATE POLICY "See published or own drafts"
ON posts FOR SELECT
USING (
  status = 'published'
  OR author_id = auth.uid()
);
```

### RLS Anti-Patterns (Don't Do These)

```sql
-- BAD: Overly permissive
CREATE POLICY "bad_policy" ON my_table FOR ALL USING (true);

-- BAD: Checking role in application, not database
-- (This can be bypassed!)

-- BAD: Forgetting WITH CHECK on INSERT/UPDATE
CREATE POLICY "incomplete" ON my_table FOR INSERT
USING (auth.uid() = user_id);  -- Wrong! Need WITH CHECK
```

---

## API Keys

### Anon Key (Public)
- **Assume it's exposed** - Anyone can see it in browser
- **Only allows RLS-permitted operations**
- **Use for:** Client-side code, public APIs

```typescript
// This is fine - anon key + RLS protects data
const supabase = createClient(url, anonKey);
```

### Service Role Key (Dangerous)
- **Bypasses all RLS** - Full database access
- **NEVER expose to client** - Server-side only
- **NEVER commit to git** - Use environment variables

```typescript
// ONLY in server/edge function context
// NEVER in client code
const supabaseAdmin = createClient(url, serviceRoleKey);
```

### When to Use Service Role

✅ **Acceptable:**
- Database migrations
- Admin scripts run locally
- Edge functions that need cross-user access
- Seeding data
- Background jobs on trusted servers

❌ **Never:**
- Client-side code
- Anywhere the key could be exposed
- When RLS policies could achieve the same thing

---

## Edge Functions

### JWT Verification is Mandatory

```typescript
// ALWAYS verify the JWT in edge functions
import { createClient } from '@supabase/supabase-js';

Deno.serve(async (req) => {
  const authHeader = req.headers.get('Authorization');

  if (!authHeader) {
    return new Response('Unauthorized', { status: 401 });
  }

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!,
    {
      global: {
        headers: { Authorization: authHeader },
      },
    }
  );

  // Verify the JWT by getting the user
  const { data: { user }, error } = await supabase.auth.getUser();

  if (error || !user) {
    return new Response('Invalid token', { status: 401 });
  }

  // Now you have a verified user
  // Continue with your logic...
});
```

### Edge Function Anti-Patterns

```typescript
// BAD: Trusting headers without verification
const userId = req.headers.get('x-user-id');  // Can be spoofed!

// BAD: Using service role without verification
const supabase = createClient(url, serviceRoleKey);
// Anyone can call this function!

// BAD: Not checking user permissions
const { data } = await supabase.from('admin_data').select('*');
// Should verify user is admin first!
```

### Admin-Only Edge Functions

```typescript
// Pattern for admin-only operations
const { data: { user } } = await supabase.auth.getUser();

// Verify admin status from database (not from JWT claims alone)
const { data: profile } = await supabase
  .from('user_profiles')
  .select('role_id')
  .eq('id', user.id)
  .single();

if (profile?.role_id !== 'admin') {
  return new Response('Forbidden', { status: 403 });
}
```

---

## Client-Side Security

### Input Validation

```typescript
// ALWAYS validate on server/database, not just client
// Client validation is for UX, not security

// BAD: Only client validation
if (email.includes('@')) { /* submit */ }

// GOOD: Client validation + database constraint
// Database: CHECK (email ~* '^[^@]+@[^@]+$')
```

### Avoiding Data Exposure

```typescript
// BAD: Selecting all columns
const { data } = await supabase.from('users').select('*');
// May expose sensitive fields!

// GOOD: Select only needed columns
const { data } = await supabase
  .from('users')
  .select('id, name, avatar_url');
```

### Secure File Uploads

```typescript
// Validate file type and size before upload
const allowedTypes = ['image/jpeg', 'image/png'];
const maxSize = 5 * 1024 * 1024; // 5MB

if (!allowedTypes.includes(file.type)) {
  throw new Error('Invalid file type');
}

if (file.size > maxSize) {
  throw new Error('File too large');
}

// Also enforce in storage bucket policies
```

---

## Database Security

### Use Constraints

```sql
-- Enforce data integrity at database level
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  amount DECIMAL NOT NULL CHECK (amount > 0),
  status TEXT NOT NULL CHECK (status IN ('pending', 'paid', 'cancelled')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Avoid SQL Injection

```typescript
// BAD: String interpolation
const { data } = await supabase
  .from('users')
  .select('*')
  .filter('name', 'eq', userInput);  // userInput could be malicious

// GOOD: Supabase client handles parameterization
// But validate/sanitize input anyway
const sanitized = userInput.replace(/[^a-zA-Z0-9 ]/g, '');
```

### Triggers for Audit/Validation

```sql
-- Use triggers for security invariants
CREATE OR REPLACE FUNCTION prevent_role_escalation()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.role_id != NEW.role_id THEN
    IF NOT is_admin(auth.uid()) THEN
      RAISE EXCEPTION 'Only admins can change roles';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER check_role_change
BEFORE UPDATE ON user_profiles
FOR EACH ROW EXECUTE FUNCTION prevent_role_escalation();
```

---

## Security Checklist

Use this when reviewing Supabase code:

### Tables
- [ ] RLS enabled on all tables
- [ ] Policies cover SELECT, INSERT, UPDATE, DELETE as needed
- [ ] No `USING (true)` without good reason
- [ ] Sensitive tables have restrictive policies

### Edge Functions
- [ ] JWT verified via `auth.getUser()`
- [ ] Admin endpoints verify admin status from database
- [ ] Service role only used when necessary
- [ ] No sensitive data in error messages

### Client Code
- [ ] Anon key used (not service role)
- [ ] Input validated before sending
- [ ] Only necessary columns selected
- [ ] Error handling doesn't expose internals

### Keys & Secrets
- [ ] Service role key not in client code
- [ ] Keys in environment variables
- [ ] .env files in .gitignore
- [ ] No secrets in logs

---

## Common Vulnerabilities in Supabase Apps

### 1. Missing RLS
**Risk:** Full table access to anyone with anon key
**Fix:** Enable RLS, add policies

### 2. Unverified Edge Functions
**Risk:** Anyone can call admin functions
**Fix:** Always verify JWT with `auth.getUser()`

### 3. Service Role in Client
**Risk:** Complete database bypass
**Fix:** Only use service role server-side

### 4. Overly Permissive Policies
**Risk:** Users can access other users' data
**Fix:** Always scope to `auth.uid()` or verified membership

### 5. Trusting JWT Claims Alone
**Risk:** Claims can be stale or manipulated
**Fix:** Verify permissions from database, not just JWT

---

## Quick Commands

```bash
# Check RLS status on all tables
supabase db lint

# View existing policies
psql -c "SELECT tablename, policyname, cmd, qual FROM pg_policies;"

# Test as specific user (in SQL editor)
SET request.jwt.claim.sub = 'user-uuid-here';
```
