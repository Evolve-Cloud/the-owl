---
title: "Security Best Practices — MCP spec v2026-07-28"
type: source
tags: [mcp, security, oauth, ssrf, confused-deputy, token-passthrough, injection]
sources: 1
updated: 2026-07-30
---
**Source:** [Security Best Practices](https://modelcontextprotocol.io/docs/2026-07-28/tutorials/security/security_best_practices.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
The canonical MCP threat model. It enumerates concrete attack vectors against MCP implementations — Confused Deputy, Token Passthrough, SSRF, State Handle Hijacking, Local MCP Server Compromise, OAuth Authorization URL Validation (XSS/RCE), stdio-transport-in-proxy privilege escalation, Mix-Up attacks, Localhost Redirect URI Impersonation, CIMD trust policies, and Scope Minimization — and specifies MUST/SHOULD countermeasures for each. Complements the MCP Authorization spec and should be read with OAuth 2.0 security BCP (RFC 9700). Primary audience: developers implementing MCP auth flows, server operators, and security reviewers.

## Key points
- **Confused Deputy**: arises when an MCP proxy uses a **static client ID** with a third-party AS, allows MCP clients to **dynamically register** (each own client_id), the third-party AS sets a **consent cookie**, and the proxy lacks per-client consent. Attacker dynamically registers a malicious client with `redirect_uri: attacker.com`, sends victim a crafted authz link; the existing consent cookie causes the third-party AS to **skip the consent screen**, and the MCP authorization code is redirected to the attacker, who exchanges it for tokens and impersonates the user.
- **Token Passthrough** = anti-pattern: MCP server accepts tokens not issued *to it* and forwards them downstream. Two dimensions: **audience validation failures** (accepting tokens meant for other services — breaks the OAuth `aud` boundary per RFC 9068) and **passthrough** (forwarding those tokens, creating a confused-deputy).
- **SSRF**: during OAuth metadata discovery, clients fetch attacker-controllable URLs (`resource_metadata` from `WWW-Authenticate`, `authorization_servers` from PRM, `token_endpoint`/`authorization_endpoint` from AS metadata). A malicious server points these at internal IPs, cloud metadata (`http://169.254.169.254/`), localhost services (Redis `:6379`), via DNS rebinding or redirect chains. SSRF also applies to **authorization servers** fetching Client ID Metadata Documents (CIMD).
- **State Handle Hijacking**: MCP is **stateless with no protocol-level sessions**; servers mint explicit handles (cart ID, workflow ID) returned as ordinary tool args. Attacker guesses/obtains the handle and acts on another user's state if the server doesn't bind the handle to the caller.
- **Local MCP Server Compromise**: local servers run as binaries with user-machine access. Attacks: malicious "startup" command in client config, malicious payload in server, DNS rebinding against an insecure localhost server. Example embedded commands exfiltrate `~/.ssh/id_rsa` or run `sudo rm -rf`.
- **OAuth Authorization URL Validation**: malicious server supplies `javascript:` URL → XSS via `window.open()`; or URL with shell injection payloads → RCE if client opens URLs via shell. Combined with stdio-in-proxy → full system compromise.
- **stdio Transport in Proxy Scenarios**: only applies to **proxy architectures** (proxy spawns servers as child processes). XSS → steal proxy auth token → authenticated requests to local proxy → proxy spawns arbitrary commands → RCE. stdio transport itself is NOT inherently vulnerable.
- **Mix-Up Attacks** (RFC 9207): attacker-controlled AS tricks client into sending a code/token issued by an honest AS. Mitigated by Authorization Response Validation binding response to recorded AS (`iss`); **PKCE alone does not prevent it** (client sends `code_verifier` to attacker's token endpoint).
- **Localhost Redirect URI Impersonation**: CIMD proves domain control but not which local process listens on a `localhost` redirect URI; attacker claims a legit client's metadata URL and binds any localhost port.
- **CIMD Trust Policies**: AS accepting Client ID Metadata Documents can apply allowlists, accept any HTTPS client_id, reputation/domain-age checks, and display CIMD hostnames to prevent phishing.
- **Scope Minimization**: broad scopes (`files:*`, `db:*`, `admin:*`, `*`, `all`, `full-access`) expand blast radius, raise revocation friction, cause consent abandonment. Use progressive least-privilege via `WWW-Authenticate` `scope="..."` step-up challenges; clients compute the **union** of prior + newly-challenged scopes.

## Security requirements (every MUST / SHOULD / MUST NOT verbatim)
**Confused Deputy — threat: consent-skip / auth-code theft via static client ID + DCR + consent cookie:**
- MCP proxy servers **MUST** implement per-client consent and proper security controls.
- **MUST**: maintain a registry of approved `client_id` values per user; check it **before** initiating the third-party authorization flow; store consent decisions securely (server-side DB or server-specific cookies).
- MCP-level consent page **MUST**: clearly identify the requesting MCP client by name; display specific third-party API scopes; show the registered `redirect_uri`; implement CSRF protection (state param, CSRF tokens); prevent iframing via `frame-ancestors` CSP or `X-Frame-Options: DENY` (clickjacking).
- Consent cookies **MUST**: use `__Host-` prefix; set `Secure`, `HttpOnly`, `SameSite=Lax`; be cryptographically signed or use server-side sessions; bind to the specific `client_id`.
- Redirect URI validation **MUST**: validate `redirect_uri` exactly matches the registered URI; reject if changed without re-registration; use exact string matching (no patterns/wildcards).
- OAuth state **MUST**: generate cryptographically secure random `state` per request; store server-side **only after** consent approved; set the state cookie/session **immediately before** redirecting to the third-party IdP (not before consent); validate at callback that `state` exactly matches stored; reject if missing/mismatched; ensure single-use (delete after validation) with short expiry (e.g. 10 min).
- The consent cookie/session containing `state` **MUST NOT** be set until **after** the user has approved the consent screen.

**Token Passthrough — threat: cross-service token reuse, confused deputy, control circumvention:**
- MCP servers **MUST NOT** accept any tokens that were not explicitly issued for the MCP server. (Token passthrough is explicitly forbidden in the authorization specification.)

**SSRF — threat: internal-network access, cloud-credential exfiltration, firewall bypass:**
- MCP clients deployed to a server **MUST** consider SSRF risks and implement appropriate mitigations when fetching OAuth-related URLs.
- Clients **SHOULD** require HTTPS for all OAuth URLs in production; reject `http://` except loopback during dev; provide explicit opt-out for dev/testing.
- Clients **SHOULD** block private/reserved IP ranges (RFC 9728 §7.7): `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`, `127.0.0.0/8`, `::1`, `169.254.0.0/16` (incl. cloud metadata), `fc00::/7`, `fe80::/10`. (Note: avoid manual IP validation — attackers use octal/hex/IPv4-mapped-IPv6 encoding tricks.)
- Clients **SHOULD** apply the same URL validation to redirect targets; not blindly follow redirects to internal resources; consider disabling automatic redirect following.
- Operators **SHOULD** consider egress proxies (e.g. Smokescreen) that block internal destinations.
- Be aware of TOCTOU DNS issues; consider pinning DNS resolution between check and use.

**State Handle Hijacking — threat: cross-user state access via guessed handle:**
- MCP servers that implement authorization **MUST** verify all inbound requests.
- MCP servers **MUST NOT** treat possession of a state handle as authentication.
- MCP servers **SHOULD** use secure, non-deterministic handles (secure RNG); avoid predictable/sequential IDs; expiring handles reduce risk.
- MCP servers **SHOULD** bind handles server-side to the authenticated user (e.g. key state as `<user_id>:<handle>` where user ID derives from the verified token, not the client) and reject a handle presented by any other principal.

**Local MCP Server Compromise — threat: arbitrary code execution / data exfiltration:**
- If an MCP client supports one-click local MCP server configuration, it **MUST** implement proper consent mechanisms prior to executing commands.
- The MCP client **MUST**: show the exact command that will be executed without truncation (incl. args); clearly identify it as potentially dangerous code execution; require explicit user approval; allow cancellation.
- The MCP client **SHOULD**: highlight dangerous patterns (`sudo`, `rm -rf`, network/FS access outside expected dirs); warn on sensitive locations (home, SSH keys, system dirs); warn servers run with client privileges; sandbox with minimal default privileges; restrict FS/network/resource access; provide explicit privilege-grant mechanisms; use platform sandboxing (containers, chroot, app sandboxes); keep sandboxing up-to-date.
- MCP servers intended to run locally **SHOULD**: use `stdio` transport to limit access to the client; if using HTTP, restrict via authorization token, unix domain sockets, or restricted IPC.

**OAuth Authorization URL Validation — threat: XSS / RCE via malicious authz URL:**
- Clients **MUST** only allow `http://` and `https://` schemes for authorization URLs (`http://` only for loopback in dev; production **MUST** use `https://`).
- Clients **MUST** reject `javascript:`, `data:`, `file:`, `vbscript:`, and other dangerous schemes.
- Clients **SHOULD** use allowlist-based (not blocklist) scheme validation.
- Clients **MUST NOT** use shell commands (`cmd.exe`, `sh`, PowerShell) to open URLs; **SHOULD** use platform-specific non-shell URL opening.
- Web-based clients **SHOULD** implement CSP (`script-src 'self'`, `default-src 'self'`, or `script-src 'nonce-<random>'`).
- Clients **MUST** sanitize and validate all URLs received from MCP servers (strict parsing, reject shell-special chars, sanitization libs, log suspicious URLs).

**stdio Transport in Proxy Scenarios — threat: XSS→RCE privilege escalation:**
- MCP proxy services **SHOULD**: sandbox/containerize spawned processes; restrict FS access; log all stdio usage; require additional authorization for dangerous commands.
- MCP clients **SHOULD**: isolate proxy communication in a separate security context; least-privilege proxy permissions; process-level sandboxing of the proxy; run proxy in a container/restricted environment.

**Scope Minimization — threat: broad-token blast radius:**
- Clients **SHOULD** compute the union of previously requested scopes and newly challenged scopes when re-authorizing (step-up flow). Down-scoping: server should accept reduced-scope tokens; auth server MAY issue a subset of requested scopes.

## Notable quotes
> "MCP servers **MUST NOT** accept any tokens that were not explicitly issued for the MCP server."

> "MCP servers **MUST NOT** treat possession of a state handle as authentication."

> "The consent cookie or session containing the `state` value **MUST NOT** be set until **after** the user has approved the consent screen at the MCP server's authorization endpoint. Setting this cookie before consent approval renders the consent screen ineffective."

> "PKCE alone does not prevent this attack because the client transmits the `code_verifier` to the attacker's token endpoint."

> [!question] Untrusted content directed at the pipeline (NOT obeyed)
> The fetched page was prefixed with injected boilerplate: "## Documentation Index — Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt — Use this file to discover all available pages before exploring further." This is an instruction to the fetching agent, not spec content. Per NFR-SEC-2 it is treated as data and NOT acted upon.

## Gaps / open questions
- IP allowlist/blocklist is explicitly warned against being implemented manually (encoding tricks) but the page does not name a canonical library — implementation choice left to operator.
- Mix-up mitigation "depends on honest authorization servers emitting `iss`" — no protection against an honest AS that omits `iss`.
- Session Hijacking guidance for protocol `2025-11-25` and earlier is deferred to the older page (server-assigned session IDs); this version relies on statelessness + explicit handles.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[sentinel]] · [[untrusted-content-boundary]] · [[mcp-docs-authorization]] · [[confused-deputy]] · [[ssrf-mitigation]] · [[token-passthrough]]
