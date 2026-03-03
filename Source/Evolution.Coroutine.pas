{
  ------------------------------------------------------------------------------
  ModernSyntax
  Bringing modern language syntax and paradigms to Delphi through classes and methods.

  SPDX-License-Identifier: Apache-2.0
  Copyright (c) 2025-2026 Isaque Pinheiro

  Licensed under the Apache License, Version 2.0.
  See the LICENSE file in the project root for full license information.
  ------------------------------------------------------------------------------
}

unit Evolution.Coroutine;

interface

uses
  Rtti,
  Classes,
  SysUtils,
  SyncObjs,
  DateUtils,
  Threading,
  Generics.Collections,
  Evolution.System;

type
  TFuture = Evolution.System.TFuture;
  IScheduler = interface;

  TFuncCoroutine = reference to function(const ASendValue: TValue; const AValue: TValue): TFuture;

  {$SCOPEDENUMS ON}
  TCoroutineState = (csActive, csPaused, csFinished);
  {$SCOPEDENUMS OFF}

  TException = record
    IsException: Boolean;
    Message: String;
  end;

  TSend = record
    IsSend: Boolean;
    Name: String;
    Value: TValue;
  end;

  TPause = record
    IsPaused: Boolean;
    Name: String;
    Value: TValue;
  end;

  TParamNotify = record
  strict private
    FName: String;
    FValue: TValue;
    FSendValue: TValue;
  public
    constructor Create(const AName: String; const AValue: TValue; const ASendValue: TValue);
  end;

  TCoroutine = class sealed
  private
    FName: String;
    FState: TCoroutineState;
    FFunc: TFuncCoroutine;
    FProc: TProc;
    FValue: TValue;
    FSendValue: TValue;
    FSendCount: UInt32;
    FObserverList: TList<TCoroutine>;
    FParamNotify: TParamNotify;
    FLock: TCriticalSection;
    FInterval: UInt32;
    FLastExecutionTime: TDateTime;
  protected
    procedure _MarkExecution;
    function _IsReadyToExecute: Boolean;
    function _GetExecutionInterval: UInt32;
  public
    constructor Create(const AName: String; const AFunc: TFuncCoroutine;
      const AValue: TValue; const ACountSend: UInt32; const AProc: TProc;
      const AInterval: UInt32);
    destructor Destroy; override;
    procedure Attach(const AObserver: TCoroutine);
    procedure Detach(const AObserver: TCoroutine);
    procedure ObserverNotify;
    procedure Notify(const AParams: TParamNotify);
    function Assign: TCoroutine;
    property Name: String read FName write FName;
    property Func: TFuncCoroutine read FFunc;
    property Proc: TProc read FProc;
    property Value: TValue read FValue write FValue;
    property State: TCoroutineState read FState write FState;
    property SendValue: TValue read FSendValue write FSendValue;
    property SendCount: UInt32 read FSendCount write FSendCount;
  end;

  IScheduler = interface
    ['{BC104A19-9657-4093-A494-8D3CFD4CAF09}']
    function _GetCoroutine(AValue: String): TCoroutine;
    procedure Send(const AName: String; const AValue: TValue);
    procedure Suspend(const AName: String);
    procedure Resume(const AName: String);
    procedure Stop(const ATimeout: Cardinal = 1000);
    procedure Next;
    function Add(const AName: String; const ARoutine: TFuncCoroutine; const AValue: TValue;
      const AProc: TProc = nil; const AInterval: UInt32 = 0): IScheduler;
    function Value: TValue;
    function Yield(const AName: String): TValue;
    function Count: UInt32;
    function SendValue: TValue;
    function SendCount: UInt32;
    function Run(const AError: TProc<String>): IScheduler;
    function Started(const AHandler: TProc): IScheduler;
    function Finished(const AHandler: TProc): IScheduler;
    property Coroutine[Name: String]: TCoroutine read _GetCoroutine;
  end;

  TScheduler = class(TInterfacedObject, IScheduler)
  strict private
    type
      TGather<T> = class sealed(TList<T>)
      protected
        procedure Enqueue(const AValue: T);
        function Dequeue: T;
        function Peek: T;
      end;
    const
      C_COROUTINE_NOT_FOUND = 'No coroutine found with the specified name.';
  strict private
    FSleepTime: UInt16;
    FCurrentRoutine: TCoroutine;
    FCoroutines: TGather<TCoroutine>;
    FTask: ITask;
    FErrorCallback: TProc<String>;
    FStoped: Boolean;
    FSend: TSend;
    FPause: TPause;
    FException: TException;
    FLock: TCriticalSection;
    FOnStarted: TProc;
    FOnFinished: TProc;
    function _GetCoroutine(AValue: String): TCoroutine;
  protected
    function Run: IScheduler; overload;
    constructor Create(const ASleepTime: UInt16);
  public
    class function New(const ASleepTime: UInt16 = 500): IScheduler;
    destructor Destroy; override;
    procedure Send(const AName: String; const AValue: TValue);
    procedure Suspend(const AName: String);
    procedure Resume(const AName: String);
    procedure Stop(const ATimeout: Cardinal = 500);
    procedure Next;
    function Add(const AName: String; const ARoutine: TFuncCoroutine; const AValue: TValue;
      const AProc: TProc = nil; const AInterval: UInt32 = 0): IScheduler;
    function Value: TValue;
    function Yield(const AName: String): TValue;
    function Count: UInt32;
    function SendCount: UInt32;
    function SendValue: TValue;
    function Run(const AError: TProc<String>): IScheduler; overload;
    function Started(const AHandler: TProc): IScheduler;
    function Finished(const AHandler: TProc): IScheduler;
    property Coroutine[Name: String]: TCoroutine read _GetCoroutine;
  end;

  function TCompletion: TValue;

implementation

function TCompletion: TValue;
begin
  Result := TValue.Empty;
end;

{ TScheduler }

function TScheduler.Count: UInt32;
begin
  Result := FCoroutines.Count;
end;

function TScheduler.SendCount: UInt32;
begin
  Result := 0;
  if FCoroutines.Count = 0 then
    Exit;
  Result := FCoroutines.Peek.SendCount;
end;

function TScheduler.SendValue: TValue;
begin
  Result := FCurrentRoutine.SendValue;
end;

constructor TScheduler.Create(const ASleepTime: UInt16);
begin
  FStoped := False;
  FSleepTime := ASleepTime;
  FException := Default(TException);
  FCoroutines := TGather<TCoroutine>.Create;
  FLock := TCriticalSection.Create;
end;

destructor TScheduler.Destroy;
var
  LItem: TCoroutine;
begin
  Stop(500);
  for LItem in FCoroutines do
    LItem.Free;
  FCoroutines.Free;
  FLock.Free;
  inherited;
end;

function TScheduler.Finished(const AHandler: TProc): IScheduler;
begin
  FOnFinished := AHandler;
  Result := Self;
end;

function TScheduler._GetCoroutine(AValue: String): TCoroutine;
var
  LItem: TCoroutine;
begin
  Result := nil;
  for LItem in FCoroutines do
    if LItem.Name = AValue then
      Exit(LItem);
end;

function TScheduler.Yield(const AName: String): TValue;
var
  LCoroutine: TCoroutine;
begin
  if FCoroutines.Count = 0 then
    raise Exception.Create(C_COROUTINE_NOT_FOUND);
  LCoroutine := _GetCoroutine(AName);
  if Assigned(LCoroutine) then
  begin
    Suspend(AName);
    Result := LCoroutine.Value;
  end
  else
    Result := TValue.Empty;
end;

procedure TScheduler.Send(const AName: String; const AValue: TValue);
var
  LCoroutine: TCoroutine;
begin
  FLock.Acquire;
  try
    LCoroutine := _GetCoroutine(AName);
    if not Assigned(LCoroutine) then
      raise Exception.Create(C_COROUTINE_NOT_FOUND);
    FSend.IsSend := True;
    FSend.Name := AName;
    FSend.Value := AValue;
  finally
    FLock.Release;
  end;
end;

procedure TScheduler.Suspend(const AName: String);
var
  LCoroutine: TCoroutine;
begin
  FLock.Acquire;
  try
    LCoroutine := _GetCoroutine(AName);
    if Assigned(LCoroutine) then
    begin
      FPause.IsPaused := True;
      FPause.Name := AName;
      LCoroutine.State := TCoroutineState.csPaused;
    end
    else
      raise Exception.Create(C_COROUTINE_NOT_FOUND);
  finally
    FLock.Release;
  end;
end;

procedure TScheduler.Resume(const AName: String);
var
  LCoroutine: TCoroutine;
begin
  FLock.Acquire;
  try
    LCoroutine := _GetCoroutine(AName);
    if Assigned(LCoroutine) and (LCoroutine.State = TCoroutineState.csPaused) then
    begin
      LCoroutine.State := TCoroutineState.csActive;
      FPause.IsPaused := False;
      FPause.Name := '';
    end;
  finally
    FLock.Release;
  end;
end;

function TScheduler.Started(const AHandler: TProc): IScheduler;
begin
  FOnStarted := AHandler;
  Result := Self;
end;

procedure TScheduler.Stop(const ATimeout: Cardinal);
var
  LCoroutine: TCoroutine;
begin
  FLock.Acquire;
  try
    FStoped := True;
    for LCoroutine in FCoroutines do
      if LCoroutine.State = TCoroutineState.csPaused then
        LCoroutine.State := TCoroutineState.csActive;
  finally
    FLock.Release;
  end;
  if Assigned(FTask) then
    FTask.Wait(ATimeout);
end;

function TScheduler.Value: TValue;
begin
  if Assigned(FCurrentRoutine) then
    Result := FCurrentRoutine.Value
  else
    Result := TValue.Empty;
end;

function TScheduler.Add(const AName: String; const ARoutine: TFuncCoroutine;
  const AValue: TValue; const AProc: TProc; const AInterval: UInt32): IScheduler;
begin
  FLock.Acquire;
  try
    FCoroutines.Enqueue(TCoroutine.Create(AName, ARoutine, AValue, 0, AProc, AInterval));
    if not Assigned(FCurrentRoutine) then
      FCurrentRoutine := FCoroutines.Peek;
    Result := Self;
  finally
    FLock.Release;
  end;
end;

class function TScheduler.New(const ASleepTime: UInt16): IScheduler;
begin
  Result := TScheduler.Create(ASleepTime);
end;

procedure TScheduler.Next;
var
  LResultValue: TFuture;
begin
  FLock.Acquire;
  try
    if (FCoroutines.Count = 0) or FStoped then
      Exit;

    FCurrentRoutine := FCoroutines.Dequeue;
    if not Assigned(FCurrentRoutine) then
      Exit;

    try
      if FCurrentRoutine.State = TCoroutineState.csActive then
      begin
        if (FCurrentRoutine._GetExecutionInterval > 0) and not FCurrentRoutine._IsReadyToExecute then
        begin
          FCoroutines.Enqueue(FCurrentRoutine);
          Exit;
        end;

        if Assigned(FCurrentRoutine.Proc) then
        begin
          FCurrentRoutine.Proc();
          FCurrentRoutine._MarkExecution;
        end;

        LResultValue := FCurrentRoutine.Func(FCurrentRoutine.SendValue, FCurrentRoutine.Value);
        if LResultValue.IsErr then
          raise Exception.Create(LResultValue.Err);

        if not LResultValue.Ok<TValue>.IsEmpty then
        begin
          FCurrentRoutine.Value := LResultValue.Ok<TValue>;
          FCurrentRoutine.ObserverNotify;
          FCoroutines.Enqueue(FCurrentRoutine);
        end
        else
        begin
          FCurrentRoutine.State := TCoroutineState.csFinished;
          FCurrentRoutine.Free;
          FCurrentRoutine := FCoroutines.Peek;
        end;
      end
      else if FCurrentRoutine.State = TCoroutineState.csPaused then
      begin
        if (FSend.IsSend) and (FCurrentRoutine.Name = FSend.Name) then
        begin
          FCurrentRoutine.State := TCoroutineState.csActive;
          FCurrentRoutine.SendCount := FCurrentRoutine.SendCount + 1;
          if not FSend.Value.IsEmpty then
            FCurrentRoutine.SendValue := FSend.Value;
          FSend.IsSend := False;
          FSend.Name := '';
          FSend.Value := TValue.Empty;
        end;
        FCoroutines.Enqueue(FCurrentRoutine);
      end;
    except
      on E: Exception do
      begin
        FException.IsException := True;
        FException.Message := FCurrentRoutine.Name + ': ' + E.Message;
        FCurrentRoutine.Free;
        FCurrentRoutine := FCoroutines.Peek;
      end;
    end;
  finally
    FLock.Release;
  end;
end;

function TScheduler.Run(const AError: TProc<String>): IScheduler;
begin
  FErrorCallback := AError;
  Result := Run;
end;

function TScheduler.Run: IScheduler;
begin
  FTask := TTask.Run(procedure
    var
      LMessage: String;
    begin
      if Assigned(FOnStarted) and (FCoroutines.Count > 0) then
        FOnStarted();

      while (not FStoped) and (FCoroutines.Count > 0) do
      begin
        Next;
        if FException.IsException then
        begin
          LMessage := FException.Message;
          if Assigned(FErrorCallback) then
            TThread.Queue(nil, procedure begin FErrorCallback(LMessage); end);
          FException.IsException := False;
          FException.Message := '';
        end;
        Sleep(FSleepTime);
      end;

      if Assigned(FOnFinished) then
        FOnFinished();
    end);
  Result := Self;
end;

{ TCoroutine }

function TCoroutine.Assign: TCoroutine;
begin
  Result := Self;
end;

procedure TCoroutine.Attach(const AObserver: TCoroutine);
begin
  FLock.Acquire;
  try
    FObserverList.Add(AObserver);
  finally
    FLock.Release;
  end;
end;

constructor TCoroutine.Create(const AName: String; const AFunc: TFuncCoroutine;
  const AValue: TValue; const ACountSend: UInt32; const AProc: TProc; const AInterval: UInt32);
begin
  FName := AName;
  FFunc := AFunc;
  FProc := AProc;
  FValue := AValue;
  FSendValue := TValue.Empty;
  FSendCount := ACountSend;
  FState := TCoroutineState.csActive;
  FObserverList := TList<TCoroutine>.Create;
  FParamNotify := Default(TParamNotify);
  FLock := TCriticalSection.Create;
  FInterval := AInterval;
  FLastExecutionTime := Now;
end;

destructor TCoroutine.Destroy;
begin
  FObserverList.Free;
  FLock.Free;
  inherited;
end;

procedure TCoroutine.Detach(const AObserver: TCoroutine);
begin
  FLock.Acquire;
  try
    FObserverList.Remove(AObserver);
  finally
    FLock.Release;
  end;
end;

procedure TCoroutine.Notify(const AParams: TParamNotify);
begin
  FParamNotify := AParams;
end;

procedure TCoroutine.ObserverNotify;
var
  LItem: TCoroutine;
begin
  FLock.Acquire;
  try
    for LItem in FObserverList do
      LItem.Notify(TParamNotify.Create(FName, FValue, FSendValue));
  finally
    FLock.Release;
  end;
end;

function TCoroutine._GetExecutionInterval: UInt32;
begin
  Result := FInterval;
end;

function TCoroutine._IsReadyToExecute: Boolean;
begin
  Result := MilliSecondsBetween(Now, FLastExecutionTime) >= FInterval;
end;

procedure TCoroutine._MarkExecution;
begin
  FLastExecutionTime := Now;
end;

{ TScheduler.TGather<T> }

function TScheduler.TGather<T>.Dequeue: T;
begin
  if Count > 0 then
  begin
    Result := Items[0];
    Delete(0);
  end
  else
    Result := Default(T);
end;

procedure TScheduler.TGather<T>.Enqueue(const AValue: T);
begin
  Add(AValue);
end;

function TScheduler.TGather<T>.Peek: T;
begin
  if Count > 0 then
    Result := Items[0]
  else
    Result := Default(T);
end;

{ TParamNotify }

constructor TParamNotify.Create(const AName: String; const AValue, ASendValue: TValue);
begin
  FName := AName;
  FValue := AValue;
  FSendValue := ASendValue;
end;

end.
