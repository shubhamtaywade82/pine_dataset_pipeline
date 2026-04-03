---
name: pine-debugger
description: Debugs Pine Script v6 compile errors, runtime logic mistakes, repainting, and order/fill misunderstandings. Use when the user pastes an error, wrong signals, or unexpected backtest behavior.
metadata:
  version: "1.0"
  domain: pine-script
---

# Pine debugger

## Steps

1. **Compile-level**: undefined identifiers, bad arity, type mismatch, misplaced `if`/`for`.
2. **Series logic**: accidental use of future data; `var` vs reassignment; off-by-one on `[]`.
3. **Repaint**: `request.security` lookahead; unconfirmed realtime bar; `calc_on_every_tick`.
4. **Strategy**: order timing (`process_orders_on_close`, `calc_on_order_fills`); conflicting `strategy.exit` ids; position size.

## Techniques

- Temporarily `plotchar` or `label.new` conditions to compare intended vs actual triggers.
- Reduce to a minimal script that still reproduces the issue.

## Output

- Fixed full script when possible.
- Short explanation: root cause and what changed.
