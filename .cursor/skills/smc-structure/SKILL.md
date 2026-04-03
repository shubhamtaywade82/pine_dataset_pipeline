---
name: smc-structure
description: Market structure in Pine—swings, BOS, CHOCH—with confirmed-bar bias. Use when the user asks for break of structure, change of character, HH/HL/LH/LL, or trend definition using SMC.
metadata:
  version: "1.0"
  domain: trading-smc
---

# SMC structure

## Implementation pattern

- Detect swings with `ta.pivothigh` / `ta.pivotlow` (length parameters explicit in inputs).
- Track **last confirmed swing highs/lows** in `var` state.
- **BOS**: close beyond prior swing in trend direction (define bullish vs bearish rules clearly).
- **CHOCH**: first break against prior dominant structure after a trend leg.

## Rules

- Prefer **close-based** confirmation when the user wants backtest stability.
- Document pivot length sensitivity; short pivots = more noise.

## Outputs

Expose boolean or enum-like series the rest of the stack can consume (e.g. `bosUp`, `bosDown`).
