---
displayed_sidebar: modernsyntaxSidebar
title: Introduction
sidebar_position: 1
---

# Introduction

## What is ModernSyntax?

**ModernSyntax** is a lightweight, zero-dependency functional programming toolkit for Delphi (XE and later). It extends native Pascal syntax with patterns and idioms that are standard in contemporary languages such as Rust, Kotlin, C#, and Haskell, without sacrificing performance or compatibility.

The library is designed to be adopted incrementally: you can use only `TOption<T>` in a single unit while leaving the rest of the codebase untouched, or you can replace all exception-based error flows with `TResultPair<S,F>` across an entire service layer.

## Philosophy

### Explicitness over exceptions

Delphi's exception model is powerful but makes error flows implicit. A function that returns an integer might raise any exception—and callers rarely document or handle them completely. ModernSyntax replaces the implicit `raise`/`try-except` model with **explicit return types**:

- `TResultPair<S, F>` encodes "this operation can fail" directly in the return type.
- Callers are forced to handle both the success (`S`) and failure (`F`) branches.

### Safe optionals over nil

Nil pointer dereferences (Access Violations) are one of the most common Delphi runtime errors. `TOption<T>` makes the presence or absence of a value a first-class concern:

- `TOption<string>.Some('hello')` — has a value
- `TOption<string>.None` — explicitly empty
- `.Unwrap`, `.UnwrapOr`, `.ValueOrElse`, `.Map`, `.Filter`, `.AndThen` — all safe combinators

### Expressive pattern matching

Nested `if-else` chains and `case` statements become hard to read at scale. `TMatch<T>` provides a fluent, composable alternative with support for equality (`CaseEq`), comparison (`CaseGt`, `CaseLt`), ranges (`CaseRange`), set membership (`CaseIn`), type dispatch (`CaseIs`), regex (`CaseRegex`), and conditional guards (`CaseIf`).

### Functional composition

Functional operators like `Map`, `Filter`, `AndThen`, `OrElse`, and `OkOr` enable chaining transformations without intermediate variables, producing code that reads like a description of the transformation rather than a sequence of imperative steps.

## What ModernSyntax is NOT

- It is **not** a replacement for Delphi's RTL or VCL.
- It does **not** require generics runtime reflection for basic use.
- It does **not** introduce a garbage collector — all records are stack-allocated value types.

## Source structure

```
Source/
  ModernSyntax.pas            — Core types: Tuple (array of TValue), TFuture, IMSObserver
  ModernSyntax.Option.pas     — TOption<T>, TSome, TNone
  ModernSyntax.ResultPair.pas — TResultPair<S,F>
  ModernSyntax.Match.pas      — TMatch<T>
  ModernSyntax.Async.pas      — TAsync, Async() function
  ModernSyntax.Tuple.pas      — TTuple, TTuple<K>
  ModernSyntax.Currying.pas   — TCurrying
  ModernSyntax.SafeTry.pas    — TSafeTry, TSafeResult
  ModernSyntax.DotEnv.pas     — TDotEnv (.env file loader)
  ModernSyntax.Stream.pas     — Stream functional helpers
  ModernSyntax.Objects.pas    — Object functional extensions
  ModernSyntax.Std.pas        — Shared standard types
  ModernSyntax.ArrowFun.pas   — Arrow-function helpers
  ModernSyntax.Coroutine.pas  — Coroutine support
  ModernSyntax.Crypt.pas      — Cryptographic helpers
  ModernSyntax.RegExpression.pas — Regex wrapper used by TMatch
```
