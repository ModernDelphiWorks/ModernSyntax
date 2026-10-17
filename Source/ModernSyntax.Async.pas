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

  /// <summary>
  ///   Handle to one asynchronous routine. Copies of a TAsync share the same task.
  /// </summary>
  /// <remarks>
  ///   OWNERSHIP: the record holds a reference-counted state object. The worker task holds a link
  ///   with the routine and a reference to that state, and the link lets go of both explicitly:
  ///   when the routine has run (after its outcome is published) and when Cancel drops a routine
  ///   that has not run yet. So nothing a routine captures - not even the TAsync itself, as in the
  ///   LAsync.CheckCanceled pattern - keeps a reference cycle alive once the task has run or has
  ///   been cancelled, and a fire-and-forget task keeps its state (and its AError) until it ends.
  ///   One case still keeps memory: a TAsync that is NEVER started (no Run/NoAwait/Await) and
  ///   whose routine captures that same TAsync. Start it, or Cancel it, to release the routine.
  ///
  ///   PROCESS EXIT: the RTL thread pool waits for its running tasks when the process ends. An
  ///   orphan left behind by an expired deadline therefore delays the exit until its routine
  ///   returns. Long routines should be cooperative (call CheckCanceled) and be cancelled.
  /// </remarks>
  TAsync = record
  private
    FState: IInterface;
    constructor Create(const AProc: TProc); overload;
    constructor Create(const AFunc: TFunc<TValue>); overload;
  public
    /// <summary>
    ///   Starts the routine if it is not running yet, waits for it, then runs
    ///   <paramref name="AContinue"/> and returns the future.
    /// </summary>
    /// <remarks>
    ///   ONE EXECUTION PER TAsync: the routine runs once. Calling Await after Run/NoAwait waits
    ///   for the task that is already running instead of starting a second one, and calling
    ///   Await again returns the same outcome.
    ///
    ///   TIMEOUT SEMANTICS: when <paramref name="ATimeout"/> elapses before the task
    ///   completes, the returned future is an ERROR (IsErr) whose message states that it
    ///   was a TIMEOUT and quotes the deadline in milliseconds. The continuation is NOT
    ///   executed and no success value is published. The timeout wins over a task exception.
    ///   A timeout does not cancel anything: the task keeps running and may be awaited again.
    ///   A TAsync that goes out of scope after a timeout is safe (the fluent
    ///   Async(...).Await(50) form included); see PROCESS EXIT on the type.
    ///
    ///   CANCELLATION: Await on a cancelled task returns an error future (not a timeout) instead
    ///   of raising.
    ///
    ///   CONTINUATION: <paramref name="AContinue"/> runs on the thread that called Await, right
    ///   after the task completes and before Await returns. An exception it raises becomes the
    ///   error of the returned future.
    ///
    ///   The lock that guards the state is never held while waiting, so Status, Cancel and
    ///   GetId called from another thread return immediately during an Await.
    ///
    ///   USE IsAwaitTimeout(LFuture) to tell a blown deadline from a task failure; do not
    ///   pattern-match the message text yourself.
    /// </remarks>
    function Await(const AContinue: TProc; const ATimeout: Cardinal = INFINITE): TFuture; overload;

    /// <summary>
    ///   Starts the routine if it is not running yet, waits for it and returns the future.
    /// </summary>
    /// <remarks>
    ///   Same single-execution, TIMEOUT, cancellation and lifetime semantics as the overload above.
    /// </remarks>
    function Await(const ATimeout: Cardinal = INFINITE): TFuture; overload;

    /// <summary>
    ///   Starts the routine (procedure form) and returns at once.
    /// </summary>
    /// <remarks>
    ///   A routine that raises leaves the task observable as failed: Status reports
    ///   TTaskStatus.Exception and a later Await returns the error. The optional AError of the
    ///   overload below is still delivered through TThread.Queue (main thread), as before; the
    ///   Exception passed to it is freed after the handler returns.
    /// </remarks>
    function Run: TFuture; overload;
    function Run(const AError: TFunc<Exception, TFuture>): TFuture; overload;
    function NoAwait: TFuture; overload;
    function NoAwait(const AError: TFunc<Exception, TFuture>): TFuture; overload;

    /// <summary>
    ///   Status of the task: Created before it starts, Canceled when it was cancelled before its
    ///   routine ran, Exception when the routine raised. Never blocks, also while another thread
    ///   is inside Await.
    /// </summary>
    function Status: TTaskStatus;
    function GetId: Integer;

    /// <summary>
    ///   Cancels the task. Before the routine runs (not started yet, or still queued) the
    ///   routine is dropped and never runs; while it runs, it observes the cancellation through
    ///   CheckCanceled.
    /// </summary>
    procedure Cancel;
    procedure CheckCanceled;
  end;

function Async(const AProc: TProc): TAsync; overload; inline;
function Async(const AFunc: TFunc<TValue>): TAsync; overload; inline;

/// <summary>
///   Starts every task, then waits for all of them under ONE shared deadline.
/// </summary>
/// <remarks>
///   The tasks run concurrently: the total wait is about the slowest task, not the sum.
///   Result[I] is the future of ATasks[I], with the same semantics as TAsync.Await; a task
///   still running when the deadline expires gets the timeout error (see IsAwaitTimeout).
///   Like Await, an expired deadline does not cancel the tasks.
/// </remarks>
function AwaitAll(const ATasks: array of TAsync; const ATimeout: Cardinal = INFINITE): TArray<TFuture>;

/// <summary>
///   Starts every task and waits for the first one to finish (completed, failed or cancelled).
/// </summary>
/// <remarks>
///   AIndex receives the position of that task in ATasks, and the result is its future (an
///   error future when it failed or was cancelled). When several have finished, the lowest
///   index wins. When the deadline expires first, AIndex is -1 and the result is the timeout
///   error. The other tasks keep running and can still be awaited.
/// </remarks>
function AwaitAny(const ATasks: array of TAsync; out AIndex: Integer;
  const ATimeout: Cardinal = INFINITE): TFuture;

/// <summary>
///   True when <paramref name="AFuture"/> is the error produced by an Await deadline that
///   expired, as opposed to an error produced by the task itself.
/// </summary>
/// <remarks>
///   THE ONE SUPPORTED WAY TO CLASSIFY A RED FUTURE. Before this existed the only way to tell
///   a blown deadline from a task failure was Pos('TIMEOUT', LFuture.Err) over the message -
///   which silently breaks the day the message is reworded, and misfires whenever a task's own
///   exception happens to contain the word.
///   Returns False for a successful future, for an empty error, and for any error the task
///   raised. See the note on the timeout message in the implementation for why the text is
///   frozen instead of TFuture carrying a discriminator field.
/// </remarks>
function IsAwaitTimeout(const AFuture: TFuture): Boolean;

implementation

uses
  SysConst;

const
  // FROZEN PUBLIC CONTRACT - DO NOT TRANSLATE, DO NOT REWORD THE PREFIX.
  // ------------------------------------------------------------------
  // A timeout is only distinguishable from a task failure by this message: TFuture carries
  // FValue/FErr/FIsOk/FIsErr and nothing that says WHY it is red. Two ways out were considered:
  //
  //   (a) give TFuture a discriminator (an error-kind enum, or an IsTimeout flag);
  //   (b) freeze the message and expose the classification in exactly one place.
  //
  // (b) was chosen, deliberately, because (a) changes public surface that is not this unit's to
  // change. TFuture lives in ModernSyntax.pas, is the return type of the whole Async API AND of
  // TFuncCoroutine in ModernSyntax.Coroutine, and is built by consumers directly through
  // SetOk/SetErr. A new state that only Await knows how to set would default to "not a timeout"
  // in every existing SetErr call site - inside this repository and in consumer code - so the
  // discriminator would be correct only where it was retrofitted and quietly wrong everywhere
  // else. That is a worse contract than a frozen string.
  //
  // Consequences of the choice, all intentional:
  //   * this is a const, NOT a resourcestring - a resourcestring is exactly what a translation
  //     tool patches, and translating it would break every consumer and the test suite at once,
  //     silently. Making it non-localizable is the enforcement, not just the documentation;
  //   * the ASCII prefix in C_AWAIT_TIMEOUT_TAG is the contract. The tail after the tag is free
  //     to be improved; the tag is not;
  //   * consumers must classify with IsAwaitTimeout, never with their own Pos/Copy over Err.
  //
  // If a discriminator is ever wanted, it is an additive change to TFuture with a migration for
  // every SetErr call site - a separate PR, not a side effect of a documentation pass.
  C_AWAIT_TIMEOUT_TAG = 'Async await TIMEOUT:';
  C_AWAIT_TIMEOUT_MESSAGE = C_AWAIT_TIMEOUT_TAG + ' the task did not complete within %d ms. ' +
    'The task was not canceled and may still be running; its result and any exception it ' +
    'raises are discarded.';
  C_RUN_AS_FUNCTION_MESSAGE = 'The "Run" method should not be invoked as a function. Utilize the "Await" method to wait for task completion and access the result, or invoke it as a procedure.';
  C_NOT_CREATED_MESSAGE = 'TAsync was not created: use Async(...) to create it.';
  C_ANY_EMPTY_MESSAGE = 'AwaitAny needs at least one task';
  C_POLL_SLICE_MS = 20;

type
  { What the worker task holds: the routine (until it runs or is cancelled) and a reference to the
    state. state -> task -> closure -> link -> state is a cycle on purpose while the task is alive
    (a fire-and-forget task must keep its state and its AError until it ends), and it is broken
    explicitly: TakeState after the routine ran, DropWork when Cancel drops a routine that has not
    run. A [Weak] back-reference is NOT an option: promoting a Delphi weak reference to a strong one
    is a plain _AddRef with no "already zero" check, so the pool thread could resurrect a state that
    the last TAsync was destroying (measured: AV / invalid pointer in a NoAwait loop). }
  TAsyncLink = class(TInterfacedObject)
  private
    FLock: TCriticalSection;
    FState: IInterface;
    FProc: TProc;
    FFunc: TFunc<TValue>;
    FTaken: Boolean;
  public
    constructor Create(const AState: IInterface; const AProc: TProc; const AFunc: TFunc<TValue>);
    destructor Destroy; override;
    { Moves the routine out (once). False when it was dropped by Cancel. }
    function TakeWork(out AProc: TProc; out AFunc: TFunc<TValue>): Boolean;
    { Cancel: drops the routine and the state when the routine has not been taken yet }
    procedure DropWork;
    { After the routine ran: moves the state reference out, breaking the cycle }
    function TakeState: IInterface;
  end;

  { Shared state of one TAsync. Every field is guarded by FLock, and FLock is only held for
    short, non-blocking sections - never across ITask.Wait. }
  TAsyncState = class(TInterfacedObject)
  private
    FLock: TCriticalSection;
    FProc: TProc;
    FFunc: TFunc<TValue>;
    FIsFunc: Boolean;
    FTask: ITask;
    FLink: IInterface;
    FCancelRequested: Boolean;
    FCompleted: Boolean;
    FFailed: Boolean;
    FValue: TValue;
    FErrorMessage: String;
    FError: TFunc<Exception, TFuture>;
  public
    constructor Create(const AProc: TProc; const AFunc: TFunc<TValue>);
    destructor Destroy; override;
    function Start: ITask;
    function Task: ITask;
    function WaitFuture(const AContinue: TProc; const ATimeout: Cardinal): TFuture;
    procedure Publish(const AValue: TValue; ARaised: Boolean; const AMessage: String;
      out AError: TFunc<Exception, TFuture>);
    function GetStatus: TTaskStatus;
    procedure Cancel;
    procedure SetErrorHandler(const AError: TFunc<Exception, TFuture>);
    property IsFunc: Boolean read FIsFunc;
  end;

function _AwaitTimeoutMessage(const ATimeout: Cardinal): String;
begin
  Result := Format(C_AWAIT_TIMEOUT_MESSAGE, [ATimeout]);
end;

function _CancelledMessage: String;
begin
  Result := SOperationCancelled;
end;

function IsAwaitTimeout(const AFuture: TFuture): Boolean;
var
  LErr: String;
begin
  Result := False;
  if not AFuture.IsErr then
    Exit;
  LErr := AFuture.Err;
  // Anchored at position 1 on purpose: a task whose own exception message merely CONTAINS the
  // word must not be misread as a blown deadline.
  Result := Copy(LErr, 1, Length(C_AWAIT_TIMEOUT_TAG)) = C_AWAIT_TIMEOUT_TAG;
end;

function _State(const AState: IInterface): TAsyncState; inline;
begin
  Result := TAsyncState(AState as TObject);
end;

{ The handler call queued to the main thread; the Exception it receives is freed afterwards }
function _ErrorDelivery(const AError: TFunc<Exception, TFuture>; const AMessage: String): TThreadProcedure;
begin
  Result :=
    procedure
    var
      LException: Exception;
    begin
      LException := Exception.Create(AMessage);
      try
        AError(LException);
      finally
        LException.Free;
      end;
    end;
end;

{ Runs on the pool thread. Kept out of TAsyncState on purpose: the closure that TTask stores must
  capture only the link, never the state (a method would capture Self). }
procedure _RunLink(const ALink: IInterface);
var
  LLink: TAsyncLink;
  LProc: TProc;
  LFunc: TFunc<TValue>;
  LValue: TValue;
  LMessage: String;
  LRaised: Boolean;
  LState: IInterface;
  LError: TFunc<Exception, TFuture>;
begin
  LLink := TAsyncLink(ALink as TObject);
  if not LLink.TakeWork(LProc, LFunc) then
  begin
    // Dropped by Cancel (the state is already gone from the link) or created with a nil routine
    // (the state is still here): a nil routine is a no-op that completes
    LState := LLink.TakeState;
    if LState <> nil then
      _State(LState).Publish(TValue.Empty, False, '', LError);
    Exit;
  end;
  LRaised := False;
  try
    if Assigned(LFunc) then
      LValue := LFunc()
    else if Assigned(LProc) then
      LProc();
  except
    on E: Exception do
    begin
      LRaised := True;
      LMessage := E.Message;
    end;
  end;
  // Drop the routine (and what it captured) before publishing
  LProc := nil;
  LFunc := nil;

  // The link lets go of the state here: from now on only the TAsync copies keep it alive
  LState := LLink.TakeState;
  if LState = nil then
    Exit;
  _State(LState).Publish(LValue, LRaised, LMessage, LError);
  LState := nil;

  // Unchanged contract of Run(AError)/NoAwait(AError): the handler is delivered to the main thread
  if LRaised and Assigned(LError) then
    TThread.Queue(nil, _ErrorDelivery(LError, LMessage));
end;

function _StartTask(const ALink: IInterface): ITask;
begin
  Result := TTask.Run(
    procedure
    begin
      _RunLink(ALink);
    end);
end;

{ TAsyncLink }

constructor TAsyncLink.Create(const AState: IInterface; const AProc: TProc; const AFunc: TFunc<TValue>);
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FState := AState;
  FProc := AProc;
  FFunc := AFunc;
end;

destructor TAsyncLink.Destroy;
begin
  FLock.Free;
  inherited;
end;

function TAsyncLink.TakeWork(out AProc: TProc; out AFunc: TFunc<TValue>): Boolean;
begin
  FLock.Acquire;
  try
    AProc := FProc;
    AFunc := FFunc;
    FProc := nil;
    FFunc := nil;
    Result := Assigned(AProc) or Assigned(AFunc);
    FTaken := Result;
  finally
    FLock.Release;
  end;
end;

procedure TAsyncLink.DropWork;
var
  LState: IInterface;
  LProc: TProc;
  LFunc: TFunc<TValue>;
begin
  FLock.Acquire;
  try
    // A routine that is already running keeps the state: it still has to publish its outcome
    if FTaken then
      Exit;
    LProc := FProc;
    LFunc := FFunc;
    LState := FState;
    FProc := nil;
    FFunc := nil;
    FState := nil;
  finally
    FLock.Release;
  end;
  // Released outside the lock: the routine or the state may hold the last reference to this link
  LProc := nil;
  LFunc := nil;
  LState := nil;
end;

function TAsyncLink.TakeState: IInterface;
begin
  FLock.Acquire;
  try
    Result := FState;
    FState := nil;
  finally
    FLock.Release;
  end;
end;

{ TAsyncState }

constructor TAsyncState.Create(const AProc: TProc; const AFunc: TFunc<TValue>);
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FProc := AProc;
  FFunc := AFunc;
  FIsFunc := Assigned(AFunc);
end;

destructor TAsyncState.Destroy;
begin
  FLock.Free;
  inherited;
end;

procedure TAsyncState.SetErrorHandler(const AError: TFunc<Exception, TFuture>);
begin
  FLock.Acquire;
  try
    FError := AError;
  finally
    FLock.Release;
  end;
end;

function TAsyncState.Start: ITask;
var
  LLink: IInterface;
begin
  FLock.Acquire;
  try
    if (FTask = nil) and not FCancelRequested then
    begin
      // The routine moves to the link: from here on the state no longer holds it
      LLink := TAsyncLink.Create(Self, FProc, FFunc);
      FProc := nil;
      FFunc := nil;
      FLink := LLink;
      FTask := _StartTask(LLink);
    end;
    Result := FTask;
  finally
    FLock.Release;
  end;
end;

function TAsyncState.Task: ITask;
begin
  FLock.Acquire;
  try
    Result := FTask;
  finally
    FLock.Release;
  end;
end;

procedure TAsyncState.Publish(const AValue: TValue; ARaised: Boolean; const AMessage: String;
  out AError: TFunc<Exception, TFuture>);
begin
  FLock.Acquire;
  try
    FValue := AValue;
    FFailed := ARaised;
    FErrorMessage := AMessage;
    FCompleted := True;
    AError := FError;
  finally
    FLock.Release;
  end;
end;

procedure TAsyncState.Cancel;
var
  LTask: ITask;
  LLink: IInterface;
begin
  FLock.Acquire;
  try
    FCancelRequested := True;
    LTask := FTask;
    LLink := FLink;
    if LTask = nil then
    begin
      // Never started: drop the routine now, it will never run
      FProc := nil;
      FFunc := nil;
    end;
  finally
    FLock.Release;
  end;
  if LTask <> nil then
    LTask.Cancel;
  // Still queued: the pool never runs a cancelled task, so the routine is released here
  if LLink <> nil then
    TAsyncLink(LLink as TObject).DropWork;
end;

function TAsyncState.GetStatus: TTaskStatus;
var
  LTask: ITask;
  LCancelRequested, LCompleted, LFailed: Boolean;
begin
  FLock.Acquire;
  try
    LTask := FTask;
    LCancelRequested := FCancelRequested;
    LCompleted := FCompleted;
    LFailed := FFailed;
  finally
    FLock.Release;
  end;
  if LTask = nil then
  begin
    if LCancelRequested then
      Exit(TTaskStatus.Canceled);
    Exit(TTaskStatus.Created);
  end;
  Result := LTask.Status;
  if Result = TTaskStatus.Completed then
  begin
    // The routine's exception is caught inside the task (so Wait never raises for it), which
    // leaves the ITask Completed: report what the routine actually did
    if LFailed then
      Result := TTaskStatus.Exception
    else if not LCompleted then
      Result := TTaskStatus.Canceled; // the routine was dropped by Cancel and never ran
  end;
end;

function TAsyncState.WaitFuture(const AContinue: TProc; const ATimeout: Cardinal): TFuture;
var
  LTask: ITask;
  LCompleted, LFailed: Boolean;
  LMessage: String;
  LValue: TValue;
begin
  try
    LTask := Start;
    if LTask = nil then
    begin
      // Cancelled before it was ever started
      Result.SetErr(_CancelledMessage);
      Exit;
    end;
    // Wait OUTSIDE the lock: Status/Cancel/GetId from other threads must not block on an Await.
    // ITask.Wait returns False when the deadline expires; INFINITE never does.
    if (not LTask.Wait(ATimeout)) and (ATimeout <> INFINITE) then
    begin
      Result.SetErr(_AwaitTimeoutMessage(ATimeout));
      Exit;
    end;
  except
    // A cancelled task makes ITask.Wait raise: report it as the error of the future
    on E: Exception do
    begin
      Result.SetErr(E.Message);
      Exit;
    end;
  end;

  FLock.Acquire;
  try
    LCompleted := FCompleted;
    LFailed := FFailed;
    LMessage := FErrorMessage;
    LValue := FValue;
  finally
    FLock.Release;
  end;

  if not LCompleted then
  begin
    // The task ended without running the routine: it was cancelled while queued
    Result.SetErr(_CancelledMessage);
    Exit;
  end;
  if LFailed then
  begin
    Result.SetErr(LMessage);
    Exit;
  end;

  // The continuation runs here, on the awaiting thread, before Await returns
  if Assigned(AContinue) then
    try
      AContinue();
    except
      on E: Exception do
      begin
        Result.SetErr(E.Message);
        Exit;
      end;
    end;

  if FIsFunc then
    Result.SetOk(LValue)
  else
    Result.SetOk(True);
end;

{ TAsync }

function Async(const AProc: TProc): TAsync;
begin
  Result := TAsync.Create(AProc);
end;

function Async(const AFunc: TFunc<TValue>): TAsync;
begin
  Result := TAsync.Create(AFunc);
end;

constructor TAsync.Create(const AProc: TProc);
begin
  FState := TAsyncState.Create(AProc, nil);
end;

constructor TAsync.Create(const AFunc: TFunc<TValue>);
begin
  FState := TAsyncState.Create(nil, AFunc);
end;

function TAsync.Await(const AContinue: TProc; const ATimeout: Cardinal): TFuture;
begin
  if FState = nil then
  begin
    Result.SetErr(C_NOT_CREATED_MESSAGE);
    Exit;
  end;
  Result := _State(FState).WaitFuture(AContinue, ATimeout);
end;

function TAsync.Await(const ATimeout: Cardinal): TFuture;
begin
  if FState = nil then
  begin
    Result.SetErr(C_NOT_CREATED_MESSAGE);
    Exit;
  end;
  Result := _State(FState).WaitFuture(nil, ATimeout);
end;

function TAsync.Run: TFuture;
begin
  if FState = nil then
  begin
    Result.SetErr(C_NOT_CREATED_MESSAGE);
    Exit;
  end;
  if _State(FState).IsFunc then
  begin
    Result.SetErr(C_RUN_AS_FUNCTION_MESSAGE);
    Exit;
  end;
  try
    _State(FState).Start;
    Result.SetOk(True);
  except
    on E: Exception do
      Result.SetErr(E.Message);
  end;
end;

function TAsync.Run(const AError: TFunc<Exception, TFuture>): TFuture;
begin
  if FState <> nil then
    _State(FState).SetErrorHandler(AError);
  Result := Run;
end;

function TAsync.NoAwait: TFuture;
begin
  Result := Run;
end;

function TAsync.NoAwait(const AError: TFunc<Exception, TFuture>): TFuture;
begin
  Result := Run(AError);
end;

function TAsync.Status: TTaskStatus;
begin
  if FState = nil then
    Exit(TTaskStatus.Created);
  Result := _State(FState).GetStatus;
end;

function TAsync.GetId: Integer;
var
  LTask: ITask;
begin
  Result := -1;
  if FState = nil then
    Exit;
  LTask := _State(FState).Task;
  if LTask <> nil then
    Result := LTask.GetId;
end;

procedure TAsync.Cancel;
begin
  if FState <> nil then
    _State(FState).Cancel;
end;

procedure TAsync.CheckCanceled;
var
  LTask: ITask;
begin
  if FState = nil then
    Exit;
  LTask := _State(FState).Task;
  if LTask <> nil then
    LTask.CheckCanceled;
end;

{ AwaitAll / AwaitAny }

function AwaitAll(const ATasks: array of TAsync; const ATimeout: Cardinal): TArray<TFuture>;
var
  LIndex: Integer;
  LStart: UInt64;
  LElapsed: UInt64;
  LRemaining: Cardinal;
begin
  SetLength(Result, Length(ATasks));
  // Start everything first, so the tasks overlap (Start, not Run: Run refuses the function form)
  for LIndex := 0 to High(ATasks) do
    if ATasks[LIndex].FState <> nil then
      _State(ATasks[LIndex].FState).Start;
  LStart := TThread.GetTickCount64;
  for LIndex := 0 to High(ATasks) do
  begin
    if ATimeout = INFINITE then
      LRemaining := INFINITE
    else
    begin
      LElapsed := TThread.GetTickCount64 - LStart;
      if LElapsed >= ATimeout then
        LRemaining := 0
      else
        LRemaining := ATimeout - Cardinal(LElapsed);
    end;
    Result[LIndex] := ATasks[LIndex].Await(LRemaining);
    // Await(LRemaining) quotes the remaining budget; report the deadline the caller asked for
    if IsAwaitTimeout(Result[LIndex]) then
      Result[LIndex].SetErr(_AwaitTimeoutMessage(ATimeout));
  end;
end;

function AwaitAny(const ATasks: array of TAsync; out AIndex: Integer; const ATimeout: Cardinal): TFuture;
var
  LIndex: Integer;
  LStart: UInt64;
  LTasks: TArray<ITask>;
  LTask: ITask;
begin
  AIndex := -1;
  if Length(ATasks) = 0 then
  begin
    Result.SetErr(C_ANY_EMPTY_MESSAGE);
    Exit;
  end;
  for LIndex := 0 to High(ATasks) do
    if ATasks[LIndex].FState <> nil then
    begin
      LTask := _State(ATasks[LIndex].FState).Start;
      if LTask <> nil then
        LTasks := LTasks + [LTask];
    end;

  LStart := TThread.GetTickCount64;
  repeat
    // A finished task - completed, failed or cancelled - is the answer; lowest index first
    for LIndex := 0 to High(ATasks) do
      case ATasks[LIndex].Status of
        TTaskStatus.Canceled:
          begin
            // A cancelled routine may still be running (cooperative cancellation): answer now,
            // without waiting for it, so the deadline holds
            AIndex := LIndex;
            Result.SetErr(_CancelledMessage);
            Exit;
          end;
        TTaskStatus.Completed, TTaskStatus.Exception:
          begin
            AIndex := LIndex;
            Result := ATasks[LIndex].Await; // already finished: returns at once
            Exit;
          end;
      end;
    if (ATimeout <> INFINITE) and (TThread.GetTickCount64 - LStart >= ATimeout) then
      Break;
    // Sleep until something finishes (or a short slice): WaitForAny raises when the task that
    // finished was cancelled, which only means "look again"
    try
      if Length(LTasks) > 0 then
        TTask.WaitForAny(LTasks, C_POLL_SLICE_MS)
      else
        Sleep(C_POLL_SLICE_MS);
    except
      // see above
    end;
  until False;
  Result.SetErr(_AwaitTimeoutMessage(ATimeout));
end;

{ TAutoLock }

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
