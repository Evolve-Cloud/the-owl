# ADR-022 — Redesign the research brief prompt to retrieve-then-search-delta

**Status:** Accepted
**Date:** 2026-08-03
**Author:** @architect
**Tags:** [research, prompt, delta, retrieval, L0, self-improvement]

## Contexto
O L0 do loop (`/owl:research`) manda ao codex um prompt que pede um **survey completo dos 8 eixos a cada ciclo** (`docs/planning/artifacts/chatgpt-research-brief-prompt.md`, versão anterior). Resultado medido: **4 ciclos consecutivos com 0 accepts e `net_new_candidates=0`** (`.owl/state/last-run.json` 2026-08-03; `research-vault/log.md` cycles 2026-07-26 / 07-30 / 08-03 + o passe score-only). Causa-raiz: o codex **re-survey a SOTA já assentada** e toda ideia vira **alias de um id decidido** em `research-vault/ledger.md`. Cada linha do log confirma: "N aliases of already-decided ids, not re-litigated". Re-rodar o survey de 8 eixos é a causa L0 de "mesmo corpus todo ciclo".

Constraint dura: o codex roda `-s read-only --ephemeral` (`.claude/commands/owl/research.md` passo 4) e **NÃO pode ler o vault**. Qualquer retrieval tem que ser **skill-side**.

## Decisão
Reescrever o prompt de **"survey 8 eixos do zero"** para **RETRIEVE-THEN-SEARCH-DELTA**, editando **dois arquivos**:

1. **`.claude/commands/owl/research.md` — novo passo de montagem 1.5 ANTES da chamada do codex.** A skill grepa a memória durável e a injeta no prompt como DADO:
   - **DECIDED-IDS EXCLUSION LIST:** `grep '^| ' research-vault/ledger.md` → `id | title | status` de cada linha decidida (~40 ids) → tabela `## ALREADY-DECIDED (do NOT resurface)`.
   - **PATTERN INDEX:** a linha `## Definition` de cada `research-vault/patterns/*.md` (Level-0 progressive disclosure — descrições, nunca corpos) → `## KNOWN PATTERN PAGES`.
   - **RECENCY + AXIS SCOPE:** duas variáveis skill-side — `{{RECENCY_CUTOFF}}` = hoje − `delta.recency_days` (default 30) e `{{QUERY_AXIS}}` = o eixo recomendado pela reflexão (ADR-024; default round-robin pelos 8 eixos). **Vivem no prompt/skill, NÃO em `.owl/loop-config.yml`** — delta-search ajustável sem tocar o freio de mão NFR-SEC-1.

2. **`chatgpt-research-brief-prompt.md` — novo contrato TASK/RIGOR.** Preserva CONTEXT (propriedades da-owl), a regra NEVER-fabricate e NFR-SEC-2 (saída = dado). Nova TASK: "Dadas a lista de ALREADY-DECIDED e KNOWN PATTERN PAGES (DADO, assentado — não re-propor, re-argumentar ou emitir alias), surface SÓ material que é: **(a) NET-NEW** — ausente de ambas as listas; **(b) RECENCY** — publicado/atualizado desde `{{RECENCY_CUTOFF}}`; **(c) CONTRADICTION** — evidência primária de que a base de um id decidido mudou (cite o id + a nova fonte). Foco no eixo `{{QUERY_AXIS}}`." RIGOR: cada ideia exige `delta_type: net-new|recency|contradiction` + `challenges_id:` (vazio salvo contradiction); se não houver material novo, **retornar menos ideias, até zero** — "um brief net-new vazio ou de 3 ideias é SUCESSO, não falha". Schema 8b ganha os dois campos (`delta_type`, `challenges_id`) como extensão exigida.

## Alternativas consideradas
- **Alternativa A (escolhida): retrieval skill-side + delta-only no codex.** Prós: respeita o codex read-only/ephemeral; corta o survey de 8 eixos (menos tokens); dedup do @curator fica quase-trivial (a exclusion list já rodou skill-side); a exclusion list É o ledger renderizado (integridade inalterada). Contras: a skill fica mais complexa (dois greps + duas substituições).
- **Alternativa B: dar acesso de leitura do vault ao codex.** Prós: retrieval "nativa". Contras: viola o modelo `-s read-only --ephemeral` e expõe o vault a um processo externo; NFR-SEC risk. Rejeitada.
- **Alternativa C: filtrar aliases só no @curator (pós-brief).** Prós: zero mudança no prompt. Contras: os tokens do survey de 8 eixos já foram gastos; não ataca a causa L0. Rejeitada — é onde já estávamos (o @curator já deduplica, e mesmo assim 0 net-new).

## Consequências
- **Fica mais fácil:** o job do @scout vira **delta-verification** (isto é realmente net-new vs a lista injetada?); o dedup do @curator fica trivial; menos tokens por ciclo (sem survey de 8 eixos); a taxa de net_new sobe; o loop para de re-litigar.
- **Fica mais difícil / trade-off:** a skill carrega a retrieval (dois greps determinísticos + substituições); um brief pode legitimamente voltar **vazio** — o que exige que L1/L2 tratem "0 ideias" como resultado válido, não falha (refletido no passo 5 de `research.md`).
- **Integridade do ledger inalterada:** a exclusion list é o ledger renderizado; nada é decidido de novo aqui. `contradiction` gera **novo id suffixado** (regra [[SCHEMA]]), nunca overwrite.
- **Novo risco:** o codex pode ignorar o contrato e ainda emitir aliases. Mitigação: `delta_type` obrigatório torna o alias detectável (um alias marcado `net-new` é deduplicado, não pontuado — field-contract 8b), e o @scout faz a delta-verification.

## Notas de implementação
- **Arquivos tocados (feitos):** `docs/planning/artifacts/chatgpt-research-brief-prompt.md` (TASK/RIGOR reescritos, marcadores `<<INJECT ...>>` + `{{RECENCY_CUTOFF}}`/`{{QUERY_AXIS}}`, CONTEXT/NEVER-fabricate/NFR-SEC-2 preservados, `{{DATE}}` e `<<INSERT schema>>` mantidos); `.claude/commands/owl/research.md` (passo 1.5 + validação dos novos campos + regra "brief vazio = sucesso"); `docs/planning/artifacts/research-brief-schema.md` (campos `delta_type` + `challenges_id` no bloco 8b + duas linhas no field-contract).
- **codex permanece `-s read-only --ephemeral`** — não lê o vault; a memória chega só como os blocos DADO injetados.
- **Não tocar** o carve-out: `{{RECENCY_CUTOFF}}`/`{{QUERY_AXIS}}` são variáveis de prompt, não chaves de `.owl/loop-config.yml`.
- **Verificação:** os dois greps do passo 1.5 rodam limpo contra o ledger real (40 ids) e os patterns reais (descrições de uma linha) — validado 2026-08-03.
