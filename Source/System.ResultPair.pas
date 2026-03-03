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

unit System.ResultPair;

interface

uses
  Rtti,
  TypInfo,
  Classes,
  SysUtils;

type
  /// <summary>
  /// Enumerator defining the possible states of a TResultPair: success or failure.
  /// </summary>
  TResultType = (rtSuccess, rtFailure);

  /// <summary>
  /// Exception raised when attempting to access a success value from a TResultPair in a failure state.
  /// </summary>
  /// <param name="F">The generic type of the failure value associated with the exception.</param>
  EFailureException<F> = class(Exception)
  public
    /// <summary>
    /// Creates an instance of the exception with the provided failure value.
    /// </summary>
    /// <param name="AValue">The failure value that triggered the exception.</param>
    constructor Create(const AValue: F);
  end;

  /// <summary>
  /// Exception raised when attempting to access a failure value from a TResultPair in a success state.
  /// </summary>
  /// <param name="S">The generic type of the success value associated with the exception.</param>
  ESuccessException<S> = class(Exception)
  public
    /// <summary>
    /// Creates an instance of the exception with the provided success value.
    /// </summary>
    /// <param name="AValue">The success value that triggered the exception.</param>
    constructor Create(const AValue: S);
  end;

  /// <summary>
  /// Exception raised when a type incompatibility occurs during operations with TResultPair.
  /// </summary>
  ETypeIncompatibility = class(Exception)
  public
    /// <summary>
    /// Creates an instance of the exception with an optional message.
    /// </summary>
    /// <param name="AMessage">A descriptive message about the incompatibility (optional).</param>
    constructor Create(const AMessage: String = '');
  end;

  /// <summary>
  /// Interface encapsulating a generic value for internal use within TResultPair.
  /// </summary>
  /// <param name="T">The generic type of the encapsulated value.</param>
  IResultPairValue<T> = interface
    ['{5E591299-AB59-45CD-8675-41F85C92436A}']
    /// <summary>
    /// Retrieves the encapsulated value.
    /// </summary>
    /// <returns>The value of type T.</returns>
    function GetValue: T;
    /// <summary>
    /// Read-only property to access the encapsulated value.
    /// </summary>
    property Value: T read GetValue;
  end;

  /// <summary>
  /// Internal class implementing IResultPairValue to store generic values in TResultPair,
  /// automatically managing the release of objects when applicable.
  /// </summary>
  /// <param name="T">The generic type of the stored value.</param>
  TResultPairValue<T> = class(TInterfacedObject, IResultPairValue<T>)
  private
    FValue: T;
    FIsObject: Boolean;
  public
    /// <summary>
    /// Creates an instance of TResultPairValue with the provided value.
    /// </summary>
    /// <param name="AValue">The value to be encapsulated.</param>
    constructor Create(AValue: T);
    /// <summary>
    /// Destructor that frees the encapsulated value if it is an object (tkClass).
    /// </summary>
    destructor Destroy; override;
    /// <summary>
    /// Retrieves the encapsulated value.
    /// </summary>
    /// <returns>The value of type T.</returns>
    function GetValue: T;
  end;

  /// <summary>
  /// Generic record representing a result pair, capable of holding either a success value (S) or a failure value (F).
  /// Inspired by patterns like Rust's Result<T, E>, it encapsulates a binary state with functional methods.
  /// </summary>
  /// <param name="S">The generic type of the success value.</param>
  /// <param name="F">The generic type of the failure value.</param>
  TResultPair<S, F> = record
  strict private
    FSuccess: IResultPairValue<S>;      // Stores the success value, if present
    FFailure: IResultPairValue<F>;      // Stores the failure value, if present
    FResultType: TResultType;           // Indicates the current state (success or failure)

    /// <summary>
    /// Sets the internal success value, clearing any existing failure value.
    /// </summary>
    /// <param name="ASuccess">The success value to be set.</param>
    procedure _SetSuccessValue(const ASuccess: S); inline;

    /// <summary>
    /// Sets the internal failure value, clearing any existing success value.
    /// </summary>
    /// <param name="AFailure">The failure value to be set.</param>
    procedure _SetFailureValue(const AFailure: F); inline;

    /// <summary>
    /// Internal constructor initializing the TResultPair with a specific state.
    /// Used by the static Success and Failure methods.
    /// </summary>
    /// <param name="AResultType">The initial state (rtSuccess or rtFailure).</param>
    constructor Create(const AResultType: TResultType);
  public
    // Implicit conversion operators

    /// <summary>
    /// Converts a TResultPair to an IResultPairValue containing the success value.
    /// </summary>
    /// <param name="V">The TResultPair to convert.</param>
    /// <returns>The encapsulated success value as IResultPairValue<S>.</returns>
    class operator Implicit(const V: TResultPair<S, F>): IResultPairValue<S>;

    /// <summary>
    /// Converts an IResultPairValue of success to a TResultPair in success state.
    /// </summary>
    /// <param name="V">The encapsulated success value.</param>
    /// <returns>A TResultPair with rtSuccess state.</returns>
    class operator Implicit(const V: IResultPairValue<S>): TResultPair<S, F>;

    /// <summary>
    /// Converts a TResultPair to an IResultPairValue containing the failure value.
    /// </summary>
    /// <param name="V">The TResultPair to convert.</param>
    /// <returns>The encapsulated failure value as IResultPairValue<F>.</returns>
    class operator Implicit(const V: TResultPair<S, F>): IResultPairValue<F>;

    /// <summary>
    /// Converts an IResultPairValue of failure to a TResultPair in failure state.
    /// </summary>
    /// <param name="V">The encapsulated failure value.</param>
    /// <returns>A TResultPair with rtFailure state.</returns>
    class operator Implicit(const V: IResultPairValue<F>): TResultPair<S, F>;

    /// <summary>
    /// Compares two TResultPair instances for equality based on their state (rtSuccess or rtFailure).
    /// </summary>
    /// <param name="Left">The first TResultPair to compare.</param>
    /// <param name="Right">The second TResultPair to compare.</param>
    /// <returns>True if both have the same state, False otherwise.</returns>
    class operator Equal(const Left, Right: TResultPair<S, F>): Boolean;

    /// <summary>
    /// Compares two TResultPair instances for inequality based on their state.
    /// </summary>
    /// <param name="Left">The first TResultPair to compare.</param>
    /// <param name="Right">The second TResultPair to compare.</param>
    /// <returns>True if the states differ, False otherwise.</returns>
    class operator NotEqual(const Left, Right: TResultPair<S, F>): Boolean;

    /// <summary>
    /// Creates a TResultPair in the success state with the provided value.
    /// </summary>
    /// <param name="ASuccess">The success value to encapsulate.</param>
    /// <returns>A new TResultPair in rtSuccess state containing ASuccess.</returns>
    class function Success(const ASuccess: S): TResultPair<S, F>; static; inline;

    /// <summary>
    /// Creates a TResultPair in the failure state with the provided value.
    /// </summary>
    /// <param name="AFailure">The failure value to encapsulate.</param>
    /// <returns>A new TResultPair in rtFailure state containing AFailure.</returns>
    class function Failure(const AFailure: F): TResultPair<S, F>; static; inline;

    /// <summary>
    /// Reduces the TResultPair to a single value of type R by applying a function that handles
    /// both success and failure cases.
    /// </summary>
    /// <param name="AFunc">Function that takes the success or failure value and returns an R value.</param>
    /// <returns>The resulting value of type R.</returns>
    function Reduce<R>(const AFunc: TFunc<S, F, R>): R; inline;

    /// <summary>
    /// Applies a specific function to the success or failure value, returning a result of type R.
    /// </summary>
    /// <param name="ASuccessFunc">Function to apply in case of success.</param>
    /// <param name="AFailureFunc">Function to apply in case of failure.</param>
    /// <returns>The resulting value of type R.</returns>
    function When<R>(const ASuccessFunc: TFunc<S, R>;
      const AFailureFunc: TFunc<F, R>): R; overload; inline;

    /// <summary>
    /// Executes a specific procedure for either the success or failure state, returning the original result pair.
    /// This overload is useful when you only need to perform an action without transforming the result.
    /// </summary>
    /// <param name="ASuccessProc">Procedure to execute in case of success.</param>
    /// <param name="AFailureProc">Procedure to execute in case of failure.</param>
    /// <returns>The original TResultPair containing the success or failure value.</returns>
    function When(const ASuccessProc: TProc<S>;
      const AFailureProc: TProc<F>): TResultPair<S, F>; overload; inline;

    /// <summary>
    /// Transforms the success value using the provided function, preserving the S type of the TResultPair.
    /// The transformation is applied only if the state is rtSuccess and R is compatible with S.
    /// </summary>
    /// <param name="ASuccessFunc">Function that transforms the success value into a new value of type R.</param>
    /// <returns>A new TResultPair with the transformed value or the original if not rtSuccess.</returns>
    function Map<R>(const ASuccessFunc: TFunc<S, R>): TResultPair<S, F>; overload; inline;

    /// <summary>
    /// Transforms the failure value using the provided function, preserving the F type of the TResultPair.
    /// The transformation is applied only if the state is rtFailure and R is compatible with F.
    /// </summary>
    /// <param name="AFailureFunc">Function that transforms the failure value into a new value of type R.</param>
    /// <returns>A new TResultPair with the transformed value or the original if not rtFailure.</returns>
    function Map<R>(const AFailureFunc: TFunc<F, R>): TResultPair<S, F>; overload; inline;

    /// <summary>
    /// Transforms the success value using the provided function, preserving the S type of the TResultPair.
    /// Similar to Map, but preserves the failure value if the state is rtFailure.
    /// </summary>
    /// <param name="ASuccessFunc">Function that transforms the success value into a new value of type R.</param>
    /// <returns>A new TResultPair with the transformed value or the preserved failure value.</returns>
    function FlatMap<R>(const ASuccessFunc: TFunc<S, R>): TResultPair<S, F>; overload; inline;

    /// <summary>
    /// Transforms the failure value using the provided function, preserving the F type of the TResultPair.
    /// Similar to Map, but applies the transformation only if the state is rtFailure.
    /// </summary>
    /// <param name="AFailureFunc">Function that transforms the failure value into a new value of type R.</param>
    /// <returns>A new TResultPair with the transformed value or the original if not rtFailure.</returns>
    function FlatMap<R>(const AFailureFunc: TFunc<F, R>): TResultPair<S, F>; overload; inline;

    /// <summary>
    /// Returns the success value or applies a fallback function if in failure state.
    /// </summary>
    /// <param name="ASuccessFunc">Fallback function that returns an S value in case of failure.</param>
    /// <returns>The success value or the result of the fallback function.</returns>
    function SuccessOrElse(const ASuccessFunc: TFunc<S, S>): S; inline;

    /// <summary>
    /// Returns the success value or raises an exception if in failure state.
    /// </summary>
    /// <returns>The success value of type S.</returns>
    /// <exception cref="EFailureException<F>">Raised if the state is rtFailure.</exception>
    function SuccessOrException: S; inline;

    /// <summary>
    /// Returns the success value or the default value of S if in failure state.
    /// </summary>
    /// <returns>The success value or Default(S).</returns>
    function SuccessOrDefault: S; overload; inline;

    /// <summary>
    /// Returns the success value or a provided default value if in failure state.
    /// </summary>
    /// <param name="ADefault">The default value to return in case of failure.</param>
    /// <returns>The success value or ADefault.</returns>
    function SuccessOrDefault(const ADefault: S): S; overload; inline;

    /// <summary>
    /// Returns the failure value or applies a fallback function if in success state.
    /// </summary>
    /// <param name="AFailureFunc">Fallback function that returns an F value in case of success.</param>
    /// <returns>The failure value or the result of the fallback function.</returns>
    function FailureOrElse(const AFailureFunc: TFunc<F, F>): F; inline;

    /// <summary>
    /// Returns the failure value or raises an exception if in success state.
    /// </summary>
    /// <returns>The failure value of type F.</returns>
    /// <exception cref="ESuccessException<S>">Raised if the state is rtSuccess.</exception>
    function FailureOrException: F; inline;

    /// <summary>
    /// Returns the failure value or the default value of F if in success state.
    /// </summary>
    /// <returns>The failure value or Default(F).</returns>
    function FailureOrDefault: F; overload; inline;

    /// <summary>
    /// Returns the failure value or a provided default value if in success state.
    /// </summary>
    /// <param name="ADefault">The default value to return in case of success.</param>
    /// <returns>The failure value or ADefault.</returns>
    function FailureOrDefault(const ADefault: F): F; overload; inline;

    /// <summary>
    /// Checks if the TResultPair is in the success state.
    /// </summary>
    /// <returns>True if the state is rtSuccess, False otherwise.</returns>
    function IsSuccess: Boolean; inline;

    /// <summary>
    /// Checks if the TResultPair is in the failure state.
    /// </summary>
    /// <returns>True if the state is rtFailure, False otherwise.</returns>
    function IsFailure: Boolean; inline;

    /// <summary>
    /// Retrieves the success value, if present.
    /// </summary>
    /// <returns>The success value of type S.</returns>
    /// <exception cref="Exception">Raised if the state is not rtSuccess.</exception>
    function ValueSuccess: S; inline;

    /// <summary>
    /// Retrieves the failure value, if present.
    /// </summary>
    /// <returns>The failure value of type F.</returns>
    /// <exception cref="Exception">Raised if the state is not rtFailure.</exception>
    function ValueFailure: F; inline;
  end;

implementation

{ TResultPair<S, F> }

procedure TResultPair<S, F>._SetFailureValue(const AFailure: F);
begin
  FFailure := TResultPairValue<F>.Create(AFailure);
  FResultType := TResultType.rtFailure;
end;

procedure TResultPair<S, F>._SetSuccessValue(const ASuccess: S);
begin
  FSuccess := TResultPairValue<S>.Create(ASuccess);
  FResultType := TResultType.rtSuccess;
end;

constructor TResultPair<S, F>.Create(const AResultType: TResultType);
begin
  FResultType := AResultType;
end;

class function TResultPair<S, F>.Failure(const AFailure: F): TResultPair<S, F>;
begin
  Result := TResultPair<S, F>.Create(TResultType.rtFailure);
  Result._SetFailureValue(AFailure);
end;

class function TResultPair<S, F>.Success(const ASuccess: S): TResultPair<S, F>;
begin
  Result := TResultPair<S, F>.Create(TResultType.rtSuccess);
  Result._SetSuccessValue(ASuccess);
end;

function TResultPair<S, F>.IsFailure: Boolean;
begin
  Result := FResultType = TResultType.rtFailure;
end;

function TResultPair<S, F>.IsSuccess: Boolean;
begin
  Result := FResultType = TResultType.rtSuccess;
end;

function TResultPair<S, F>.When(const ASuccessProc: TProc<S>;
  const AFailureProc: TProc<F>): TResultPair<S, F>;
begin
  Result := Self;
  if (not Assigned(ASuccesspROC)) and (not Assigned(AFailurepROC)) then
    Exit;
  case FResultType of
    TResultType.rtSuccess: ASuccessProc(FSuccess.GetValue);
    TResultType.rtFailure: AFailureProc(FFailure.GetValue);
  end;
end;

function TResultPair<S, F>.When<R>(const ASuccessFunc: TFunc<S, R>;
  const AFailureFunc: TFunc<F, R>): R;
begin
  Result := Default(R);
  if (not Assigned(ASuccessFunc)) and (not Assigned(AFailureFunc)) then
    Exit;
  case FResultType of
    TResultType.rtSuccess: Result := ASuccessFunc(FSuccess.GetValue);
    TResultType.rtFailure: Result := AFailureFunc(FFailure.GetValue);
  end;
end;

function TResultPair<S, F>.Reduce<R>(const AFunc: TFunc<S, F, R>): R;
begin
  Result := Default(R);
  if not Assigned(AFunc) then
    Exit;
  case FResultType of
    TResultType.rtSuccess: Result := AFunc(FSuccess.GetValue, Default(F));
    TResultType.rtFailure: Result := AFunc(Default(S), FFailure.GetValue);
  end;
end;

function TResultPair<S, F>.SuccessOrException: S;
begin
  if FResultType = TResultType.rtFailure then
    raise EFailureException<F>.Create(FFailure.GetValue);
  Result := FSuccess.GetValue;
end;

class operator TResultPair<S, F>.Implicit(
  const V: IResultPairValue<F>): TResultPair<S, F>;
begin
  Result.FFailure := V;
end;

class operator TResultPair<S, F>.Implicit(
  const V: TResultPair<S, F>): IResultPairValue<F>;
begin
  Result := V.FFailure;
end;

class operator TResultPair<S, F>.Implicit(
  const V: IResultPairValue<S>): TResultPair<S, F>;
begin
  Result.FSuccess := V;
end;

class operator TResultPair<S, F>.Implicit(
  const V: TResultPair<S, F>): IResultPairValue<S>;
begin
  Result := V.FSuccess;
end;

function TResultPair<S, F>.ValueFailure: F;
begin
  Result := FFailure.GetValue;
end;

function TResultPair<S, F>.ValueSuccess: S;
begin
  Result := FSuccess.GetValue;
end;

function TResultPair<S, F>.Map<R>(const ASuccessFunc: TFunc<S, R>): TResultPair<S, F>;
var
  LCast: TValue;
begin
  Result := Self;
  if not Assigned(ASuccessFunc) then
    Exit;
  case FResultType of
    TResultType.rtSuccess:
    begin
      LCast := TValue.From<R>(ASuccessFunc(FSuccess.GetValue));
      Result._SetSuccessValue(LCast.AsType<S>);
    end;
  end;
end;

function TResultPair<S, F>.Map<R>(const AFailureFunc: TFunc<F, R>): TResultPair<S, F>;
var
  LCast: TValue;
begin
  Result := Self;
  if not Assigned(AFailureFunc) then
    Exit;
  case FResultType of
    TResultType.rtFailure:
    begin
      LCast := TValue.From<R>(AFailureFunc(FFailure.GetValue));
      Result._SetFailureValue(LCast.AsType<F>);
    end;
  end;
end;

class operator TResultPair<S, F>.NotEqual(const Left,
  Right: TResultPair<S, F>): Boolean;
begin
  Result := not (Left = Right);
end;

function TResultPair<S, F>.FlatMap<R>(
  const ASuccessFunc: TFunc<S, R>): TResultPair<S, F>;
var
  LCast: TValue;
begin
  Result := Self;
  if not Assigned(ASuccessFunc) then
    Exit;
  case FResultType of
    TResultType.rtSuccess:
    begin
      LCast := TValue.From<R>(ASuccessFunc(FSuccess.GetValue));
      Result._SetSuccessValue(LCast.AsType<S>);
    end;
    TResultType.rtFailure: _SetFailureValue(FFailure.GetValue);
  end;
end;

function TResultPair<S, F>.FlatMap<R>(
  const AFailureFunc: TFunc<F, R>): TResultPair<S, F>;
var
  LCast: TValue;
begin
  Result := Self;
  if not Assigned(AFailureFunc) then
    exit;
  case FResultType of
    TResultType.rtFailure:
    begin
      LCast := TValue.From<R>(AFailureFunc(FFailure.GetValue));
      Result._SetFailureValue(LCast.AsType<F>);
    end;
  end;
end;

function TResultPair<S, F>.SuccessOrElse(const ASuccessFunc: TFunc<S, S>): S;
begin
  case FResultType of
    TResultType.rtSuccess: Result := FSuccess.GetValue;
    TResultType.rtFailure: Result := ASuccessFunc(FSuccess.GetValue);
  else
    Result := Default(S);
  end;
end;

function TResultPair<S, F>.SuccessOrDefault(const ADefault: S): S;
begin
  case FResultType of
    TResultType.rtSuccess: Result := FSuccess.GetValue;
    TResultType.rtFailure: Result := ADefault;
  else
    Result := Default(S);
  end;
end;

function TResultPair<S, F>.SuccessOrDefault: S;
begin
  case FResultType of
    TResultType.rtSuccess: Result := FSuccess.GetValue;
    TResultType.rtFailure: Result := Default(S);
  else
    Result := Default(S);
  end;
end;

class operator TResultPair<S, F>.Equal(const Left,
  Right: TResultPair<S, F>): Boolean;
begin
  Result := (Left = Right);
end;

function TResultPair<S, F>.FailureOrDefault: F;
begin
  case FResultType of
    TResultType.rtSuccess: Result := Default(F);
    TResultType.rtFailure: Result := FFailure.GetValue;
  else
    Result := Default(F);
  end;
end;

function TResultPair<S, F>.FailureOrDefault(const ADefault: F): F;
begin
  case FResultType of
    TResultType.rtSuccess: Result := ADefault;
    TResultType.rtFailure: Result := FFailure.GetValue;
  else
    Result := Default(F);
  end;
end;

function TResultPair<S, F>.FailureOrElse(const AFailureFunc: TFunc<F, F>): F;
begin
  case FResultType of
    TResultType.rtSuccess: Result := AFailureFunc(FFailure.GetValue);
    TResultType.rtFailure: Result := FFailure.GetValue;
  else
    Result := Default(F);
  end;
end;

function TResultPair<S, F>.FailureOrException: F;
begin
  if FResultType = TResultType.rtSuccess then
    raise ESuccessException<S>.Create(FSuccess.GetValue);
  Result := FFailure.GetValue;
end;

{ TResultPairValue<T> }

constructor TResultPairValue<T>.Create(AValue: T);
begin
  inherited Create;
  FValue := AValue;
  FIsObject := PTypeInfo(TypeInfo(T))^.Kind = tkClass;
end;

destructor TResultPairValue<T>.Destroy;
begin
  if (FIsObject) and (Assigned(Pointer(@FValue))) then
    TObject(Pointer(@FValue)^).Free;
  inherited;
end;

function TResultPairValue<T>.GetValue: T;
begin
  Result := FValue;
end;

{ EFailureException<F> }

constructor EFailureException<F>.Create(const AValue: F);
begin
  inherited CreateFmt('A generic exception occurred with value %s', [TValue.From<F>(AValue).AsString]);
end;

{ ESuccessException<S> }

constructor ESuccessException<S>.Create(const AValue: S);
begin
  inherited CreateFmt('A generic exception occurred with value %s', [TValue.From<S>(AValue).AsString]);
end;

{ ETypeIncompatibility }

constructor ETypeIncompatibility.Create(const AMessage: String);
begin
  inherited CreateFmt('Type incompatibility: %s', [AMessage]);
end;

end.
