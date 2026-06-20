---
displayed_sidebar: modernsyntaxSidebar
title: Quick Start
sidebar_position: 1
---

# Quick Start

This page shows the three most common patterns. Each example compiles in isolation — add the corresponding unit to your `uses` clause.

## 1. Null Safety with `TOption<T>`

```delphi
uses
  ModernSyntax.Option;

var
  LName: TOption<string>;
begin
  // Wrap a value in Some
  LName := TOption<string>.Some('Isaque');

  if LName.IsSome then
    WriteLn('Value: ' + LName.Value)
  else
    WriteLn('No value found.');

  // Safe default fallback (never raises)
  WriteLn(LName.UnwrapOr('Default Name'));

  // Chain transformations
  LName
    .Map<string>(function(const S: string): string begin Result := S.ToUpper; end)
    .IfSome(procedure(const S: string) begin WriteLn(S); end);

  // Empty option
  LName := TOption<string>.None;
  WriteLn(LName.UnwrapOrDefault); // empty string — no exception
end;
```

## 2. Pattern Matching with `TMatch<T>`

```delphi
uses
  ModernSyntax.Match;

var
  LScore: Integer;
begin
  LScore := 85;

  TMatch<Integer>.Value(LScore)
    .CaseRange(90, 100, procedure begin WriteLn('A — Excellent'); end)
    .CaseRange(75, 89,  procedure begin WriteLn('B — Good'); end)
    .CaseRange(60, 74,  procedure begin WriteLn('C — Satisfactory'); end)
    .Default(procedure begin WriteLn('F — Needs improvement'); end)
    .Execute;
  // Prints: B — Good
end;
```

Equality matching with a result value:

```delphi
var
  LInput: Integer;
  LResult: TResultPair<TValue, string>;
begin
  LInput := 2;

  LResult := TMatch<Integer>.Value(LInput)
    .CaseEq(1, function(const V: Integer): TValue begin Result := TValue.From('First!'); end)
    .CaseEq(2, function(const V: Integer): TValue begin Result := TValue.From('Second!'); end)
    .CaseEq(3, function(const V: Integer): TValue begin Result := TValue.From('Third!'); end)
    .Default(function(const V: Integer): TValue begin Result := TValue.From('Other'); end)
    .Execute<TValue>;

  if LResult.IsSuccess then
    WriteLn(LResult.ValueSuccess.AsString);
  // Prints: Second!
end;
```

## 3. Railway Results with `TResultPair<S,F>`

```delphi
uses
  ModernSyntax.ResultPair;

function Divide(const A, B: Double): TResultPair<Double, string>;
begin
  if B = 0 then
    Result := TResultPair<Double, string>.Failure('Division by zero!')
  else
    Result := TResultPair<Double, string>.Success(A / B);
end;

var
  LResult: TResultPair<Double, string>;
begin
  LResult := Divide(10, 2);

  if LResult.IsSuccess then
    WriteLn('Result: ', LResult.ValueSuccess:0:2)
  else
    WriteLn('Error: ', LResult.ValueFailure);
end;
```

## 4. Async task with `TAsync`

```delphi
uses
  ModernSyntax.Async;

var
  LFuture: TFuture;
begin
  LFuture := Async(procedure
    begin
      Sleep(500);
      WriteLn('Background work done');
    end).Await;

  if LFuture.IsOk then
    WriteLn('Task completed successfully')
  else
    WriteLn('Task failed: ', LFuture.Err);
end;
```

## Next steps

- [Null Safety guide](../guides/null-safety.md) — full `TOption<T>` API
- [Pattern Matching guide](../guides/pattern-matching.md) — all `TMatch<T>` case types
- [Railway Results guide](../guides/railway-results.md) — `TResultPair<S,F>` combinators
- [Functional Helpers guide](../guides/functional-helpers.md) — `TSafeTry`, `TTuple`, `TCurrying`
