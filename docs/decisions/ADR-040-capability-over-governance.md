# ADR-040 — Capability over governance: eixos de domínio, matriz de capacidade e classificação de aceite

**Status:** Accepted
**Date:** 2026-08-13
**Author:** dono (owner-directed, sessão de análise crítica externa — Claude + review codex de segunda opinião)
**Tags:** [capability, research-axes, curator, scout, matrix]

## Contexto
O propósito declarado da-owl é um time de agentes **cada vez mais capacitado e atualizado com base em referências** — inclusive estrutura, descriptions e tools. O que a série de aceites mostra é outra função sendo otimizada: entre ADR-016 e ADR-039, 8+ aceites foram **governança do próprio loop** (checkpoint, staleness, proveniência, liveness), contra ~2 convenções com efeito nos agentes — e destas, `role-ownership` mediu Δ≈0 (reetiquetada documentation-only, ADR-015) e só `handoff-contract` provou Δ (+11.0). Em paralelo, os ciclos 6–8 tiveram **0 aceites com 100% de alias**: o eixo de pesquisa "engenharia de times de agentes" **saturou** — o retrieve-delta (ADR-022) funcionou, mas a pergunta esgotou. O loop está saudável; a direção não.

## Decisão
Três mudanças acopladas, owner-directed:
1. **Eixos de CAPACIDADE viram o default do `{{QUERY_AXIS}}`.** Nova família de eixos de domínio (`platform-engineering` · `data-engineering` · `mcp-and-claude-harness` · `secure-sdlc`), com lista canônica em `research-vault/capabilities/agent-capability-matrix.md`. Os 8 eixos estruturais saem do round-robin default e só entram por recomendação da reflexão (ADR-024) ou direção do dono.
2. **Matriz de capacidade dos agentes** (`agent-capability-matrix.md`): `agente × capacidade × fontes × arquivo-alvo × eval × Δ medido`. É o denominador de "o time está mais capacitado?" e o alvo obrigatório de todo aceite de capacidade.
3. **Todo aceite do curator leva `classe: capability | governance`** (passo 2.7). Capability nomeia a célula da matriz + eval fixture (sem fixture ⇒ `eval: ausente`, aceite provisório ADR-015 + follow-up). Governance leva **haircut adicional −5** e justificativa escrita "por que isto não é capability".

## Alternativas consideradas
- **A (escolhida): duas famílias de eixos, capacidade como default + classificação com haircut assimétrico.** Prós: reusa TODO o maquinário existente (retrieve-delta, rubrica, veto, gate, fitness); reversível (os eixos estruturais seguem listados no 8a); o viés −5 é pequeno o bastante para governança genuinamente boa ainda passar. Contras: o haircut é um número escolhido, não medido (mesma classe do threshold 75 — calibrável pelo dono); eixos de domínio dependem de fixtures de eval que ainda não existem (mitigado: `eval: ausente` ⇒ provisório).
- **B: intercalar as famílias no round-robin (mod 12).** Prós: mudança mínima. Contras: mantém 8/12 do budget de pesquisa num eixo com 0 aceites em 3 ciclos consecutivos — não corrige a direção, dilui.
- **C: quota dura ("todo ciclo DEVE aceitar ≥1 capability").** Prós: força o resultado. Contras: viola o princípio mais bem-provado da-owl — "cap é teto, não meta; nunca fabricar aceite" (ciclos 6–8). Rejeitada por contradizer o próprio rigor.

## Consequências
- O brief do codex passa a perguntar sobre o domínio que os especialistas aplicam (releases, deprecações, breaking changes com fonte primária), não só sobre como times de agentes se organizam — o alias-rate deve cair porque o corpus é novo.
- Aceites de governança continuam possíveis, mas deixam de ser o caminho de menor resistência; a assimetria é deliberada e está escrita no passo 2.7 com a evidência (8+ vs ~2).
- Risco novo: conhecimento de domínio envelhece mais rápido que convenção estrutural — mitigado pelo staleness de 30 dias herdado do catálogo de capabilities e pelo ADR-017/4.5.
- Risco novo: mis-classificação para escapar do haircut — mitigado pelo veredito capability×governance do @challenger no gate (a formalização no par do challenger é o Passo do plano seguinte; challenger é carve-out, edição owner-only).
- CX4 (`secure-sdlc`) tem nota explícita: achados NUNCA editam sentinel/guardian/challenger (NFR-SEC-1); landam em capability pages / agentes não-carve-out.

## Notas de implementação
Arquivos tocados (owner-directed, 2026-08-13): `research-vault/capabilities/agent-capability-matrix.md` (novo) · `research-vault/capabilities/index.md` (link) · `docs/planning/artifacts/chatgpt-research-brief-prompt.md` (abertura + bloco de eixos + nota de runtime) · `.claude/commands/owl/research.md` (default do QUERY_AXIS) · par `scout` (eixos + fontes de domínio; ADR-028, edição idêntica nas 2 cópias) · par `curator` (SEMPRE FAÇA + passo 2.7 + passo 4 + correção de 2 afirmações estruturais expiradas "markdown-only/no-runtime" no 🎯 e no rótulo Fit da rubrica, sincronizadas com `structural-properties.md`; ADR-028, idêntico nas 2 cópias). Pesos da rubrica e `safety_floor` INTOCADOS (carve-out). Verificação: grep `ADR-040` deve retornar as 8 superfícies; o par scout/curator deve ter diffs idênticos por metade. Follow-ups nomeados: fixtures de eval de domínio (Passo 2 do plano) e o veredito capability×governance no par do challenger (owner-only).
