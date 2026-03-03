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

{$T+}

unit ModernSyntax.Async;

interface

uses
  Rtti,
  SysUtils,
  Classes,
  SyncObjs,
  Threading,
  ModernSyntax;

type
  TValue = Rtti.TValue;
  TFuture = ModernSyntax.TFuture;
  EAsyncAwait = Exception;

  IAutoLock = interface
    ['{1857DCF0-4B4C-491B-A546-CB82B199E2E1}']
    procedure Acquire;
    procedure Release;
  end;

  TAutoLock = class(TInterfacedObject, IAutoLock)
  private
    FCriticalSection: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Acquire; inline;
    procedure Release; inline;
  end;

  PAsync = ^TAsync;
  TAsync = record
  strict private
    FTask: ITask;
    FProc: TProc;
    FFunc: TFunc<TValue>;
    FError: TFunc<Exception, TFuture>;
    FLock: IAutoLock;

    function _AwaitProc(const AContinue: TProc; const ATimeout: Cardinal): TFuture; overload;
    function _AwaitFunc(const AContinue: TProc; const ATimeout: Cardinal): TFuture; overload;
    function _AwaitProc(const ATimeout: Cardinal): TFuture; overload;
    function _AwaitFunc(const ATimeout: Cardinal): TFuture; overload;
    function _ExecProc: TFuture;
  private
    constructor Create(const AProc: TProc); overload;
    constructor Create(const AFunc: TFunc<TValue>); overload;
  public
    function Await(const AContinue: TProc; const ATimeout: Cardinal = INFINITE): TFuture; overload; inline;
    function Await(const ATimeout: Cardinal = INFINITE): TFuture; overload; inline;
    function Run: TFuture; overload;
    function Run(const AError: TFunc<Exception, TFuture>): TFuture; overload; inline;
    function NoAwait: TFuture; overload;
    function NoAwait(const AError: TFunc<Exception, TFuture>): TFuture; overload; inline;
    function Status: TTaskStatus; inline;
    function GetId: Integer; inline;
    procedure Cancel; inline;
    procedure CheckCanceled; inline;
  end;

function Async(const AProc: TProc): TAsync; overload; inline;
function Async(const AFunc: TFunc<TValue>): TAsync; overload; inline;

implementation

function Async(const AProc: TProc): TAsync;
var
  LAsync: TAsync;
begin
  LAsync := TAsync.Create(AProc);
  Result := LAsync;
end;

function Async(const AFunc: TFunc<TValue>): TAsync;
begin
  Result := TAsync.Create(AFunc);
end;

function TAsync.Await(const AContinue: TProc; const ATimeout: Cardinal): TFuture;
begin
  if Assigned(FProc) then
    Result := _AwaitProc(AContinue, ATimeout)
  else
  if Assigned(FFunc) then
    Result := _AwaitFunc(AContinue, ATimeout)
end;

constructor TAsync.Create(const AProc: TProc);
begin
  FLock := TAutoLock.Create;
  FTask := nil;
  FProc := AProc;
  FFunc := nil;
end;

function TAsync.Await(const ATimeout: Cardinal): TFuture;
begin
  if Assigned(FProc) then
    Result := _AwaitProc(ATimeout)
  else
  if Assigned(FFunc) then
    Result := _AwaitFunc(ATimeout)
end;

procedure TAsync.Cancel;
begin
  FLock.Acquire;
  try
    if Assigned(FTask) then
      FTask.Cancel;
  finally
    FLock.Release;
  end;
end;

procedure TAsync.CheckCanceled;
begin
  FLock.Acquire;
  try
    if Assigned(FTask) then
      FTask.CheckCanceled;
  finally
    FLock.Release;
  end;
end;

constructor TAsync.Create(const AFunc: TFunc<TValue>);
begin
  FLock := TAutoLock.Create;
  FTask := nil;
  FProc := nil;
  FFunc := AFunc;
end;

function TAsync.Run: TFuture;
begin
  if Assigned(FProc) then
    Result := _ExecProc
  else
  if Assigned(FFunc) then
    Result.SetErr('The "Run" method should not be invoked as a function. Utilize the "Await" method to wait for task completion and access the result, or invoke it as a procedure.');
end;

function TAsync.GetId: Integer;
begin
  FLock.Acquire;
  try
    if Assigned(FTask) then
      Result := FTask.GetId
    else
      Result := -1;
  finally
    FLock.Release;
  end;
end;

function TAsync.NoAwait(const AError: TFunc<Exception, TFuture>): TFuture;
begin
  Result :=  Run(AError);
end;

function TAsync.NoAwait: TFuture;
begin
  Result := Run;
end;

function TAsync.Run(const AError: TFunc<Exception, TFuture>): TFuture;
begin
  FError := AError;
  Result := Self.Run;
end;

function TAsync.Status: TTaskStatus;
begin
  FLock.Acquire;
  try
    if Assigned(FTask) then
      Result := FTask.Status
    else
      Result := TTaskStatus.Created;
  finally
    FLock.Release;
  end;
end;

function TAsync._AwaitProc(const AContinue: TProc; const ATimeout: Cardinal): TFuture;
var
  LSelf: PAsync;
  LMessage: String;
begin
  LSelf := @Self;
  FLock.Acquire;
  try
    try
      FTask := TTask.Run(procedure
                         begin
                           try
                             LSelf^.FProc();
                           except
                             on E: Exception do
                               LMessage := E.Message;
                           end;
                         end);
      FTask.Wait(ATimeout);
      if LMessage <> '' then
        raise EAsyncAwait.Create(LMessage);

      if Assigned(AContinue) then
        TThread.Queue(TThread.CurrentThread,
                      procedure
                      begin
                        try
                          AContinue();
                        except
                          on E: Exception do
                            LMessage := E.Message;
                        end;
                      end);
      if LMessage <> '' then
        raise EAsyncAwait.Create(LMessage);

      Result.SetOk(True);
    except
      on E: Exception do
        Result.SetErr(E.Message);
    end;
  finally
    FLock.Release;
  end;
end;

function TAsync._ExecProc: TFuture;
var
  LProc: TProc;
  LError: TFunc<Exception, TFuture>;
begin
  LProc := FProc;
  LError := FError;
  FLock.Acquire;
  try
    try
      FTask := TTask.Run(procedure
                         var
                           LMessage: String;
                         begin
                           try
                             LProc();
                           except
                             on E: Exception do
                             begin
                               LMessage := E.Message;
                               if Assigned(LError) then
                                 TThread.Queue(TThread.CurrentThread,
                                               procedure
                                               begin
                                                 LError(Exception.Create(LMessage));
                                               end);
                             end;
                           end;
                         end);
      Result.SetOk(True);
    except
      on E: Exception do
        Result.SetErr(E.Message);
    end;
  finally
    FLock.Release;
  end;
end;

function TAsync._AwaitFunc(const AContinue: TProc; const ATimeout: Cardinal): TFuture;
var
  LValue: TValue;
  LSelf: PAsync;
  LMessage: String;
begin
  LSelf := @Self;
  FLock.Acquire;
  try
    try
      FTask := TTask.Run(procedure
                         begin
                           try
                             LValue := LSelf^.FFunc();
                           except
                             on E: Exception do
                               LMessage := E.Message;
                           end;
                         end);
      FTask.Wait(ATimeout);
      if LMessage <> '' then
        raise EAsyncAwait.Create(LMessage);

      if Assigned(AContinue) then
        TThread.Queue(TThread.CurrentThread,
                      procedure
                      begin
                        try
                          AContinue();
                        except
                          on E: Exception do
                            LMessage := E.Message;
                        end;
                      end);
      if LMessage <> '' then
        raise EAsyncAwait.Create(LMessage);

      Result.SetOk(LValue);
    except
      on E: Exception do
        Result.SetErr(E.Message);
    end;
  finally
    FLock.Release;
  end;
end;

function TAsync._AwaitFunc(const ATimeout: Cardinal): TFuture;
var
  LValue: TValue;
  LSelf: PAsync;
  LMessage: String;
begin
  LSelf := @Self;
  FLock.Acquire;
  try
    try
      FTask := TTask.Run(procedure
                         begin
                           try
                             LValue := LSelf^.FFunc();
                           except
                             on E: Exception do
                               LMessage := E.Message;
                           end;
                         end);
      FTask.Wait(ATimeout);
      if LMessage <> '' then
        raise EAsyncAwait.Create(LMessage);

      Result.SetOk(LValue);
    except
      on E: Exception do
        Result.SetErr(E.Message);
    end;
  finally
    FLock.Release;
  end;
end;

function TAsync._AwaitProc(const ATimeout: Cardinal): TFuture;
var
  LSelf: PAsync;
  LMessage: String;
begin
  LSelf := @Self;
  FLock.Acquire;
  try
    try
      FTask := TTask.Run(procedure
                         begin
                           try
                             LSelf^.FProc();
                           except
                             on E: Exception do
                               LMessage := E.Message;
                           end;
                         end);
      FTask.Wait(ATimeout);
      if LMessage <> '' then
        raise EAsyncAwait.Create(LMessage);

      Result.SetOk(True);
    except
      on E: Exception do
        Result.SetErr(E.Message);
    end;
  finally
    FLock.Release;
  end;
end;

{ TCriticalSectionHelper }

procedure TAutoLock.Acquire;
begin
  FCriticalSection.Acquire;
end;

constructor TAutoLock.Create;
begin
  inherited Create;
  FCriticalSection := TCriticalSection.Create;
end;

destructor TAutoLock.Destroy;
begin
  FCriticalSection.Free;
  inherited;
end;

procedure TAutoLock.Release;
begin
  FCriticalSection.Release;
end;

end.
