# Segundo Cérebro (Atlas) — graphify + Obsidian

> Processo interno para transformar qualquer pasta de código/docs num **grafo de
> conhecimento consultável** (graphify) + um **vault Obsidian** que o agente sabe
> operar (obsidian-skills). Montado e validado em 2026-07-28 no `the-owl`.

## 0. O conceito em uma linha

**graphify desenha o mapa · obsidian-skills dão as mãos ao agente.** Rodam
**100% local** (AST determinístico + o seu próprio Claude; sem servidor, sem
vector store, sem key). Fonte: `github.com/Graphify-Labs/graphify` (Apache-2.0),
`github.com/kepano/obsidian-skills` (MIT, do CEO do Obsidian).

### Docs vs. graphify — complementares, não concorrentes

graphify **não guarda nem substitui** documento. Ele **indexa** os markdown que
você escreve e constrói o grafo por cima. A doc `.md` é o **substrato** (fonte da
verdade, versionada no git, legível por humano); o grafo é a **lente** que acha as
conexões entre docs espalhados. Você escreve a doc **uma vez**; o loop de
auto-update a transforma em nó do cérebro. Não escolha um — o arquivo é os dois.

### UM VAULT SÓ — research-vault é a casa (decisão 2026-07-28)

O vault humano é o **`research-vault`** (curado, com `SCHEMA.md`/index/ledger). **Não criamos um
segundo vault** e **não despejamos stubs auto-gerados** nele. Papéis, sem redundância:
- **research-vault** = a casa (você/agente **escrevem**, curado). Intocado pelo graphify.
- **graphify** = **motor de query** (o agente consulta via `graphify-mcp`/`graphify query`; mapa
  visual via `graph.html`). Query do agente **não precisa de stubs no vault** — o vault é só HUMANO.
- Write-back = **síntese autorada** no research-vault (respeitando o SCHEMA), não cópia da fonte.
- Export de vault do graphify: **só** se quiser o mapa no Obsidian, e aí numa **subpasta dedicada**
  (`--obsidian-dir <research-vault>/maps/<proj>`), nunca o root. Por padrão: **query-mode, sem vault.**

## 1. Instalação — one-time, global (já feito nesta máquina)

```bash
# 1. o motor (Mac: pipx, porque o Python é externally-managed)
pipx install graphifyy          # dois Ys — o nome 'graphify' está tomado no PyPI; o CLI é 'graphify'
graphify install                # registra a skill /graphify no ~/.claude/skills/

# 2. as mãos (dentro do Claude Code — são comandos do harness, não shell)
/plugin marketplace add kepano/obsidian-skills
/plugin install obsidian@obsidian-skills
/reload-plugins
```

Instala: CLI `graphify` + `graphify-mcp` (`~/.local/bin`), a skill `/graphify`, e
5 skills Obsidian (`obsidian:obsidian-markdown / obsidian-bases / json-canvas /
obsidian-cli / defuddle`). **Obsidian CLI vem DESABILITADO** — ligar em
`Settings > General > Advanced > command line interface` (precisa Obsidian ≥1.12).

## 2. Padrão para projetos NOVOS (o default)

Rodar uma vez, na raiz do projeto (o `scripts/atlas-bootstrap.sh init` faz isso):

```bash
graphify claude install     # grava seção ## graphify + PreToolUse hook no CLAUDE.md LOCAL
                            #   → always-on: Claude checa o grafo antes de responder sobre o repo
                            #     e reconstrói após mudança de código, sem /graphify manual
graphify hook install       # git post-commit/post-checkout → auto-rebuild do mapa a cada commit
/graphify . --obsidian      # 1º build: grafo + vault Obsidian (graphify-out/obsidian/)
graphify global add graphify-out/graph.json --as <projeto>   # agrega ao cérebro cross-projeto
echo 'graphify-out/' >> .gitignore    # output gerado (a menos que você queira versionar o vault)
```

Depois disso o projeto é "always-on": o mapa se mantém sozinho e responde queries.

## 3. Uso diário

```bash
/graphify .                          # (re)mapeia a pasta atual  → HTML; + --obsidian p/ vault
/graphify ./sub --mode deep          # extração mais rica (mais edges INFERRED)
graphify query "como funciona o auth?"   # PERGUNTA ao grafo — não re-lê os arquivos
graphify path "AuthModule" "Database"    # caminho mais curto entre dois nós
graphify explain "RLS lockdown"          # explica um nó e sua vizinhança
/graphify add <url>                      # puxa uma página web pro grafo (defuddle limpa pra markdown)
graphify export obsidian                 # vault + graph.canvas (whiteboard JSON Canvas)
graphify global list                     # projetos no cérebro global (~/.graphify/global-graph.json)
```

**Tags de honestidade em todo edge:** `EXTRACTED` (está no arquivo) · `INFERRED`
(o modelo conectou) · `AMBIGUOUS` (baixa confiança — revisar primeiro).

## 4. Auto-atualização — como funciona AGORA (o loop)

O ponto-chave: **um git hook roda em shell puro, FORA do Claude Code** → só faz o
que não precisa de LLM. Por isso o auto-update é assimétrico:

| mudança | mecanismo | custo | automático? |
|---|---|---|---|
| **Código** (`.py/.ts/.go`…) | `graphify hook install` → post-commit re-extrai via **AST** os arquivos do `git diff` | **grátis** (sem LLM) | ✅ a cada commit |
| **Código, ao vivo** | `graphify watch .` → rebuild on-change (AST) | grátis | ✅ enquanto trabalha |
| **Docs/imagens** (`.md/.pdf`…) | **o hook IGNORA** (extração semântica precisa de LLM) → rodar `/graphify --update` **dentro do Claude Code** | tokens (só os arquivos mudados, cache SHA256) | ❌ manual |
| pendência de doc | `graphify check-update <path>` (cron-safe) avisa que há re-extração semântica pendente | — | notificação |
| **write-back** | o agente escreve notas c/ wikilinks no vault (obsidian-skills) → o próximo map pass indexa | tokens | fecha o loop |

**Regra operacional:** código se mantém sozinho (hook, grátis). Docs você atualiza
com `/graphify --update` quando quiser (barato — só o que mudou). Um `check-update`
no cron pode lembrar quando há doc pendente.

## 5. Grafo global — o cérebro cross-projeto

`graphify global add <graph.json> --as <tag>` funde o grafo de um projeto em
`~/.graphify/global-graph.json`. Com todos os projetos agregados, dá pra perguntar
coisas que cruzam repos ("onde mais usamos RLS?", "que projetos têm um AuthModule?").
`global list/remove/path` gerenciam. **Esse é o second brain de verdade** — não um
grafo por repo isolado, mas um mapa único de tudo que a gente construiu.

## 6. Economia de token (por que vale)

- **Código = AST, grátis.** `/graphify .` num repo de código não manda conteúdo pro
  LLM — só estrutura (funções, imports, edges). Zero token, zero exposição de valor.
- **Docs = semântico, cacheado.** Só o 1º pass e os arquivos MUDADOS custam (cache
  SHA256). Re-runs pagam só o delta.
- **Query = 71,5x mais barato** (benchmark do próprio graphify, corpus de 52 arquivos):
  perguntar ao grafo vs. re-ler todo arquivo. É o mesmo princípio `piso × turnos` que
  otimizamos nos agentes — pagar 1x pra construir, economizar pra sempre nas consultas.

## 7. Segurança (security-first)

- **Local-only** — nada sai da máquina. Não lê `ANTHROPIC/OPENAI_API_KEY`.
- **Pula sensíveis** — o `detect` reporta `skipped_sensitive` (arquivos flagados como
  segredo). Conferir a lista; renomear/mover um falso-positivo.
- **Docs passam pelo LLM** (host agent) → um `.md` com credencial colada seria lido.
  **Mantenha segredo fora de doc.** Código é AST (só estrutura, não vaza valor).
- **Vault é local** — mesmo o que entra no grafo não é exfiltrado; mas é texto em claro
  no `graphify-out/`. Gitignore por padrão; versionar só se o repo for privado e limpo.
- Escolher a pasta com cuidado: mapear o workspace inteiro = muitos docs + muitos
  segredos espalhados. Começar por um projeto.

## 8. Empacotamento

`scripts/atlas-bootstrap.sh` empacota o processo:
- `atlas-bootstrap.sh doctor` — checa pipx/graphify/plugins e reporta o que falta.
- `atlas-bootstrap.sh install` — instala o motor global (pipx + graphify install) e
  imprime os `/plugin` (comandos do harness, não roda por shell).
- `atlas-bootstrap.sh init [pasta]` — aplica o **padrão por projeto** (§2) num repo.

Nível seguinte (opcional): virar uma skill própria `/second-brain` que orquestra o
`init` por projeto dentro do Claude Code.

## 9. O que já rodamos (validação)

`the-owl/.claude/commands/agents/` (13 agentes) → **54 nós, 92 edges, 8 comunidades**
→ vault de **63 notas + graph.canvas + graph.html**. Honestidade: **96% EXTRACTED,
0% AMBIGUOUS** (mapa sólido). God nodes = Architect (grau 15), Chronicler (12),
Guardian (12), Builder (11), Sentinel (11) — confirmando a topologia hub-and-spoke
ancorada no Architect. Query no grafo respondeu "por que o Architect é o hub" da
estrutura, sem re-ler os arquivos.
