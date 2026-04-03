---
name: pine-v6-core
description: Strict Pine Script v6 syntax, execution model, and API discipline. Use when generating, reviewing, or fixing any Pine Script code, or when the user mentions Pine v6, TradingView scripts, indicators, or strategies.
metadata:
  version: "1.0"
  domain: pine-script
---

# Pine Script v6 core

## Non-negotiables

- Start every script with `//@version=6`.
- Use only APIs that exist in the official Pine v6 reference; do not invent `ta.*`, `strategy.*`, or `request.*` members.
- Pine executes **once per bar**; no async, no network, no file I/O.
- Respect series vs simple types; use `var` only for persistent state across bars.

## Before writing code

1. If this workspace has `output/reference/functions.json` or an MCP pine server is enabled, **look up** signatures before using a function.
2. Prefer `barstate.isconfirmed` when the user requires non-repainting behavior on the realtime bar.

## Output contract

- Deliver a **complete** script (indicator or strategy) unless the user asked for a snippet only.
- No placeholders like `// TODO` for logic the user requested.

## Deeper reference

See [references/pine-v6-constraints.md](references/pine-v6-constraints.md) for type and plotting reminders.
