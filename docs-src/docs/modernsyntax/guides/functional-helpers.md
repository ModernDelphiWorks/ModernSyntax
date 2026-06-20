---
displayed_sidebar: modernsyntaxSidebar
title: Functional Helpers
sidebar_position: 3
---

# Functional Helpers

This page documents the supporting functional utilities in ModernSyntax beyond the three pillars (`TOption`, `TResultPair`, `TMatch`).

---

## Safe Try — `TSafeTry` / `TSafeResult`

**Unit:** `ModernSyntax.SafeTry`

`TSafeTry` wraps a Delphi `try-except-finally` block in a fluent, functional style. The result is a `TSafeResult` record that carries either a value or an error message — never throws.

### Creating a safe try

```delphi
uses ModernSyntax.SafeTry;

var
  LResult: TSafeResult;
begin
  LResult := TSafeTry.Try(function: TValue
    begin
      Result := TValue.From<Integer>(10 div 2);
    end)
    .Except(procedure(E: Exception) begin WriteLn('Caught: ', E.Message); end)
    .Finally(procedure begin WriteLn('Always runs'); end)
    .End;

  if LResult.IsOk then
    WriteLn('Value: ', LResult.GetValue.AsInteger)
  else
    WriteLn('Error: ', LResult.ExceptionMessage);
end;
```

The global `Try()` function is also available:

```delphi
LResult := &Try(procedure begin DoRiskyWork; end)
              .Except(procedure(E: Exception) begin { handle } end)
              .End;
```

### `TSafeResult` API

| Method | Description |
|---|---|
| `IsOk` | `True` if no exception was raised |
| `IsErr` | `True` if an exception was caught |
| `GetValue` | Returns the `TValue` result |
| `TryGetValue(out AValue)` | Non-raising value extraction |
| `ExceptionMessage` | The captured exception message |
| `AsType<T>` | Casts the result value to `T` |
| `IsType<T>` | Tests whether the result is type `T` |

---

## Tuples — `TTuple` and `TTuple<K>`

**Unit:** `ModernSyntax.Tuple`

### `TTuple` (positional, `array of TValue`)

A lightweight anonymous record indexed by position:

```delphi
uses ModernSyntax.Tuple;

var
  LTuple: TTuple;
begin
  LTuple := TTuple.New([TValue.From(1), TValue.From('hello'), TValue.From(True)]);
  WriteLn(LTuple.Get<Integer>(0));  // 1
  WriteLn(LTuple.Get<string>(1));   // hello
  WriteLn(LTuple.Get<Boolean>(2));  // True
end;
```

Wildcard matching in `TMatch<T>.CaseEq`:
- `'_'` matches any single element
- `'_*'` matches any trailing elements

### `TTuple<K>` (keyed dictionary tuple)

```delphi
var LT: TTuple<string>;
begin
  LT := TTuple<string>.New(
    ['name', 'age'],
    [TValue.From('Ana'), TValue.From(30)]
  );
  WriteLn(LT.Get<string>('name'));    // Ana
  WriteLn(LT.Get<Integer>('age'));    // 30
end;
```

| Method | Description |
|---|---|
| `New(AKeys, AValues)` | Creates a keyed tuple |
| `Get<T>(AKey)` | Returns value cast to T |
| `TryGet<T>(AKey, out AValue)` | Non-raising lookup |
| `Count` | Number of entries |
| `SetTuple(AKeys, AValues)` | Replaces all entries |

---

## Currying — `TCurrying`

**Unit:** `ModernSyntax.Currying`

`TCurrying` brings partial function application to Delphi. It also exposes a `INumeric<T>` interface for type-safe numeric operations.

### `INumeric<T>` operations

| Method | Description |
|---|---|
| `Add(Value)` | Adds `Value` to current |
| `Subtract(Value)` | Subtracts `Value` |
| `Multiply(Value)` | Multiplies by `Value` |
| `Divide(Value)` | Divides by `Value` |
| `Power(Value)` | Raises to `Value` |
| `Modulus(Value)` | Computes modulus |

The actual `Curry` class method signature is:

```delphi
class function Curry<T, U, V>(F: TFunc<T, U, V>): TFunc<T, TFunc<U, V>>;
```

It transforms a binary function `(T, U) → V` into a curried form `T → (U → V)`.
The companion `UnCurry<T, U, V>` reverses the transformation.

See the `Examples/CurryingDemo.dpr` project in the repository for live usage.

---

## Async — `TAsync` / `Async()`

**Unit:** `ModernSyntax.Async`

`TAsync` wraps Delphi's `TTask` (from `System.Threading`) in a functional interface. The global `Async()` function is the entry point.

### Creating async tasks

```delphi
uses ModernSyntax.Async;

// From a procedure
var LTask: TAsync := Async(procedure begin DoWork; end);

// From a function returning TValue
var LTask2: TAsync := Async(function: TValue begin Result := TValue.From(42); end);
```

### `TAsync` methods

| Method | Description |
|---|---|
| `Await(ATimeout?)` | Waits for the task; returns `TFuture` |
| `Await(AContinue, ATimeout?)` | Waits then runs a continuation proc |
| `Run` | Starts task; returns `TFuture` immediately |
| `Run(AError)` | Starts with an error handler func |
| `NoAwait` | Fire-and-forget; returns `TFuture` |
| `NoAwait(AError)` | Fire-and-forget with error handler |
| `Status` | Returns `TTaskStatus` |
| `GetId` | Returns task integer ID |
| `Cancel` | Cancels the task |
| `CheckCanceled` | Raises if task was canceled |

---

## DotEnv — `TDotEnv`

**Unit:** `ModernSyntax.DotEnv`

Loads environment variables from a `.env` file into the process environment. Cross-platform: uses `SetEnvironmentVariable` on Windows and `setenv`/`unsetenv` (via `Posix.Stdlib`) on Linux/macOS.

```delphi
uses ModernSyntax.DotEnv;

var LEnv: TDotEnv;
begin
  LEnv := TDotEnv.Create('.env', {AUseSystemFallback=}True);
  try
    WriteLn(LEnv['DATABASE_URL']);
  finally
    LEnv.Free;
  end;
end;
```

Constructor parameters:

| Parameter | Default | Description |
|---|---|---|
| `AFileName` | `'.env'` | Path to the `.env` file |
| `AUseSystemFallback` | `True` | Fall back to OS env vars when key not in file |
