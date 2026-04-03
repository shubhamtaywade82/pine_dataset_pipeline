---
name: smc-fvg-liquidity
description: Fair value gaps and liquidity sweeps in Pine. Use when the user asks for FVG, imbalance, equal highs/lows, stop runs, or liquidity grabs alongside SMC.
metadata:
  version: "1.0"
  domain: trading-smc
---

# FVG and liquidity

## FVG (3-candle pattern)

- **Bullish FVG**: `low[1] > high[2]` (gap between candles—tune strictness if user wants wick-based variants).
- **Bearish FVG**: `high[1] < low[2]`.

## Liquidity (conceptual in Pine)

- **Equal highs/lows**: threshold on `abs(high - high[1])` and similar—expose threshold as input.
- **Sweep**: price trades through a prior swing level then rejects—define with closes or wicks per user preference.

## Notes

Keep patterns **deterministic**; label parameters the user can adjust for asset volatility.
