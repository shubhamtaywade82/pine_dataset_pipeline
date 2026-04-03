# Parity: `pinescript-agents` (Python) → this repo (Ruby)

This document relates **[pinescript-agents](https://github.com/TradersPost/pinescript-agents)**—a Claude Code–oriented Pine Script v6 workspace (Python tooling + static docs + skills)—to **pine_dataset_pipeline**, which is the Ruby-based source of truth for **crawled** TradingView docs, **JSON** artifacts, and the **MCP** reference server used from Cursor.

## Local clone (reference)

If you keep a checkout next to other trading tools, a typical path is:

`/home/nemesis/project/trading-workspace/pinescript-agents`

(Adjust for your machine; the upstream repo is `TradersPost/pinescript-agents`.)

## What the Python project is

| Area | Role |
|------|------|
| **Claude Code** | `CLAUDE.md` drives onboarding, command words (`start`, `help`, …), and behavioral rules. |
| **Skills** | `.claude/skills/` and `.cursor/skills/` (`pine-developer`, `pine-debugger`, `pine-optimizer`, …). |
| **Static docs** | `docs/pinescript-v6/` — curated Markdown reference and guides checked into that repo. |
| **Layout** | `templates/`, `examples/`, `projects/` for `.pine` files; `projects/README.md` describes conventions. |
| **Python** | `tools/video-analyzer.py` — YouTube → transcript → trading-oriented analysis (optional workflow). |
| **Shell** | `start` / `start.sh` — interactive TTY menu for humans. |

It is **not** a single long-running agent server; it is an **IDE workspace** plus **skills** and **scripts**.

## What this Ruby repo is

| Area | Role |
|------|------|
| **Pipeline** | `bin/pine_docs_sync sync` crawls TradingView Pine **manual + v6 reference**, writes **`output/*.json`**. |
| **MCP** | `pine_mcp/` — stdio MCP tools (`search_functions`, `get_doc_page`, `validate_code`, …) over that JSON. |
| **Skills** | `.cursor/skills/` — Pine v6 + SMC packs aligned with this workspace (see repo `README.md`). |
| **Ruby only** | No Python runtime required for docs sync or MCP. |

## Component mapping

| pinescript-agents | pine_dataset_pipeline |
|-------------------|------------------------|
| `docs/pinescript-v6/` (static) | `output/normalized_pages.json` + `output/reference/functions.json` (synced from live docs) |
| Reading docs in-chat | Enable MCP **`pine-dataset`** + run sync (see `README.md`, `pine_mcp/README.md`) |
| `pine-developer` / `pine-debugger` skills | `.cursor/skills/pine-*` and `smc-*` (different filenames; same idea) |
| `tools/video-analyzer.py` | *Not ported here.* Options: keep using the Python tool from that repo, or add a separate Ruby/CLI tool later (e.g. `yt-dlp` + transcript APIs). |
| `start` interactive script | `bin/pine_docs_sync workspace` — **status only** (dataset + MCP bundle checks); not a full TUI clone |
| `projects/` for `.pine` files | This repo is dataset + tooling; **author scripts** in another folder or clone `pinescript-agents` only for `projects/` + templates if you want that layout |

## Recommended combined workflow

1. **Use this repo** for: staying current with TV docs → JSON → MCP lookups in Cursor.
2. **Optionally keep pinescript-agents** for: templates, `examples/`, video analysis, or Claude-specific `CLAUDE.md` flows.
3. **In Cursor**, enable **Agent Skills** from this repo and the **`pine-dataset`** MCP server so the model **looks up** functions and manual text instead of relying only on static Markdown from another clone.

## Drift and ownership

- **Curated prose** (long-form guides, internal playbooks) may still live in `pinescript-agents` or your own notes.
- **API truth** (built-ins, namespaces) should prefer **this repo’s** synced `output/reference/functions.json` (and MCP tools) so it tracks TradingView’s published reference.

## See also

- [README.md](../README.md) — sync, MCP, skills overview  
- [pine_mcp/README.md](../pine_mcp/README.md) — dataset paths and tools  
- [`.cursor/mcp.json`](../.cursor/mcp.json) — Cursor MCP entry for `pine-dataset`
