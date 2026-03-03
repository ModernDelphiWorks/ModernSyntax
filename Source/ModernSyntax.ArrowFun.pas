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

unit ModernSyntax.ArrowFun;

interface

uses
  Rtti,
  SysUtils,
  TypInfo,
  Generics.Collections,
  ModernSyntax.Std,
  ModernSyntax;

type
  EArrowException = Exception;

  /// <summary>
  ///   A utility record providing functional programming constructs for managing and manipulating values and variables.
  /// </summary>
  /// <remarks>
  ///   TArrow offers methods to create procedures and functions that operate on TValue instances, enabling side effects on variables
  ///   or returning computed results. It supports both single-value and multi-value operations through arrays and tuples, with automatic
  ///   type conversion and error handling.
  /// </remarks>
  TArrow = record
  strict private
    class var FValue: TValue; // Internal storage for the last processed value

    /// <summary>
    ///   Frees the internally stored TValue when the class is destroyed.
    /// </summary>
    class destructor Destroy;

  public
    /// <summary>
    ///   Creates a procedure that sets an internal value without affecting external variables.
    /// </summary>
    /// <param name="AValue">The value to store internally.</param>
    /// <returns>A procedure that assigns AValue to the internal FValue when executed.</returns>
    class function Fn(const AValue: TValue): TProc; overload; static;
    class function Fn(const AValue: string): TProc; overload; static;
    class function Fn(const AValue: Integer): TProc; overload; static;
    class function Fn(const AValue: Boolean): TProc; overload; static;
    class function Fn(const AValue: TObject): TProc; overload; static;
    class function Fn(const AVarRefs: TArray<Pointer>; const AValues: Tuple): TProc<TValue>; overload; static;
    class function Fn<T>(var AVar: T; const AValue: T): TProc<TValue>; overload; static;

    /// <summary>
    ///   Creates a function that sets an internal value and returns it.
    /// </summary>
    /// <param name="AValue">The value to store and return.</param>
    /// <returns>A function that assigns AValue to FValue and returns it when executed.</returns>
    class function Result(const AValue: TValue): TFunc<TValue>; overload; static;
//    class function Result(const AValue: string): TFunc<string>; overload; static;
//    class function Result(const AValue: Integer): TFunc<Integer>; overload; static;
//    class function Result(const AValue: Boolean): TFunc<Boolean>; overload; static;
//    class function Result(const AValue: Double): TFunc<Double>; overload; static;
//    class function Result(const AValue: TDateTime): TFunc<TDateTime>; overload; static;
//    class function Result(const AValue: TObject): TFunc<TObject>; overload; static;
//    class function Result<T>(const AValue: T): TFunc<T>; overload; static;

    /// <summary>
    ///   Retrieves the last stored value as a specified type.
    /// </summary>
    /// <remarks>
    ///   Attempts to cast the internal FValue to type T. Raises EArrowException if the cast fails.
    /// </remarks>
    /// <returns>The internal FValue cast to type T.</returns>
    class function Value<T>: T; static;

    /// <summary>
    /// Retrieves the last stored value as a string.
    /// </summary>
    /// <returns>The internal FValue as a string.</returns>
    class function AsString: string; static;
  end;

implementation

{ TArrow }

class function TArrow.Fn(const AValue: TValue): TProc;
begin
  Result := procedure
            begin
              FValue := AValue;
            end;
end;

class function TArrow.Result(const AValue: TValue): TFunc<TValue>;
begin
  Result := function: TValue
            begin
              FValue := AValue;
              Result := AValue;
            end;
end;

class function TArrow.Fn<T>(var AVar: T; const AValue: T): TProc<TValue>;
var
  LVar: ^T;
  LValue: T;
begin
  LVar := @AVar;
  LValue := AValue;
  Result := procedure(AValue: TValue)
            begin
              try
                FValue := nil;
                FValue := AValue;
                LVar^ := LValue;
              except
                on E: Exception do
                  raise EArrowException.Create('Error in TArrow.Fn: ' + E.Message);
              end;
            end;
end;

//class function TArrow.Result(const AValue: TDateTime): TFunc<TDateTime>;
//begin
//  Result := function: TDateTime
//            begin
//              Result := AValue;
//            end;
//end;

//class function TArrow.Result(const AValue: string): TFunc<string>;
//begin
//  Result := function: string
//            begin
//              Result := AValue;
//            end;
//end;

class function TArrow.Value<T>: T;
begin
  try
    Result := FValue.AsType<T>;
  except
    on E: Exception do
      raise EArrowException.Create('Error in TArrow.Value: Cannot cast value to specified type. ' + E.Message);
  end;
end;

class function TArrow.AsString: string;
begin
  try
    Result := FValue.AsString;
  except
    on E: Exception do
      raise EArrowException.Create('Error in TArrow.AsString: Cannot cast value to string. ' + E.Message);
  end;
end;

class destructor TArrow.Destroy;
begin
  FValue := nil;
end;

class function TArrow.Fn(const AVarRefs: TArray<Pointer>; const AValues: Tuple): TProc<TValue>;
var
  LVarRefs: TArray<Pointer>;
begin
  if Length(AVarRefs) <> Length(AValues) then
    raise Exception.Create('Different-sized arrays in TArrow.Fn.');

  LVarRefs := AVarRefs;
  Result := procedure(AValue: TValue)
            var
              LFor: Integer;
              LTypeInfo: PTypeInfo;
            begin
              try
                FValue := AValue;
                for LFor := 0 to High(LVarRefs) do
                begin
                  case AValues[LFor].Kind of
                    tkInt64:
                      PInt64(LVarRefs[LFor])^ := AValues[LFor].AsInt64;
                    tkInteger, tkSet:
                      PInteger(LVarRefs[LFor])^ := AValues[LFor].AsInteger;
                    tkFloat:
                      PDouble(LVarRefs[LFor])^ := AValues[LFor].AsExtended;
                    tkUString, tkLString, tkWString, tkString, tkChar, tkWChar:
                      PUnicodeString(LVarRefs[LFor])^ := AValues[LFor].AsString;
                    tkClass:
                      PObject(LVarRefs[LFor])^ := AValues[LFor].AsObject;
                    tkEnumeration:
                      PBoolean(LVarRefs[LFor])^ := AValues[LFor].AsBoolean;
                    tkRecord, tkVariant:
                      PVariant(LVarRefs[LFor])^ := AValues[LFor].AsVariant;
                    tkArray, tkDynArray:
                    begin
                      LTypeInfo := AValues[LFor].TypeInfo;
                      case GetTypeData(LTypeInfo).elType2^.Kind of
                        tkInt64:
                          TArray<Int64>(LVarRefs[LFor]) := AValues[LFor].AsType<TArray<Int64>>;
                        tkInteger, tkSet:
                          TArray<Integer>(LVarRefs[LFor]) := AValues[LFor].AsType<TArray<Integer>>;
                        tkFloat:
                          TArray<Extended>(LVarRefs[LFor]) := AValues[LFor].AsType<TArray<Extended>>;
                        tkUString, tkLString, tkWString, tkString, tkChar, tkWChar:
                          TArray<String>(LVarRefs[LFor]) := AValues[LFor].AsType<TArray<String>>;
                        tkClass:
                          TArray<TObject>(LVarRefs[LFor]) := AValues[LFor].AsType<TArray<TObject>>;
                        tkEnumeration:
                          TArray<Boolean>(LVarRefs[LFor]) := AValues[LFor].AsType<TArray<Boolean>>;
                        tkRecord, tkVariant:
                          TArray<Variant>(LVarRefs[LFor]) := AValues[LFor].AsType<TArray<Variant>>;
                      else
                        raise EArrowException.Create('Unsupported array element type at index ' + IntToStr(LFor));
                      end;
                    end;
                  else
                    raise EArrowException.Create('Unsupported type at index ' + IntToStr(LFor));
                  end;
                end;
              except
                on E: Exception do
                  raise EArrowException.Create('Error in TArrow.Fn (array): ' + E.Message);
              end;
            end;
end;

class function TArrow.Fn(const AValue: TObject): TProc;
begin
  Result := procedure
            begin
              FValue := TValue.From<TObject>(AValue);
            end;
end;

class function TArrow.Fn(const AValue: Boolean): TProc;
begin
  Result := procedure
            begin
              FValue := TValue.From<Boolean>(AValue);
            end;
end;

class function TArrow.Fn(const AValue: Integer): TProc;
begin
  Result := procedure
            begin
              FValue := TValue.From<Integer>(AValue);
            end;
end;

class function TArrow.Fn(const AValue: string): TProc;
begin
  Result := procedure
            begin
              FValue := TValue.From<string>(AValue);
            end;
end;

//class function TArrow.Result(const AValue: Integer): TFunc<Integer>;
//begin
//  Result := function: Integer
//            begin
//              Result := AValue;
//            end;
//end;

//class function TArrow.Result(const AValue: Boolean): TFunc<Boolean>;
//begin
//  Result := function: Boolean
//            begin
//              Result := AValue;
//            end;
//end;

//class function TArrow.Result(const AValue: Double): TFunc<Double>;
//begin
//  Result := function: Double
//            begin
//              Result := AValue;
//            end;
//end;

//class function TArrow.Result(const AValue: TObject): TFunc<TObject>;
//begin
//  Result := function: TObject
//            begin
//              Result := AValue;
//            end;
//end;

//class function TArrow.Result<T>(const AValue: T): TFunc<T>;
//begin
//  Result := function: T
//            begin
//              Result := AValue;
//            end;
//end;

end.

