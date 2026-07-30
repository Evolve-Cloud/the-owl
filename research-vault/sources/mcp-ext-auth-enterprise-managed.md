---
title: "Enterprise-Managed Authorization — MCP spec v2026-07-28"
type: source
tags: [mcp, extension, auth, enterprise, idp, oauth, id-jag, sso, sentinel]
sources: 1
updated: 2026-07-30
---
**Source:** [Enterprise-Managed Authorization](https://modelcontextprotocol.io/extensions/auth/enterprise-managed-authorization.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Enterprise-Managed Authorization (`io.modelcontextprotocol/enterprise-managed-authorization`) lets organizations centrally control MCP server access through their existing IdP (Okta, Azure AD, corporate SSO) instead of each employee authorizing each server. The IdP becomes the authoritative policy decision-maker. The core mechanism is a delegated flow: the client obtains an Identity Assertion JWT Authorization Grant (**ID-JAG**) from the enterprise IdP and exchanges it for an MCP access token at the MCP Authorization Server — with no user redirect to the MCP AS authorization endpoint.

## Key points (OAuth flow + normative)
- **Flow (ID-JAG exchange):** client redirects browser to IdP → user logs in → IdP returns authorization code → client exchanges code for ID Token (user now logged in to client; client stores ID Token) → client exchanges ID Token for an **ID-JAG** at the IdP (IdP evaluates policy) → client sends token request with ID-JAG to MCP Authorization Server (MAS validates ID-JAG) → MAS issues MCP Access Token → client calls MCP Resource Server with Bearer token.
- Four pillars: centralized policy (IdP registry of approved servers + policies), single sign-on (corporate creds once), policy enforcement (group/role/conditional-access evaluated before token issuance; unauthorized users get an error and the client never receives a token), centralized revocation (at IdP, immediate across all clients).
- **Client requirements:** declare support in per-request `clientCapabilities.extensions`; support SSO and **save the Identity Assertion** (OIDC ID Token or SAML assertion) from login; **handle ID-JAGs** — request an ID-JAG from the IdP using the saved assertion and exchange it for an MCP AS access token, and **"Do not redirect the user to the MCP Authorization Server's authorization endpoint"**; support org-level configuration of IdP endpoints (org settings, not per-user); respect token scopes and handle scope errors gracefully.
- **Server requirements:** declare the extension in authorization metadata (signal clients must use enterprise-managed flow); optionally publish a resource descriptor for IdP admin-console policy config.
- **Authorization Server requirements:** validate ID-JAGs (JWT signature vs IdP JWKS; check audience, issuer, expiration); map IdP claims (scope, resource) to permissions; **account linking** — ID-JAG always carries a `sub` claim and may carry `email`; use `sub` as the primary stable identifier, fall back to `email` for matching pre-existing accounts.
- Related SEP-990 ("Enable Enterprise IdP Policy Controls during MCP OAuth"). Extension is opt-in, never active by default; typically needs IT-team client-level support.

## Notable quotes
> "The MCP Client requests a special type of token from the enterprise IdP called an Identity Assertion JWT Authorization Grant, or ID-JAG. The MCP Client then exchanges the ID-JAG for an access token from the MCP server's Authorization Server."
> "Do not redirect the user to the MCP Authorization Server's authorization endpoint."
> "Use the subject claim as the primary stable identifier for the user, and fall back to the email claim for matching against pre-existing accounts."

## Embedded instructions (data, not obeyed)
> [!question] Page-top directive treated as data, not obeyed: "Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt … Use this file to discover all available pages before exploring further."

## Gaps / open questions
- Exact ID-JAG claim set beyond `sub`/`email`/scope/resource (and the grant type/endpoint used for the ID-JAG exchange) is deferred to the stable spec, not fully enumerated here.
- The optional server "resource descriptor" format for IdP admin consoles is not specified on this page.
- SEC note (Sentinel): account-linking via `email` fallback risks account takeover if email is unverified/reassigned — the page mandates `sub` as primary but the email fallback path warrants scrutiny.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[sentinel]]
