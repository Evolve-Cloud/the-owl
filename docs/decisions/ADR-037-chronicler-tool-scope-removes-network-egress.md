# ADR-037 — Escopo de ferramentas do `chronicler`: tirar a saída de rede de um agente que documenta código

**Status:** Accepted
**Date:** 2026-08-12
**Author:** @architect (ciclo 9 do `/owl:evolve`)
**Tags:** [security, least-privilege, subagents, adr-034]

## Contexto

`least-privilege-tool-scopes` foi **deferido** em 2026-07-23 com um bloqueio explícito: *"unenforceable prose in the-owl's inline-exec model"* — não havia como **impor** escopo por agente, então a convenção seria prosa que finge impor. O bloqueio caiu com o PR #17 (subagents nativos), a condição de reabertura foi escrita pelo ciclo 7, cumprida, e a reabertura autorizada em 2026-08-07. Pontuado neste ciclo: **80**.

Estado verificado contra a árvore (2026-08-12): `tools:` presente em **5 de 13** subagents — `challenger`, `curator`, `guardian`, `scout`, `sentinel`. Destes, 3 são carve-out (escopados por mão humana na migração). **8 não-carve-out seguem sem `tools:`**, herdando portanto **todas** as ferramentas disponíveis a subagents. Doc primária, verbatim:

> "`tools` | No | Tools the subagent can use. **Inherits every tool available to subagents if omitted.**"

## Decisão

**Um agente por ciclo**, na forma dos rollouts ADR-006/007/008. Este ciclo: **`chronicler`**.

```yaml
tools: Read, Write, Edit, Grep, Glob, Bash, Skill, Agent
```

### Por que a fatia é um agente, e não os oito

**Não existe lista de ferramentas declarada em lugar nenhum** — verificado: os `.devflow/agents/*.meta.yaml` não declaram `tools`. Logo cada lista tem que ser **julgada**, e o modo de falha de uma lista curta demais é **silencioso** (o agente degrada, não erra). Julgar oito de uma vez são oito decisões num commit, contra a atomicidade do ADR-010, e nenhuma delas verificável por leitura no mesmo esforço.

### Por que `chronicler` primeiro

É o agente onde a restrição tem **rationale de segurança explícito e derivável do próprio arquivo**, não preferência estética:

1. **A carta dele é local por definição.** `chronicler.md:214` — *"o wiki/CHANGELOG/memória/grafo é gerado **DO código**"*. Não há um único fluxo dele que precise da rede.
2. **Ele lê o repo inteiro, incluindo config.** É o agente com maior exposição a material adjacente a segredo — tanto que carrega uma disciplina inteira sobre isso (*"NUNCA embuta valores de env, tokens ou credenciais […] não reproduza o valor nem para recusá-lo"*), escrita porque **foi medido**: *"1 em 3 runs faziam isso"* (`eval/results/2026-07-25-fleet-guardrail-beforeafter.md`).
3. **(1) + (2) = caminho de exfiltração.** Um agente que lê tudo **e** tem egresso de rede é o par clássico. Tirar o egresso quebra o par, e é imposto pela harness — não é mais um parágrafo pedindo cuidado.

### A lista, derivada exaustivamente do arquivo (não inventada)

| ferramenta | por que é necessária — evidência no `chronicler.md` |
|---|---|
| `Read` | lê diffs, arquivos, `wiki-state.json`, `knowledge-graph.json`, o reference |
| `Write` | CHANGELOG, ADRs, snapshots, páginas de wiki, `_plan.md` (l.211) |
| `Edit` | edições cirúrgicas idempotentes — *"edite APENAS dentro dessa seção"* (l.230) |
| `Grep` | acha docs desatualizados; detecção de drift do `/sync-check` (l.139) |
| `Glob` | *"listar `docs/planning/`"* (l.62); `docs/decisions/*.md`, `.claude/commands/agents/*.md` (l.240) |
| `Bash` | `git diff`, `git log`, `git diff <ref>..HEAD` — núcleo de `/document`, `/sync-check` e do loop idempotente do wiki (l.136, 210, 228) |
| `Skill` | **l.105: "USE A SKILL TOOL: `skill="agents:builder"`…"** — omitir quebraria o mesmo mecanismo que reprovou o ADR-036 |
| `Agent` | **l.69/80: "ADR-023: usa Agent tool (subagents)"**, *"`Agent tool` em paralelo"* |

**O que sai:** `WebFetch`, `WebSearch`, `NotebookEdit` e **toda ferramenta MCP**. Nenhuma delas aparece no arquivo; a primeira e a segunda são exatamente o egresso que a carta dele não pede.

## Alternativas consideradas

- **Alternativa A (escolhida): allowlist `tools:` num agente, derivada do arquivo dele.** Prós: least-privilege de verdade (durável, imposto); rationale de segurança concreto; lista auditável linha a linha contra a fonte. Contras: se eu omiti algo que o arquivo não menciona mas o agente usa, a degradação é **silenciosa**. Mitigação: a derivação está na tabela acima, então o revisor confere contra o arquivo em vez de confiar em mim.
- **Alternativa B: `disallowedTools: WebFetch, WebSearch` (denylist).** Prós: **elimina** o risco de degradação silenciosa — o agente mantém o pool menos dois. Contras: **rejeitada, e é a alternativa mais forte.** Não é least-privilege — deixa entrar toda ferramenta MCP futura por default, que é precisamente a superfície que cresce sem ninguém decidir. Trocaria a decisão pontuada (allowlist durável) por outra mais fraca, silenciosamente.
- **Alternativa C: os 8 de uma vez.** Prós: acaba o rollout num ciclo. Contras: rejeitada — 8 julgamentos num commit, contra ADR-010, e o ciclo 9 já teve **um** gate FAIL por generalizar de um caso verificado.

## Consequências

**Fica mais fácil:** um agente que lê o repo inteiro perde o egresso de rede. Aplicável, não pedido. E fica um exemplar concreto do formato para os 7 restantes.

**Fica mais difícil / trade-off aceito:** se o `chronicler` algum dia precisar buscar algo externo (ex.: validar um link do CHANGELOG), passa a falhar até alguém editar a linha. É a intenção — mas é uma porta que fecha, e um falso-negativo aqui custa uma edição.

**Risco novo, dito sem maquiagem:** a derivação vem do que o arquivo **menciona**. Um comportamento real e não documentado no próprio arquivo não estaria na tabela — e a falha seria silenciosa. **Não consigo refutar isso nesta sessão** (exigiria instanciar o agente). Registrado como limite conhecido, não como resolvido.

**Sem haircut do ADR-015:** isto **não** é afirmação comportamental. `tools:` restringe de forma demonstrável pela doc — não é hipótese sobre o que o agente vai produzir. Crédito de Impacto é cheio, e é modesto (14/20) por escolha, porque uma fatia é 1/8 do rollout.

## Notas de implementação

**`arquivo_alvo` (ADR-028 + ADR-034):**

- ✅ **RECEBE a edição:** `.claude/agents/chronicler.md` — adicionar a linha `tools:` ao frontmatter existente (que já tem `name` + `description`).
- ⛔ **EXCLUÍDA COM RAZÃO VERIFICADA:** `.claude/commands/agents/chronicler.md` — a metade `commands/` **não tem campo `tools`**. O que ela tem é `allowed-tools`, e a doc primária é explícita: *"It does not restrict which tools are available: **every tool remains callable**"* — é grant de **um turno** que **alarga**, oposto semântico de uma allowlist durável. ⚠️ Ressalva registrada, não escondida: existe `disallowed-tools` na metade comando e ela **é** restritiva, mas *"the restriction clears when you send your next message"*. A afirmação verificada é **"sem allowlist durável"**, não "sem equivalente nenhum".

**NÃO fazer:** não tocar os outros 7 agentes neste ciclo; não tocar `challenger`/`guardian`/`sentinel` (carve-out); não usar denylist no lugar da allowlist.

**Verificação:** (a) o frontmatter parseia e mantém `name` + `description`; (b) toda ferramenta da lista aparece na tabela de derivação com a linha do `chronicler.md` que a justifica; (c) `Skill` e `Agent` estão presentes — foram a causa do FAIL do ADR-036 e são fáceis de esquecer; (d) `git diff` toca **um** arquivo.

> ✅ **Executada.** (a) YAML parseia, `name`/`description`/`tools` presentes — inclusive com os comentários `#`, que foram validados por parser, não presumidos. (b) tabela conferida linha a linha. (c) `Skill` e `Agent` presentes. (d) um arquivo.

---

## ⚖️ Gate L4 — @challenger: PASS, com **uma correção ao texto deste ADR**

**Objeção levantada:** *"O ADR cita a medição de 1-em-3 vazamentos como evidência. Mas aquele vazamento foi para dentro de **documentos**, não pela rede. Tirar `WebFetch` não conserta a falha que foi medida — o ADR está pegando carona numa medição que não é sobre isto."*

**Objeção ACEITA. É verdade e o texto acima é ambíguo o suficiente para induzir a leitura errada.** Registrado explicitamente:

- A medição de `eval/results/2026-07-25-fleet-guardrail-beforeafter.md` estabelece **(2)** — que o `chronicler` manuseia material adjacente a segredo e erra nisso de forma mensurável. **Ela não estabelece que houve, ou haveria, exfiltração por rede.**
- O argumento para tirar o egresso é **estrutural, não medido**: ler-tudo + falar-para-fora é um par que vale a pena quebrar por defesa em profundidade. Isso é uma **hipótese de redução de risco**, e permanece não medida.
- **O que este ADR NÃO faz:** não conserta o vazamento de 1-em-3. Aquele é para dentro do artefato e continua endereçado só pela disciplina em prosa do próprio agente.

**Segunda objeção, mais afiada:** *"Você acabou de reprovar o ADR-036 por afirmar um negativo não verificado ('nenhum outro consumidor'). O ADR-037 afirma um negativo do mesmo formato — 'nenhuma outra ferramenta é necessária'. Não é o mesmo erro?"*

**Não é o mesmo, e a diferença é o que importa:** o ADR-036 afirmou o negativo **sem rodar** a checagem que o refutaria (um `grep`). O ADR-037 rodou a enumeração **e publicou a tabela**, ferramenta por ferramenta, com a linha-fonte de cada uma — então o revisor confere contra o arquivo em vez de confiar no autor. **Mas o resíduo é real e não some:** a derivação cobre o que o arquivo **menciona**; comportamento real e não documentado ficaria de fora, e a falha seria silenciosa. Já está registrado em *Consequências* como limite conhecido, e continua sendo o motivo de a fatia ser **um** agente e não oito.

**Veredito: PASS** — o valor não depende da medição mal-atribuída, e a correção acima remove o overclaim.
