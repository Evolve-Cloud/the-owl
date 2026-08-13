# ADR-044 — Observabilidade externa do schedule: watchdog no GitHub + auto-abertura do shadow PR

**Status:** Accepted
**Date:** 2026-08-13
**Author:** dono (owner-directed, Passo 4 do plano ADR-040)
**Tags:** [schedule, liveness, github-actions, adr-039, adr-010]

## Contexto
Dois limites conhecidos e escritos: (1) o passo 4.7 (ADR-039) declara *"só roda quando um ciclo roda — não detecta um repo completamente parado"* — o verificador retroativo ainda vive na mesma máquina que o mecanismo verificado; (2) desde o ADR-010, o run agendado sem token **não abre o PR** — empurra a branch e depende de um humano lembrar de abrir. O schedule já morreu 3 semanas em silêncio uma vez.

## Decisão
Dois workflows no GitHub (fora do Mac executor):
1. **`owl-schedule-watchdog.yml`** — cron toda terça 15:00 UTC (dia seguinte à janela de segunda): se nenhuma branch `owl/evolve-*` recebeu push em 8 dias, abre/atualiza uma issue rotulada `owl-watchdog` com o checklist de diagnóstico (regra dos DOIS artefatos do ADR-039) e falha o job; quando volta a viver, comenta e fecha a issue. **Observa e alerta; NUNCA repara** — mesma fronteira do 4.5/4.6/4.7.
2. **`owl-open-shadow-pr.yml`** — em push de `owl/evolve-**`, abre o shadow PR contra `main` com `GITHUB_TOKEN` se ainda não existir.

O launchd continua o EXECUTOR — mover a execução do loop para Actions exigiria API keys pagas (hoje codex/claude rodam na autenticação de assinatura do Mac) e secrets no repo; recusado.

## Alternativas consideradas
- **A (escolhida): executor local + observador externo.** Prós: fecha os dois gaps com `GITHUB_TOKEN` nativo (zero secrets novos, zero custo de API); a topologia do ADR-039 finalmente tem um verificador FORA da máquina verificada. Contras: depende do repo estar no GitHub e do cron de Actions (que pode atrasar minutos — irrelevante numa cadência semanal).
- **B: mover a execução do loop para GitHub Actions.** Prós: elimina o Mac como ponto único. Contras: API keys pagas + secrets de codex/claude no repo + runner sem `~/.codex` — mudança de modelo de custo e de superfície de segurança; não é higiene, é migração.
- **C: segundo watcher local (cron/launchd irmão).** Contras: "mais uma coisa que morre em silêncio na mesma máquina" — o argumento do próprio ADR-039 contra daemons novos.

## Consequências
Repo parado com automação morta deixa de ser o caso invisível: o alerta chega como issue, de fora. O follow-up de PR manual do ADR-010 morre. Riscos aceitos: workflows agendados só rodam depois do merge na default branch; issues do watchdog em repo privado consomem minutos de Actions (desprezível). O `evolve.md` L5 mantém o fallback de compare-URL (defesa em profundidade se o workflow falhar).

## Notas de implementação
`.github/workflows/owl-schedule-watchdog.yml` + `owl-open-shadow-pr.yml`. Permissions mínimas por workflow (`issues: write` / `pull-requests: write`). Verificação pós-merge: disparar o watchdog via `workflow_dispatch` e conferir o veredito "Vivo"; no próximo push agendado de branch `owl/evolve-*`, conferir o PR auto-aberto.
