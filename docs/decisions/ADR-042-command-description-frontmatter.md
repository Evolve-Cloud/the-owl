# ADR-042 — description: nos 11 comandos (inert-command-frontmatter) + disable-model-invocation no /owl:evolve

**Status:** Accepted
**Date:** 2026-08-13
**Author:** dono (owner-directed — promove o candidato `inert-command-frontmatter`, 80, cabeça da fila do ciclo 11 com pré-condição satisfeita)
**Tags:** [frontmatter, commands, loading, safety]

## Contexto
`inert-command-frontmatter` (ledger, 80): 11 de 11 blocos de frontmatter de comando usavam SÓ campos que a harness ignora (`trigger:`/`category:`/`priority:`), e `description:` — o campo que de fato governa o carregamento — estava ausente de todos. Sem ele a harness cai no primeiro parágrafo do corpo, então adicionar `description:` **muda quando Claude carrega** os comandos (não é cosmético — razão do resequenciamento pós-ADR-036). A pré-condição escrita ("rodar o grep de consumidores ANTES do ADR") foi executada no ciclo 10: único consumidor é `scripts/pack-owl-agents.sh`, que copia `quick/` para o pack — mitigação: re-rodar o pack no mesmo commit. Item relacionado em `open_for_owner` (ciclo 10): `/owl:evolve` sem `disable-model-invocation` deixa Claude **auto-invocar o loop autônomo**.

## Decisão
1. `description:` precisa e aterrada no corpo real, nos **11** arquivos: 9 `quick/*` + `owl/research.md` + `owl/evolve.md`. Campos legados mantidos como documentação.
2. `disable-model-invocation: true` em `owl/evolve.md` — decisão do DONO (o ciclo 10 registrou corretamente que o loop não pode tunar o próprio trigger). O schedule NÃO é afetado: `claude -p "/owl:evolve"` é invocação de usuário, não do modelo; nenhum agente peer-invoca `/owl:*` (grep dos 13 pares: só `agents:*`).
3. `owl-agents/` re-packed no mesmo commit (fecha a pré-condição do consumidor).

## Alternativas consideradas
- **A (escolhida): description + disable-model-invocation no evolve, campos legados mantidos.** Prós: carregamento explícito; fecha a superfície de auto-invocação do loop; pack fresco. Contras: descriptions são texto que pode divergir do corpo (mesma classe de qualquer prosa — coberto pelo ADR-017/staleness).
- **B: remover trigger/category/priority junto.** Prós: menos ruído. Contras: são documentação de intenção útil e custo zero; remoção é mudança a mais sem ganho verificado.
- **C: não tocar `owl/evolve.md` (só os outros 10).** Prós: máxima cautela. Contras: deixa aberta a auto-invocação do loop autônomo — exatamente o risco que `open_for_owner` nomeou; a assimetria "usuário pode, modelo não" é o comportamento desejado e o campo é verificado real (fonte primária, ADR-036/038).

## Consequências
Os 9 `/quick:*` e os 2 `/owl:*` carregam por descrição explícita, não por primeiro parágrafo. O modelo não pode mais disparar `/owl:evolve` sozinho — só o dono e o schedule. Risco aceito: se a doc da harness mudar a semântica de `disable-model-invocation`, o registro P-novo entra na varredura 4.6 (propriedade de capacidade, caminho-prova `owl/evolve.md`).

## Notas de implementação
Aplicado por script (python, assert de frontmatter existente + ausência prévia de `description:`), 11/11 ok. Pack re-rodado: 11 agents / 9 quick cmds. Ledger: linha `inert-command-frontmatter` promovida deferred→accepted (precedente da promoção do `convention-staleness-review`, 2026-07-26, sem id sufixado).
