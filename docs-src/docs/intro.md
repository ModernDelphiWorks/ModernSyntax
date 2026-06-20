---
displayed_sidebar: docsSidebar
title: Documentation portal
slug: /
sidebar_position: 0
---

Welcome to the **ModernSyntax** technical documentation portal. Content is derived from source code, tests, and examples.

## Projects

<div className="row">
  <div className="col col--6 margin-bottom--lg">
    <div className="card">
      <div className="card__header">
        <h3>ModernSyntax</h3>
      </div>
      <div className="card__body">
        <p>Functional programming toolkit and modern syntax extension for Delphi. Brings null safety (<code>TOption&lt;T&gt;</code>), railway-oriented error handling (<code>TResultPair&lt;S,F&gt;</code>), expressive pattern matching (<code>TMatch&lt;T&gt;</code>), async scheduling (<code>TAsync</code>), tuples, and currying to Delphi XE and later.</p>
      </div>
      <div className="card__footer">
        <a className="button button--primary" href="./modernsyntax/">Open documentation →</a>
      </div>
    </div>
  </div>
</div>

## Documented release

This portal matches the published source on [github.com/ModernDelphiWorks/ModernSyntax](https://github.com/ModernDelphiWorks/ModernSyntax).

- **Null Safety** — `TOption<T>` prevents null-reference Access Violations
- **Railway Results** — `TResultPair<S,F>` replaces untracked exceptions
- **Pattern Matching** — `TMatch<T>` replaces nested `if-else` / `case` blocks
- **Async** — `TAsync` / `Async()` with `Await` and `NoAwait`
- **Tuples & Currying** — `TTuple`, `TTuple<K>`, `TCurrying`
- **Safe Try** — `TSafeTry` / `Try()` functional exception wrapper

Cross-platform verified: **Win32, Win64, Linux64** (`dcclinux64`).
