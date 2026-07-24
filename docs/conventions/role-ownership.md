# Convenção — Papel & Não-Papel (ownership de cada agente)

**Status:** Adotado (ADR-009) · **Origem:** ciclo autônomo do `/owl:evolve` (2026-07-24) · **Par de:** [`handoff-contract.md`](./handoff-contract.md)

## Por quê
Rótulo de papel não basta. O modo de falha convergente (e primário) da engenharia de times de agentes em 2026 é: **papéis vagos e responsabilidades sobrepostas fazem agentes duplicarem trabalho ou empurrarem tarefas em loop, sem resolução** (CrewAI 2026); "um monte de agentes sobrepostos é mais difícil de gerir do que poucos bem afiados" (Anthropic best-practices). O antídoto é declarar, para cada agente, **o que ele possui e o que ele explicitamente NÃO possui** — com o dono da fronteira contestada nomeado. Isto reforça o princípio hub-and-spoke e contexto-mínimo (N-1) da-owl.

## O contrato (campos obrigatórios)
Todo agente declara, de forma consistente entre o seu `.md` (prosa) e o seu `.meta.yaml` (estruturado):

| Campo | O que é |
|---|---|
| **Possui** | Os direitos de decisão do agente + o **único artefato** que ele entrega (com path/formato). |
| **Não possui** | As decisões/ações fora do escopo — cada uma apontando **qual agente é o dono** (fronteira explícita, não implícita). |
| **Entradas exigidas** | As dependências diretas a montante de que ele precisa para começar (ponteiros, não histórico). |
| **Critério de pronto** | Condição verificável de que o artefato dele está completo. |
| **Fonte da verdade** | A prosa (`🎯 Minha Responsabilidade` / `⛔ NUNCA FAÇA` / `⚠️ Quando NÃO me usar`) e o `.meta.yaml` (`responsibilities.primary` / `constraints.should_not_do` / `should_delegate_to` / `outputs`) **devem concordar**. |

## Regras
- **Uma fronteira, um dono.** Nenhuma responsabilidade é de dois agentes. Se duas funções brigam por uma fronteira, o `Não possui` de um aponta para o `Possui` do outro.
- **Não-Papel é tão obrigatório quanto Papel.** Declarar só o que se faz — sem declarar o que NÃO se faz e para quem delegar — é o que reintroduz a sobreposição.
- **Estruturado + prosa em sincronia.** O `.meta.yaml` é a forma auditável do ownership; o `.md` é a forma legível. Divergência entre os dois é bug a corrigir.
- **Hub-and-spoke preservado.** O agente devolve o controle ao orquestrador e nunca invoca outro especialista diretamente (ver [`handoff-contract.md`](./handoff-contract.md)).

## Rollout (follow-up incremental, um agente por ADR)
Esta convenção é a fonte da verdade; ciclos seguintes do `/owl:evolve` incorporam a seção "Papel & Não-Papel" em cada agente, incrementalmente. Estado atual encontrado na auto-auditoria (L1.5, ADR-005): 8 de 11 agentes têm `.meta.yaml` com os campos de ownership; **`scout` e `curator` ainda não têm** (`.meta.yaml` a criar no rollout).

> ⚖️ **Carve-out NFR-SEC-1:** o `sentinel` também não tem `.meta.yaml`, mas está **dentro do carve-out** — o loop **NUNCA** o edita. A metadata de ownership do `sentinel` (e de `guardian`/`challenger`) é completada **por um humano**. Esta convenção apenas documenta o padrão; ela não autoriza o loop a tocar nesses arquivos.
