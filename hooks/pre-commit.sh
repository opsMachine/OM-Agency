#!/bin/bash
# Pre-Commit Hook (v3.1)
# Runs a quick security scan and quality check before git commit.

echo "🔒 Running Pre-Commit Security Quick-Check..."

# 1. Scan for hardcoded secrets (crude but effective for a hook)
# Looks for common patterns like API keys, secrets, private keys
SECRETS_FOUND=$(grep -rE "password:|secret:|api_key:|sk_live_" . --exclude-dir=.git --exclude=*.sh --exclude=settings.example.json | wc -l)

if [ "$SECRETS_FOUND" -gt 0 ]; then
  echo "❌ WARNING: Potential hardcoded secrets found!"
  grep -rE "password:|secret:|api_key:|sk_live_" . --exclude-dir=.git --exclude=*.sh --exclude=settings.example.json
  # We don't exit 1 yet as these might be false positives, but we alert loudly.
fi

# 2. Check for RLS on new migrations
NEW_TABLES=$(git diff --cached | grep -E "CREATE TABLE" | wc -l)
RLS_POLICIES=$(git diff --cached | grep -E "ALTER TABLE .* ENABLE ROW LEVEL SECURITY" | wc -l)

if [ "$NEW_TABLES" -gt "$RLS_POLICIES" ]; then
  echo "⚠️ WARNING: You are creating new tables without enabling RLS in the same commit."
fi

# 3. Check for Service Role usage in client code
SERVICE_ROLE_USAGE=$(git diff --cached | grep -E "service_role|SERVICE_ROLE" | grep -vE "supabase/functions" | wc -l)

if [ "$SERVICE_ROLE_USAGE" -gt 0 ]; then
  echo "❌ WARNING: Service role key usage detected outside of Edge Functions!"
fi

echo "✅ Security quick-check complete."
exit 0
