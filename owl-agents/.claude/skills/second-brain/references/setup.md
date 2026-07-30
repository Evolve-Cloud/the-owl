# /second-brain — detalhe do `init` (onboard de projeto)

Leia isto **só quando for rodar o `init`**. Aplica os defaults do `docs/second-brain-atlas.md`.

## Guardrail ANTES de mapear (obrigatório)

1. **Detecção prévia** (barato, sem LLM) para dimensionar custo e pegar segredo:
   ```bash
   graphify-out/.graphify_python -c "..."   # ou deixe o /graphify Step 2 fazer a detecção
   ```
   Na prática: rode `/graphify <pasta>` que ele mesmo detecta e reporta `code/docs/...` +
   `skipped_sensitive`. **Pare e avise** se:
   - `skipped_sensitive` não-vazio → liste os arquivos (renomear/mover falso-positivo).
   - muitos **docs** (o doc-pass custa tokens) → estime e confirme, ainda mais se o usuário
     bateu em limite. Ofereça um **slice** (subpasta) primeiro.
   - a pasta tem `.env`/credencial em doc → alerte que docs passam pelo LLM.

## Passos do init

```bash
# 1. always-on no Claude Code (grava seção ## graphify + PreToolUse hook no CLAUDE.md LOCAL do projeto)
graphify claude install

# 2. auto-rebuild de CÓDIGO por commit (git post-commit; pula se não for repo git)
graphify hook install

# 3. gitignore do output gerado (idempotente)
grep -qxF 'graphify-out/' .gitignore || echo 'graphify-out/' >> .gitignore
```

Depois, o **1º build** (dentro do Claude Code, para a extração semântica usar o host agent):
- invoque o `/graphify <pasta>` (query-mode: gera grafo + `graph.html`, **SEM vault** — não criamos um
  segundo vault; o humano é o research-vault). Use `--obsidian --obsidian-dir <research-vault>/maps/<proj>`
  **só** se quiser o mapa visível no Obsidian, e ainda assim numa subpasta dedicada, nunca no root do vault.
- ao terminar, **agregue ao cérebro cross-projeto**:
  ```bash
  graphify global add graphify-out/graph.json --as <nome-do-projeto>
  ```

## Fecho

Reporte ao usuário: onde ficou o vault (`graphify-out/obsidian/`), como abrir
(`open graphify-out/graph.html` ou o vault no Obsidian), e a regra do auto-update
(código = automático no commit; docs = `/second-brain update` manual). Não narre cada passo — entregue o resultado.
