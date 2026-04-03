# Pine dataset MCP server

Stdio MCP server (Ruby official [`mcp`](https://rubygems.org/gems/mcp) gem) that exposes lookup tools over the JSON produced by `bin/pine_docs_sync sync` in the parent repo.

## Setup

```bash
cd pine_mcp
bundle install
```

Run a sync first so `../output/` contains `reference/functions.json`, `normalized_pages.json`, and `mcp_index.json`.

## Run (manual)

```bash
PINE_DATASET_ROOT=/absolute/path/to/pine_dataset_pipeline/output bundle exec ruby bin/pine_mcp_server
```

If `PINE_DATASET_ROOT` is unset, it defaults to `../../output` relative to `pine_mcp/bin`.

## Cursor

The repo includes [`.cursor/mcp.json`](../.cursor/mcp.json) with `cwd` `pine_mcp` and relative `PINE_DATASET_ROOT`. If your Cursor build does not resolve those paths, set **absolute** `cwd`, `command`, and `PINE_DATASET_ROOT` in your user MCP settings.

## Tools

- `search_functions`, `get_function`, `list_namespace` — `reference/functions.json`
- `search_docs`, `get_doc_page` — `normalized_pages.json`
- `validate_code` — version header + identifier allowlist against the local function registry

This is not a TradingView compiler; it is a **local, deterministic** reference layer.
