---
name: smc-core
description: Smart Money Concepts foundations—structure, liquidity, displacement, order flow context. Use when the user mentions SMC, institutions, liquidity, or smart money in Pine or trading logic.
metadata:
  version: "1.0"
  domain: trading-smc
---

# SMC core

## Model (conceptual)

- Price seeks **liquidity** (stops, equal highs/lows).
- **Displacement** shows aggressive participation; often paired with structure breaks.
- **Order blocks** and **FVGs** are zones; they are hypotheses, not guarantees.

## Pine discipline

- Encode **confirmed** structure (e.g. closes beyond levels), not repainting wicks, unless the user accepts repaint.
- State assumptions explicitly (pivot length, what counts as displacement).

## Related skills

- Structure: `smc-structure`
- Order blocks: `smc-orderblocks`
- FVG / liquidity sweeps: `smc-fvg-liquidity`
- Full assembly: `smc-strategy-orchestrator`
