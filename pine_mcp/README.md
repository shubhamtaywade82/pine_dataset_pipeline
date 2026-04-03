# Pine dataset MCP server

Stdio MCP server (Ruby official [`mcp`](https://rubygems.org/gems/mcp) gem) that exposes lookup tools over the JSON produced by `bin/pine_docs_sync sync` in the parent repo. The crawl targets **Pine Script v6** reference and manual URLs configured in the parent [`config/sources.yml`](../config/sources.yml).

## Setup

```bash
cd pine_mcp
bundle install
```

Run a sync first so the parent repo’s `output/` contains `reference/functions.json`, `normalized_pages.json`, and `mcp_index.json`:

```bash
cd ..   # repo root
bin/pine_docs_sync sync
```

If `reference/functions.json` is empty or stale, function lookup tools return little or no data until you run (or re-run) sync.

## Dataset path (`PINE_DATASET_ROOT`)

Paths in the catalog are resolved from the string you pass in—**relative paths are relative to the process current working directory** (when Cursor starts the server, that should be `pine_mcp/` per [`.cursor/mcp.json`](../.cursor/mcp.json)).

### Cursor: `LoadError` / “No such file or directory -- bin/pine_mcp_server”

Cursor often **does not apply `cwd`** to MCP stdio processes, so `bundle exec ruby bin/pine_mcp_server` runs from the wrong directory. The workspace [`.cursor/mcp.json`](../.cursor/mcp.json) therefore calls **[`run_stdio.sh`](run_stdio.sh)** by **absolute path** (`${workspaceFolder}/pine_mcp/run_stdio.sh`): that script `cd`s to its own directory, optionally **sources RVM**, then runs `bundle exec ruby bin/pine_mcp_server`. Reload MCP after edits.

If `${workspaceFolder}` is not expanded in your Cursor build, set **`args`** to the **absolute** path of `run_stdio.sh` (e.g. `/home/you/.../pine_dataset_pipeline/pine_mcp/run_stdio.sh`). Ensure `run_stdio.sh` is executable: `chmod +x pine_mcp/run_stdio.sh`.

- **Default (recommended for this repo):** leave `PINE_DATASET_ROOT` unset. [`bin/pine_mcp_server`](bin/pine_mcp_server) then uses `File.expand_path("../../output", __dir__)` (repo `output/` next to `pine_mcp/`).
- **Wrong:** `PINE_DATASET_ROOT=output` with `cwd` `pine_mcp` points at `pine_mcp/output/`, which is not where the pipeline writes. The workspace [`.cursor/mcp.json`](../.cursor/mcp.json) intentionally omits `PINE_DATASET_ROOT` so the default applies.
- **Override:** set `PINE_DATASET_ROOT` to an **absolute** directory when the repo lives somewhere non-standard or Cursor cannot use the bundled `cwd` (WSL example: `/home/you/project/pine_dataset_pipeline/output`).

### Verify the server sees your dataset

From `pine_mcp/` (same cwd the MCP process should use):

```bash
# Default root (same as unset PINE_DATASET_ROOT)
test -f "$(ruby -e 'puts File.expand_path("../../output/reference/functions.json", "bin")')" && echo "functions.json reachable"

# Or with explicit absolute path
test -f "$PINE_DATASET_ROOT/reference/functions.json" && echo "ok"
```

## Run (manual)

**Do not** run `lib/pine_mcp/server.rb` directly (e.g. `./lib/pine_mcp/server.rb`). That file has no Ruby shebang; the shell will interpret it as a script and you will see errors like `require: not found`. Always start **`bin/pine_mcp_server`** with the `ruby` interpreter.

```bash
cd pine_mcp
bundle exec ruby bin/pine_mcp_server
```

With an explicit dataset directory:

```bash
PINE_DATASET_ROOT=/absolute/path/to/pine_dataset_pipeline/output bundle exec ruby bin/pine_mcp_server
```

If `PINE_DATASET_ROOT` is unset or empty, it defaults to `../../output` relative to `pine_mcp/bin`.

## Cursor

Enable the **`pine-dataset`** server from [`.cursor/mcp.json`](../.cursor/mcp.json): `bundle exec ruby bin/pine_mcp_server` with `cwd` `pine_mcp`. No `PINE_DATASET_ROOT` is set there so the default repo `output/` path is used.

If your Cursor build does not resolve `cwd` relative to the workspace, duplicate this entry in **user** MCP settings with **absolute** `cwd` and, if needed, absolute `PINE_DATASET_ROOT`.

### Using this with Pine v6 in the editor

- **MCP tools** supply signatures, doc text search, and light `validate_code` checks from your **local** JSON index.
- **Agent skills** under [`.cursor/skills/`](../.cursor/skills/) (e.g. `pine-v6-core`) describe *how* to write Pine; the MCP server is the *ground truth* for names and docs **after sync**.

This is not a TradingView compiler; it is a **local, deterministic** reference layer.

## Tools

| Tool | Data source | Purpose |
|------|-------------|---------|
| `search_functions` | `reference/functions.json` | Substring search on function keys |
| `get_function` | same | Full entry for one name |
| `list_namespace` | same | Names under a namespace |
| `search_docs` | `normalized_pages.json` | Search manual / concept pages |
| `get_doc_page` | same | Fetch one normalized page |
| `validate_code` | registry derived from functions | Version header + identifier allowlist (not TV compile) |
