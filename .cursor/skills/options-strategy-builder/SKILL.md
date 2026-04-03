---
name: options-strategy-builder
description: Options-aware Pine strategy patterns—ATM/near-ATM discipline, risk/reward framing, confirmation stack. Use when the user mentions options, CE/PE, NSE, or defined-risk option buying alongside signals.
metadata:
  version: "1.0"
  domain: trading-options
---

# Options strategy builder (Pine context)

## Reality check

- Pine strategies backtest **underlying** prices unless you model derivatives externally. Encode options **logic as constraints** on the underlying signal (timing, trend, IV proxy if used).

## Signal stack (example)

1. Structure (`smc-structure`) aligned with higher timeframe filter.
2. Zone interaction (`smc-orderblocks` / `smc-fvg-liquidity`).
3. Risk filter: ATR band, session, avoid extreme wicks if specified.

## Risk rules

- Enforce minimum R-multiple or SL/TP distances the user specifies.
- Prefer **ATM / near-ATM** language as execution intent, not a literal Pine order type.

Pair with `pine-strategy-builder` for `strategy.*` mechanics.
