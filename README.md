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

## Related: `pinescript-agents` (Python reference workspace)

If you use **`/home/nemesis/project/trading-workspace/pinescript-agents`** (same as `~/project/trading-workspace/pinescript-agents` on your machine)—TradersPost-style Pine assistant with Claude skills, hand-curated `docs/pinescript-v6/`, templates, and Python video tools—treat **this repo as the Ruby-native replacement for the “knowledge + MCP” layer**, not a line-for-line port of the whole agent.

| `pinescript-agents` (Python project) | This repo (Ruby) |
|--------------------------------------|------------------|
| Static markdown under `docs/pinescript-v6/` | **`bin/pine_docs_sync sync`** → `output/*.json` (crawled from TradingView; refresh on demand) |
| No first-party MCP over that corpus (external servers optional) | **`pine_mcp/`** → stdio MCP reading `output/` (`search_functions`, `get_function`, `search_docs`, `validate_code`, …) |
| Skills: `pine-developer`, `pine-debugger`, `pine-optimizer`, `pine-visualizer`, `pine-backtester`, `pine-manager`, `pine-publisher` | Skills: **`pine-v6-core`**, **`pine-indicator-builder`**, **`pine-strategy-builder`**, **`pine-debugger`**, **`pine-optimizer`**, plus **SMC / options** skills (see below) |
| `templates/`, `examples/`, `projects/` for scripts | No bundled `projects/` tree—add your own repo or symlink a folder; copy **patterns** from their templates/examples |
| `tools/video-analyzer.py`, `run_analysis.py`, Whisper/FFmpeg | **Not replicated here**—keep video workflows in that project or reimplement in Ruby separately if needed |

**Practical workflow:** keep **Cursor skills** in this repo for day-to-day Pine generation with **MCP + synced JSON**; open `pinescript-agents` when you want their **long-form SKILL bodies** (e.g. ternary / line-wrap rules in `pine-developer`), **publisher/backtester/manager** narratives, or **video analysis**. You can gradually fold the best bits into [`.cursor/skills/`](.cursor/skills/) here as shorter, agentskills-compliant `SKILL.md` + `references/` files.

## Agent skills (Cursor)

This repo includes an [Agent Skills](https://agentskills.io/specification)-style pack under [`.cursor/skills/`](.cursor/skills/):

- Pine: `pine-v6-core`, `pine-indicator-builder`, `pine-strategy-builder`, `pine-debugger`, `pine-optimizer`
- SMC / options: `smc-core`, `smc-structure`, `smc-orderblocks`, `smc-fvg-liquidity`, `options-strategy-builder`, `smc-strategy-orchestrator`

Validate with [skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref) if installed:

```bash
skills-ref validate .cursor/skills/pine-v6-core
```

## MCP server (local, Pine v6)

The [`pine_mcp/`](pine_mcp/) directory is a small Bundler project that loads **`output/*.json`** (same v6-oriented dataset produced by `bin/pine_docs_sync sync`) and registers MCP tools for Cursor and other MCP clients.

### What it is for

- **Lookup:** function names, namespaces, and manual/reference text from your synced JSON—not live TradingView.
- **Light checks:** `validate_code` uses the local function registry (version header + identifiers). It is **not** the TradingView compiler.

### Tools (server name: `pine-dataset`)

| Tool | Role |
|------|------|
| `search_functions` | Find built-ins by substring |
| `get_function` | One function entry (signature-oriented text from the index) |
| `list_namespace` | Functions in a namespace |
| `search_docs` | Search normalized manual / concept pages |
| `get_doc_page` | Load one page record |
| `validate_code` | Heuristic validation against the local registry |

Details and path rules: [`pine_mcp/README.md`](pine_mcp/README.md).

### Cursor setup

1. Repo root: `bundle install` and `bin/pine_docs_sync sync` so `output/` is populated.
2. `cd pine_mcp && bundle install`.
3. Enable MCP server **`pine-dataset`** (see [`.cursor/mcp.json`](.cursor/mcp.json)).

[`.cursor/mcp.json`](.cursor/mcp.json) uses `cwd` **`pine_mcp`** and does **not** set `PINE_DATASET_ROOT`, so the server defaults to the repo’s **`output/`** directory (`../../output` from `pine_mcp/bin`). Do **not** set `PINE_DATASET_ROOT=output` with that `cwd`—that would look for `pine_mcp/output`, which the pipeline does not use.

If Cursor does not resolve `cwd` relative to the workspace, copy the server entry into user MCP settings with **absolute** `cwd` (and **absolute** `PINE_DATASET_ROOT` only if you must override the default). On WSL, use Linux paths (e.g. `/home/.../pine_dataset_pipeline/pine_mcp` and `/home/.../pine_dataset_pipeline/output`).

### Agent skills + MCP

Skills under [`.cursor/skills/`](.cursor/skills/) (e.g. [`pine-v6-core`](.cursor/skills/pine-v6-core/SKILL.md)) guide Pine v6 style and API discipline. When the MCP server is enabled, prefer **tool lookups** for exact names and signatures instead of guessing.

### Relation to `pinescript-agents` (Python workspace)

If you use **[pinescript-agents](https://github.com/TradersPost/pinescript-agents)** (e.g. `~/project/trading-workspace/pinescript-agents`) for Claude Code skills, templates, and optional **Python** video analysis, this Ruby repo is the place for **synced docs → JSON → MCP**. See **[docs/pinescript-agents-ruby-parity.md](docs/pinescript-agents-ruby-parity.md)** for a full component mapping and a suggested combined workflow.

Quick workspace check (dataset files + `pine_mcp` bundle hints):

```bash
bin/pine_docs_sync workspace
```

### Verify paths (optional)

From `pine_mcp/`:

```bash
test -f "$(ruby -e 'puts File.expand_path("../../output/reference/functions.json", "bin")')" && echo "default dataset path ok"
```

After a full sync, `output/reference/functions.json` should be non-empty so function tools return useful results.

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
