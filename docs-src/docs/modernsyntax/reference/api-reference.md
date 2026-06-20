---
displayed_sidebar: modernsyntaxSidebar
title: API Reference
sidebar_position: 0
---

# API Reference

Complete public API surface for ModernSyntax. All types are in the `Source/` directory; unit names follow the `ModernSyntax.*` convention.

---

## `TOption<T>` — `ModernSyntax.Option`

### Class methods (constructors)

| Method | Signature | Description |
|---|---|---|
| `Some` | `class function Some(const AValue: T): TOption<T>` | Creates an option with a value |
| `None` | `class function None: TOption<T>` | Creates an empty option |
| `Zip` | `class function Zip(const AThis, AOther: TOption<Variant>): TOption<Variant>` | Combines two options into a Variant pair |

### Inspection

| Method | Signature | Description |
|---|---|---|
| `IsSome` | `function IsSome: Boolean` | True if has value |
| `IsNone` | `function IsNone: Boolean` | True if empty |
| `IsSomeAnd` | `function IsSomeAnd(const APredicate: TFunc<T, Boolean>): Boolean` | True if has value and predicate passes |
| `Contains` | `function Contains(const AValue: T; const AComparer: TFunc<T, T, Boolean> = nil): Boolean` | True if value equals AValue |

### Extraction

| Method | Signature | Description |
|---|---|---|
| `Value` | `property Value: T` (read-only) | Raises if None |
| `Unwrap` | `function Unwrap: T` | Alias for Value |
| `UnwrapOr` | `function UnwrapOr(const ADefault: T): T` | Value or default |
| `UnwrapOrElse` | `function UnwrapOrElse(const ADefaultFunc: TFunc<T>): T` | Value or computed default |
| `UnwrapOrDefault` | `function UnwrapOrDefault: T` | Value or type default |
| `Expect` | `function Expect(const AMessage: string): T` | Value or raises with message |

### Transformation

| Method | Signature | Description |
|---|---|---|
| `Map<U>` | `function Map<U>(const AFunc: TFunc<T, U>): TOption<U>` | Applies func to value |
| `Filter` | `function Filter(const APredicate: TFunc<T, Boolean>): TOption<T>` | Keeps value if predicate |
| `AndThen<U>` | `function AndThen<U>(const AFunc: TOptionAndThen<U>): TOption<U>` | flatMap |
| `Otherwise` | `function Otherwise(const AAlternative: TOption<T>): TOption<T>` | Self if Some, else alternative |
| `OrElse` | `function OrElse(const AAlternativeFunc: TOptionOrElse<T>): TOption<T>` | Self if Some, else computed |
| `Flatten<U>` | `function Flatten<U>: TOption<U>` | Unwrap `TOption<TOption<U>>` |

### Conversion

| Method | Signature | Description |
|---|---|---|
| `OkOr<F>` | `function OkOr<F>(const AFailure: F): TResultPair<T, F>` | Success if Some, Failure if None |
| `AsString` | `function AsString: string` | RTTI string representation |

### Branching

| Method | Signature | Description |
|---|---|---|
| `Match` (proc) | `procedure Match(const ASomeProc: TSomeProc<T>; const ANoneProc: TNoneProc)` | Execute on Some or None |
| `Match<R>` (func) | `function Match<R>(const ASome: TSome; const ANone: TNone): R` | Return value from branch |
| `IfSome` | `procedure IfSome(const AAction: TSomeProc<T>)` | Execute only if Some |

### Mutation

| Method | Signature | Description |
|---|---|---|
| `Take` | `function Take(var ASelf: TOption<T>): TOption<T>` | Extract and clear |
| `Replace` | `function Replace(var ASelf: TOption<T>; const ANewValue: T): TOption<T>` | Swap; return old |

---

## `TResultPair<S, F>` — `ModernSyntax.ResultPair`

### Class methods (constructors)

| Method | Signature | Description |
|---|---|---|
| `Success` | `class function Success(const ASuccess: S): TResultPair<S, F>` | Creates a success result |
| `Failure` | `class function Failure(const AFailure: F): TResultPair<S, F>` | Creates a failure result |

### Inspection

| Property / Method | Description |
|---|---|
| `IsSuccess` | True when rtSuccess |
| `IsFailure` | True when rtFailure |
| `ValueSuccess` | The success value |
| `ValueFailure` | The failure value |

### Chaining

| Method | Description |
|---|---|
| `ThenOf(AFunc)` | Registers `AFunc(ValueSuccess): TResultPair<S,F>` in the success queue; runs on `Return` |
| `ExceptOf(AFunc)` | Registers `AFunc(ValueFailure): TResultPair<S,F>` in the failure queue; runs on `Return` |
| `Ok(ASuccessProc)` | Executes `ASuccessProc(ValueSuccess)` immediately if IsSuccess |
| `Fail(AFailureProc)` | Executes `AFailureProc(ValueFailure)` immediately if IsFailure |
| `Return` | Drains the success/failure queues built by `ThenOf`/`ExceptOf` |

### Supporting types

| Type | Description |
|---|---|
| `TResultType` | Enum: `rtNone`, `rtSuccess`, `rtFailure` |
| `EFailureException<F>` | Exception carrying a failure value |
| `ESuccessException<S>` | Exception carrying a success value |
| `ETypeIncompatibility` | Raised on RTTI type mismatch |
| `TResultValue` | Record holding both Success and Failure `TValue` fields |
| `TResultPairValue<T>` | Internal wrapper with `HasValue: Boolean` |

---

## `TMatch<T>` — `ModernSyntax.Match`

### Entry point

| Method | Signature | Description |
|---|---|---|
| `Value` | `class function Value(const AValue: T): TMatch<T>` | Starts a match session |

### Case builders

| Method | Description |
|---|---|
| `CaseEq(AValue, AProc/AFunc)` | Equality match |
| `CaseGt(AValue, AProc/AFunc)` | Greater-than match |
| `CaseLt(AValue, AProc/AFunc)` | Less-than match |
| `CaseRange(AStart, AEnd, AProc/AFunc)` | Inclusive range match |
| `CaseIn(AArray/ASet, AProc/AFunc)` | Membership match (array, TSysCharSet, TIntegerSet) |
| `CaseIs<Typ>(AProc/AFunc)` | Type-kind match |
| `CaseIf(ACondition, AProc/AFunc?)` | Conditional guard |
| `CaseRegex(AInput, APattern)` | Regular expression match |

All case builders return `TMatch<T>` (fluent API). Each has multiple overloads accepting `TProc`, `TProc<T>`, `TProc<TValue>`, `TFunc<TValue>`, `TFunc<T, TValue>`.

### Terminals

| Method | Returns | Description |
|---|---|---|
| `Default(AProc/AFunc)` | `TMatch<T>` | Fallback case |
| `TryExcept(AProc)` | `TMatch<T>` | Exception fallback inside the match |
| `Combine(AMatch)` | `TMatch<T>` | Merge two matches |
| `Execute` | `TResultPair<Boolean, String>` | Run proc cases; True on match |
| `Execute<R>` | `TResultPair<R, String>` | Run func cases; typed value on match |

### Session states

`TMatchSession` enum: `sMatch`, `sGuard`, `sCase`, `sDefault`, `sTryExcept`.

---

## `TAsync` — `ModernSyntax.Async`

| Method | Returns | Description |
|---|---|---|
| `Await(ATimeout?)` | `TFuture` | Block until task completes |
| `Await(AContinue, ATimeout?)` | `TFuture` | Block then run continuation |
| `Run` | `TFuture` | Start and return immediately |
| `Run(AError)` | `TFuture` | Start with error handler |
| `NoAwait` | `TFuture` | Fire-and-forget |
| `NoAwait(AError)` | `TFuture` | Fire-and-forget with error handler |
| `Status` | `TTaskStatus` | Current task status |
| `GetId` | `Integer` | Task identifier |
| `Cancel` | — | Request cancellation |
| `CheckCanceled` | — | Raise if cancelled |

**Global functions:** `Async(AProc: TProc): TAsync` and `Async(AFunc: TFunc<TValue>): TAsync`.

---

## `TFuture` — `ModernSyntax` (core unit)

| Method | Description |
|---|---|
| `IsOk` | True if task succeeded |
| `IsErr` | True if task raised |
| `Ok<T>` | Typed result value |
| `Err` | Error message string |
| `SetOk(AValue)` | Set success (internal use) |
| `SetErr(AMessage)` | Set error (internal use) |

---

## `TTuple` — `ModernSyntax.Tuple`

| Method | Description |
|---|---|
| `New(AValues: TValueArray)` | Factory |
| `Get<T>(AIndex)` | Typed value by position |
| `Count` | Element count |
| `Items[AIndex]` | Default indexed property (TValue) |

Implicit conversions: `TTuple ↔ TValueArray`, `array of Variant → TTuple`.

---

## `TTuple<K>` — `ModernSyntax.Tuple`

| Method | Description |
|---|---|
| `New(AKeys, AValues)` | Factory |
| `Get<T>(AKey)` | Typed value by key |
| `TryGet<T>(AKey, out AValue)` | Non-raising lookup |
| `Count` | Entry count |
| `SetTuple(AKeys, AValues)` | Replace all |

---

## `TSafeTry` / `TSafeResult` — `ModernSyntax.SafeTry`

### `TSafeTry`

| Method | Returns | Description |
|---|---|---|
| `Try(AFunc)` | `TSafeTry` | Start with a function (class method) |
| `Try(AProc?)` | `TSafeTry` | Start with a procedure (class method) |
| `Except(AProc)` | `TSafeTry` | Register exception handler |
| `Finally(AProc)` | `TSafeTry` | Register finally block |
| `End` | `TSafeResult` | Execute and return result |

Global: `Try(AFunc)`, `Try(AProc)`, `Try` (no args).

### `TSafeResult`

| Method | Description |
|---|---|
| `IsOk` | True if no exception |
| `IsErr` | True if exception caught |
| `GetValue` | Raw `TValue` |
| `TryGetValue(out AValue)` | Non-raising |
| `ExceptionMessage` | Captured message |
| `AsType<T>` | Cast result |
| `IsType<T>` | Test result type |

---

## `TDotEnv` — `ModernSyntax.DotEnv`

| Method | Description |
|---|---|
| `Create(AFileName, AUseSystemFallback)` | Constructor; loads the file immediately |
| `Open` | Reloads variables from the current file |
| `LoadFiles(AFileNames)` | Loads multiple `.env` files in order; later files override earlier |
| `Save` | Writes current variables back to the file |
| `Add(AName, AValue)` | Adds or updates a variable |
| `Push(AName, AValue)` | Like `Add` but returns `Self` for chaining |
| `Delete(AName)` | Removes a variable |
| `Value<T>(AName)` | Returns the variable as type `T`; raises if not found |
| `Get<T>(AName)` | Alias for `Value<T>` |
| `GetOr<T>(AName, ADefault)` | Returns the variable or `ADefault` if not found |
| `TryGet<T>(AName, out AValue)` | Non-raising lookup; returns `False` if not found |
| `Count` | Number of variables loaded |
| `EnvCreate(AName, AValue)` | Creates a system environment variable |
| `EnvLoad(AName)` | Reads a system environment variable |
| `EnvUpdate(AName, AValue)` | Updates a system environment variable |
| `EnvDelete(AName)` | Deletes a system environment variable |
| `Items[AName]` | Default property; read/write access as `TValue` |
| `UseSystemFallback` | Property; if `True`, falls back to system env vars when key is missing |
