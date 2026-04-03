---
name: smc-orderblocks
description: Order block zones in Pine—last opposing candle before displacement, mitigation rules. Use when the user asks for bullish/bearish OB, supply/demand zones, or OB retest entries.
metadata:
  version: "1.0"
  domain: trading-smc
---

# SMC order blocks

## Definition (Pine-friendly)

- **Bullish OB**: last down (bearish) candle before a bullish displacement leg.
- **Bearish OB**: last up (bullish) candle before a bearish displacement leg.

## Detection checklist

1. Define **displacement** (body vs ATR, structure break)—keep inputs explicit.
2. Identify the **reference candle** (opposite color) before the impulse.
3. Store zone high/low (`obHigh`, `obLow`); optional `box.new` for visualization.

## Risk context

- OBs can invalidate; track **mitigation** (close through zone) if the user wants realistic behavior.

Combine with `smc-structure` for trend and `pine-strategy-builder` for orders.
