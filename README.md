# Pine Dataset Pipeline

Ruby pipeline that crawls the TradingView Pine Script **user manual** and **v6 reference** pages, normalizes them into JSON, and optionally serves them to Cursor via an MCP stdio server.

## What it indexes

- **Primer, Language, Concepts, Writing, Release notes** — from [Pine Script docs](https://www.tradingview.com/pine-script-docs/)
- **Reference manual** — from [Pine Script v6 reference](https://www.tradingview.com/pine-script-reference/v6/) (HTML parsed for `fun_*` / `var_*` / `type_*` section anchors, plus code-block fallback)
- **Derived artifacts**: layered page JSON, global index, MCP-oriented index, function / namespace maps

## Install

```bash
bundle install
```

## Run sync

```bash
bin/pine_docs_sync sync
```

Respect TradingView `robots.txt` and terms of use. Crawl limits live in [`config/sources.yml`](config/sources.yml) (`max_pages`, `max_depth`, `seed_urls`).

## Output layout

| File | Purpose |
|------|---------|
| `output/raw_pages.json` | Crawled pages (HTML string, no Nokogiri object) |
| `output/normalized_pages.json` | Classified, trimmed fields for search / agents |
| `output/index.json` | `by_url`, `by_layer`, `by_topic`, counts |
| `output/mcp_index.json` | Reference name/namespace maps + concept hints + doc listings |
| `output/reference/functions.json` | Extracted + seed-merged function entries |
| `output/reference/namespaces.json` | Namespace → function names |
| `output/{primer,language,concepts,writing,release_notes}/pages.json` | Split by layer |

### Reference seed overrides

Edit [`data/seed/reference_seed.yml`](data/seed/reference_seed.yml) to pin or patch symbols when HTML parsing drifts. Optional path override: `reference_seed_path` in `sources.yml`.

## Agent skills (Cursor)

This repo includes an [Agent Skills](https://agentskills.io/specification)-style pack under [`.cursor/skills/`](.cursor/skills/):

- Pine: `pine-v6-core`, `pine-indicator-builder`, `pine-strategy-builder`, `pine-debugger`, `pine-optimizer`
- SMC / options: `smc-core`, `smc-structure`, `smc-orderblocks`, `smc-fvg-liquidity`, `options-strategy-builder`, `smc-strategy-orchestrator`

Validate with [skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref) if installed:

```bash
skills-ref validate .cursor/skills/pine-v6-core
```

## MCP server (local)

The [`pine_mcp/`](pine_mcp/) directory is a small Bundler project that loads `output/*.json` and registers MCP tools (`search_functions`, `get_function`, `list_namespace`, `search_docs`, `get_doc_page`, `validate_code`).

See [`pine_mcp/README.md`](pine_mcp/README.md) and [`.cursor/mcp.json`](.cursor/mcp.json). If Cursor does not resolve relative `cwd` / `PINE_DATASET_ROOT`, point both at **absolute** paths on your machine.

## Tests

```bash
bundle exec rspec
```

## Doc sources (human-readable)

- [User manual](https://www.tradingview.com/pine-script-docs/)
- [Language / Built-ins](https://www.tradingview.com/pine-script-docs/language/built-ins/)
- [Type system](https://www.tradingview.com/pine-script-docs/language/type-system/)
- [Concepts / Strategies](https://www.tradingview.com/pine-script-docs/concepts/strategies/)
- [v6 reference](https://www.tradingview.com/pine-script-reference/v6/)
