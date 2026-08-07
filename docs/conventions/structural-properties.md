# Registro — Propriedades estruturais da-owl (o que somos, verificado)

**Status:** Adotado (ADR-033, forma B) · **Ratificado:** 2026-08-07 · **Última verificação completa:** 2026-08-07

## Por que este arquivo existe

A-owl rejeita famílias inteiras de ideias invocando **propriedades estruturais** — "não temos runtime", "é markdown-only", "é inline-exec". Essas frases entram no prompt de pesquisa (bloco de classes do ADR-030), em ADRs e em razões de deferral no `ledger.md`, e passam a decidir por conta própria.

**Propriedade estrutural muda.** Quando muda e ninguém relê, a rejeição sobrevive à razão: o filtro continua barrando uma família cujo bloqueio já caiu. Isso aconteceu de forma verificada — o PR #17 derrubou o bloqueio de `least-privilege-tool-scopes`, um humano registrou a queda por escrito no ciclo 7, e nada releu o registro. A varredura de 2026-08-07 achou **um evento invalidando 3 linhas do ledger e 3 afirmações vivas**, incluindo uma dentro do próprio ADR-033.

Este registro é a **lista que a regra re-verifica**. Sem ela, a regra não tem alvo — a varredura de 2026-08-07 teve que reconstruir a lista à mão, e é essa reconstrução que não pode depender de alguém lembrar.

> ⚖️ Isto é um **registro de fatos**, não uma convenção de comportamento. Ele não diz o que um agente deve fazer; ele diz o que é verdade sobre a-owl hoje, com a prova. A regra que o consome está em `curator.md` (passo 4.6).

## As propriedades

`prova` = os caminhos cujo estado **demonstra** a propriedade. São eles que disparam a re-verificação (ver Gatilho).

| # | Propriedade afirmada | Estado hoje | Prova (caminhos) | Verificado |
|---|---|---|---|---|
| P1 | "não há **spawner**" | **FALSA** — existem Agent tool, 13 subagents nativos e o agente `team` (fan-out paralelo) | `.claude/agents/*.md` | 2026-08-07 |
| P2 | "não há **scheduler**" | **FALSA** — launchd. Mas é **carve-out**: o loop não o edita | `scripts/*.plist`, `scripts/owl-daily.sh` | 2026-08-07 |
| P3 | "não há **superfície de trigger / hook**" | **FALSA** — `post-commit` e `post-checkout` ativos, disparando a cada commit; `post-commit` computa `git diff --name-only` | `.git/hooks/`, `.claude/settings*.json` | 2026-08-07 |
| P4 | "**inline-exec**: não existe `.claude/agents/`" | **FALSA** — 13 existem desde o PR #17. O loop roda inline por **decisão de confiabilidade** (ADR-010), não por ausência | `.claude/agents/*.md`, `.claude/commands/owl/evolve.md` | 2026-08-07 |
| P5 | "escopo de ferramenta por agente é **inimponível**" | **FALSA (parcial)** — `tools:` é imposto pela harness em **5 de 13**. `Memory`/`isolation` seguem **não verificados** como campos reais | `.claude/agents/*.md` frontmatter | 2026-08-07 |
| P6 | "**markdown + YAML** apenas" | **FALSA (parcial)** — há Python e shell em `scripts/` | `scripts/` | 2026-08-07 |
| P7 | "topologia **hub-and-spoke**" | **VERDADEIRA** — especialistas devolvem o controle, nunca chamam uns aos outros | `.claude/commands/agents/*.md`, ADR-010 | 2026-08-07 |
| P8 | "**carve-out NFR-SEC-1**" | **VERDADEIRA** — governança, não capacidade. Não expira por mudança de harness | ADR-001, `.owl/loop-config.yml` | 2026-08-07 |

### A distinção que faz o trabalho

**P1–P6 são capacidade. P7–P8 são escolha.** Capacidade muda quando a plataforma muda; escolha só muda por decisão do dono.

Quase toda rejeição "runtime-shaped" da-owl está de fato correta — mas pela razão errada. O que desqualifica não é *"a-owl não tem runtime"* (falso), é **"o loop não pode mexer no runtime que existe"** (verdadeiro: carve-out + design sequencial). Conclusão certa, premissa expirada. É essa confusão que este registro existe para impedir, e é literalmente o defeito que o bloco de classes carregava até 2026-08-07.

## Gatilho — quando re-verificar

**Não é por ciclo.** Propriedade estrutural muda de forma **rara e discreta** (uma vez na história deste repo até agora); reler no relógio gasta atenção em ciclo parado e ainda assim chega tarde. A re-verificação dispara por **evento**:

1. **Qualquer caminho da coluna `Prova` foi tocado ou observado no ciclo.** Verificável mecanicamente:
   ```bash
   # o que mudou nos caminhos-prova desde a última verificação completa
   git log --since=2026-08-07 --name-only --pretty=format: -- \
     .claude/agents/ scripts/ .claude/settings.json .claude/commands/owl/evolve.md | sort -u
   ls .git/hooks/ | grep -v '\.sample$'   # hooks não são rastreados pelo git
   ```
2. **O @scout ou o @curator registrou um achado de capacidade** em `ledger.md` / `log.md` — "campo X é imposto pela harness", "a plataforma agora faz Y". Foi exatamente esta a forma do achado do ciclo 7.

Qualquer um dos dois ⇒ rodar o passo 4.6 do `curator.md`. Nenhum dos dois ⇒ **custo zero**, nada a fazer, nada a logar.

## O que depende deste registro (manter em sincronia — os dois sentidos)

- **`.claude/commands/owl/research.md`** → o bloco `## REJECTED CLASSES`, injetado no prompt do codex **todo ciclo**. A classe *Runtime-shaped* afirma P1–P4 e P8. **Mudou aqui ⇒ reler lá.** (O bloco aponta de volta para cá.)
- **`.claude/commands/owl/evolve.md`** → o "Modelo de execução" afirma P4 e P7.
- **`research-vault/ledger.md`** → razões de deferral/rejeição que citam uma propriedade. São o alvo da varredura do passo 4.6.
- **ADR-010** (inline-exec/hub-spoke) · **ADR-001** (carve-out) · **ADR-030** (o bloco de classes).

## Limites

- ⛔ **Este registro não autoriza nada.** Uma propriedade virar falsa **não** torna a ideia associada aceitável — ela volta a ser **candidata**, pontuada pela rubrica normal, com veto de segurança, haircut do ADR-015 e gate. Nunca auto-aceita.
- ⛔ **P8 (carve-out) não expira.** É governança. Nenhuma mudança de harness a move; só o dono.
- ⚖️ **Não confundir "a capacidade existe" com "o loop pode usá-la".** P2 e P3 existem e são intocáveis pelo loop.
- 📌 **Editar git hooks está fora** — hook executa código, é superfície de segurança e decisão do dono. Este registro apenas **observa** que hooks existem.

## Related
- ADR-033 (forma B — a regra que consome este registro) · ADR-030 (bloco de classes) · ADR-017 (o espelho: staleness de convenções *aceitas*) · ADR-001 (carve-out) · ADR-010 (inline-exec, hub-spoke)
- Varredura que produziu a lista: `research-vault/log.md` → `[2026-08-07] sweep`
