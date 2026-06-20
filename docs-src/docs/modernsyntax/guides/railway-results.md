---
displayed_sidebar: modernsyntaxSidebar
title: Railway Results — TResultPair
sidebar_position: 2
---

# Railway Results — `TResultPair<S, F>`

**Unit:** `ModernSyntax.ResultPair`

`TResultPair<S, F>` implements the **Railway-Oriented Programming** pattern: every operation that can fail returns either a **Success** (`S`) or a **Failure** (`F`), making the error path explicit in the type signature and impossible to silently ignore.

## Core concept

```
Input → [Operation] → Success(S)
                    ↘ Failure(F)
```

The caller must explicitly branch on `IsSuccess` / `IsFailure` before accessing the inner value. There is no "current exception" hidden state.

## Creating results

```delphi
uses ModernSyntax.ResultPair;

function ParseInt(const AText: string): TResultPair<Integer, string>;
begin
  var LValue: Integer;
  if TryStrToInt(AText, LValue) then
    Result := TResultPair<Integer, string>.Success(LValue)
  else
    Result := TResultPair<Integer, string>.Failure('Not a valid integer: ' + AText);
end;
```

## Inspecting results

| Method / Property | Description |
|---|---|
| `IsSuccess` | `True` when the result holds a success value |
| `IsFailure` | `True` when the result holds a failure value |
| `ValueSuccess` | Returns the success value; behaviour when Failure is implementation-defined |
| `ValueFailure` | Returns the failure value; behaviour when Success is implementation-defined |

```delphi
var LResult: TResultPair<Integer, string>;
begin
  LResult := ParseInt('42');
  if LResult.IsSuccess then
    WriteLn('Parsed: ', LResult.ValueSuccess)
  else
    WriteLn('Error: ', LResult.ValueFailure);
end;
```

## Chaining operations

`TResultPair<S, F>` supports chaining: register callbacks that are called only if the current state matches.

```delphi
// ThenOf queues a success handler; ExceptOf queues a failure handler.
// Call Return to drain the queues.
LResult
  .ThenOf(function(const ASuccess: Integer): TResultPair<Integer, string>
    begin
      Result := TResultPair<Integer, string>.Success(ASuccess * 2);
    end)
  .ExceptOf(function(const AFailure: string): TResultPair<Integer, string>
    begin
      WriteLn('Handling error: ', AFailure);
      Result := TResultPair<Integer, string>.Failure(AFailure);
    end)
  .Return;
```

For immediate (non-queued) side-effect callbacks use `Ok(ASuccessProc)` and `Fail(AFailureProc)` — these execute the proc right away without touching the queue.

## Exception wrappers

`TResultPair` includes exception types for converting between exception-based and result-based code:

| Type | Description |
|---|---|
| `EFailureException<F>` | Raised by internal machinery when a failure must propagate as an exception |
| `ESuccessException<S>` | Raised when a success value must propagate as an exception |
| `ETypeIncompatibility` | Raised on RTTI type mismatch in map/bind operations |

## TResultType enumeration

Internal state is tracked by `TResultType`:

| Value | Meaning |
|---|---|
| `rtNone` | Initial/uninitialized state |
| `rtSuccess` | Result holds a success value |
| `rtFailure` | Result holds a failure value |

## Converting from TOption

`TOption<T>.OkOr<F>(AFailure)` converts an option to a result:

```delphi
uses ModernSyntax.Option, ModernSyntax.ResultPair;

var
  LName  : TOption<string>;
  LResult: TResultPair<string, string>;
begin
  LName   := TOption<string>.None;
  LResult := LName.OkOr<string>('Name was not provided');
  // LResult.IsFailure = True; LResult.ValueFailure = 'Name was not provided'
end;
```

## Using with TMatch

`TMatch<T>.Execute<R>` and `TMatch<T>.Execute` both return `TResultPair`:

```delphi
var LMatchResult: TResultPair<Boolean, string>;
begin
  LMatchResult := TMatch<Integer>.Value(LValue)
    .CaseGt(0, procedure begin WriteLn('Positive'); end)
    .Execute;

  if LMatchResult.IsFailure then
    WriteLn('No case matched: ', LMatchResult.ValueFailure);
end;
```

## TFuture (async results)

Async operations (`TAsync.Await`, `TAsync.Run`, `TAsync.NoAwait`) return `TFuture` — a lightweight analog to `TResultPair` for background tasks:

| Method | Description |
|---|---|
| `IsOk` | True when the task completed successfully |
| `IsErr` | True when the task raised an exception |
| `Ok<T>` | Returns the typed result value |
| `Err` | Returns the error message string |

```delphi
uses ModernSyntax.Async;

var LFuture: TFuture;
begin
  LFuture := Async(function: TValue
    begin
      Result := TValue.From<Integer>(42);
    end).Await;

  if LFuture.IsOk then
    WriteLn('Result: ', LFuture.Ok<Integer>)
  else
    WriteLn('Error: ', LFuture.Err);
end;
```
