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

unit System.Tuple;

interface

uses
  Rtti,
  TypInfo,
  SysUtils,
  Generics.Collections,
  Generics.Defaults;

type
  ITupleDict<K> = interface
    ['{73CD7882-7D2C-4842-A828-96CD6ECF417C}']
    function GetDict: TDictionary<K, TValue>;
    function Count: Integer;
    function GetItem(const AKey: K): TValue;
    function TryGetValue(const AKey: K; out AValue: TValue): Boolean;
  end;

  TTupleDict<K> = class(TInterfacedObject, ITupleDict<K>)
  private
    FTupleDict: TDictionary<K, TValue>;
  public
    constructor Create(const ATuples: TArray<TPair<K, TValue>>);
    destructor Destroy; override;
    function GetDict: TDictionary<K, TValue>;
    function Count: Integer;
    function GetItem(const AKey: K): TValue;
    function TryGetValue(const AKey: K; out AValue: TValue): Boolean;
  end;

  TTuple<K> = record
  strict private
    FTupleDict: ITupleDict<K>;
    constructor Create(const ATuples: TArray<TPair<K, TValue>>);
    function GetItem(const AKey: K): TValue;
  public
    class operator Implicit(const P: TTuple<K>): TArray<TPair<K, TValue>>; inline;
    class operator Implicit(const P: TArray<TPair<K, TValue>>): TTuple<K>; inline;
    class operator Equal(const Left, Right: TTuple<K>): Boolean; inline;
    class operator NotEqual(const Left, Right: TTuple<K>): Boolean; inline;
    class function New(const AKeys: TArray<K>;
      const AValues: TArray<TValue>): TTuple<K>; static; inline;
    function Get<T>(const AKey: K): T; inline;
    function TryGet<T>(const AKey: K; out AValue: T): Boolean; inline;
    function Count: Integer; inline;
    function SetTuple(const AKeys: TArray<K>; const AValues: TArray<TValue>): TTuple<K>; inline;
    property Items[const Key: K]: TValue read GetItem; default;
  end;

  TValueArray = array of TValue;

  PTuple = ^TTuple;
  TTuple = record
  strict private
    FTuples: TValueArray;
    constructor Create(const Args: TValueArray);
    function GetItem(const AIndex: Integer): TValue;
  public
    class operator Implicit(const Args: TTuple): TValueArray;
    class operator Implicit(const Args: array of Variant): TTuple;
    class operator Implicit(const Args: TValueArray): TTuple;
    class operator Equal(const Left, Right: TTuple): Boolean; inline;
    class operator NotEqual(const Left, Right: TTuple): Boolean; inline;
    class function New(const AValues: TValueArray): TTuple; static; inline;
    function Get<T>(const AIndex: Integer): T; inline;
    function Count: Integer; inline;
    procedure Dest(const AVarRefs: TArray<Pointer>);
    property Items[const Key: Integer]: TValue read GetItem; default;
  end;

  TTupluString = TTuple<string>;
  TTupluInteger = TTuple<Integer>;
  TTupluInt16 = TTuple<Int16>;
  TTupluInt32 = TTuple<Int32>;
  TTupluInt64 = TTuple<Int64>;
  TTupluDouble = TTuple<Double>;
  TTupluCurrency = TTuple<Currency>;
  TTupluSingle = TTuple<Single>;
  TTupluDate = TTuple<TDate>;
  TTupluTime = TTuple<TTime>;
  TTupluDateTime = TTuple<TDateTime>;
  TTupluChar = TTuple<Char>;
  TTupluVariant = TTuple<Variant>;

implementation

{ TTupleDict<K> }

constructor TTupleDict<K>.Create(const ATuples: TArray<TPair<K, TValue>>);
var
  LFor: Integer;
begin
  FTupleDict := TDictionary<K, TValue>.Create;
  for LFor := 0 to High(ATuples) do
    FTupleDict.Add(ATuples[LFor].Key, ATuples[LFor].Value);
end;

destructor TTupleDict<K>.Destroy;
begin
  FTupleDict.Free;
  inherited;
end;

function TTupleDict<K>.GetDict: TDictionary<K, TValue>;
begin
  Result := FTupleDict;
end;

function TTupleDict<K>.Count: Integer;
begin
  Result := FTupleDict.Count;
end;

function TTupleDict<K>.GetItem(const AKey: K): TValue;
begin
  Result := FTupleDict[AKey];
end;

function TTupleDict<K>.TryGetValue(const AKey: K; out AValue: TValue): Boolean;
begin
  Result := FTupleDict.TryGetValue(AKey, AValue);
end;

{ TTuple<K> }

function TTuple<K>.Count: Integer;
begin
  Result := FTupleDict.Count;
end;

constructor TTuple<K>.Create(const ATuples: TArray<TPair<K, TValue>>);
begin
  FTupleDict := TTupleDict<K>.Create(ATuples);
end;

class operator TTuple<K>.Equal(const Left, Right: TTuple<K>): Boolean;
var
  LComp1: IEqualityComparer<K>;
  LComp2: IEqualityComparer<TValue>;
  LPair: TPair<K, TValue>;
begin
  Result := False;
  if Left.FTupleDict.Count <> Right.FTupleDict.Count then
    Exit;
  LComp1 := TEqualityComparer<K>.Default;
  LComp2 := TEqualityComparer<TValue>.Default;
  for LPair in Left.FTupleDict.GetDict do
  begin
    if not Right.FTupleDict.GetDict.ContainsKey(LPair.Key) then
      Exit;
    if not LComp2.Equals(LPair.Value, Right.FTupleDict.GetDict[LPair.Key]) then
      Exit;
  end;
  Result := True;
end;

function TTuple<K>.SetTuple(const AKeys: TArray<K>;
  const AValues: TArray<TValue>): TTuple<K>;
begin
  Result := TTuple<K>.New(AKeys, AValues);
end;

function TTuple<K>.Get<T>(const AKey: K): T;
begin
  Result := FTupleDict.GetItem(AKey).AsType<T>;
end;

function TTuple<K>.TryGet<T>(const AKey: K; out AValue: T): Boolean;
var
  LValue: TValue;
begin
  Result := FTupleDict.TryGetValue(AKey, LValue);
  if Result then
    AValue := LValue.AsType<T>
  else
    AValue := Default(T);
end;

function TTuple<K>.GetItem(const AKey: K): TValue;
begin
  Result := FTupleDict.GetItem(AKey);
end;

class operator TTuple<K>.Implicit(const P: TArray<TPair<K, TValue>>): TTuple<K>;
begin
  Result := TTuple<K>.Create(P);
end;

class operator TTuple<K>.Implicit(const P: TTuple<K>): TArray<TPair<K, TValue>>;
var
  LPair: TPair<K, TValue>;
  LFor: Integer;
begin
  SetLength(Result, P.FTupleDict.Count);
  LFor := 0;
  for LPair in P.FTupleDict.GetDict do
  begin
    Result[LFor] := LPair;
    Inc(LFor);
  end;
end;

class function TTuple<K>.New(const AKeys: TArray<K>;
  const AValues: TArray<TValue>): TTuple<K>;
var
  LPairs: TArray<TPair<K, TValue>>;
  LFor: Integer;
begin
  if Length(AKeys) <> Length(AValues) then
    raise Exception.Create('Number of keys and values must match');

  SetLength(LPairs, Length(AKeys));
  for LFor := 0 to High(AKeys) do
    LPairs[LFor] := TPair<K, TValue>.Create(AKeys[LFor], AValues[LFor]);
  Result := TTuple<K>.Create(LPairs);
end;

class operator TTuple<K>.NotEqual(const Left, Right: TTuple<K>): Boolean;
begin
  Result := not (Left = Right);
end;

{ TTuple }

function TTuple.Count: Integer;
begin
  Result := Length(FTuples);
end;

constructor TTuple.Create(const Args: TValueArray);
var
  LFor: Integer;
begin
  SetLength(FTuples, Length(Args));
  for LFor := Low(Args) to High(Args) do
    FTuples[LFor] := Args[LFor];
end;

class operator TTuple.Equal(const Left, Right: TTuple): Boolean;
var
  LFor: Integer;
begin
  Result := False;
  if Length(Left.FTuples) <> Length(Right.FTuples) then
    Exit;
  for LFor := 0 to High(Left.FTuples) do
  begin
    if Left.FTuples[LFor].Kind <> Right.FTuples[LFor].Kind then
      Exit;
    if Left.FTuples[LFor].ToString <> Right.FTuples[LFor].ToString then
      Exit;
  end;
  Result := True;
end;

function TTuple.Get<T>(const AIndex: Integer): T;
begin
  Result := FTuples[AIndex].AsType<T>;
end;

function TTuple.GetItem(const AIndex: Integer): TValue;
begin
  Result := FTuples[AIndex];
end;

procedure TTuple.Dest(const AVarRefs: TArray<Pointer>);
var
  LFor: Integer;
  LTypeInfo: PTypeInfo;
begin
  if Length(AVarRefs) <> Length(FTuples) then
    raise Exception.Create('Number of pointers (' + IntToStr(Length(AVarRefs)) +
      ') must match tuple length (' + IntToStr(Length(FTuples)) + ')');

  for LFor := Low(AVarRefs) to High(AVarRefs) do
  begin
    case FTuples[LFor].Kind of
      tkInt64:
        PInt64(AVarRefs[LFor])^ := FTuples[LFor].AsInt64;
      tkInteger, tkSet:
        PInteger(AVarRefs[LFor])^ := FTuples[LFor].AsInteger;
      tkFloat:
        PDouble(AVarRefs[LFor])^ := FTuples[LFor].AsExtended;
      tkUString, tkLString, tkWString, tkString, tkChar, tkWChar:
        PUnicodeString(AVarRefs[LFor])^ := FTuples[LFor].AsString;
      tkClass:
        PObject(AVarRefs[LFor])^ := FTuples[LFor].AsObject;
      tkEnumeration:
        PBoolean(AVarRefs[LFor])^ := FTuples[LFor].AsBoolean;
      tkRecord, tkVariant:
        PVariant(AVarRefs[LFor])^ := FTuples[LFor].AsVariant;
      tkArray, tkDynArray:
      begin
        LTypeInfo := FTuples[LFor].TypeInfo;
        case GetTypeData(LTypeInfo).elType2^.Kind of
          tkInt64:
            TArray<Int64>(AVarRefs[LFor]) := FTuples[LFor].AsType<TArray<Int64>>;
          tkInteger, tkSet:
            TArray<Integer>(AVarRefs[LFor]) := FTuples[LFor].AsType<TArray<Integer>>;
          tkFloat:
            TArray<Extended>(AVarRefs[LFor]) := FTuples[LFor].AsType<TArray<Extended>>;
          tkUString, tkLString, tkWString, tkString, tkChar, tkWChar:
            TArray<String>(AVarRefs[LFor]) := FTuples[LFor].AsType<TArray<String>>;
          tkClass:
            TArray<TObject>(AVarRefs[LFor]) := FTuples[LFor].AsType<TArray<TObject>>;
          tkEnumeration:
            TArray<Boolean>(AVarRefs[LFor]) := FTuples[LFor].AsType<TArray<Boolean>>;
          tkRecord, tkVariant:
            TArray<Variant>(AVarRefs[LFor]) := FTuples[LFor].AsType<TArray<Variant>>;
          else
            raise Exception.Create('Unsupported array element type at index ' + IntToStr(LFor));
        end;
      end;
      else
        raise Exception.Create('Unsupported type at index ' + IntToStr(LFor));
    end;
  end;
end;

class operator TTuple.Implicit(const Args: TTuple): TValueArray;
begin
  Result := Args.FTuples;
end;

class operator TTuple.Implicit(const Args: array of Variant): TTuple;
var
  LFor: Integer;
begin
  SetLength(Result.FTuples, Length(Args));
  for LFor := Low(Args) to High(Args) do
    Result.FTuples[LFor] := TValue.FromVariant(Args[LFor]);
end;

class operator TTuple.Implicit(const Args: TValueArray): TTuple;
begin
  Result := TTuple.Create(Args);
end;

class function TTuple.New(const AValues: TValueArray): TTuple;
begin
  Result := TTuple.Create(AValues);
end;

class operator TTuple.NotEqual(const Left, Right: TTuple): Boolean;
begin
  Result := not (Left = Right);
end;

end.

