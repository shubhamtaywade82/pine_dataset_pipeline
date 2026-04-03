---
name: pine-strategy-builder
description: Builds backtestable Pine Script v6 strategies with entries, exits, stops, targets, and risk settings. Use when the user asks for a strategy, backtest, long/short system, or SL/TP rules.
metadata:
  version: "1.0"
  domain: pine-script
---

# Strategy builder

## Declaration

Use `strategy()` with explicit commission and sizing the user asked for, or sensible defaults:

- `default_qty_type` / `default_qty_value` or fixed contracts.
- `commission_type` / `commission_value` when specified.

## Entries and exits

- `strategy.entry` for direction; unique `id` per entry leg.
- **Every strategy the user wants tradable must define risk out** via `strategy.exit` and/or `strategy.close` patterns that include stop and/or limit (or documented ATR-based prices).
- Avoid naked entries: if the user did not specify SL/TP, choose ATR multiples or structure-based stops and state assumptions in a comment.

## Discipline

- Respect pyramiding: set `pyramiding=` when multiple entries are intentional.
- Use confirmed signals when the user cares about repaint.

## Orchestration

Combine with `pine-v6-core` for API correctness and `pine-debugger` if fills or orders behave unexpectedly.
