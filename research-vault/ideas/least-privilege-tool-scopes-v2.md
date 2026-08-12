---
title: "Per-agent tool scopes, re-opened: the harness now enforces them"
type: idea
tags: [security, tooling, subagents, least-privilege]
supersedes_context: least-privilege-tool-scopes
scored: cycle-9 (2026-08-12)
status: accepted
score: 80
adr: ADR-037
origin: reflection
reopened: 2026-08-07
reopened_by: human-directed (ADR-033 finding)
updated: 2026-08-12
---

> [!important] **Este candidato NÃO está pontuado — e de propósito.**
> Reabrir não é aceitar. Isto é um candidato na fila para o @curator pontuar no ciclo 9, pela rubrica normal, com o veto de segurança normal, o haircut do ADR-015 normal e o gate normal. Não há tabela de rubrica, total nem nota de Impacto nesta página porque nenhuma foi atribuída.
>
> **Não existe linha no `ledger.md` para o id `least-privilege-tool-scopes-v2` — isso é intencional, não um esquecimento.** O ledger é o ledger de **decisões**; um candidato não pontuado não tem decisão. Se uma linha for adicionada aqui, o passo 1 do curator (`curator.md:80` — *"id decidido → pular"*) vai tratar o id como decidido e **pular**, e a reabertura vira no-op que parece feita. O @curator escreve a linha quando pontuar. O **ato** de reabrir tem a sua própria linha (`hd-reopen-least-privilege-tool-scopes`), com id distinto.

## Por que este id existe (regra do id sufixado)

`least-privilege-tool-scopes` (66) foi **deferido** em 2026-07-23 com um bloqueio explícito: *"unenforceable prose in the-owl's inline-exec model (ADR-010)"* — a-owl não tinha como **impor** escopo de ferramenta por agente, então a convenção seria prosa que finge impor. Bloqueio correto na época.

Esse bloqueio **caiu**. O SCHEMA manda que evidência materialmente nova para um id decidido vire **linha nova com sufixo, nunca sobrescrita silenciosa** — daí o `-v2`.

**A condição de reabertura foi escrita pelo próprio ciclo 7, em `ledger.md`, e é citada verbatim:**

> "The deferral blocker (inability to enforce per-agent tool scope) is therefore being removed […] **Re-open for a loop accept only if a concrete carve-out-safe atomic slice for a NON-carve-out agent still remains after the migration merges.**"

O merge aconteceu (PR #17, `dcb5e6b`; frontmatter em `2cb5aef`). A condição está **cumprida**. Ninguém reabriu — o ADR-033 identificou exatamente essa lacuna (nada no fluxo relê uma condição de reabertura registrada) e a reabertura foi autorizada pelo dono em 2026-08-07.

## O fato estrutural mudado (re-verificado contra a árvore hoje, não herdado da prosa)

`tools:` no frontmatter de `.claude/agents/*.md` é campo **imposto pela harness** (confirmado ao vivo pelo scout no ciclo 7 na doc de subagents do Claude Code, junto com `disallowedTools`/`permissionMode`/`maxTurns`).

| | agentes | n |
|---|---|---|
| **têm `tools:`** | challenger, curator, guardian, scout, sentinel | 5 de 13 |
| ├─ destes, **carve-out NFR-SEC-1** | challenger, guardian, sentinel | 3 |
| └─ destes, **não-carve-out** | curator, scout | 2 |
| **não-carve-out, SEM `tools:`** | architect, builder, chronicler, database-specialist, mcp-builder, strategist, system-designer, team | **8** |

⚖️ **Fronteira do carve-out, intocada.** challenger/guardian/sentinel já foram escopados **por mão humana** na migração. O loop **nunca** os edita — a fatia deles não faz parte deste candidato e não pode fazer. O que resta são os 8 acima.

## Questões em aberto que o @curator precisa resolver ANTES de pontuar

Estas não são detalhes; cada uma pode mover o score ou matar a fatia. São o motivo de o candidato viajar com elas.

1. **~~Assimetria do par de personas (ADR-028)~~ → RESOLVIDA pelo ADR-034, condicional a uma verificação.** O ADR-028 manda que `arquivo_alvo` nomeie o **par** (`.claude/agents/<x>.md` + `.claude/commands/agents/<x>.md`) e que tocar só uma cópia seja **fase FALHOU**, não sucesso parcial. Mas **0 de 13** personas-comando têm frontmatter YAML (verificado hoje: nenhuma começa com `---`), e `allowed-tools` não aparece em lugar nenhum de `.claude/commands/`. Ou seja: **a metade `commands/` estruturalmente não recebe `tools:`**. O **ADR-034** (2026-08-07) resolveu isso: campo imposto pela harness cuja superfície-irmã **não impõe equivalente** pode landar só na que impõe, desde que `arquivo_alvo` liste as duas e marque a excluída com a razão. ⚠️ **Mas a condição não está satisfeita ainda:** o ADR-034 exige que *"não impõe equivalente"* seja **verificado contra a doc primária (ADR-013)**, e o teste é **imposição**, não ausência — personas-comando **podem** ter frontmatter (`owl/research.md` tem), só não têm. **Isso torna a Q2 abaixo pré-requisito de caminho crítico, não curiosidade.** Se a verificação mostrar que `allowed-tools` num comando **é** imposto, não há assimetria: a edição vai nas duas metades na forma de cada uma, e a alternativa B do ADR-034 passa a valer.
2. **A sub-questão que o ciclo 7 registrou e deixou sem resposta, aqui verbatim:** *"whether `allowed-tools` on a **skill** is harness-enforced the way `tools`/`disallowedTools` are on a **subagent**"* — **não resolvida**, e explicitamente registrada *"for whoever re-opens that id"*. Se a resposta for "não é imposto", a classe *Unenforceable prose* volta a morder a metade `commands/`, e a fatia encolhe para só a metade `agents/`.
3. **`team` conta como alvo?** É o hub orquestrador e foi **excluído por design** do rollout do contrato de handoff (ADR-011, N/A). Se a mesma exclusão vale aqui, a superfície real é **7**, não 8. Não decidido.
4. **Qual é a fatia atômica?** "Adicionar `tools:` a 8 agentes" não é uma edição lógica — a-owl mantém 1 ideia → 1 ADR → 1 edição. Um agente por ciclo (a forma dos rollouts ADR-006/007/008) ou um conjunto justificado? Escolha do curator/architect, não deste registro.
5. **O que este candidato NÃO é.** Não é uma convenção nova de prosa dizendo "agentes devem ter escopo mínimo" — essa é a forma que foi deferida em 2026-07-23 e que a classe *Unenforceable prose* ainda rejeita. O delta é **o campo imposto**, não o texto.

## Ligação com o bloco de classes do ADR-030

O ADR-030 citava este id como exemplo vivo de *Unenforceable prose*. O exemplo foi **removido** em 2026-08-07 (`hd-unstale-rejected-class-example`) porque tinha expirado antes do bloco entrar em operação. A classe segue válida como **propriedade estrutural** — o que caducou foi a instância. Este candidato é o outro lado da mesma correção: o exemplo saiu do filtro, o id volta para a fila.

---

# PONTUAÇÃO — ciclo 9 (2026-08-12)

> As 5 questões em aberto acima foram resolvidas antes de pontuar, como o próprio candidato exigia. Q1/Q2 pela verificação alvo em [[scout-notes-2026-08-12]] §4; Q3 e Q4 aqui.

## Resolução das questões em aberto

**Q2 (pré-requisito de caminho crítico) — RESOLVIDA.** `allowed-tools` num comando **não** é imposto do jeito que `tools:` é num subagent. Doc primária, verbatim:

> "The `allowed-tools` field **grants permission** for the listed tools during the turn that invokes the skill […] **It does not restrict which tools are available: every tool remains callable.**"

É pré-aprovação de **um turno** que **alarga** acesso — oposto semântico de uma allowlist durável que estreita. ⚠️ Com a ressalva que este candidato tem que carregar: existe `disallowed-tools` na metade comando e ela **é** restritiva, mas *"The restriction clears when you send your next message"*. A afirmação verificada é **"sem allowlist durável"**, não "sem equivalente nenhum" — dizer o segundo seria overclaim.

**Q1 — RESOLVIDA em consequência.** A condição do ADR-034 está **satisfeita e verificada**: a metade `commands/` não impõe equivalente durável. A alternativa B do ADR-034 foi testada e falhou; a cláusula de assimetria vale.

**Q3 (`team` conta?) — SIM, conta.** A exclusão do ADR-011 é sobre **contrato de handoff** (o `team` é hub, não recebe handoff). Escopo de ferramenta é ortogonal a isso: o `team` executa e portanto tem superfície de ferramenta como qualquer outro. Superfície real = **8**, não 7.

**Q4 (qual é a fatia atômica?) — UM AGENTE**, na forma dos rollouts ADR-006/007/008 que o próprio candidato nomeia. Razão registrada sem maquiagem: **não existe lista de ferramentas declarada em lugar nenhum** — verificado, os `.devflow/agents/*.meta.yaml` não declaram `tools`. Logo a lista tem que ser **julgada**, não lida. Julgar 8 de uma vez é 8 decisões num commit (contra a atomicidade do ADR-010) e, pior, o modo de falha é **silencioso**: uma lista curta demais degrada o agente sem erro. Um agente por vez é verificável por leitura; oito não é.

## Curator verdict — score 80 (threshold 75)

| Criterion | Score | Note |
|---|---|---|
| Fit to architecture (25) | 20 | Campo imposto pela harness, agentes não-carve-out, assimetria ADR-034 verificada. −5: a ideia como escrita ("dar escopo aos 8") **não é** uma edição lógica; só vira atômica depois do haircut da Q4 para um agente. |
| Evidence strength (20) | 18 | `tools:` verificado na doc primária neste ciclo (*"Tools the subagent can use. Inherits every tool available to subagents if omitted"*), e a condição de reabertura foi escrita pelo ciclo 7 e está cumprida (PR #17). −2: evidência de **capacidade**, não de efeito — nenhuma fonte mede redução de incidente. |
| Impact (20) | 14 | Aperto real e **imposto**, não prosa — sem haircut do ADR-015, porque não é afirmação comportamental: `tools:` restringe de forma demonstrável. −6: os 8 agentes já são limitados pelo modo de permissão da sessão; a redução marginal de risco é modesta, e a fatia de 1 agente entrega 1/8 dela. |
| Simplicity & reversibility (15) | 9 | Revert é apagar uma linha — reversibilidade alta. Mas **verificabilidade baixa**: não dá para confirmar in-session que o agente editado continua funcionando sem instanciá-lo, e o modo de falha de uma lista curta demais é **silencioso** (degradação, não erro). A doc só promete falha ruidosa quando **nenhuma** entrada resolve. |
| Safety (10) | 10 | Restrição pura, zero capacidade nova. challenger/guardian/sentinel fora (carve-out), reconfirmado arquivo a arquivo. |
| Non-duplication (10) | 9 | Nenhum id decidido cobre isto — o `-v1` foi deferido por bloqueio que caiu. −1: adjacente a `routing-eligibility-mode` (ambos "campo imposto no frontmatter"), mas campo, superfície e efeito são distintos. |

**Safety sub-score 10 ≥ floor 7.** ✅ · **ACEITO — 3º dos 3 do cap.**

## Claim verification

- **Claim:** `tools:` no frontmatter de subagent é imposto pela harness; a superfície-irmã (`commands/`) não impõe equivalente durável.
- **Source:** [Claude Code — Create custom subagents](https://code.claude.com/docs/en/sub-agents) + [Extend Claude with skills](https://code.claude.com/docs/en/slash-commands) · buscadas 2026-08-12
- **Verdict:** **confirmed.**
- **Evidence:**
  > "`tools` | No | Tools the subagent can use. **Inherits every tool available to subagents if omitted.**"
  >
  > "`allowed-tools` […] **It does not restrict which tools are available: every tool remains callable.**"

## `arquivo_alvo` (ADR-028 + ADR-034)

- ✅ **RECEBE a edição:** `.claude/agents/chronicler.md`
- ⛔ **EXCLUÍDA COM RAZÃO VERIFICADA:** `.claude/commands/agents/chronicler.md` — a metade `commands/` não tem campo `tools`; o que ela tem (`allowed-tools`) é grant de turno que **alarga**, verificado na citação acima. Assimetria estrutural, não ausência por esquecimento.
- **Por que `chronicler` e não outro:** é o agente cuja superfície de ferramenta é mais claramente delimitável pelo que ele mesmo declara possuir (documentação: ler o repo, escrever docs, git para histórico) e é **não-carve-out**. Os outros 7 seguem na fila, um por ciclo.

## Related
- [[ledger]] (condição de reabertura, ciclo 7 · sub-questão não resolvida, passagem 2026-08-07)
- [[scout-notes-2026-08-12]] (a verificação que resolveu Q1/Q2) · [[routing-eligibility-mode]] (irmão do ciclo, mesma classe)
- ADR-033 (achado que destravou isto) · ADR-030 + `## Correção` (exemplo expirado) · ADR-028 (regra do par) + **ADR-034** (cláusula de assimetria — resolve a Q1, condicional à Q2) · ADR-011 (`team` N/A) · ADR-010 (modelo inline-exec, o bloqueio original)
- Fonte do fato estrutural: `.claude/agents/*.md` frontmatter, merge `dcb5e6b` / `2cb5aef` (PR #17)
