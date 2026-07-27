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
    /// <summary>
    ///   Waits for the task, then runs <paramref name="AContinue"/> and returns the future.
    /// </summary>
    /// <remarks>
    ///   TIMEOUT SEMANTICS: when <paramref name="ATimeout"/> elapses before the task
    ///   completes, the returned future is an ERROR (IsErr) whose message states that it
    ///   was a TIMEOUT and quotes the deadline in milliseconds. The continuation is NOT
    ///   executed and no success value is published.
    ///   PRECEDENCE: the timeout wins over a task exception. Once the deadline expires the
    ///   worker is still running, so its error slot is being written by another thread and
    ///   cannot be read safely; the future reports the timeout and discards whatever the
    ///   orphan task may produce later.
    ///   With the default INFINITE there is no deadline and the behaviour is unchanged.
    ///
    ///   THE ORPHAN TASK OUTLIVES THE AWAIT - KEEP THE TAsync ALIVE. A timeout does not cancel
    ///   anything: the worker keeps running, and it holds LSelf := @Self, a RAW POINTER to this
    ///   record (ModernSyntax.Async.pas:258, :352, :406 and :444), which it dereferences to
    ///   reach FProc/FFunc. If the TAsync was a temporary, its storage is gone the moment the
    ///   expression ends and the orphan dereferences dead memory. So with a FINITE deadline the
    ///   fluent form is unsafe:
    ///
    ///     LFuture := Async(LWork).Await(50);   // WRONG: the TAsync is a temporary
    ///
    ///     LAsync  := Async(LWork);             // RIGHT: named variable, outlives the orphan
    ///     LFuture := LAsync.Await(50);
    ///     // ...and keep LAsync in scope until LAsync.Status is Completed/Exception, or the
    ///     // work is otherwise known to have finished.
    ///
    ///   The lifetime hazard is older than the timeout support, but it used to be unreachable
    ///   in practice: with INFINITE the await only returns after the task is done, so the
    ///   record is never released early. Finite deadlines - and the timeout/retry style they
    ///   invite - are what make the orphan a real exposure.
    ///
    ///   USE IsAwaitTimeout(LFuture) to tell a blown deadline from a task failure; do not
    ///   pattern-match the message text yourself.
    /// </remarks>
    function Await(const AContinue: TProc; const ATimeout: Cardinal = INFINITE): TFuture; overload; inline;

    /// <summary>
    ///   Waits for the task and returns the future.
    /// </summary>
    /// <remarks>
    ///   Same TIMEOUT semantics and precedence documented in the overload above: an expired
    ///   deadline yields IsErr with a timeout message, never a success.
    ///   The same lifetime rule applies: with a finite deadline the orphan task keeps
    ///   dereferencing @Self, so hold the TAsync in a named variable instead of awaiting a
    ///   temporary. Use IsAwaitTimeout to classify the result.
    /// </remarks>
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

/// <summary>
///   True when the await deadline expired with the task still running.
/// </summary>
/// <remarks>
///   ITask.Wait returns False when it gives up on the deadline and True when the task
///   finished. That Boolean used to be discarded, so an expired deadline fell straight
///   through to SetOk and a blown deadline was reported as SUCCESS.
///   INFINITE means "no deadline": Wait only ever returns after the task completes, and the
///   extra guard keeps that path provably identical to the previous behaviour.
/// </remarks>
function _AwaitTimedOut(const ATask: ITask; const ATimeout: Cardinal): Boolean;
begin
  Result := (not ATask.Wait(ATimeout)) and (ATimeout <> INFINITE);
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
      if _AwaitTimedOut(FTask, ATimeout) then
      begin
        // Deadline expired: the worker is still running and still owns LMessage, so reading
        // it here would be a data race on a half-written value. TIMEOUT therefore takes
        // precedence over "the task raised", the continuation does not run and nothing is
        // published as success.
        Result.SetErr(_AwaitTimeoutMessage(ATimeout));
        Exit;
      end;
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
      if _AwaitTimedOut(FTask, ATimeout) then
      begin
        // Deadline expired: LValue may never have been assigned (or is being assigned right
        // now by the worker), so publishing it as a success would hand back a value the task
        // never produced. TIMEOUT takes precedence and the continuation does not run.
        Result.SetErr(_AwaitTimeoutMessage(ATimeout));
        Exit;
      end;
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
      if _AwaitTimedOut(FTask, ATimeout) then
      begin
        // Worst of the four sites before the fix: SetOk(LValue) published an LValue the task
        // may never have produced. TIMEOUT takes precedence and nothing is published.
        Result.SetErr(_AwaitTimeoutMessage(ATimeout));
        Exit;
      end;
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
      if _AwaitTimedOut(FTask, ATimeout) then
      begin
        // Deadline expired with the worker still running: report the TIMEOUT instead of the
        // old SetOk(True), which claimed the procedure had finished when it had not.
        Result.SetErr(_AwaitTimeoutMessage(ATimeout));
        Exit;
      end;
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
