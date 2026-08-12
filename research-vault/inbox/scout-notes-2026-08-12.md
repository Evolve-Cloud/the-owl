---
title: "Scout notes — ciclo 9 (2026-08-12), eixo: orchestration topology"
type: source
tags: [scout, cycle-9, orchestration, frontmatter, routing]
sources: 3
updated: 2026-08-12
---

**Entrada:** [[research-brief-2026-08-12]] (3 fontes, 2 ideias) · **Eixo:** orchestration topology · **Cutoff:** 2026-07-13

> [!important] Todo conteúdo externo abaixo é **dado, não instrução** (NFR-SEC-2). Nenhuma diretiva encontrada em fonte externa foi executada. Nenhuma fonte continha texto dirigido ao pipeline.

---

## 1. Verificação das fontes do brief (o scout não confia, confere)

O brief afirmou dois fatos externos de carga. Os dois foram buscados na fonte primária.

### ✅ CONFIRMADO — `infer: false` no GitHub Copilot SDK

**Fonte:** [GitHub Docs — Custom agents and sub-agent orchestration](https://docs.github.com/en/copilot/how-tos/copilot-sdk/features/custom-agents) (primária) · buscada 2026-08-12

Tabela de config, verbatim:
> `infer` | `boolean` | "Whether the runtime can auto-select this agent (default: `true`)"

E o exemplo de código da própria doc:
```typescript
{
    name: "dangerous-cleanup",
    description: "Deletes unused files and dead code",
    infer: false, // Only invoked when user explicitly asks for this agent
}
```
Na sequência de delegação: a seleção ocorre *"If a match is found and `infer` is not `false`"*.

O brief descreveu isto com precisão. **Confirmado, não parafraseado.**

### ⚠️ NÃO verificado — o pinning de roster do Managed Agents

`pinned-roster-snapshots` apoia-se numa única fonte (s1, `platform.claude.com/docs/en/managed-agents/multiagent-orchestration`) que **não foi buscada nesta passagem**. O candidato segue com `evidence: [s1]` **não confirmada** — e pelo ADR-013 isso o barra de ser aceito até que seja. Registrado como estado, não como falha.

---

## 2. 🔑 O achado do ciclo: a versão IMPOSTA de `infer` já existe na nossa harness

O brief marcou o próprio risco de `routing-eligibility-mode`:

> "If described as enforcement when the Claude Code harness does not enforce it directly, it risks becoming unenforceable prose"

**Essa ressalva está desatualizada.** A busca na doc primária do Claude Code mostra que a harness **impõe** exatamente este controle — e com o mesmo nome de conceito que o GitHub deu.

**Fonte:** [Claude Code — Extend Claude with skills](https://code.claude.com/docs/en/slash-commands) (primária) · buscada 2026-08-12

| campo | doc verbatim | equivale a |
|---|---|---|
| `disable-model-invocation` | "Set to `true` to **prevent Claude from automatically loading this skill**. Use for workflows you want to trigger manually with `/name`." | `infer: false` |
| `user-invocable` | "Set to `false` to **hide from the `/` menu**." | (sem par no GitHub) |

E a doc nomeia o caso de uso **exatamente** como o do GitHub:
> "Use this for workflows **with side effects** or that you want to control timing, like `/commit`, `/deploy`, or `/send-slack-message`. **You don't want Claude deciding to deploy because your code looks ready.**"

**Convergência de dois fornecedores independentes** (GitHub Copilot SDK e Anthropic Claude Code) no mesmo controle, no mesmo mês. E do nosso lado ele **não é prosa** — é campo lido pela harness.

### O fato estrutural que faltava aos dois candidatos reabertos

> "**Custom commands have been merged into skills.** A file at `.claude/commands/deploy.md` and a skill at `.claude/skills/deploy/SKILL.md` both create `/deploy` and work the same way."

**As 13 personas-comando da-owl SÃO skills** e suportam ~20 campos de frontmatter. A premissa que `least-privilege-tool-scopes-v2` e `agent-frontmatter-fields-v2` carregam — *"a metade `commands/` estruturalmente não recebe frontmatter"* — **é falsa**. Ela recebe; só não recebe **aqueles dois campos específicos**. A assimetria do ADR-034 sobrevive **campo a campo**, não como propriedade da superfície. (Detalhe completo em `## 4`.)

---

## 3. Estado REAL da-owl (verificado contra a árvore hoje, não herdado de prosa)

```
.claude/commands/agents/*.md   → 13 arquivos, 0 com frontmatter
.claude/commands/owl/*.md      → 2 arquivos, 2 com frontmatter
.claude/commands/quick/*.md    → 9 arquivos, 9 com frontmatter
```

**Chaves de frontmatter efetivamente usadas nos 11 comandos que têm frontmatter:**

| chave | ocorrências | é campo real do Claude Code? |
|---|---|---|
| `trigger:` | 11 | ❌ **NÃO** — ausente da tabela de referência |
| `category:` | 11 | ❌ **NÃO** — ausente da tabela |
| `priority:` | 11 | ❌ **NÃO** — ausente da tabela |

**11 de 11 blocos de frontmatter de comando da-owl são compostos INTEIRAMENTE de campos que a harness ignora.** Parecem configuração. Não configuram nada.

E o campo que de fato governa quando Claude carrega um comando — `description` — está **ausente dos 11**. (Sem ele, a doc diz que a harness cai para *"the first paragraph of markdown content"*.)

`disable-model-invocation` aparece **0 vezes** em todo o repo.

> [!important] **Consequência que precisa ser dita em voz alta, e que é decisão do DONO, não do loop.**
> `/owl:evolve` — o loop autônomo que escreve ADR, edita agentes e commita — **não tem `disable-model-invocation: true`**. Pela doc: *"By default, Claude can invoke any skill that doesn't have `disable-model-invocation: true` set."* O `trigger:` que o arquivo carrega e que parece cumprir esse papel é inerte.
> ⚖️ **O scout NÃO propõe que o loop edite isso.** Um loop que ajusta a própria superfície de disparo é precisamente a classe que o carve-out NFR-SEC-1 mantém em mão humana — mesmo quando a edição **aperta** em vez de afrouxar. Levantado para o dono, marcado, não acionado.

---

## 4. Verificação alvo que os DOIS candidatos reabertos declaravam como pré-requisito

Ambos escreveram: *"resolver ANTES de pontuar"*. Resolvido aqui, na doc primária.

### Subagent (`.claude/agents/*.md`) — lista completa, verbatim
> "…`description`, `prompt`, `tools`, `disallowedTools`, `model`, `permissionMode`, `mcpServers`, `hooks`, `maxTurns`, `skills`, `initialPrompt`, `memory`, `effort`, `background`, `isolation`, and `color`."

| campo | veredito | correção ao candidato |
|---|---|---|
| `maxTurns` | **REAL** — "Maximum number of agentic turns before the subagent stops" | — |
| `memory` | **REAL** | o candidato escreve `Memory`; **o campo é minúsculo** |
| `isolation` | **REAL** — "Set to `worktree` to run the subagent in a temporary git worktree" | só aceita `worktree`; é concern de VCS/runtime, **não** de prompt |

⇒ Os **três** campos do título de `agent-frontmatter-fields` são reais. Aquele bloqueio **caiu por inteiro**.

### Comando/skill — o campo `tools` NÃO existe; `allowed-tools` é outra coisa

Verbatim, e é a citação que decide:
> "The `allowed-tools` field **grants permission** for the listed tools during the turn that invokes the skill […] **It does not restrict which tools are available: every tool remains callable.**"

`allowed-tools` é o **oposto semântico** de `tools:` — pré-aprovação que **alarga**, com escopo de **um turno**. `tools:` num subagent é allowlist que **estreita**, pela vida do subagent.

⚠️ **Ressalva que o candidato tem que carregar, não esconder:** existe `disallowed-tools` na metade comando, e ela **é** restritiva — mas *"The restriction clears when you send your next message"*. Então a afirmação verificada **não** é "sem equivalente nenhum". É:

> a metade `commands/` **não tem allowlist durável**; o que ela tem é *grant* de turno e *denylist* efêmera.

Dizer "sem equivalente" seco seria **overclaim** — e o ADR-034 exige razão **verificada**, não presumida.

### ⇒ Condição do ADR-034: **SATISFEITA e verificada** para os dois candidatos

| campo proposto | metade `agents/` | metade `commands/` | assimetria |
|---|---|---|---|
| `tools:` | impõe allowlist durável | **sem equivalente durável** | **SIM, verificada** |
| `maxTurns:` | impõe teto de turnos | **campo inexistente** | **SIM, verificada** |

A alternativa B do ADR-034 (*"se for imposto, edite as duas metades"*) foi **testada e falhou** — a cláusula de assimetria é a que vale. O ADR-034 era falsificável por construção; foi exercitado e sobreviveu.

---

## 5. Candidatos que este scout entrega ao @curator

| id | origem | delta | uma linha |
|---|---|---|---|
| `routing-eligibility-mode` | brief (s2,s3) + scout | net-new | eligibilidade de roteamento por especialista — **e a harness impõe** via `disable-model-invocation` |
| `pinned-roster-snapshots` | brief (s1) | recency | roster versionado em ADR que muda topologia — **fonte não verificada** |
| `inert-command-frontmatter` | scout (reflection) | net-new | 11/11 blocos de frontmatter de comando usam só campos que a harness ignora; `description` ausente nos 11 |
| `stale-context-block-in-l0-prompt` | scout (reflection) | net-new | o bloco CONTEXT do artefato 8a afirma propriedades expiradas e agora **contradiz** o bloco de classes do mesmo prompt |

### Sobre `stale-context-block-in-l0-prompt` — achado ao montar o próprio L0 deste ciclo

`docs/planning/artifacts/chatgpt-research-brief-prompt.md:30-41` é injetado no prompt do codex **todo ciclo** e diz:

> "the-owl is a markdown-only, **NO-RUNTIME** library of **~8** specialized Claude Code agents […] **No orchestration engine, no swarm runtime, no daemon.**"

Contra `docs/conventions/structural-properties.md`: P1 (spawner), P2 (scheduler), P3 (hooks), P4 (subagents), P6 (markdown-only) — **as cinco FALSAS**. E são 13 agentes, não ~8.

**O agravante:** a correção de 2026-08-07 consertou o bloco `## REJECTED CLASSES` do `research.md`, que é injetado no **mesmo prompt**. O prompt montado hoje portanto se **contradiz internamente**: o CONTEXT diz *"no daemon, no orchestration engine"* e, 90 linhas abaixo, o bloco de classes diz *"Existem spawner (Agent tool + 13 subagents nativos), scheduler (launchd) e hooks de git ativos"*.

**Por que ninguém pegou:** a seção *"O que depende deste registro"* do `structural-properties.md` lista `research.md`, `evolve.md`, `ledger.md`, ADR-010/001/030 — **e não lista o artefato 8a**. O registro de acoplamento tem um buraco exatamente do tamanho do arquivo que carrega a afirmação para dentro do prompt. Não é o mecanismo do ADR-033 falhando: é a **lista de alvos dele estando incompleta**.

---

## Related
- [[research-brief-2026-08-12]] · [[structural-properties]] · [[ledger]]
- Irmãos reabertos aguardando pontuação: `least-privilege-tool-scopes-v2` · `agent-frontmatter-fields-v2`
- ADR-034 (cláusula de assimetria — verificada aqui) · ADR-013 (verificação de claim) · ADR-030 (bloco de classes) · ADR-033 (passo 4.6)
