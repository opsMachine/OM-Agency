---
name: onecli
description: Diagnose and fix OneCLI gateway issues — Docker not running, 407 proxy auth, 401 from API (MITM not active), stale aoc_ token, CA cert refresh, secret setup, version pinning. Use when onecliStart fails, update-fathom-db fails, proxy returns 407 or 401, mode=tunnel in logs, or after OneCLI container recreation.
---

# OneCLI Skill

OneCLI is a self-hosted credential proxy. Agents route HTTPS traffic through it; the gateway injects real API keys from an encrypted vault so agents never hold raw credentials.

**Stack:** Docker Compose at `~/.onecli/docker-compose.yml` · App: `127.0.0.1:10254` · Gateway: `127.0.0.1:10255` · Alias: `onecliStart`

---

## Failure modes and fixes

### Docker not running

**Symptom:** `onecliStart` → `dial unix /var/run/docker.sock: no such file`

```bash
sudo systemctl start docker
onecliStart
```

---

### 407 Proxy Authentication Required

**Symptom:** `Proxy response (407) !== 200 when HTTP Tunneling`

**Cause:** Stale `aoc_` agent token. Happens whenever the OneCLI container is recreated (new `:latest` image pulled). The `aoc_` token in env files is from the old container.

**Fix:** Get fresh token from the live container's API:

```bash
curl -sS http://127.0.0.1:10254/api/agents \
  -H "Authorization: Bearer <oc_token_from_env>" \
  | python3 -m json.tool
```

Copy the `accessToken` field (`aoc_...`) → update `ONECLI_AOC_TOKEN` in the relevant `.env` file(s).

**Auth method:** OneCLI requires `aoc_` token as **basic auth in proxy URL** — NOT `HTTP_PROXY_AUTH=Bearer`. The correct pattern:

```bash
PROXY_URL="http://x:${AOC_TOKEN}@127.0.0.1:10255"
export HTTP_PROXY="$PROXY_URL"
export HTTPS_PROXY="$PROXY_URL"
```

The `oc_` management token only gets plain tunnel mode (no header injection). Only `aoc_` activates MITM.

---

### 401 from target API / MITM not active

**Symptom:** API returns 401 even though proxy auth passes. Docker logs show `mode="tunnel"` (not `mode="mitm"`).

**Root cause:** OneCLI is tunneling without header injection. Check Docker logs:

```bash
docker logs onecli --tail 20
```

- `mode="tunnel"` + `agent="-"` → agent not authenticated → stale `aoc_` token (see 407 fix above)
- `mode="tunnel"` + agent populated → secret not assigned to agent in dashboard
- `mode="mitm"` but still 401 → wrong API key value in vault secret

**Dashboard checklist** at `http://127.0.0.1:10254`:
1. Agents → confirm agent exists, copy fresh `aoc_` token
2. Secrets → secret must be assigned to that agent
3. Secret config: correct Host pattern, Header name, value format `{value}` (not `Bearer {value}` unless the API requires Bearer)

---

### Stale CA cert after container recreation

**Symptom:** TLS errors or MITM not working despite correct token.

The gateway CA cert is regenerated each time volumes are recreated. Re-extract:

```bash
docker cp onecli:/app/data/gateway/ca.pem ~/.onecli/gateway-ca.pem
```

Verify it matches:
```bash
docker cp onecli:/app/data/gateway/ca.pem /tmp/onecli-ca-current.pem
diff <(openssl x509 -in ~/.onecli/gateway-ca.pem -noout -fingerprint) \
     <(openssl x509 -in /tmp/onecli-ca-current.pem -noout -fingerprint) \
  && echo "MATCH" || echo "STALE — re-extract"
```

---

## Preventing surprise wipes

OneCLI uses `:latest` by default — a new image pull recreates containers and invalidates the `aoc_` token and vault secrets.

**Pin the image version** in `~/.onecli/.env`:

```bash
# Get current digest
docker inspect ghcr.io/onecli/onecli:latest --format '{{index .RepoDigests 0}}'
# Pin it
echo 'ONECLI_VERSION=@sha256:<digest>' >> ~/.onecli/.env
```

The `docker-compose.yml` reads `${ONECLI_VERSION:-latest}`, so this pins without editing the compose file.

**After any intentional upgrade:** re-enter vault secrets in dashboard, re-extract CA cert, get fresh `aoc_` token.

---

## Health check

If a project has a `check-onecli-*.sh` script, run it first. It probes both the proxy auth and the target API end-to-end.

Manual probe pattern:

```bash
# 1. Gateway reachable?
curl -sS -o /dev/null -w "%{http_code}" --max-time 5 \
  -x http://127.0.0.1:10255 \
  -H "Proxy-Authorization: Bearer <oc_token>" \
  "https://example.com/"
# Expect: 200/301/302/404 = reachable; 407 = token wrong; 000 = Docker down

# 2. MITM + secret injection working?
curl -sS -o /dev/null -w "%{http_code}" \
  --proxy "http://x:<aoc_token>@127.0.0.1:10255" \
  --cacert ~/.onecli/gateway-ca.pem \
  -H "X-Api-Key: <secret-name-placeholder>" \
  "https://target-api.example.com/endpoint"
# Expect: 200 = working; 401 = MITM not active or wrong secret; 407 = stale aoc_ token
```

---

## Checklist after container recreation

1. `docker cp onecli:/app/data/gateway/ca.pem ~/.onecli/gateway-ca.pem`
2. `GET /api/agents` with `oc_` token → copy fresh `aoc_` token → update `.env`
3. Dashboard → Secrets → re-enter any vault secrets
4. Run health check
