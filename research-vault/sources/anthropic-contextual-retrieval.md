---
title: "Anthropic — Introducing Contextual Retrieval"
type: source
tags: [rag, retrieval, contextual-retrieval, embeddings, bm25, context-engineering]
sources: 1
updated: 2026-07-26
---
**Source:** [Introducing Contextual Retrieval](https://www.anthropic.com/engineering/contextual-retrieval) · **Type:** blog · **Stars/credibility:** n/a · primary
**Author / Org:** Daniel Ford; contributors Orowa Sikder, Gautam Mittal, Kenneth Lien (Anthropic)  ·  **Published:** 2024-09-19  ·  **Ingested:** 2026-07-26 (imported from carinhAI; note — renamed from carinhAI's `contextual-retrieval.md` to avoid a filename collision with the [[contextual-retrieval]] pattern page in this vault)

## Summary
Traditional RAG loses critical context when chunking documents — isolated chunks fail retrieval because they lack identifying details about companies, dates, or document sources. Contextual Retrieval prepends 50-100 token Claude-generated summaries to each chunk before embedding and indexing, reducing retrieval failure rates by 49% alone and 67% when combined with reranking. At $1.02 per million document tokens (with prompt caching), the technique is economically viable at scale.

## Key points
- Core problem: standard RAG chunking strips context, causing retrieval failures on isolated text.
- Dual-technique solution: Contextual Embeddings (semantic similarity with context) + Contextual BM25 (exact-match with context).
- Performance: 49% reduction in retrieval failure rates independently; 67% reduction combined with reranking.
- Cost: ~$1.02 per million document tokens using Claude's prompt caching — economically viable at scale.
- For small knowledge bases (<200K tokens): including the entire corpus in prompts with caching is simpler than RAG.
- Validated across codebases, fiction, ArXiv papers, and scientific publications.

## Informs (ideas / patterns)
- [[contextual-retrieval]] — foundational description; contextual embeddings + BM25 combination; chunk contextualization via LLM; failure-rate reduction metrics.
- [[context-engineering]] — retrieval as a context-quality problem; prompt caching as cost enabler; alternative to RAG for small corpora.

## Notable quotes
> "Contextual Retrieval solves this problem by prepending chunk-specific explanatory context to each chunk before embedding."
> "All these benefits stack: to maximize performance improvements, we can combine contextual embeddings with contextual BM25, plus a reranking step."

## Gaps / open questions
- How does context quality from LLM-generated summaries compare to human-authored context?
- What's the right chunk size for contextual retrieval vs. standard RAG?

## Related
- [[contextual-retrieval]] · [[context-engineering]] · [[effective-context-engineering]]
