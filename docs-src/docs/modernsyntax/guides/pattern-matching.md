---
displayed_sidebar: modernsyntaxSidebar
title: Pattern Matching — TMatch
sidebar_position: 1
---

# Pattern Matching — `TMatch<T>`

**Unit:** `ModernSyntax.Match`

`TMatch<T>` is a fluent, composable pattern-matching record for Delphi. It replaces nested `if-else` chains and limited `case` statements with expressive, type-safe branches that can produce side effects (`TProc`) or return values (`TFunc<TValue>`).

## Entry point

```delphi
uses ModernSyntax.Match;

TMatch<Integer>.Value(LScore)
  // ... add cases ...
  .Execute;
```

`TMatch<T>.Value(AValue)` starts a match session on `AValue`. The static method is the canonical constructor (the `Create` constructor is also accessible but `Value` is preferred for readability).

## Case types

### `CaseEq` — equality

```delphi
TMatch<string>.Value(LStatus)
  .CaseEq('active',   procedure begin WriteLn('Active'); end)
  .CaseEq('inactive', procedure begin WriteLn('Inactive'); end)
  .Default(procedure begin WriteLn('Unknown status'); end)
  .Execute;
```

### `CaseGt` / `CaseLt` — comparison

```delphi
TMatch<Integer>.Value(LAge)
  .CaseLt(18, procedure begin WriteLn('Minor'); end)
  .CaseGt(64, procedure begin WriteLn('Senior'); end)
  .Default(procedure begin WriteLn('Adult'); end)
  .Execute;
```

### `CaseRange` — inclusive range

```delphi
TMatch<Integer>.Value(LScore)
  .CaseRange(90, 100, procedure begin WriteLn('A'); end)
  .CaseRange(75, 89,  procedure begin WriteLn('B'); end)
  .CaseRange(60, 74,  procedure begin WriteLn('C'); end)
  .Default(procedure begin WriteLn('F'); end)
  .Execute;
```

### `CaseIn` — set/array membership

```delphi
// Array membership
TMatch<string>.Value(LDay)
  .CaseIn(['Saturday', 'Sunday'], procedure begin WriteLn('Weekend'); end)
  .Default(procedure begin WriteLn('Weekday'); end)
  .Execute;

// Char set
TMatch<Char>.Value(LChar)
  .CaseIn(['a', 'e', 'i', 'o', 'u'], procedure begin WriteLn('Vowel'); end)
  .Default(procedure begin WriteLn('Consonant'); end)
  .Execute;
```

`CaseIn` also accepts `TSysCharSet` and `TIntegerSet` overloads.

### `CaseIs` — type dispatch

Matches based on the runtime type kind of `T`. Useful for `TObject` hierarchies or variant values:

```delphi
TMatch<TValue>.Value(LValue)
  .CaseIs<Integer>(procedure(const V: Integer) begin WriteLn('Integer: ', V); end)
  .CaseIs<string>(procedure(const V: string)  begin WriteLn('String: ', V);  end)
  .Default(procedure begin WriteLn('Other type'); end)
  .Execute;
```

`TDateTime` is special-cased to `tkFloat` internally.

### `CaseIf` — conditional guard

Guards run before the case evaluation. A guard that evaluates to `False` skips the entire match block:

```delphi
TMatch<Integer>.Value(LValue)
  .CaseIf(LEnabled)          // guard: skip all if not enabled
  .CaseGt(0, procedure begin WriteLn('Positive'); end)
  .Default(procedure begin WriteLn('Non-positive'); end)
  .Execute;
```

### `CaseRegex` — regular expression

```delphi
TMatch<string>.Value(LEmail)
  .CaseRegex(LEmail, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
  .Default(procedure begin WriteLn('Invalid or valid email'); end)
  .Execute;
```

`CaseRegex(AInput, APattern)` takes exactly two string arguments — the text to test and the regex pattern. It does not accept a callback; it increments an internal counter when the pattern matches (a positive count allows `Execute` to proceed). Pair it with a `Default` or other cases to handle both matched and unmatched outcomes.

Note: `CaseRegex` is implemented via `TModernRegEx.IsMatch` from `ModernSyntax.RegExpression`. The regex match increments/decrements an internal counter; a negative count means no regex matched.

## Returning a value — `Execute<R>`

When cases use `TFunc<TValue>` instead of `TProc`, call `Execute<R>` to get a typed result:

```delphi
var LResult: TResultPair<TValue, string>;
begin
  LResult := TMatch<Integer>.Value(LInput)
    .CaseEq(1, function(const V: Integer): TValue begin Result := TValue.From('One'); end)
    .CaseEq(2, function(const V: Integer): TValue begin Result := TValue.From('Two'); end)
    .Default(function(const V: Integer): TValue begin Result := TValue.From('Other'); end)
    .Execute<TValue>;

  if LResult.IsSuccess then
    WriteLn(LResult.ValueSuccess.AsString);
end;
```

`Execute` (without type parameter) returns `TResultPair<Boolean, String>` — `True` on a successful proc match.

## Combining matches

`Combine` merges two independent `TMatch<T>` instances so both are evaluated:

```delphi
var
  LMatch1, LMatch2: TMatch<Integer>;
begin
  LMatch1 := TMatch<Integer>.Value(LValue)
    .CaseGt(10, procedure begin WriteLn('>10'); end);

  LMatch2 := TMatch<Integer>.Value(LValue)
    .CaseLt(100, procedure begin WriteLn('<100'); end);

  LMatch1.Combine(LMatch2).Execute;
end;
```

## Exception handling in a match

`TryExcept` registers a fallback proc that runs if any case raises an exception:

```delphi
TMatch<Integer>.Value(LValue)
  .CaseEq(0, procedure begin raise Exception.Create('Oops'); end)
  .TryExcept(procedure begin WriteLn('Exception caught inside match'); end)
  .Execute;
```

## Session state machine

`TMatch<T>` enforces a legal call sequence through an internal `TMatchSession` state:

| State | Meaning |
|---|---|
| `sMatch` | Initial state after `Value()` |
| `sGuard` | After a `CaseIf` that evaluated to `True` |
| `sCase` | After any `CaseEq`, `CaseGt`, etc. |
| `sDefault` | After `Default()` |
| `sTryExcept` | After `TryExcept()` |

`Execute` / `Execute<R>` is only valid from `sCase`, `sDefault`, or `sTryExcept`.
