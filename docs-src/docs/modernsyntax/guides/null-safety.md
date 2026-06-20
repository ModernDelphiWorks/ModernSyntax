---
displayed_sidebar: modernsyntaxSidebar
title: Null Safety — TOption
sidebar_position: 0
---

# Null Safety — `TOption<T>`

**Unit:** `ModernSyntax.Option`

`TOption<T>` is a generic record that explicitly represents a value that may or may not be present. It replaces the Delphi pattern of returning `nil`, `0`, or empty string to signal "no value" — which is silent and easy to misuse.

## Creating options

```delphi
uses ModernSyntax.Option;

var
  LName : TOption<string>;
  LCount: TOption<Integer>;
  LEmpty: TOption<string>;
begin
  LName  := TOption<string>.Some('Isaque');   // has value
  LCount := TOption<Integer>.Some(42);
  LEmpty := TOption<string>.None;             // no value
end;
```

## Inspecting state

| Method | Returns | Description |
|---|---|---|
| `IsSome` | `Boolean` | `True` if the option has a value |
| `IsNone` | `Boolean` | `True` if the option is empty |
| `IsSomeAnd(APredicate)` | `Boolean` | `True` if has value **and** predicate passes |
| `Contains(AValue)` | `Boolean` | `True` if has value equal to `AValue` |

```delphi
if LName.IsSome then
  WriteLn('Has value');

if LName.IsSomeAnd(function(const S: string): Boolean begin Result := S.Length > 3; end) then
  WriteLn('Long name');
```

## Extracting values

| Method | Description |
|---|---|
| `Value` (property) | Returns the value; **raises** if None |
| `Unwrap` | Alias for `Value` — raises if None |
| `UnwrapOr(ADefault)` | Returns value or `ADefault` if None |
| `UnwrapOrElse(ADefaultFunc)` | Returns value or calls `ADefaultFunc()` if None |
| `UnwrapOrDefault` | Returns value or type default (0, nil, '') if None |
| `Expect(AMessage)` | Returns value; raises with `AMessage` if None |

```delphi
var S: string;
begin
  S := LName.UnwrapOr('anonymous');         // safe
  S := LName.UnwrapOrElse(function: string begin Result := GetDefaultName; end);
  S := LName.Expect('Name must be present'); // descriptive error
end;
```

## Transforming options

| Method | Returns | Description |
|---|---|---|
| `Map<U>(AFunc)` | `TOption<U>` | Applies `AFunc` to the value if Some |
| `Filter(APredicate)` | `TOption<T>` | Keeps value if predicate passes, else None |
| `AndThen<U>(AFunc)` | `TOption<U>` | Chains; `AFunc` returns `TOption<U>` (flatMap) |
| `Otherwise(AAlternative)` | `TOption<T>` | Returns self if Some, else `AAlternative` |
| `OrElse(AAlternativeFunc)` | `TOption<T>` | Returns self if Some, else calls `AAlternativeFunc` |
| `Flatten<U>` | `TOption<U>` | Unwraps `TOption<TOption<U>>` → `TOption<U>` |

```delphi
var LUpper: TOption<string>;
begin
  LUpper := LName
    .Filter(function(const S: string): Boolean begin Result := S <> ''; end)
    .Map<string>(function(const S: string): string begin Result := S.ToUpper; end);
end;
```

## Pattern matching on options

```delphi
// Procedural — run side effects
LName.Match(
  procedure(const S: string) begin WriteLn('Found: ' + S); end,
  procedure begin WriteLn('Nothing'); end
);

// Action if Some only
LName.IfSome(procedure(const S: string) begin WriteLn(S); end);
```

## Converting to TResultPair

```delphi
uses ModernSyntax.Option, ModernSyntax.ResultPair;

var LResult: TResultPair<string, string>;
begin
  LResult := LName.OkOr<string>('Name not found');
  // Success if LName.IsSome, Failure('Name not found') if None
end;
```

## Combining two options

```delphi
var
  LFirst : TOption<Variant>;
  LSecond: TOption<Variant>;
  LZipped: TOption<Variant>;
begin
  LFirst  := TOption<Variant>.Some('hello');
  LSecond := TOption<Variant>.Some(42);
  LZipped := TOption<Variant>.Zip(LFirst, LSecond);
  // LZipped.IsSome = True; value is a Variant array [0]='hello', [1]=42
end;
```

## Mutating helpers

| Method | Description |
|---|---|
| `Take(var ASelf)` | Moves value out; sets `ASelf` to None |
| `Replace(var ASelf, ANewValue)` | Swaps value; returns old option |

## Supporting types

- **`TSome`** — record wrapping a `TValue`; used for `Match<R>(ASome, ANone)` overload
- **`TNone`** — record holding an error message; used for the same overload
- **`TSomeProc<T>`** — `procedure(const AValue: T)` reference
- **`TNoneProc`** — `procedure` reference (no parameters)
