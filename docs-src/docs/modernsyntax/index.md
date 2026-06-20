---
displayed_sidebar: modernsyntaxSidebar
title: ModernSyntax
sidebar_position: 0
---

# ModernSyntax

**ModernSyntax** is a high-performance, lightweight functional programming and modern syntax extension toolkit for Delphi. It brings paradigms found in **Rust**, **Kotlin**, **C#**, and **Haskell** directly into native Pascal code.

## Core modules

| Unit | Type | Purpose |
|---|---|---|
| `ModernSyntax.Option` | `TOption<T>` | Null-safe optional values |
| `ModernSyntax.ResultPair` | `TResultPair<S,F>` | Railway-oriented error handling |
| `ModernSyntax.Match` | `TMatch<T>` | Expressive pattern matching |
| `ModernSyntax.Async` | `TAsync` / `Async()` | Async/await task scheduling |
| `ModernSyntax.Tuple` | `TTuple`, `TTuple<K>` | Lightweight anonymous data structures |
| `ModernSyntax.Currying` | `TCurrying` | Partial function application |
| `ModernSyntax.SafeTry` | `TSafeTry` | Functional exception wrapper |
| `ModernSyntax.DotEnv` | `TDotEnv` | `.env` file loader (cross-platform) |

## Platform support

| Environment | Platforms | Status |
|---|---|---|
| Delphi XE or superior | Win32, Win64 | Fully supported |
| Delphi XE or superior | Linux64 (`dcclinux64`) | Build-verified (2026-06-20) |
| Delphi XE or superior | macOS / iOS / Android | Supported by RTL; not build-verified |

## Quick links

- [Installation](./getting-started/installation.md)
- [Quick start](./getting-started/quickstart.md)
- [Null safety guide](./guides/null-safety.md)
- [Pattern matching guide](./guides/pattern-matching.md)
- [Railway results guide](./guides/railway-results.md)
- [API reference](./reference/api-reference.md)
