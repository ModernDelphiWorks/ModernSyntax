# Changelog

All notable changes to **ModernSyntax** are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project
aims at [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

This file starts at `v1.2.0`; for anything older, read the git history.

---

## [Unreleased]

### ⚠️ BREAKING — `Await(timeout)` no longer reports success on a blown deadline

Merged in [#7](https://github.com/ModernDelphiWorks/ModernSyntax/pull/7).

`TAsync.Await` discarded the `Boolean` returned by `ITask.Wait(ATimeout)` at all four await
sites, so an expired deadline fell through to `Result.SetOk(...)`. A blown deadline was
reported as **SUCCESS**, and the `TFunc` overload even published an `LValue` the task might
never have produced. Now an expired deadline yields `IsErr` with a message that says `TIMEOUT`
and quotes the deadline in ms; the continuation does not run and nothing is published.

**Who breaks:** anyone who called `Await(timeout)` with a *finite* deadline and treated the
result as "fire and forget with a grace period" — i.e. code that read `IsOk` after the
deadline and carried on. That code used to see `IsOk = True` for work that had not finished;
it now sees `IsErr = True`. Any branch keyed on `IsOk` inverts.

**Who does not break:** `Await` and `Await(INFINITE)` — the parameter default — are provably
unchanged. `_AwaitTimedOut` only reports a timeout when `ATimeout <> INFINITE`, so the
no-deadline path is byte-for-byte the old behaviour. This is the path every pre-existing
caller who never passed a deadline is on.

**Migration:**

```pascal
// before - "success" could mean "still running"
LFuture := LAsync.Await(500);
if LFuture.IsOk then
  ...

// after - decide explicitly what a blown deadline means
LFuture := LAsync.Await(500);
if LFuture.IsOk then
  ...                        // really finished
else if IsAwaitTimeout(LFuture) then
  ...                        // deadline blown, task still running
else
  ...                        // the task itself failed: LFuture.Err
```

To keep the old "no deadline" semantics, drop the argument: `LAsync.Await`.

### Added

- `ModernSyntax.Async.IsAwaitTimeout(const AFuture: TFuture): Boolean` — the supported way to
  tell a blown `Await` deadline from a task failure. Replaces `Pos('TIMEOUT', LFuture.Err)`,
  which breaks on a reworded message and misfires on task messages that merely contain the
  word. The check is anchored at the start of the message.

### Changed

- The `Await` timeout message is now a **frozen contract**, declared as a `const` instead of a
  `resourcestring` so that translation tooling cannot silently patch it. Its ASCII prefix
  (`Async await TIMEOUT:`) must not be reworded or localized; the tail after the prefix may be
  improved. Rationale, including why `TFuture` did **not** get a discriminator field, is
  documented above the constant in `Source/ModernSyntax.Async.pas`.
- `TAsync.Await` `<remarks>` now document that a timeout does **not** cancel the task and that
  the orphan keeps dereferencing `@Self`, so with a finite deadline the `TAsync` must be held
  in a named variable rather than awaited as a temporary (`Async(...).Await(50)`).
- `TResultPair.Dispose` `<remarks>` now state that idempotence is **per instance, not per
  object**: two copies of the record hold the same pointer, so two copies with one `Dispose`
  each still free twice.
- Corrected the "why there is no `class operator Finalize`" note in
  `Source/ModernSyntax.ResultPair.pas`: it cited `ModernSyntax.inc`, a Delphi 2010 floor and an
  FPC/Lazarus target, none of which hold. The unit does not include the `.inc`, no unit in the
  repository consumes any symbol it defines, the declared floor is Delphi XE (`README.md:3`,
  `README.md:33`), and the `.inc`'s Lazarus block is dead code guarded by a typo (`FCP`). The
  decision itself is unchanged and still correct: managed records need 10.4+, which is above
  the XE floor.

### Fixed

- Restored the accented characters in two test files that were mangled to `U+FFFD` by an
  encoding change in #7: `Test Delphi/EclbrResultPair/UTestMS.ResultPair.pas` and
  `Test Delphi/EclbrSystem/UTestMMS.Threading.pas`. Both are back to the repository's CP1252,
  no-BOM convention for accented Pascal sources.

### Documented (not fixed)

- `KNOWN BUG` markers on `TResultPair._ReturnSuccess` / `_ReturnFailure`, tracked by
  [#8](https://github.com/ModernDelphiWorks/ModernSyntax/issues/8): the `Return` chain discards
  the transformation (`Result := Self` is taken before the loop mutates `Self`), does not
  compose across steps, and leaves a dangling pointer (`_Set*Value` adopts a pointer that the
  following `LResult.Dispose` frees). For `TResultPair<class, class>` #7 changed how it shows
  up: it used to abort loudly with `'Value is nil.'`, it is now a silent use-after-free. The
  fix is an ownership refactor of the chain and belongs in its own PR.

---

## [1.2.0] - 2026-06-20

### Fixed

- `dcclinux64` E2076: `TResultPair<>.Failure` / `.Success` were being called as class methods;
  changed to `.New.Failure` / `.New.Success` in `ModernSyntax.Match` and `ModernSyntax.Option`.

### Added

- Cross-platform build verified on Win32, Win64 and Linux64 (`dcclinux64`): POSIX
  `setenv`/`unsetenv` shim for `TDotEnv`, `stderr` fallback for `OutputDebugString`,
  `AtomicIncrement` in place of `InterlockedIncrement64`, and `{$IFDEF MSWINDOWS}` guards on
  bare `uses Windows` clauses.

[Unreleased]: https://github.com/ModernDelphiWorks/ModernSyntax/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/ModernDelphiWorks/ModernSyntax/releases/tag/v1.2.0
