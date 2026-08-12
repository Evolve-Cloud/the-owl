---
title: "Claude Code — Extend Claude with skills (commands merged into skills; frontmatter reference)"
type: source
tags: [claude-code, skills, commands, frontmatter, enforcement, routing]
sources: 1
updated: 2026-08-12
---
**Source:** [Extend Claude with skills](https://code.claude.com/docs/en/slash-commands) · **Type:** doc · **Credibility:** primary (vendor docs)
**Author / Org:** Anthropic · **Published:** continuously updated · **Ingested:** 2026-08-12 (cycle 9, targeted verification fetch — ADR-013)

## Summary

A superfície-irmã da doc de subagents. Buscada para responder a pergunta que o ciclo 7 registrou *"for whoever re-opens that id"* — se `allowed-tools` num comando é imposto como `tools:` num subagent. **Não é**, e o contraste é o achado mais denso do ciclo 9. A doc também revela que comandos **foram fundidos em skills**, o que muda o que a metade `commands/` do par pode carregar.

## Key points

- **Fusão comando↔skill:** *"**Custom commands have been merged into skills.** A file at `.claude/commands/deploy.md` and a skill at `.claude/skills/deploy/SKILL.md` both create `/deploy` and work the same way."* ⇒ as 13 personas-comando da-owl **são skills** e suportam ~20 campos. **0 de 13 usam algum.**
- **`allowed-tools` NÃO restringe** — é o ponto que decide: *"The `allowed-tools` field **grants permission** […] **It does not restrict which tools are available: every tool remains callable**"*, e o grant **expira** na próxima mensagem do usuário.
- `disallowed-tools` **é** restritivo, mas *"the restriction clears when you send your next message"* — denylist **efêmera**, não allowlist durável. É a ressalva que impede o overclaim "sem equivalente nenhum".
- **`tools` e `maxTurns` não existem** nesta superfície.
- `disable-model-invocation`: *"prevent Claude from automatically loading this skill"*, e *"**Use `disable-model-invocation: true` to block programmatic invocation**"* — **inclusive via Skill tool**. Foi esta frase que reprovou o ADR-036.
- Também: *"This removes the skill from Claude's context entirely."*
- Caso de uso nomeado pela doc: *"Use this for workflows **with side effects** […] You don't want Claude deciding to deploy because your code looks ready."*

## Informs (ideas / patterns)

- [[least-privilege-tool-scopes-v2]] / ADR-037 — a assimetria verificada que o ADR-034 exigia.
- [[routing-eligibility-mode]] — forneceu **e depois refutou** a mudança: o campo é real, e é exatamente por bloquear invocação programática que quebraria 9 agentes.
- [[inert-command-frontmatter]] — a tabela de campos é o que prova que `trigger`/`category`/`priority` são inertes.
- [[guardrails-and-safety]] · [[tool-design-and-capability-scoping]]

## Notable quotes

> "It does not restrict which tools are available: every tool remains callable."

> "The `user-invocable` field only controls menu visibility, not Skill tool access. Use `disable-model-invocation: true` to block programmatic invocation."

## Gaps / open questions

- Não diz se `disable-model-invocation` afeta a invocação **pelo usuário** via `/name` — a leitura direta é que não (a doc a apresenta como o jeito de manter workflows *"to trigger manually with `/name`"*), mas isso não foi testado.

## Related
- [[claude-code-subagents-frontmatter]] (a superfície-irmã) · [[github-copilot-custom-agents]] (mesmo controle, outro fornecedor) · [[scout-notes-2026-08-12]]
