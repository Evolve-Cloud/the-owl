# ADR-034 — Assimetria estrutural: a regra do par se cumpre na forma que cada superfície impõe

**Status:** Accepted · **Ratificado:** 2026-08-07 (dono)
**Date:** 2026-08-07
**Author:** main loop (human-directed; do conflito que travou dois candidatos reabertos)
**Tags:** [grounding, hybrid-agents, guardrails, curator, enforcement]
**Related:** ADR-028 (**este o estende, não o retrofita**), ADR-005 (grounding L1.5), ADR-010 (modelo inline), ADR-033 (forma B — o mecanismo que produziu os dois candidatos), ADR-013 (verificação de claim — de onde vem a obrigação de verificar)

> ⚖️ **Extensão, não correção.** O ADR-028 não está errado; ele é **silencioso** sobre um caso que não existia quando foi escrito — ninguém tinha proposto um campo de frontmatter. Pela disciplina que o próprio ADR-028 escreve (*"decision records are append-only; supersession is declared, never retrofitted"*), a forma certa é um ADR novo. O texto do ADR-028 fica intacto.

## Contexto

O ADR-028 estabeleceu que, quando o alvo é uma persona, `arquivo_alvo` nomeia **o par** — `.claude/agents/<x>.md` **e** `.claude/commands/agents/<x>.md` — e que a mesma edição lógica vai nas duas; tocar só uma é **fase FALHOU**.

Ele foi escrito por um motivo concreto e bom: ao landar o ADR-027, a edição foi só na cópia-comando, e o subagent nativo teria rodado o loop **sem o passo que o próprio ADR acabara de mandatar**. O risco que a regra impede é real.

**Mas esse risco é sobre prosa.** As duas cópias podem carregar texto; se uma não carrega, é esquecimento. A regra foi escrita para esse caso e acerta nele.

### O caso que ela não previu — e que agora trava dois candidatos

A reabertura de `least-privilege-tool-scopes` e `agent-frontmatter-fields` (ambas via ADR-033 forma B) propõe **campos de frontmatter impostos pela harness** — `tools:` e `maxTurns`. Estado verificado da árvore:

| | estado |
|---|---|
| `.claude/agents/*.md` (subagent nativo) | frontmatter YAML em **13/13**; `tools:` imposto pela harness em 5 |
| `.claude/commands/agents/*.md` (persona-comando) | frontmatter YAML em **0/13** |

Aplicada literalmente, a regra do par torna **os dois candidatos impontuáveis**: a edição precisaria tocar as duas metades, e uma metade não recebe o campo. O @curator do ciclo 9 bate nisso duas vezes e **não tem autoridade para emendar o ADR-028**.

### O teste óbvio é o errado

O primeiro enquadramento — *"a outra metade não consegue carregar"* — **não se sustenta**. Slash-commands **podem** ter frontmatter: `.claude/commands/owl/research.md` tem (`trigger`/`category`/`priority`). As personas-comando simplesmente **não têm**. Um teste baseado em ausência viraria desculpa: *"não colocamos lá"* passaria a satisfazer a regra.

O teste tem que ser **imposição**, não presença. E isso torna operante uma pergunta que estava parada: o ciclo 7 registrou, *"for whoever re-opens that id"*, se **`allowed-tools` numa skill/comando é imposto como `tools:` num subagent** — e a deixou **não resolvida**. Sob este ADR ela deixa de ser curiosidade e vira **pré-requisito**.

## Decisão

**Cláusula de assimetria estrutural.** Quando a mudança é um **campo imposto pela harness**, a regra do par do ADR-028 continua valendo — mas ela se cumpre editando **cada metade na forma que aquela superfície impõe**.

Se uma superfície **não impõe equivalente** — **verificado contra a doc primária, não presumido** — editar só a superfície que impõe **satisfaz** a regra, desde que:

1. `arquivo_alvo` **liste as duas metades** (nunca omita a excluída);
2. marque **explicitamente qual não recebe a edição e por quê**;
3. o ADR da mudança **registre a assimetria** e a verificação que a sustenta.

**Fora desse caso o ADR-028 vale inteiro: prosa exige as duas cópias, sem exceção.**

> ⛔ **"Não impõe equivalente" é achado VERIFICADO, nunca *"ainda não colocamos lá"*.** A verificação é um fetch alvo na doc primária, na forma do ADR-013 — mesma disciplina de qualquer claim que a-owl usa para decidir. Sem essa verificação registrada, a assimetria **não pode ser alegada** e a regra do ADR-028 se aplica inteira.

## Alternativas consideradas

- **A (escolhida): cláusula estreita, com gatilho de imposição verificada.** Prós: destrava os dois candidatos sem tocar o caso para o qual o ADR-028 foi escrito; o teste é **verificável** (a doc primária impõe ou não), não julgamento; e transforma uma pergunta parada há 4 dias em pré-requisito de caminho crítico. Contras: afrouxa um guardrail — ver *Novos riscos*.
- **B: dar frontmatter às personas-comando e manter o par simétrico.** Prós: preservaria o ADR-028 intacto. Contras: assume exatamente a resposta que ninguém verificou (se `allowed-tools` num comando é imposto). Se **não** for, isto escreve prosa que finge impor — a classe *Unenforceable prose*, o defeito original que deferiu o `least-privilege` em 2026-07-23. **Não rejeitada para sempre:** se a verificação mostrar que É imposto, B é estritamente melhor que A e a assimetria nem existe. **A verificação decide qual das duas vale** — e é por isso que ela é pré-requisito, não detalhe.
- **C: teste por ausência** (*"a outra metade não tem o campo"*). Rejeitada — ver Contexto: `.claude/commands/` **pode** ter frontmatter, então ausência é estado, não impossibilidade, e o teste viraria desculpa.
- **D: não fazer nada; deixar os dois candidatos travarem.** Prós: honesto, custo zero, e o mecanismo do ADR-033 ainda teria disparado corretamente. Contras: o ciclo 9 produziria dois candidatos que não pontuam por conflito de regra que nem o curator nem o loop podem resolver — o mecanismo ratificado horas antes entregaria dois becos sem saída na primeira execução. Rejeitada, mas era opção real: **nada quebraria**, perderia-se uma semana nos dois.
- **E: revogar o ADR-028.** Rejeitada sem discussão longa — o defeito que ele impede é real, aconteceu, e foi pego por acaso.

## Consequências

- **Mais fácil:** um campo imposto pela harness pode landar na superfície que o impõe, sem que o gate L3 reprove por uma simetria que a plataforma não oferece.
- **Trade-offs aceitos:** mais uma condição no contrato de grounding. Estreita de propósito — só campo imposto, só com verificação registrada.
- **⚠️ Novos riscos — dito sem maquiagem: este ADR autoriza uma edição de persona em UMA metade só, e o ADR-028 foi escrito exatamente porque uma edição de uma metade só quase entrou em produção.** É afrouxamento de guardrail, não refinamento neutro. **Mitigação:** a assimetria tem que ser **verificada e registrada em `arquivo_alvo`**, não afirmada — e a metade excluída é **listada**, nunca omitida, então o revisor vê a lacuna em vez de não ver nada. A regra continua falhando alto no caso de prosa, que é onde o defeito original aconteceu.
- **Interação com o bloco de classes do ADR-030 — a classe NÃO afrouxou.** *Unenforceable prose* segue valendo inteira: prosa apresentada como se fosse imposta continua sendo o modo de falha. Este ADR trata de um campo que **é** imposto numa superfície e não na outra — nem "enforceable" limpo, nem "unenforceable prose". Um leitor futuro não deve ler o ADR-034 como licença para escrever convenção que a harness ignora.
- **Não toca o carve-out:** edita `.claude/commands/agents/curator.md` + `.claude/agents/curator.md` (o par — e aplicar este ADR às duas cópias é a própria regra que ele estende) e `.claude/commands/owl/evolve.md`. `sentinel`/`guardian`/`challenger`, `.owl/loop-config.yml`, agenda, `settings.json` e os git hooks intocados.

## Notas de implementação

- **Edições (uma mudança lógica, três arquivos):** (1) `curator.md` ×2 — a definição de `arquivo_alvo` no passo 0; (2) `evolve.md` L3 — a instrução de edição (~linha 45) **e a verificação (~linha 47)**. A verificação é onde a cláusula precisa morder: se o L3 continuar exigindo "as duas cópias ou FALHOU" de forma incondicional, o gate reprova exatamente as edições que este ADR autoriza.
- **A verificação passa a chavear no que `arquivo_alvo` DECLARA** — incluindo uma cópia marcada como excluída-com-razão — e não numa contagem fixa de duas.
- **Os dois candidatos reabertos foram atualizados no mesmo commit.** Ambos nomeavam o conflito ADR-028 como questão bloqueante; a questão mudou de forma (de "bloqueado" para "resolvido pelo ADR-034, **condicional** à verificação de `allowed-tools`). Deixá-los stale faria o curator do ciclo 9 ler um bloqueio que não existe mais — exatamente o defeito que ocupou este dia inteiro.
- **NÃO fazer:** não editar o ADR-028 (append-only; este o estende). Não alegar assimetria sem a verificação do ADR-013 registrada.
- **Ledger:** mudança **human-directed** (ADR-027) — linha `hd-adr028-structural-asymmetry-clause`.
- **Falsificável:** se a verificação mostrar que `allowed-tools` **é** imposto numa persona-comando, a assimetria que motivou este ADR **não existe** para `tools:`, a alternativa B passa a valer, e esta cláusula fica sem instância viva — devendo então ser relida sob o passo 4.6 (ADR-033) como qualquer outra afirmação estrutural.
