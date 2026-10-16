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

  /// <summary>
  ///   Shared, reference-counted state of one asynchronous routine.
  /// </summary>
  /// <remarks>
  ///   The worker task holds a reference to this object, never a pointer to the TAsync record.
  ///   That is what makes every copy of a TAsync, and every orphan left behind by an expired
  ///   deadline, safe: the state lives as long as anyone - the caller or the worker - still uses it.
  /// </remarks>
  IAsyncState = interface
    ['{6F0B7D2E-31A4-4C5E-9B8D-2A7E5C1F9D43}']
    function Start: ITask;
    function Task: ITask;
    function WaitFuture(const AContinue: TProc; const ATimeout: Cardinal): TFuture;
    function IsFunc: Boolean;
    function Failed: Boolean;
    procedure SetErrorHandler(const AError: TFunc<Exception, TFuture>);
  end;

  PAsync = ^TAsync;
  TAsync = record
  private
    FState: IAsyncState;
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
    ///   The orphan task keeps its own reference to the shared state, so a TAsync that goes out
    ///   of scope after a timeout is safe (the fluent Async(...).Await(50) form included).
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
    function Await(const AContinue: TProc; const ATimeout: Cardinal = INFINITE): TFuture; overload; inline;

    /// <summary>
    ///   Starts the routine if it is not running yet, waits for it and returns the future.
    /// </summary>
    /// <remarks>
    ///   Same single-execution, TIMEOUT and lifetime semantics as the overload above.
    /// </remarks>
    function Await(const ATimeout: Cardinal = INFINITE): TFuture; overload; inline;

    /// <summary>
    ///   Starts the routine (procedure form) and returns at once.
    /// </summary>
    /// <remarks>
    ///   A routine that raises leaves the task observable as failed: Status reports
    ///   TTaskStatus.Exception and a later Await returns the error. The optional AError of the
    ///   overload below is still delivered through TThread.Queue (main thread), as before.
    /// </remarks>
    function Run: TFuture; overload;
    function Run(const AError: TFunc<Exception, TFuture>): TFuture; overload; inline;
    function NoAwait: TFuture; overload;
    function NoAwait(const AError: TFunc<Exception, TFuture>): TFuture; overload; inline;

    /// <summary>
    ///   Status of the task: Created before it starts, Exception when the routine raised.
    ///   Never blocks, also while another thread is inside Await.
    /// </summary>
    function Status: TTaskStatus;
    function GetId: Integer;
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
/// </remarks>
function AwaitAll(const ATasks: array of TAsync; const ATimeout: Cardinal = INFINITE): TArray<TFuture>;

/// <summary>
///   Starts every task and waits for the first one to complete.
/// </summary>
/// <remarks>
///   AIndex receives the position of that task in ATasks, and the result is its future.
///   When the deadline expires first, AIndex is -1 and the result is the timeout error.
///   The other tasks keep running and can still be awaited.
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

type
  { The one implementation of IAsyncState. Every field is guarded by FLock, and FLock is only
    held for short, non-blocking sections - never across ITask.Wait. }
  TAsyncState = class(TInterfacedObject, IAsyncState)
  private
    FLock: TCriticalSection;
    FProc: TProc;
    FFunc: TFunc<TValue>;
    FTask: ITask;
    FValue: TValue;
    FErrorMessage: String;
    FFailed: Boolean;
    FError: TFunc<Exception, TFuture>;
    procedure Execute;
  public
    constructor Create(const AProc: TProc; const AFunc: TFunc<TValue>);
    destructor Destroy; override;
    function Start: ITask;
    function Task: ITask;
    function WaitFuture(const AContinue: TProc; const ATimeout: Cardinal): TFuture;
    function IsFunc: Boolean;
    function Failed: Boolean;
    procedure SetErrorHandler(const AError: TFunc<Exception, TFuture>);
  end;

function _AwaitTimeoutMessage(const ATimeout: Cardinal): String;
begin
  Result := Format(C_AWAIT_TIMEOUT_MESSAGE, [ATimeout]);
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

{ TAsyncState }

constructor TAsyncState.Create(const AProc: TProc; const AFunc: TFunc<TValue>);
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FProc := AProc;
  FFunc := AFunc;
end;

destructor TAsyncState.Destroy;
begin
  FLock.Free;
  inherited;
end;

function TAsyncState.IsFunc: Boolean;
begin
  Result := Assigned(FFunc);
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

procedure TAsyncState.Execute;
var
  LValue: TValue;
  LMessage: String;
  LRaised: Boolean;
  LError: TFunc<Exception, TFuture>;
begin
  LRaised := False;
  try
    if Assigned(FFunc) then
      LValue := FFunc()
    else if Assigned(FProc) then
      FProc();
  except
    on E: Exception do
    begin
      LRaised := True;
      LMessage := E.Message;
    end;
  end;

  FLock.Acquire;
  try
    FValue := LValue;
    FFailed := LRaised;
    FErrorMessage := LMessage;
    LError := FError;
  finally
    FLock.Release;
  end;

  // Unchanged contract of Run(AError)/NoAwait(AError): the handler is delivered to the main thread
  if LRaised and Assigned(LError) then
    TThread.Queue(nil,
      procedure
      begin
        LError(Exception.Create(LMessage));
      end);
end;

function TAsyncState.Start: ITask;
var
  LSelf: IAsyncState;
begin
  FLock.Acquire;
  try
    if FTask = nil then
    begin
      // The worker holds an interface reference: the state outlives any TAsync copy
      LSelf := Self;
      FTask := TTask.Run(
        procedure
        begin
          (LSelf as TAsyncState).Execute;
        end);
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

function TAsyncState.Failed: Boolean;
begin
  FLock.Acquire;
  try
    Result := FFailed;
  finally
    FLock.Release;
  end;
end;

function TAsyncState.WaitFuture(const AContinue: TProc; const ATimeout: Cardinal): TFuture;
var
  LTask: ITask;
  LFailed: Boolean;
  LMessage: String;
  LValue: TValue;
begin
  LTask := Start;
  // Wait OUTSIDE the lock: Status/Cancel/GetId from other threads must not block on an Await.
  // ITask.Wait returns False when the deadline expires; INFINITE never does.
  try
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
    LFailed := FFailed;
    LMessage := FErrorMessage;
    LValue := FValue;
  finally
    FLock.Release;
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

  if Assigned(FFunc) then
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
  Result := FState.WaitFuture(AContinue, ATimeout);
end;

function TAsync.Await(const ATimeout: Cardinal): TFuture;
begin
  Result := FState.WaitFuture(nil, ATimeout);
end;

function TAsync.Run: TFuture;
begin
  if FState.IsFunc then
  begin
    Result.SetErr(C_RUN_AS_FUNCTION_MESSAGE);
    Exit;
  end;
  try
    FState.Start;
    Result.SetOk(True);
  except
    on E: Exception do
      Result.SetErr(E.Message);
  end;
end;

function TAsync.Run(const AError: TFunc<Exception, TFuture>): TFuture;
begin
  FState.SetErrorHandler(AError);
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
var
  LTask: ITask;
begin
  LTask := FState.Task;
  if LTask = nil then
    Exit(TTaskStatus.Created);
  Result := LTask.Status;
  // The routine's exception is caught inside the task (so Wait never raises), which leaves the
  // ITask Completed: report the failure the routine actually had.
  if (Result = TTaskStatus.Completed) and FState.Failed then
    Result := TTaskStatus.Exception;
end;

function TAsync.GetId: Integer;
var
  LTask: ITask;
begin
  LTask := FState.Task;
  if LTask <> nil then
    Result := LTask.GetId
  else
    Result := -1;
end;

procedure TAsync.Cancel;
var
  LTask: ITask;
begin
  LTask := FState.Task;
  if LTask <> nil then
    LTask.Cancel;
end;

procedure TAsync.CheckCanceled;
var
  LTask: ITask;
begin
  LTask := FState.Task;
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
    ATasks[LIndex].FState.Start;
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
    // Await(0) on a task that is still running reports the timeout with the remaining budget
    // (0 ms); report the deadline the caller asked for instead
    if IsAwaitTimeout(Result[LIndex]) then
      Result[LIndex].SetErr(_AwaitTimeoutMessage(ATimeout));
  end;
end;

function AwaitAny(const ATasks: array of TAsync; out AIndex: Integer; const ATimeout: Cardinal): TFuture;
var
  LTasks: TArray<ITask>;
  LIndex: Integer;
  LAsync: TAsync;
begin
  AIndex := -1;
  if Length(ATasks) = 0 then
  begin
    Result.SetErr('AwaitAny needs at least one task');
    Exit;
  end;
  SetLength(LTasks, Length(ATasks));
  for LIndex := 0 to High(ATasks) do
  begin
    LAsync := ATasks[LIndex];
    LTasks[LIndex] := LAsync.FState.Start;
  end;
  try
    LIndex := TTask.WaitForAny(LTasks, ATimeout);
  except
    // A cancelled task makes WaitForAny raise: report it like Await does
    on E: Exception do
    begin
      Result.SetErr(E.Message);
      Exit;
    end;
  end;
  if LIndex < 0 then
  begin
    Result.SetErr(_AwaitTimeoutMessage(ATimeout));
    Exit;
  end;
  AIndex := LIndex;
  Result := ATasks[LIndex].Await;
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
