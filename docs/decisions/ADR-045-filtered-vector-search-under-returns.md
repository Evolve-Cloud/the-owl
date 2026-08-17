# ADR-045 — Filtered vector search under-returns, and our own eval advice is what hides it

**Status:** Accepted
**Date:** 2026-08-17
**Author:** @architect (ciclo autônomo do `/owl:evolve`, cycle 11)
**Tags:** [capability, data-engineering, rag, retrieval, database-specialist]

## Contexto

O eixo de capacidade deste ciclo foi `data-engineering` (CX2). A passagem própria do @scout achou uma propriedade dos índices vetoriais aproximados que o `database-specialist` não carrega — e o interessante não é o fato isolado, é **onde** ele cai.

O agente já sabe as duas peças, separadamente:

- `.claude/agents/database-specialist.md:86` — recomenda o índice vetorial: *"pgvector (HNSW p/ recall, IVFFlat p/ memória)"*.
- `.claude/agents/database-specialist.md:88` — exige avaliação medida: *"recall@k / precision@k — o doc que responde à pergunta é recuperado? Monte um golden set de (pergunta → doc esperado) e meça"*.

O que falta é a **interação** entre elas. Com índice aproximado, o filtro roda **depois** da varredura do índice, não durante. O índice devolve uma lista de candidatos de tamanho fixo (`hnsw.ef_search`, default 40) e o `WHERE` então descarta a maior parte dela. Fonte primária, buscada ao vivo em 2026-08-17 ([pgvector README](https://github.com/pgvector/pgvector)):

> "With approximate indexes, filtering is applied _after_ the index is scanned."
>
> "If a condition matches 10% of rows, with HNSW and the default `hnsw.ef_search` of 40, only 4 rows will match on average."

A falha é **silenciosa**: sem erro, sem aviso — só um resultado curto que se parece com "o corpus não tinha mais nada".

**E aqui está a razão de isto virar um ADR em vez de uma nota de rodapé.** O método de avaliação que o próprio agente prescreve é exatamente o que **esconde** o defeito. Um golden set montado sem o filtro de produção passa com recall cheio; a query real — que filtra por `tenant_id`, ACL, tipo de doc ou data, ou seja, praticamente toda query de RAG em produção — devolve uma fração de k. O agente construiria, com as próprias instruções, a avaliação que não pega o bug que ele deveria pegar.

Grounding L1.5 (ADR-005), mecânico: `grep -rli` por `iterative_scan`, `iterative scan`, `ef_search` e `overfilter` em `.claude/`, `docs/conventions/`, `research-vault/capabilities/` e `eval/tasks/` devolve **zero arquivos** para todos os quatro termos. O conceito está ausente do repo inteiro.

## Decisão

Adicionar ao par `database-specialist` o conhecimento da interação **filtro × índice aproximado**, em três partes indivisíveis:

1. **A propriedade geral** — com índice aproximado o filtro é pós-varredura, então um top-k filtrado pode retornar silenciosamente menos que k.
2. **As saídas** — `hnsw.iterative_scan` / `ivfflat.iterative_scan` (limitadas por `max_scan_tuples`), ou over-fetch elevando `ef_search` bem acima de k, ou índice parcial por valor de filtro quando a cardinalidade é baixa.
3. **A correção do método de avaliação** — medir `recall@k` **com o filtro de produção aplicado**, nunca em golden set sem filtro.

A parte (3) é a que carrega o valor. (1) e (2) sem (3) deixam de pé a instrução que produz a avaliação cega.

O texto afirma a **propriedade** como geral e o **knob** como instância nomeada do pgvector — não o contrário. Inverter isso criaria um falso universal, já que outros motores (Qdrant, Milvus, Weaviate) anunciam pré-filtragem verdadeira e **não** foram verificados neste ciclo.

## Alternativas consideradas

- **Alternativa A (escolhida): bloco de conhecimento no par `database-specialist` + uma red flag.** Prós: cai numa seção que já existe (retrieval do RAG), é uma edição lógica, revert = apagar o bloco, e chega ao agente no momento em que ele desenha retrieval. Contras: duas cópias para manter em sincronia (mitigado — ADR-041 tornou isso mecânico via `sync-persona-pair.sh`); e a-owl passa a carregar um knob específico de motor, que exige o cuidado de fraseado descrito acima.

- **Alternativa B: uma `capabilities/` page nova sobre índices vetoriais.** Prós: espaço para nuance por-motor e para a comparação pré-filtro × pós-filtro que este ciclo não fez. Contras: **rejeitada porque erra o momento da entrega.** O agente não lê `capabilities/` ao responder; ele lê o próprio prompt. Uma página que descreve corretamente uma armadilha, num lugar que o consumidor não abre na hora certa, é a classe de defeito que o ADR-035 nomeou (afirmação verdadeira numa superfície que ninguém lê no momento certo) e que a entrada de 2026-08-15 chamou de **síntese órfã**. Repetir isso conscientemente seria pior que não escrever.

- **Alternativa C: corrigir só a linha de avaliação ("meça recall@k com filtro") sem explicar o mecanismo.** Prós: a edição mínima absoluta. Contras: rejeitada — uma regra sem o porquê não generaliza. O agente saberia executar o teste e não saberia diagnosticar o resultado, nem escolher entre `iterative_scan`, over-fetch e índice parcial.

## Consequências

**Fica mais fácil:** o agente passa a desenhar retrieval filtrado que de fato retorna k, e a montar avaliação que exercita o caminho de produção. Colateral com peso de segurança: RAG multi-tenant cujo filtro é de ACL é precisamente onde "sob-retornar em silêncio" vira resposta incompleta que ninguém percebe.

**Fica mais difícil:** o par ganha ~6 linhas. `builder`/`architect`/`system-designer` já estão acima do teto de instrução sinalizado pelo ADR-017; `database-specialist` (149 linhas) não está, mas cada adição consome a mesma folga.

**Riscos aceitos:**
- **Especificidade de motor.** O fraseado separa propriedade de knob, mas se um motor dominante passar a pré-filtrar de verdade, a propriedade geral encolhe. Mitigação: é conhecimento de capacidade e herda a regra de staleness de 30 dias do `verified_on` da matriz.
- **Impacto NÃO medido.** É afirmação comportamental. Por ADR-015 o aceite é **provisório-pendente-de-fitness**, e o crédito cheio de Impacto só vem depois que um fixture confirmar o Δ na dimensão-alvo.
- **Ausência de fixture, verificada e não presumida.** `eval/tasks/13-database-specialist-schema-capability.md` está na **mesma célula da matriz** (`sensitive_to: matrix-cell database-specialist x data-engineering`), o que torna tentador contá-lo como cobertura. Ele foi **lido**: o cenário é paginação por OFFSET profundo, e a dimensão *Domain accuracy & currency (30)* pontua keyset pagination, índice parcial e `CREATE INDEX CONCURRENTLY`. Nada ali toca busca vetorial ou filtro sobre índice aproximado — esta edição não moveria aquele número em ponto nenhum. **Follow-up nomeado:** fixture `16-database-specialist-rag-filter-capability`, com um RAG multi-tenant filtrado por `tenant_id`, onde o agente-base morde o anzol se recomendar HNSW + `WHERE` e um golden set sem filtro.

## Notas de implementação

**Arquivos (ADR-028 — o par, as DUAS cópias recebem a edição; sem exceção ADR-034, isto é prosa e não campo imposto pela harness):**

1. `.claude/agents/database-specialist.md` — **canônico**, editar aqui.
2. `.claude/commands/agents/database-specialist.md` — **derivado**, gerado.

**Ordem obrigatória (ADR-041):**
1. `./scripts/sync-persona-pair.sh --check` **antes** — confirmar 13/13 na árvore.
2. Editar **só** o canônico: adicionar o bullet do filtro na seção "RAG (lado de recuperação)" após o bullet de *Hybrid search*, e uma linha na lista "⚠️ Red Flags que eu recuso".
3. `./scripts/sync-persona-pair.sh --sync database-specialist`.
4. `./scripts/sync-persona-pair.sh --check` de novo — 13/13.

**O que NÃO fazer:**
- Não editar a cópia derivada à mão — o `--check` do próximo ciclo acusa a divergência.
- Não afirmar que iterative scan é universal em bancos vetoriais; é a grafia do pgvector.
- Não tocar em `guardian`/`sentinel`/`challenger`, `.owl/loop-config.yml`, `.claude/settings.json` nem no schedule — carve-out NFR-SEC-1, **zero contato** nesta mudança.
- Não reescrever a seção de avaliação existente; **estender** a linha de recall@k, preservando o golden set que já está lá.

## Related
- Ideia: `research-vault/ideas/filtered-vector-search-overfiltering.md` (score 80, `classe: capability`)
- Fonte: `research-vault/sources/pgvector-readme.md`
- ADR-028 (regra do par) · ADR-041 (par é artefato gerado) · ADR-013 (verificação de claim) · ADR-015 (aceite provisório) · ADR-040 (capability × governance) · ADR-035 (afirmação verdadeira na superfície errada — a razão da Alternativa B ser rejeitada)
