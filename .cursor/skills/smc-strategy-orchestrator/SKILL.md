---
name: smc-strategy-orchestrator
description: Assembles SMC modules into a full Pine v6 strategy—structure, zones, liquidity, filters, entries, SL/TP. Use when the user wants a complete SMC-based strategy, not a single indicator fragment.
metadata:
  version: "1.0"
  domain: trading-smc
---

# SMC strategy orchestrator

## Pipeline

1. **Filters**: regime (EMA/HTF), volatility (ATR), session.
2. **Structure** (`smc-structure`): BOS/CHOCH flags.
3. **Zones** (`smc-orderblocks`, `smc-fvg-liquidity`): valid unfilled zones.
4. **Liquidity event** (optional): sweep detection before entry.
5. **Entry**: combine booleans into `longCondition` / `shortCondition`.
6. **Risk**: SL beyond invalidation; TP by RR or structure.

## Pine output

- Use `strategy()` with explicit exits (`strategy.exit`) matching user RR.
- Document all pivot/ATR/session inputs in one `input` group for tuning.

## Skills to load alongside

- `pine-v6-core`, `pine-strategy-builder`, `pine-debugger` (if behavior mismatches intent).
