{
  ------------------------------------------------------------------------------
  ModernSyntax
  Functional programming toolkit and modern syntax extension for Delphi.

  SPDX-License-Identifier: MIT
  Copyright (c) 2025-2026 Isaque Pinheiro

  Licensed under the MIT License.
  See the LICENSE file in the project root for full license information.
  ------------------------------------------------------------------------------
}

unit ModernSyntax.Coroutine;

interface

uses
  Rtti,
  Classes,
  SysUtils,
  SyncObjs,
  DateUtils,
  Threading,
  Generics.Collections,
  ModernSyntax;

const
  /// <summary>
  ///   Default deadline, in milliseconds, for an explicit <c>IScheduler.Stop</c>.
  /// </summary>
  /// <remarks>
  ///   Single source of truth on purpose. IScheduler.Stop used to default to 1000 while
  ///   TScheduler.Stop defaulted to 500, so the deadline you actually got depended on whether
  ///   the call went through the interface or the class - and every caller goes through the
  ///   interface, so 1000 was the effective default. Both declarations now use this constant.
  /// </remarks>
  C_STOP_TIMEOUT = 1000;

  /// <summary>
  ///   Deadline, in milliseconds, the destructor gives the worker before abandoning it.
  /// </summary>
  /// <remarks>
  ///   Deliberately far more generous than C_STOP_TIMEOUT: at destruction there is no second
  ///   chance. Whatever the destructor does not wait for, it either abandons (leaks) or
  ///   corrupts. Override per instance with TScheduler.New's second parameter.
  /// </remarks>
  C_SHUTDOWN_TIMEOUT = 5000;

  /// <summary>
  ///   Bounded budget, in milliseconds, for taking FLock inside Stop.
  /// </summary>
  C_STOP_LOCK_BUDGET = 250;

type
  TFuture = ModernSyntax.TFuture;
  IScheduler = interface;

  /// <summary>
  ///   Notified when a TScheduler had to be abandoned because its worker was still running at
  ///   destruction. <paramref name="ATimeoutMs"/> is the deadline that was given and blown.
  /// </summary>
  TSchedulerAbandonEvent = reference to procedure(const ATimeoutMs: Cardinal);

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

    /// <summary>
    ///   Asks the scheduler to stop and waits up to <paramref name="ATimeout"/> milliseconds
    ///   for the worker to actually finish.
    /// </summary>
    /// <returns>
    ///   True when the worker really stopped inside the deadline; False when the deadline
    ///   expired with the worker STILL RUNNING.
    /// </returns>
    /// <remarks>
    ///   THE RESULT IS NOT DECORATION. Until this became a function the Boolean returned by
    ///   ITask.Wait was discarded here - the same defect that made TAsync.Await report success
    ///   on a blown deadline. Stop looked like it had stopped the scheduler even when it had
    ///   not, and callers then released resources the worker was still touching.
    ///   A False result means the coroutines are STILL EXECUTING: do not free anything they
    ///   can reach, and do not assume the scheduler is idle.
    ///   Stop is idempotent and may be called again with a longer deadline.
    /// </remarks>
    function Stop(const ATimeout: Cardinal = C_STOP_TIMEOUT): Boolean;
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
    class var FAbandonedCount: Integer;
    class var FOnAbandon: TSchedulerAbandonEvent;
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
    FShutdownTimeout: Cardinal;
    FAbandoned: Boolean;
    function _GetCoroutine(AValue: String): TCoroutine;
    function _TryAcquireLock(const ABudgetMs: Cardinal): Boolean;
    procedure _Abandon(const ATimeoutMs: Cardinal);
  protected
    function Run: IScheduler; overload;
    constructor Create(const ASleepTime: UInt16; const AShutdownTimeout: Cardinal);
  public
    class function New(const ASleepTime: UInt16 = 500;
      const AShutdownTimeout: Cardinal = C_SHUTDOWN_TIMEOUT): IScheduler;

    /// <summary>
    ///   How many TScheduler instances have been abandoned so far in this process, i.e. how
    ///   many times the destructor found the worker still running past its deadline and chose
    ///   to leak rather than free memory the worker still dereferences.
    /// </summary>
    /// <remarks>
    ///   Non-zero is a defect signal in the HOST application, not in the scheduler: something
    ///   is destroying a scheduler whose coroutines will not yield. Also the observation point
    ///   for tests, since an abandoned instance cannot report anything about itself.
    /// </remarks>
    class function AbandonedCount: Integer; static;
    class procedure ResetAbandonedCount; static;

    /// <summary>
    ///   Optional hook invoked when an instance is abandoned. Left nil by default: this unit
    ///   deliberately does not pick an I/O channel (a destructor writing to stderr in a GUI
    ///   process is its own kind of bug). Exceptions raised by the handler are swallowed.
    /// </summary>
    class property OnAbandon: TSchedulerAbandonEvent read FOnAbandon write FOnAbandon;

    destructor Destroy; override;

    /// <summary>
    ///   Releases the instance memory, UNLESS this scheduler was abandoned.
    /// </summary>
    /// <remarks>
    ///   TObject.FreeInstance is CleanupInstance + _FreeMem, so skipping it keeps BOTH the
    ///   object storage and its managed fields (FTask, the TValues, the closures) alive. That
    ///   is the whole point: an abandoned scheduler still has a worker thread dereferencing
    ///   Self, and freeing the storage under it is exactly the use-after-free this change
    ///   exists to prevent. Leaking a scheduler is bounded and diagnosable; corrupting the heap
    ///   from a background thread is neither.
    /// </remarks>
    procedure FreeInstance; override;

    procedure Send(const AName: String; const AValue: TValue);
    procedure Suspend(const AName: String);
    procedure Resume(const AName: String);
    function Stop(const ATimeout: Cardinal = C_STOP_TIMEOUT): Boolean;
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

constructor TScheduler.Create(const ASleepTime: UInt16; const AShutdownTimeout: Cardinal);
begin
  FStoped := False;
  FAbandoned := False;
  FSleepTime := ASleepTime;
  FShutdownTimeout := AShutdownTimeout;
  FException := Default(TException);
  FCoroutines := TGather<TCoroutine>.Create;
  FLock := TCriticalSection.Create;
end;

class function TScheduler.AbandonedCount: Integer;
begin
  Result := FAbandonedCount;
end;

class procedure TScheduler.ResetAbandonedCount;
begin
  FAbandonedCount := 0;
end;

procedure TScheduler._Abandon(const ATimeoutMs: Cardinal);
begin
  FAbandoned := True;
  AtomicIncrement(FAbandonedCount);
  if not Assigned(FOnAbandon) then
    Exit;
  try
    FOnAbandon(ATimeoutMs);
  except
    // A destructor must not propagate, least of all because of a diagnostic hook.
  end;
end;

procedure TScheduler.FreeInstance;
begin
  if FAbandoned then
    Exit;
  inherited FreeInstance;
end;

// SHUTDOWN CONTRACT
// -----------------
// The worker started by Run dereferences Self on every iteration: it reads FStoped, calls Next
// (which takes FLock and walks FCoroutines) and finally FOnFinished. The old destructor gave it
// Stop(500), IGNORED the answer, and then freed the coroutines, the list and the lock - so any
// worker that had not finished in 500 ms was left walking released memory. Use-after-free at
// shutdown, on a background thread, which is the hardest possible place to diagnose it.
//
// There is no third option here. Either the destructor waits until the worker is provably done,
// or it must not touch anything the worker can reach. Waiting forever is not acceptable either:
// a coroutine body that never returns would hang process shutdown with no way out.
//
// The middle ground, in order:
//   1) ask to stop and wait FShutdownTimeout (default 5 s - ten times the old deadline, and
//      per-instance tunable through TScheduler.New for callers with harder shutdown budgets);
//   2) if it stopped, free everything exactly as before;
//   3) if it did NOT stop, ABANDON: free nothing, skip FreeInstance, count it and fire
//      OnAbandon. The process leaks one scheduler and its coroutines - bounded, visible through
//      AbandonedCount, and infinitely preferable to heap corruption from a live thread.
// A non-zero AbandonedCount is a bug report about the host: some coroutine is not yielding.
destructor TScheduler.Destroy;
var
  LItem: TCoroutine;
  LStopped: Boolean;
begin
  try
    LStopped := Stop(FShutdownTimeout);
  except
    // ITask.Wait re-raises whatever the worker raised. A faulted task is a FINISHED task, and
    // "finished" is the only thing this decision depends on.
    LStopped := True;
  end;

  if not LStopped then
  begin
    _Abandon(FShutdownTimeout);
    inherited;
    Exit;
  end;

  for LItem in FCoroutines do
    LItem.Free;
  FCoroutines.Free;
  FCoroutines := nil;
  FLock.Free;
  FLock := nil;
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

function TScheduler._TryAcquireLock(const ABudgetMs: Cardinal): Boolean;
var
  LStart: TDateTime;
begin
  LStart := Now;
  repeat
    Result := FLock.TryEnter;
    if Result then
      Exit;
    Sleep(1);
  until Cardinal(MilliSecondsBetween(Now, LStart)) >= ABudgetMs;
end;

function TScheduler.Stop(const ATimeout: Cardinal): Boolean;
var
  LCoroutine: TCoroutine;
begin
  // The stop flag is published WITHOUT the lock, on purpose. It is a plain Boolean that the
  // worker only polls (Run's `while not FStoped`, which already read it unsynchronised), and
  // taking the lock first would block forever whenever a coroutine body hangs while Next holds
  // it - precisely the case Stop has to survive. Requesting a stop must never be the thing that
  // hangs.
  FStoped := True;

  // The un-pause walk DOES need the lock, because it touches FCoroutines. Bounded, so a hung
  // coroutine cannot turn Stop into an unbounded wait. Skipping it costs nothing for
  // termination: the loop exits on FStoped regardless of any paused state.
  if _TryAcquireLock(C_STOP_LOCK_BUDGET) then
  begin
    try
      for LCoroutine in FCoroutines do
        if LCoroutine.State = TCoroutineState.csPaused then
          LCoroutine.State := TCoroutineState.csActive;
    finally
      FLock.Release;
    end;
  end;

  // THE POINT OF THE CHANGE: ITask.Wait's Boolean was discarded here, exactly as it was in
  // TAsync.Await before #7, so Stop could not tell "stopped" from "gave up waiting".
  if not Assigned(FTask) then
    Exit(True);            // never started: there is nothing still running
  Result := FTask.Wait(ATimeout);
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

class function TScheduler.New(const ASleepTime: UInt16;
  const AShutdownTimeout: Cardinal): IScheduler;
begin
  Result := TScheduler.Create(ASleepTime, AShutdownTimeout);
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
