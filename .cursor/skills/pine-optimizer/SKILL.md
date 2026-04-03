---
name: pine-optimizer
description: Improves Pine Script v6 performance, readability, and TradingView resource limits. Use when the user asks to optimize, slim down, or speed up a script.
metadata:
  version: "1.0"
  domain: pine-script
---

# Pine optimizer

## Performance

- Hoist repeated `ta.*` calls into locals.
- Minimize `request.security` calls; batch expressions in one call when possible.
- Avoid unbounded `label`/`line`/`box` creation; delete or limit historical objects.

## Readability

- Name series for intent (`bullishCross`, `atrStop`).
- Group inputs and keep one responsibility per block.

## Output

- Revised script plus a brief list of changes (what got faster or simpler).
