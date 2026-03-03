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

unit System.Objects;

{$I .\evolution4d.inc}

interface

uses
  Rtti,
  TypInfo,
  SysUtils,
  Classes,
  Variants,
  SyncObjs,
  Generics.Collections;

type
  TArrayValue = array of TValue;

  IEvolutoinObject = interface
    ['{486D1BA3-6AEE-46A6-A845-D5154BEBE31C}']
    function Factory(const AClass: TClass): TObject; overload;
    function Factory(const AClass: TClass; const AArgs: TArrayValue;
      const AMethodName: String): TObject; overload;
  end;

  TEvolutionObject = class sealed(TInterfacedObject, IEvolutoinObject)
  strict private
    class var FContext: TRttiContext;
    class var FAutoRefLock: TCriticalSection;
  protected
    class function AutoRefLock: TCriticalSection; static;
    class procedure InitializeContext; static;
    class procedure FinalizeContext; static;
    class function Context: TRttiContext; static;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: IEvolutoinObject;
    function Factory(const AClass: TClass): TObject; overload;
    function Factory(const AClass: TClass; const AArgs: TArrayValue;
      const AMethodName: String): TObject; overload;
    function Factory<T: IInterface>: T; overload;
  end;

  ISmartPtr<T> = interface
    ['{57FF7863-CE3E-4FE6-89BE-99539495CDB7}']
    function IsNull: Boolean;
    function IsLoaded: Boolean;
  end;

  IAutoRefLock = interface
    ['{4D666831-0735-4EF7-9977-06CF47C33ED6}']
    procedure Acquire;
    procedure Release;
  end;

  TAutoRefLock = class(TInterfacedObject, IAutoRefLock)
  private
    FAutoRefLock: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Acquire;
    procedure Release;
  end;

  TSmartPtr<T: class, constructor> = record
  strict private
    FValue: T;
    FSmartPtr: ISmartPtr<T>;
    FAutoRefLock: IAutoRefLock;
    FObjectEx: IEvolutoinObject;
    function _GetAsRef: T;
  strict private
    type
      TSmartPtr = class(TInterfacedObject, ISmartPtr<T>)
      private
        FValue: TObject;
        FIsLoaded: Boolean;
      public
        constructor Create(const AObjectRef: TObject);
        destructor Destroy; override;
        function IsNull: Boolean;
        function IsLoaded: Boolean;
      end;
  public
    constructor Create(const AObjectRef: T);
    class operator Implicit(const AObjectRef: T): TSmartPtr<T>;
    class operator Implicit(const AAutoRef: TSmartPtr<T>): T;
    function IsNull: Boolean;
    function IsLoaded: Boolean;
    function Match<R>(const ANullFunc: TFunc<R>; const AValidFunc: TFunc<T, R>): R;
    procedure Scoped(const AAction: TProc<T>);
    property AsRef: T read _GetAsRef;
  end;

//  TImmutableHook = class
//  private
//    FInstance: TObject;
//    FOriginalSetters: TDictionary<string, Pointer>;
//    FContext: TRttiContext;
//    procedure _HookAllSetters;
//    procedure _RestoreAllSetters;
//  public
//    constructor Create(AInstance: TObject);
//    destructor Destroy; override;
//    function GetProperty(const APropertyName: string): TValue;
//  end;

  TMutableRef<T> = record
  strict private
    FValue: TValue;
    FSmartPtr: ISmartPtr<T>;
    FAutoRefLock: IAutoRefLock;
    FObjectEx: IEvolutoinObject;
    FIsMutable: Boolean;
    function _GetAsRef: T;
  strict private
    type
      TSmartPtr = class(TInterfacedObject, ISmartPtr<T>)
      private
        FValue: TValue;
        FIsLoaded: Boolean;
//        FImmutableHook: TImmutableHook;
      public
        constructor Create(const AValue: TValue);
        destructor Destroy; override;
        function IsNull: Boolean;
        function IsLoaded: Boolean;
      end;
  public
    constructor Create(const AValueRef: T; const AMutable: Boolean = False); overload;
    class operator Implicit(const AValueRef: T): TMutableRef<T>;
    class operator Implicit(const AAutoRef: TMutableRef<T>): T;
    function IsNull: Boolean;
    function IsLoaded: Boolean;
    function IsMutable: Boolean;
    function Match<R>(const ANullFunc: TFunc<R>; const AValidFunc: TFunc<T, R>): R;
    procedure Scoped(const AAction: TFunc<T, TValue>);
    property AsRef: T read _GetAsRef;
  end;

procedure BlockedSetter(const Value: Variant);

implementation

uses
  Windows;

procedure BlockedSetter(const Value: Variant);
begin
  raise Exception.Create('Property is immutable');
end;


{ TObjectEx }

class function TEvolutionObject.AutoRefLock: TCriticalSection;
begin
  Result := FAutoRefLock;
end;

class function TEvolutionObject.Context: TRttiContext;
begin
  Result := FContext;
end;

constructor TEvolutionObject.Create;
begin

end;

destructor TEvolutionObject.Destroy;
begin
  inherited;
end;

class procedure TEvolutionObject.InitializeContext;
begin
  FContext := TRttiContext.Create;
  FAutoRefLock := TCriticalSection.Create;
end;

class procedure TEvolutionObject.FinalizeContext;
begin
  FAutoRefLock.Free;
  FContext.Free;
end;

class function TEvolutionObject.New: IEvolutoinObject;
begin
  Result := TEvolutionObject.Create;
end;

function TEvolutionObject.Factory(const AClass: TClass): TObject;
begin
  Result := Factory(AClass, [], 'Create');
end;

function TEvolutionObject.Factory(const AClass: TClass; const AArgs: TArrayValue;
  const AMethodName: String): TObject;
var
  LConstructor: TRttiMethod;
  LInstance: TValue;
  LType: TRttiType;
begin
  LType := FContext.GetType(AClass);
  LConstructor := LType.GetMethod(AMethodName);
  if LConstructor = nil then
    raise Exception.CreateFmt('Constructor "%s" not found in class %s', [AMethodName, AClass.ClassName]);
  try
    LInstance := LConstructor.Invoke(LType.AsInstance.MetaClassType, AArgs);
    Result := LInstance.AsObject;
  except
    on E: Exception do
      raise Exception.CreateFmt('Failed to invoke constructor "%s" in class %s: %s', [AMethodName, AClass.ClassName, E.Message]);
  end;
end;

function TEvolutionObject.Factory<T>: T;
var
  LType: TRttiType;
  LInstance: TValue;
begin
  LType := FContext.GetType(TypeInfo(T));
  LInstance := LType.GetMethod('Create').Invoke(LType.AsInstance.MetaClassType, []);
  Result := LInstance.AsType<T>;
end;

{ AutoRef<T>.TSmartPtr }

constructor TSmartPtr<T>.TSmartPtr.Create(const AObjectRef: TObject);
begin
  FValue := AObjectRef;
  FIsLoaded := Assigned(FValue);
end;

destructor TSmartPtr<T>.TSmartPtr.Destroy;
begin
  if Assigned(FValue) then
    FValue.Free;
  inherited;
end;

function TSmartPtr<T>.TSmartPtr.IsNull: Boolean;
begin
  Result := FValue = nil;
end;

function TSmartPtr<T>.TSmartPtr.IsLoaded: Boolean;
begin
  Result := FIsLoaded;
end;

{ AutoRef<T> }

constructor TSmartPtr<T>.Create(const AObjectRef: T);
begin
  FValue := AObjectRef;
  if Assigned(FValue) then
    FSmartPtr := TSmartPtr.Create(FValue);
  FObjectEx := TEvolutionObject.New;
  FAutoRefLock := TAutoRefLock.Create;
end;

function TSmartPtr<T>._GetAsRef: T;
begin
  if not Assigned(FAutoRefLock) then
  begin
    TEvolutionObject.AutoRefLock.Acquire;
    try
      if not Assigned(FAutoRefLock) then
        FAutoRefLock := TAutoRefLock.Create;
    finally
      TEvolutionObject.AutoRefLock.Release;
    end;
  end;

  FAutoRefLock.Acquire;
  try
    if (FSmartPtr = nil) or FSmartPtr.IsNull then
    begin
      if FObjectEx = nil then
        FObjectEx := TEvolutionObject.New;
      FValue := FObjectEx.Factory(T) as T;
      FSmartPtr := TSmartPtr.Create(FValue);
    end;
    Result := FValue;
  finally
    FAutoRefLock.Release;
  end;
end;

class operator TSmartPtr<T>.Implicit(const AObjectRef: T): TSmartPtr<T>;
begin
  Result := TSmartPtr<T>.Create(AObjectRef);
end;

class operator TSmartPtr<T>.Implicit(const AAutoRef: TSmartPtr<T>): T;
begin
  Result := AAutoRef.AsRef;
end;

function TSmartPtr<T>.IsNull: Boolean;
begin
  Result := True;
  if FSmartPtr = nil then
    Exit;
  Result := FSmartPtr.IsNull;
end;

function TSmartPtr<T>.IsLoaded: Boolean;
begin
  Result := (FSmartPtr <> nil) and FSmartPtr.IsLoaded;
end;

function TSmartPtr<T>.Match<R>(const ANullFunc: TFunc<R>; const AValidFunc: TFunc<T, R>): R;
begin
  if IsNull then
    Result := ANullFunc()
  else
    Result := AValidFunc(AsRef);
end;

procedure TSmartPtr<T>.Scoped(const AAction: TProc<T>);
begin
  try
    AAction(AsRef);
  finally
    FSmartPtr := nil;
  end;
end;

{ TAutoRefLock }

procedure TAutoRefLock.Acquire;
begin
  FAutoRefLock.Acquire;
end;

constructor TAutoRefLock.Create;
begin
  FAutoRefLock := TCriticalSection.Create;
end;

destructor TAutoRefLock.Destroy;
begin
  FAutoRefLock.Free;
  inherited;
end;

procedure TAutoRefLock.Release;
begin
  FAutoRefLock.Release;
end;

{ MutableRef<T> }

constructor TMutableRef<T>.Create(const AValueRef: T; const AMutable: Boolean);
begin
  FIsMutable := AMutable;
  FValue := TValue.From<T>(AValueRef);
  FSmartPtr := TSmartPtr.Create(FValue);
  FObjectEx := TEvolutionObject.New;
  FAutoRefLock := TAutoRefLock.Create;
end;

class operator TMutableRef<T>.Implicit(const AValueRef: T): TMutableRef<T>;
begin
  if Result.IsLoaded then
    if not Result.IsMutable then
      raise Exception.Create('Attempt to modify an immutable value.');
  Result := TMutableRef<T>.Create(AValueRef);
end;

class operator TMutableRef<T>.Implicit(const AAutoRef: TMutableRef<T>): T;
begin
  if AAutoRef.IsLoaded then
    if not AAutoRef.IsMutable then
      raise Exception.Create('Attempt to modify an immutable value.');
  Result := AAutoRef.AsRef;
end;

function TMutableRef<T>.IsLoaded: Boolean;
begin
  Result := (FSmartPtr <> nil) and FSmartPtr.IsLoaded;
end;

function TMutableRef<T>.IsMutable: Boolean;
begin
  Result := FIsMutable;
end;

function TMutableRef<T>.IsNull: Boolean;
begin
  Result := True;
  if FSmartPtr = nil then
    Exit;
  Result := FSmartPtr.IsNull;
end;

function TMutableRef<T>.Match<R>(const ANullFunc: TFunc<R>; const AValidFunc: TFunc<T, R>): R;
begin
  if IsNull then
    Result := ANullFunc()
  else
    Result := AValidFunc(AsRef);
end;

procedure TMutableRef<T>.Scoped(const AAction: TFunc<T, TValue>);
begin
  if IsNull then
    Exit;
  if not FIsMutable then
    raise Exception.Create('Attempt to modify an immutable value.');
  FValue := AAction(FValue.AsType<T>);
end;

function TMutableRef<T>._GetAsRef: T;
var
  LType: TRttiType;
begin
  if not Assigned(FAutoRefLock) then
  begin
    TEvolutionObject.AutoRefLock.Acquire;
    try
      if not Assigned(FAutoRefLock) then
        FAutoRefLock := TAutoRefLock.Create;
    finally
      TEvolutionObject.AutoRefLock.Release;
    end;
  end;

  FAutoRefLock.Acquire;
  try
    if (FSmartPtr = nil) or FSmartPtr.IsNull then
    begin
      if FValue.IsEmpty then
      begin
        if FObjectEx = nil then
          FObjectEx := TEvolutionObject.New;
        LType := TEvolutionObject.Context.GetType(TypeInfo(T));
        if LType.IsInstance then
        begin
          FValue := FObjectEx.Factory(LType.AsInstance.MetaclassType);
          FIsMutable := False;
        end
        else
          raise Exception.Create('MutableRef<T> can only create instances of class types');
      end;
      FSmartPtr := TSmartPtr.Create(FValue);
    end;
    Result := FValue.AsType<T>;
  finally
    FAutoRefLock.Release;
  end;
end;

{ MutableRef<T>.TSmartPtr }

constructor TMutableRef<T>.TSmartPtr.Create(const AValue: TValue);
begin
  FValue := AValue;
  FIsLoaded := not FValue.IsEmpty;
//  if PTypeInfo(TypeInfo(T))^.Kind = tkClass then
//    FImmutableHook := TImmutableHook.Create(AValue.AsObject);
end;

destructor TMutableRef<T>.TSmartPtr.Destroy;
begin
  if PTypeInfo(TypeInfo(T))^.Kind = tkClass then
  begin
    if not FValue.IsEmpty then
      TObject(FValue.AsObject).Free;
  end;
//  if Assigned(FImmutableHook) then
//    FImmutableHook.Free;
  inherited;
end;

function TMutableRef<T>.TSmartPtr.IsLoaded: Boolean;
begin
  Result := FIsLoaded;
end;

function TMutableRef<T>.TSmartPtr.IsNull: Boolean;
begin
  Result := FValue.IsEmpty;
end;

{ TImmutableHook }

//constructor TImmutableHook.Create(AInstance: TObject);
//begin
//  FInstance := AInstance;
//  FContext := TRttiContext.Create;
//  FOriginalSetters := TDictionary<string, Pointer>.Create;
//  _HookAllSetters;
//end;
//
//destructor TImmutableHook.Destroy;
//begin
//  _RestoreAllSetters;
//  FOriginalSetters.Free;
//  FContext.Free;
//  inherited;
//end;
//
//function TImmutableHook.GetProperty(const APropertyName: string): TValue;
//var
//  RttiType: TRttiType;
//  Prop: TRttiProperty;
//begin
//  RttiType := FContext.GetType(FInstance.ClassType);
//  Prop := RttiType.GetProperty(APropertyName);
//  if Assigned(Prop) then
//    Result := Prop.GetValue(FInstance)
//  else
//    raise Exception.CreateFmt('Propriedade "%s" não encontrada', [APropertyName]);
//end;
//
//procedure TImmutableHook._HookAllSetters;
//var
//  RttiType: TRttiType;
//  Prop: TRttiProperty;
//  Method: TRttiMethod;
//  MethodAddress: Pointer;
//  NewMethod: Pointer;
//  OldProtect: DWORD;
//  SetterName: string;
//begin
//  RttiType := FContext.GetType(FInstance.ClassType);
//  for Prop in RttiType.GetProperties do
//  begin
//    if Prop.IsWritable then
//    begin
//      SetterName := '_Set' + Prop.Name;
//      Method := RttiType.GetMethod(SetterName);
//      if Assigned(Method) then
//      begin
//        MethodAddress := Method.CodeAddress;
//        FOriginalSetters.Add(SetterName, MethodAddress);
//        NewMethod := @BlockedSetter;
//
//        if VirtualProtect(MethodAddress, SizeOf(Pointer), PAGE_EXECUTE_READWRITE, OldProtect) then
//        try
//          PPointer(MethodAddress)^ := NewMethod;
//        finally
//          VirtualProtect(MethodAddress, SizeOf(Pointer), OldProtect, OldProtect);
//        end
//        else
//          raise Exception.Create('Failed to hook setter for ' + Prop.Name);
//      end
//      else
//        raise Exception.Create('Setter ' + SetterName + ' not found for property ' + Prop.Name);
//    end;
//  end;
//end;
//
//procedure TImmutableHook._RestoreAllSetters;
//var
//  RttiType: TRttiType;
//  Method: TRttiMethod;
//  MethodAddress: Pointer;
//  OldProtect: DWORD;
//  SetterPair: TPair<string, Pointer>;
//begin
//  RttiType := FContext.GetType(FInstance.ClassType);
//  for SetterPair in FOriginalSetters do
//  begin
//    Method := RttiType.GetMethod(SetterPair.Key);
//    if Assigned(Method) then
//    begin
//      MethodAddress := Method.CodeAddress;
//      if VirtualProtect(MethodAddress, SizeOf(Pointer), PAGE_EXECUTE_READWRITE, OldProtect) then
//      try
//        PPointer(MethodAddress)^ := SetterPair.Value;
//      finally
//        VirtualProtect(MethodAddress, SizeOf(Pointer), OldProtect, OldProtect);
//      end;
//    end;
//  end;
//end;

initialization
  TEvolutionObject.InitializeContext;

finalization
  TEvolutionObject.FinalizeContext;

end.
