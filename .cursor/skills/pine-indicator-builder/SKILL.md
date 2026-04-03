---
name: pine-indicator-builder
description: Builds Pine Script v6 indicators with grouped inputs, core ta logic, visuals, and alerts. Use when the user asks for an indicator, overlay, oscillator, or study (not a backtest strategy).
metadata:
  version: "1.0"
  domain: pine-script
---

# Indicator builder

## Workflow

1. **Declare** `indicator(...)` with correct `overlay` flag.
2. **Inputs**: group with `input.string` group parameters or `group=` on `input.*`.
3. **Compute** with `ta.*` / `math.*`; store reused values in locals.
4. **Plot** series and mark signals with `plotshape` / `plotchar` when useful.
5. **Alerts**: `alertcondition(condition, title, message)` for discrete conditions.

## Rules

- Default to **non-repainting** unless the user explicitly wants realtime repainting behavior.
- Do not add strategy order functions in an indicator.

## Template shape

```pinescript
//@version=6
indicator("Title", overlay = true)

// inputs → series → plots → alertconditions
```

Load `pine-v6-core` when unsure about types or API validity.
