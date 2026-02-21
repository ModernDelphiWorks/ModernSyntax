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

unit Evolution.Safetry;

interface

uses
  SysUtils,
  Rtti;

type
  TSafeResult = record
  private
    FIsOk: Boolean;
    FValue: TValue;
    FException: String;
    procedure _Ok(const AValue: TValue);
    procedure _Err(const AException: String);
    class function _CreateOk(const AValue: TValue): TSafeResult; static;
    class function _CreateErr(const AException: String): TSafeResult; static;
  public
    function IsOk: Boolean;
    function IsErr: Boolean;
    function GetValue: TValue;
    function TryGetValue(out AValue: TValue): Boolean;
    function ExceptionMessage: String;
    function AsType<T>: T;
    function IsType<T>: Boolean;
  end;

  TSafeTry = record
  private
    FTryFunc: TFunc<TValue>;
    FTryProc: TProc;
    FExcept: TProc<Exception>;
    FFinally: TProc;
    function _EndExecute: TValue;
  public
    class function &Try(const AFunc: TFunc<TValue>): TSafeTry; overload; static;
    class function &Try(const AProc: TProc = nil): TSafeTry; overload; static;
    function &Except(const AProc: TProc<Exception>): TSafeTry;
    function &Finally(const AProc: TProc): TSafeTry;
    function &End: TSafeResult;
  end;

function &Try(const AFunc: TFunc<TValue>): TSafeTry; overload;
function &Try(const AProc: TProc): TSafeTry; overload;
function &Try: TSafeTry; overload;

implementation

{ TSafeResult }

procedure TSafeResult._Ok(const AValue: TValue);
begin
  FIsOk := True;
  FValue := AValue;
  FException := '';
end;

procedure TSafeResult._Err(const AException: String);
begin
  FIsOk := False;
  FValue := TValue.Empty;
  FException := AException;
end;

function TSafeResult.IsOk: Boolean;
begin
  Result := FIsOk;
end;

function TSafeResult.IsErr: Boolean;
begin
  Result := not FIsOk;
end;

function TSafeResult.GetValue: TValue;
begin
  if not FIsOk then
    raise Exception.Create('Cannot get value when result is an error.');
  Result := FValue;
end;

function TSafeResult.TryGetValue(out AValue: TValue): Boolean;
begin
  Result := FIsOk;
  if Result then
    AValue := FValue
  else
    AValue := TValue.Empty;
end;

function TSafeResult.ExceptionMessage: String;
begin
  Result := FException;
end;

function TSafeResult.AsType<T>: T;
begin
  Result := GetValue.AsType<T>;
end;

function TSafeResult.IsType<T>: Boolean;
begin
  Result := FIsOk and FValue.IsType(TypeInfo(T));
end;

class function TSafeResult._CreateOk(const AValue: TValue): TSafeResult;
begin
  Result._Ok(AValue);
end;

class function TSafeResult._CreateErr(const AException: String): TSafeResult;
begin
  Result._Err(AException);
end;

{ TSafeTry }

class function TSafeTry.&Try(const AFunc: TFunc<TValue>): TSafeTry;
begin
  Result.FTryFunc := AFunc;
  Result.FTryProc := nil;
  Result.FExcept := nil;
  Result.FFinally := nil;
end;

class function TSafeTry.&Try(const AProc: TProc): TSafeTry;
begin
  Result.FTryProc := AProc;
  Result.FTryFunc := nil;
  Result.FExcept := nil;
  Result.FFinally := nil;
end;

function TSafeTry.&Except(const AProc: TProc<Exception>): TSafeTry;
begin
  FExcept := AProc;
  Result := Self;
end;

function TSafeTry.&Finally(const AProc: TProc): TSafeTry;
begin
  FFinally := AProc;
  Result := Self;
end;

function TSafeTry._EndExecute: TValue;
var
  LExceptMessage: String;
begin
  try
    try
      if Assigned(FTryFunc) then
      begin
        Result := FTryFunc();
        if Result.IsEmpty then
          Result := TValue.From(True);
      end
      else if Assigned(FTryProc) then
      begin
        FTryProc();
        Result := TValue.From(True);
      end
      else
        Result := TValue.From(True);
    except
      on E: Exception do
      begin
        LExceptMessage := E.Message;
        if Assigned(FExcept) then
        begin
          try
            FExcept(E);
          except
            on EInner: Exception do
              LExceptMessage := E.Message + ' (Except handler failed: ' + EInner.Message + ')';
          end;
        end;
        raise Exception.Create(LExceptMessage);
      end;
    end;
  finally
    if Assigned(FFinally) then
    begin
      try
        FFinally();
      except
        on E: Exception do
          // Ignora exceções em Finally silenciosamente
          // Futuro: Poderia logar se houver um mecanismo global
      end;
    end;
  end;
end;

function TSafeTry.&End: TSafeResult;
var
  LValue: TValue;
begin
  try
    LValue := _EndExecute;
    Result := TSafeResult._CreateOk(LValue);
  except
    on E: Exception do
      Result := TSafeResult._CreateErr(E.Message);
  end;
end;

{ Função Auxiliar }

function &Try(const AFunc: TFunc<TValue>): TSafeTry;
begin
  Result := TSafeTry.&Try(AFunc);
end;

function &Try(const AProc: TProc): TSafeTry;
begin
  Result := TSafeTry.&Try(AProc);
end;

function &Try: TSafeTry;
begin
  Result := TSafeTry.&Try;
end;

end.


