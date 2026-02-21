{
                          Apache License
                      Version 2.0, January 2004
                   http://www.apache.org/licenses/

       Licensed under the Apache License, Version 2.0 (the "License");
       you may not use this file except in compliance with the License.
       You may obtain a copy of the License at

             http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing, software
       distributed under the License is distributed on an "AS IS" BASIS,
       WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
       See the License for the specific language governing permissions and
       limitations under the License.
}

{
  @abstract(Evolution4D: Modern Delphi Development Library for Delphi)
  @description(Evolution4D brings modern, fluent, and expressive syntax to Delphi, making code cleaner and development more productive.)
  @created(03 Abr 2025)
  @author(Isaque Pinheiro <isaquepsp@gmail.com>)
  @Discord(https://discord.gg/T2zJC8zX)
}

unit Evolution.Option;

interface

uses
  Rtti,
  SysUtils,
  Variants,
  Evolution.ResultPair;

type
  TSomeProc<T> = reference to procedure(const AValue: T);
  TNoneProc = reference to procedure;

  TSome = record
  private
    FValue: TValue;
  public
    constructor Create(const AValue: string);
    class operator Implicit(const AValue: Integer): TSome;
    class operator Implicit(const AValue: string): TSome;
    class operator Implicit(const AValue: Boolean): TSome;
    property Value: TValue read FValue;
  end;

  TNone = record
  private
    FMessage: TValue;
  public
    constructor Create(const AValue: string);
    class operator Implicit(const AMessage: string): TNone;
    property Message: TValue read FMessage;
  end;

  TOption<T> = record
  private
    FHasValue: Boolean;
    FValue: T;
    /// <summary>
    /// Gets the value if present, otherwise raises an exception.
    /// </summary>
    /// <returns>The stored value of type T.</returns>
    function GetValue: T;
  public
    type
      TOptionAndThen<A> = reference to function(const Value: T): TOption<A>;
      TOptionOrElse<O> = reference to function: TOption<O>;
      TSomeFunc<T, R> = reference to function(const AValue: T): R;
      TNoneFunc<R> = reference to function: R;
  public
    /// <summary>
    /// Creates a TOption with a value.
    /// </summary>
    /// <param name="AValue">The value to store.</param>
    /// <returns>A TOption containing the specified value.</returns>
    class function Some(const AValue: T): TOption<T>; static;

    /// <summary>
    /// Creates an empty TOption.
    /// </summary>
    /// <returns>A TOption with no value.</returns>
    class function None: TOption<T>; static;

    /// <summary>
    /// Combines two TOption<Variant> into a single TOption<Variant> containing a pair.
    /// </summary>
    /// <param name="This">The first TOption.</param>
    /// <param name="Other">The second TOption.</param>
    /// <returns>A TOption with a Variant array if both have values, otherwise None.</returns>
    class function Zip(const AThis: TOption<Variant>; const AOther: TOption<Variant>): TOption<Variant>; static;

    /// <summary>
    /// Checks if the TOption contains a value.
    /// </summary>
    /// <returns>True if it has a value, False otherwise.</returns>
    function IsSome: Boolean;

    /// <summary>
    /// Checks if the TOption is empty.
    /// </summary>
    /// <returns>True if it has no value, False otherwise.</returns>
    function IsNone: Boolean;

    /// <summary>
    /// Checks if the TOption has a value that satisfies the predicate.
    /// </summary>
    /// <param name="APredicate">The condition to test the value.</param>
    /// <returns>True if it has a value and the predicate passes, False otherwise.</returns>
    function IsSomeAnd(const APredicate: TFunc<T, Boolean>): Boolean;

    /// <summary>
    /// Checks if the TOption contains a specific value.
    /// </summary>
    /// <param name="AValue">The value to compare.</param>
    /// <param name="AComparer">Optional custom comparer; uses default if nil.</param>
    /// <returns>True if the value matches, False otherwise.</returns>
    function Contains(const AValue: T; const AComparer: TFunc<T, T, Boolean> = nil): Boolean;

    /// <summary>
    /// Extracts the value, raising an exception if None.
    /// </summary>
    /// <returns>The stored value.</returns>
    function Unwrap: T;

    /// <summary>
    /// Extracts the value or returns a default if None.
    /// </summary>
    /// <param name="ADefault">The default value if None.</param>
    /// <returns>The stored value or the default.</returns>
    function UnwrapOr(const ADefault: T): T;

    /// <summary>
    /// Extracts the value or computes a default if None.
    /// </summary>
    /// <param name="ADefaultFunc">Function to compute the default value.</param>
    /// <returns>The stored value or the computed default.</returns>
    function UnwrapOrElse(const ADefaultFunc: TFunc<T>): T;

    /// <summary>
    /// Extracts the value or returns the type's default if None.
    /// </summary>
    /// <returns>The stored value or the type's default (e.g., 0, nil).</returns>
    function UnwrapOrDefault: T;

    /// <summary>
    /// Extracts the value or raises an exception with a custom message if None.
    /// </summary>
    /// <param name="AMessage">The exception message if None.</param>
    /// <returns>The stored value.</returns>
    function Expect(const AMessage: string): T;

    /// <summary>
    /// Transforms the value using a function, returning a new TOption.
    /// </summary>
    /// <typeparam name="U">The type of the transformed value.</typeparam>
    /// <param name="AFunc">The transformation function.</param>
    /// <returns>A new TOption with the transformed value, or None if empty.</returns>
    function Map<U>(const AFunc: TFunc<T, U>): TOption<U>;

    /// <summary>
    /// Filters the value based on a predicate.
    /// </summary>
    /// <param name="APredicate">The condition to filter the value.</param>
    /// <returns>The current TOption if the predicate passes, None otherwise.</returns>
    function Filter(const APredicate: TFunc<T, Boolean>): TOption<T>;

    /// <summary>
    /// Applies a function that returns another TOption.
    /// </summary>
    /// <typeparam name="U">The type of the resulting TOption.</typeparam>
    /// <param name="AFunc">The function returning a TOption.</param>
    /// <returns>The result of the function if Some, None otherwise.</returns>
    function AndThen<U>(const AFunc: TOptionAndThen<U>): TOption<U>;

    /// <summary>
    /// Returns the current value or an alternative if None.
    /// </summary>
    /// <param name="AAlternative">The alternative TOption if None.</param>
    /// <returns>The current TOption if Some, the alternative if None.</returns>
    function Otherwise(const AAlternative: TOption<T>): TOption<T>;

    /// <summary>
    /// Returns the current value or computes an alternative if None.
    /// </summary>
    /// <param name="AAlternativeFunc">Function to compute the alternative.</param>
    /// <returns>The current TOption if Some, the computed alternative if None.</returns>
    function OrElse(const AAlternativeFunc: TOptionOrElse<T>): TOption<T>;

    /// <summary>
    /// Converts the TOption to a TResultPair with a failure value if None.
    /// </summary>
    /// <typeparam name="F">The type of the failure value.</typeparam>
    /// <param name="AFailure">The failure value if None.</param>
    /// <returns>A TResultPair with the value if Some, or the failure if None.</returns>
    function OkOr<F>(const AFailure: F): TResultPair<T, F>;

    /// <summary>
    /// Executes an action based on the TOption state.
    /// </summary>
    /// <param name="ASomeProc">Action to run if Some.</param>
    /// <param name="ANoneProc">Action to run if None.</param>
    procedure Match(const ASomeProc: TSomeProc<T>; const ANoneProc: TNoneProc); overload;

    /// <summary>
    /// Returns the value from ASome if Some, or the message from ANone if None.
    /// </summary>
    /// <param name="ASome">The Some case, containing the value to return.</param>
    /// <param name="ANone">The None case, containing the message to return.</param>
    /// <returns>The value from ASome if Some, or the message from ANone if None.</returns>
    function Match<R>(const ASome: TSome; const ANone: TNone): R; overload;

    /// <summary>
    /// Executes an action if the TOption contains a value.
    /// </summary>
    /// <param name="AAction">Action to run if Some.</param>
    procedure IfSome(const AAction: TSomeProc<T>);

    /// <summary>
    /// Extracts the value and sets the original to None.
    /// </summary>
    /// <param name="ASelf">The TOption to modify.</param>
    /// <returns>The extracted TOption, or None if already empty.</returns>
    function Take(var ASelf: TOption<T>): TOption<T>;

    /// <summary>
    /// Flattens a nested TOption<TOption<U>> into TOption<U>.
    /// </summary>
    /// <typeparam name="U">The inner type to flatten to.</typeparam>
    /// <returns>The flattened TOption<U>, or None if empty.</returns>
    function Flatten<U>: TOption<U>;

    /// <summary>
    /// Replaces the current value with a new one, returning the old value.
    /// </summary>
    /// <param name="ASelf">The TOption to modify.</param>
    /// <param name="ANewValue">The new value to set.</param>
    /// <returns>The previous TOption value.</returns>
    function Replace(var ASelf: TOption<T>; const ANewValue: T): TOption<T>;

    function AsString: String; inline;

    /// <summary>
    /// Provides read-only access to the stored value.
    /// </summary>
    property Value: T read GetValue;
  end;

implementation

{ TOption<T> }

class function TOption<T>.Some(const AValue: T): TOption<T>;
begin
  Result.FHasValue := True;
  Result.FValue := AValue;
end;

class function TOption<T>.None: TOption<T>;
begin
  Result.FHasValue := False;
end;

function TOption<T>.IsSome: Boolean;
begin
  Result := FHasValue;
end;

function TOption<T>.IsNone: Boolean;
begin
  Result := not FHasValue;
end;

function TOption<T>.IsSomeAnd(const APredicate: TFunc<T, Boolean>): Boolean;
begin
  Result := FHasValue and APredicate(FValue);
end;

function TOption<T>.AsString: String;
begin
  Result := TValue.From<T>(FValue).ToString;
end;

function TOption<T>.Contains(const AValue: T; const AComparer: TFunc<T, T, Boolean>): Boolean;
begin
  if not FHasValue then
    Result := False
  else if Assigned(AComparer) then
    Result := AComparer(FValue, AValue)
  else
    Result := (SizeOf(T) <= SizeOf(Pointer)) and (CompareMem(@FValue, @AValue, SizeOf(T)));
end;

function TOption<T>.GetValue: T;
begin
  if not FHasValue then
    raise Exception.Create('Attempted to access a value from TOption.None');
  Result := FValue;
end;

function TOption<T>.Unwrap: T;
begin
  Result := GetValue;
end;

function TOption<T>.UnwrapOr(const ADefault: T): T;
begin
  if FHasValue then
    Result := FValue
  else
    Result := ADefault;
end;

function TOption<T>.UnwrapOrElse(const ADefaultFunc: TFunc<T>): T;
begin
  if FHasValue then
    Result := FValue
  else
    Result := ADefaultFunc();
end;

class function TOption<T>.Zip(const AThis, AOther: TOption<Variant>): TOption<Variant>;
var
  LPair: Variant;
begin
  if AThis.IsSome and AOther.IsSome then
  begin
    LPair := VarArrayCreate([0, 1], varVariant);
    LPair[0] := AThis.Unwrap;
    LPair[1] := AOther.Unwrap;
    Result := TOption<Variant>.Some(LPair);
  end
  else
    Result := TOption<Variant>.None;
end;

function TOption<T>.UnwrapOrDefault: T;
var
  LDefault: T;
begin
  if FHasValue then
    Result := FValue
  else
  begin
    FillChar(LDefault, SizeOf(T), 0);
    Result := LDefault;
  end;
end;

function TOption<T>.Expect(const AMessage: string): T;
begin
  if not FHasValue then
    raise Exception.Create(AMessage);
  Result := FValue;
end;

function TOption<T>.Map<U>(const AFunc: TFunc<T, U>): TOption<U>;
begin
  if FHasValue then
    Result := TOption<U>.Some(AFunc(FValue))
  else
    Result := TOption<U>.None;
end;

function TOption<T>.Filter(const APredicate: TFunc<T, Boolean>): TOption<T>;
begin
  if FHasValue and APredicate(FValue) then
    Result := Self
  else
    Result := TOption<T>.None;
end;

function TOption<T>.AndThen<U>(const AFunc: TOptionAndThen<U>): TOption<U>;
begin
  if FHasValue then
    Result := AFunc(FValue)
  else
    Result := TOption<U>.None;
end;

function TOption<T>.Otherwise(const AAlternative: TOption<T>): TOption<T>;
begin
  if FHasValue then
    Result := Self
  else
    Result := AAlternative;
end;

function TOption<T>.OrElse(const AAlternativeFunc: TOptionOrElse<T>): TOption<T>;
begin
  if FHasValue then
    Result := Self
  else
    Result := AAlternativeFunc();
end;

function TOption<T>.OkOr<F>(const AFailure: F): TResultPair<T, F>;
begin
  if FHasValue then
    Result := TResultPair<T, F>.Success(FValue)
  else
    Result := TResultPair<T, F>.Failure(AFailure);
end;

procedure TOption<T>.Match(const ASomeProc: TSomeProc<T>; const ANoneProc: TNoneProc);
begin
  if FHasValue then
    ASomeProc(FValue)
  else
    ANoneProc();
end;

function TOption<T>.Match<R>(const ASome: TSome; const ANone: TNone): R;
begin
  if FHasValue then
    Result := ASome.Value.AsType<R>
  else
    Result := ANone.Message.AsType<R>;
end;

procedure TOption<T>.IfSome(const AAction: TSomeProc<T>);
begin
  if FHasValue then
    AAction(FValue);
end;

function TOption<T>.Take(var ASelf: TOption<T>): TOption<T>;
begin
  if ASelf.FHasValue then
  begin
    Result := TOption<T>.Some(ASelf.FValue);
    ASelf.FHasValue := False;
  end
  else
    Result := TOption<T>.None;
end;

function TOption<T>.Flatten<U>: TOption<U>;
var
  LInner: TValue;
begin
  if FHasValue then
  begin
    LInner := TValue.From<T>(FValue);
    if LInner.IsType<TOption<U>> then
      Result := LInner.AsType<TOption<U>>
    else
      raise Exception.Create('Flatten só pode ser usado quando T é TOption<U>');
  end
  else
    Result := TOption<U>.None;
end;

function TOption<T>.Replace(var ASelf: TOption<T>; const ANewValue: T): TOption<T>;
begin
  Result := ASelf;
  ASelf := TOption<T>.Some(ANewValue);
end;

{ Some }

class operator TSome.Implicit(const AValue: Integer): TSome;
begin
  Result.FValue := TValue.From<Integer>(AValue);
end;

class operator TSome.Implicit(const AValue: string): TSome;
begin
  Result.FValue := TValue.From<string>(AValue);
end;

constructor TSome.Create(const AValue: string);
begin
  FValue := AValue;
end;

class operator TSome.Implicit(const AValue: Boolean): TSome;
begin
  Result.FValue := TValue.From<Boolean>(AValue);
end;

constructor TNone.Create(const AValue: string);
begin
  FMessage := AValue;
end;

{ None }

class operator TNone.Implicit(const AMessage: string): TNone;
begin
  Result.FMessage := AMessage;
end;

end.



