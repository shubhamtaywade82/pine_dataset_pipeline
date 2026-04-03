# Pine v6 constraints (quick reference)

- **Plots**: `plot` for continuous series; `plotshape` / `plotchar` for discrete signals; `bgcolor` for zones.
- **Higher timeframes**: `request.security` — mind gaps, alignment, and lookahead; document choices when used.
- **Colors**: use `color.*` and transparency explicitly when relevant.
- **Errors to avoid**: forward references, mixing incompatible types, omitting required `strategy.exit` risk parameters when the user asked for SL/TP.
