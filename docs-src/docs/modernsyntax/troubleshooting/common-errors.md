---
displayed_sidebar: modernsyntaxSidebar
title: Common Errors
sidebar_position: 0
---

# Common Errors

## Access Violation when calling `TOption<T>.Value`

**Cause:** `Value` (and `Unwrap`) raise `Exception.Create('Attempted to access a value from TOption.None')` when the option is empty.

**Fix:** Always guard with `IsSome` or use a safe extractor:

```delphi
// Bad — may raise
WriteLn(LName.Value);

// Good
if LName.IsSome then
  WriteLn(LName.Value);

// Better — safe default
WriteLn(LName.UnwrapOr('(no name)'));
```

---

## `TMatch<T>.Execute` returns `IsFailure` with "Use Execute after session..."

**Cause:** `Execute` was called before any case builder (`CaseEq`, `CaseGt`, etc.) or `Default`. The match session is still in `sMatch` state.

**Fix:** Add at least one case or a `Default` before calling `Execute`:

```delphi
// Bad
TMatch<Integer>.Value(LValue).Execute;

// Good
TMatch<Integer>.Value(LValue)
  .CaseGt(0, procedure begin WriteLn('Positive'); end)
  .Default(procedure begin WriteLn('Zero or negative'); end)
  .Execute;
```

---

## `TMatch<T>.Execute` returns `IsFailure` with "No matching case found."

**Cause:** The input value did not match any registered case and no `Default` was provided.

**Fix:** Always add a `Default` at the end of each match:

```delphi
TMatch<string>.Value(LStatus)
  .CaseEq('active',   procedure begin { ... } end)
  .CaseEq('inactive', procedure begin { ... } end)
  .Default(procedure begin WriteLn('Unknown: ' + LStatus); end)  // required
  .Execute;
```

---

## `TResultPair<S,F>` — accessing `ValueSuccess` on a failure result

**Cause:** `ValueSuccess` on a `Failure` result is implementation-defined (may return default or raise).

**Fix:** Always check `IsSuccess` or `IsFailure` first:

```delphi
var LResult: TResultPair<Integer, string>;
begin
  LResult := ParseInt('abc');
  // Bad
  WriteLn(LResult.ValueSuccess);  // undefined if failure

  // Good
  if LResult.IsSuccess then
    WriteLn(LResult.ValueSuccess)
  else
    WriteLn('Error: ', LResult.ValueFailure);
end;
```

---

## `TSafeTry.End` returns `IsErr` even though no exception was raised

**Cause:** The `Try(AProc)` overload with `nil` will do nothing. Ensure a non-nil proc or func is passed.

**Fix:**

```delphi
// Bad — nil proc
LResult := TSafeTry.Try(nil).End;

// Good
LResult := TSafeTry.Try(procedure begin DoWork; end).End;
```

---

## `TAsync.Await` hangs indefinitely

**Cause:** The background task never completes, or a timeout was not set.

**Fix:** Pass an explicit timeout in milliseconds:

```delphi
LFuture := Async(procedure begin LongWork; end).Await(5000); // 5 s timeout
if LFuture.IsErr then
  WriteLn('Timed out or failed: ', LFuture.Err);
```

---

## `Flatten<U>` raises "Flatten só pode ser usado quando T é `TOption<U>`"

**Cause:** `Flatten<U>` is only valid when `T` is itself a `TOption<U>`. The inner type must be accessible via RTTI.

**Fix:** Use `Flatten<U>` only on `TOption<TOption<U>>`:

```delphi
var
  LNested: TOption<TOption<string>>;
  LFlat  : TOption<string>;
begin
  LNested := TOption<TOption<string>>.Some(TOption<string>.Some('hello'));
  LFlat   := LNested.Flatten<string>;
end;
```

---

## Linux64 compile error: `OutputDebugString` not found

**Cause:** The Linux target does not have `Windows` unit; `OutputDebugString` is Windows-only.

**Fix:** This is already handled by `{$IFDEF MSWINDOWS}` guards in ModernSyntax source. If you see this error, ensure you are using the version from the official repository and not a patched or partial copy.

---

## `TDotEnv` — key not found, returns empty TValue

**Cause:** Either the key is missing from the `.env` file or `AUseSystemFallback` is `False` and the key is not in the OS environment.

**Fix:**

```delphi
var LEnv: TDotEnv;
begin
  LEnv := TDotEnv.Create('.env', True);  // fallback to OS env
  try
    var LValue := LEnv['DATABASE_URL'];
    if LValue.IsEmpty then
      raise Exception.Create('DATABASE_URL is not set');
  finally
    LEnv.Free;
  end;
end;
```
