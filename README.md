# Pine Dataset Pipeline

A Ruby pipeline that crawls the TradingView Pine Script docs and builds a structured dataset for an MCP-backed Pine intelligence server.

## What it indexes

- Reference layer: functions, namespaces, constants, types, methods
- Language layer: syntax, type system, execution model, built-ins, user-defined functions
- Concepts layer: strategies, repainting, security, libraries, sessions, visual behavior
- Writing layer: style guide and docs for authoring scripts
- Release notes: version changes and new language features
- Meta: source URLs, crawl timestamps, checksum, tags

## Install

```bash
bundle install
```

## Run

```bash
bin/pine_docs_sync sync
```

## Output

The pipeline writes normalized JSON to:

- `output/raw_pages.json`
- `output/normalized_pages.json`
- `output/reference/functions.json`
- `output/reference/namespaces.json`
- `output/language/pages.json`
- `output/concepts/pages.json`
- `output/writing/pages.json`
- `output/release_notes/pages.json`
- `output/index.json`

## Notes

The official TradingView user manual exposes Primer, Language, Concepts, and Release notes sections, while the Reference Manual is the definitive source for built-ins, types, and other language items. The type system, strategies, style guide, and user-defined functions pages provide the semantic rules needed for an MCP validator. See the TradingView pages at:

- User Manual home
- Language / Built-ins
- Language / Type system
- Concepts / Strategies
- Release notes
- Writing / Style guide
- Language / User-defined functions

