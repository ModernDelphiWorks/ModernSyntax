unit UTestMMS.Threading;

interface

uses
  DUnitX.TestFramework,
  Rtti,
  SysUtils,
  DateUtils,
  Classes,
  SyncObjs,
  Generics.Collections,
  Diagnostics,
  Threading,
  ModernSyntax.Async,
  ModernSyntax;

type
  [TestFixture]
  TTesTStd = class
  private
    function FetchData: TValue;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestRunProc;
    [Test]
    procedure TestNoAwaitProc;
    [Test]
    procedure TestAwaitProc;
    [Test]
    procedure TestRunFutureProc;
    [Test]
    procedure TestAwaitFunc;
    [Test]
    procedure TestAwaitFuture;
    [Test]
    procedure TestFetchAsyncAwait;
    // --- Await(timeout): an expired deadline must be an ERROR, never a success ---
    [Test]
    procedure TestAwaitProcTimeoutFails;
    [Test]
    procedure TestAwaitFuncTimeoutPublishesNoValue;
    [Test]
    procedure TestAwaitTimeoutDoesNotRunContinuation;
    [Test]
    procedure TestAwaitWithinDeadlineSucceeds;
    [Test]
    procedure TestAwaitInfiniteIsUnchanged;
    [Test]
    procedure TestAwaitTaskExceptionKeepsItsMessage;
    [Test]
    procedure TestIsAwaitTimeoutClassifiesWithoutStringSniffing;
    [Test]
    procedure TestAwaitTaskExceptionWinsWhenTaskFinishedInTime;
    // --- shared state (#13, #15, orphan lifetime) ---
    [Test]
    procedure TestStatusDoesNotBlockDuringAwait;
    [Test]
    procedure TestCancelReachesTaskDuringAwait;
    [Test]
    procedure TestRunThenAwaitExecutesOnce;
    [Test]
    procedure TestAwaitTwiceExecutesOnce;
    [Test]
    procedure TestFluentAwaitTimeoutIsSafe;
    [Test]
    procedure TestFinishedTaskReleasesWhatItCaptured;
    // --- continuation on the awaiting thread (#14) ---
    [Test]
    procedure TestContinuationRunsOnAwaitingThread;
    // --- failures of fire-and-forget tasks (#16) ---
    [Test]
    procedure TestNoAwaitFailureIsObservable;
    // --- AwaitAll / AwaitAny (#17) ---
    [Test]
    procedure TestAwaitAllRunsConcurrently;
    [Test]
    procedure TestAwaitAllSharesOneDeadline;
    [Test]
    procedure TestAwaitAnyReturnsFirstToFinish;
  end;

implementation

procedure TTesTStd.Setup;
begin

end;

procedure TTesTStd.TearDown;
begin

end;

procedure TTesTStd.TestAwaitProc;
var
  LFuture: TFuture;
  LExecuted: Boolean;
begin
  LFuture := Async(procedure
                   begin
                     LExecuted := True;
                   end)
            .Await;

  Assert.IsTrue(LFuture.IsOk);
  Assert.IsTrue(LFuture.Ok<Boolean>);
end;

procedure TTesTStd.TestFetchAsyncAwait;
var
  LFuture: TFuture;
begin
  LFuture := Async(FetchData).Await;

  Assert.IsTrue(LFuture.IsOk);
  Assert.AreEqual(LFuture.Ok<String>, 'sucesso!');
end;

procedure TTesTStd.TestNoAwaitProc;
var
  LFuture: TFuture;
  LExecuted: Boolean;
begin
  LFuture := Async(procedure
                   begin
                     LExecuted := True;
                   end)
            .NoAwait;

  Assert.IsTrue(LFuture.Ok<Boolean>);
end;

function TTesTStd.FetchData: TValue;
begin
  Sleep(50);
  Result := 'sucesso!';
end;

procedure TTesTStd.TestAwaitFunc;
var
  LFuture: TFuture;
begin
  LFuture := Async(function: TValue
                   begin
                     Sleep(300);
                     Result := 'Delphi Await';
                   end)
            .Await;

  Assert.IsTrue(LFuture.IsOk);
  Assert.AreEqual(LFuture.Ok<String>, 'Delphi Await');
end;

procedure TTesTStd.TestAwaitFuture;
var
  LFuture: TFuture;
  LContinue: Boolean;
begin
  LContinue := False;
  LFuture := Async(function: TValue
                   begin
                     Result := 'Await and Continue';
                   end)
            .Await(procedure
                   begin
                     LContinue := True;
                   end);

  Assert.IsTrue(LContinue);
  Assert.IsTrue(LFuture.IsOk);
  Assert.AreEqual(LFuture.Ok<String>, 'Await and Continue');
end;

procedure TTesTStd.TestRunProc;
var
  LFuture: TFuture;
  LExecuted: Boolean;
begin
  LFuture := Async(procedure
                   begin
                     LExecuted := True;
                   end)
            .Run;

  Assert.IsTrue(LFuture.Ok<Boolean>);
end;

procedure TTesTStd.TestRunFutureProc;
var
  LFuture: TFuture;
  LErr: String;
begin
  // Neste caso no ECL o "Run" não usa Function, mas somente Procedure, se quiser
  // usar Function use o "Await", pois ele espera o resultado para devolver, o
  // "Run" não fica esperando, somente aloca a thread e executa
  LFuture := Async(function: TValue
                   begin
                     Result := False;
                   end)
            .Run;

  Assert.IsTrue(LFuture.IsErr);
  LErr := 'The "Run" method should not be invoked as a function. Utilize the "Await" method to wait for task completion and access the result, or invoke it as a procedure.';
  Assert.AreEqual(LErr, LFuture.Err);
end;

{ Await(timeout)

  Until this fix, FTask.Wait(ATimeout) had its Boolean result DISCARDED at the four await
  sites, so execution fell straight through to Result.SetOk(...): a blown deadline was
  reported as SUCCESS, and in the TFunc overload it even published an LValue the task might
  never have produced.

  DETERMINISM (no machine-speed dependency, on purpose):
    * the "must time out" tests run a task that sleeps CTaskSleepMs and wait only
      CDeadlineMs. Sleep never returns EARLY, so the task physically cannot finish inside the
      deadline - a slow machine only makes the gap bigger. There is no flake window;
    * the "must succeed" tests use CGenerousMs, three orders of magnitude above the work;
    * after a timeout the orphan task keeps running (Await does not cancel it). Each timeout
      test drains it with Sleep(CDrainMs) before returning, so no stray task survives into
      the next test. }

const
  CTaskSleepMs = 300;   // task work: ALWAYS longer than the deadline below
  CDeadlineMs  = 60;    // deadline: ALWAYS shorter than the task work above
  CDrainMs     = 600;   // > CTaskSleepMs: lets the orphaned task finish before we return
  CGenerousMs  = 30000; // deadline a trivial task cannot miss

procedure TTesTStd.TestAwaitProcTimeoutFails;
var
  LAsync: TAsync;
  LFuture: TFuture;
begin
  LAsync := Async(procedure
                  begin
                    Sleep(CTaskSleepMs);
                  end);
  LFuture := LAsync.Await(CDeadlineMs);
  try
    Assert.IsTrue(LFuture.IsErr, 'an expired deadline is an ERROR');
    Assert.IsFalse(LFuture.IsOk, 'and it must NOT be reported as a success');
    Assert.IsTrue(IsAwaitTimeout(LFuture),
      'it has to be classifiable as a TIMEOUT, so it can be told apart from "the task ' +
      'failed": ' + LFuture.Err);
    Assert.IsTrue(Pos(IntToStr(CDeadlineMs) + ' ms', LFuture.Err) > 0,
      'the message has to quote the deadline that was blown: ' + LFuture.Err);
  finally
    Sleep(CDrainMs);
  end;
end;

procedure TTesTStd.TestAwaitFuncTimeoutPublishesNoValue;
var
  LAsync: TAsync;
  LFuture: TFuture;
begin
  // The nastiest of the four sites: SetOk(LValue) used to publish a value the task had not
  // produced yet. Now nothing at all is published.
  LAsync := Async(function: TValue
                  begin
                    Sleep(CTaskSleepMs);
                    Result := 'never delivered';
                  end);
  LFuture := LAsync.Await(CDeadlineMs);
  try
    Assert.IsTrue(LFuture.IsErr, 'an expired deadline is an ERROR');
    Assert.IsTrue(IsAwaitTimeout(LFuture), 'and it classifies as a TIMEOUT: ' + LFuture.Err);
    Assert.WillRaise(
      procedure
      begin
        LFuture.Ok<String>;
      end,
      Exception,
      'no success value may be readable after a timeout');
  finally
    Sleep(CDrainMs);
  end;
end;

procedure TTesTStd.TestAwaitTimeoutDoesNotRunContinuation;
var
  LAsync: TAsync;
  LFuture: TFuture;
  LContinue: Boolean;
begin
  LContinue := False;
  LAsync := Async(function: TValue
                  begin
                    Sleep(CTaskSleepMs);
                    Result := 'never delivered';
                  end);
  LFuture := LAsync.Await(procedure
                          begin
                            LContinue := True;
                          end,
                          CDeadlineMs);
  try
    Assert.IsTrue(LFuture.IsErr, 'an expired deadline is an ERROR');
    Assert.IsFalse(LContinue,
      'the continuation belongs to a COMPLETED task - it must not run after a timeout');
  finally
    Sleep(CDrainMs);
  end;
end;

procedure TTesTStd.TestAwaitWithinDeadlineSucceeds;
var
  LFuture: TFuture;
begin
  // A deadline that is comfortably met must behave exactly like before the fix.
  LFuture := Async(function: TValue
                   begin
                     Result := 'inside the deadline';
                   end)
            .Await(CGenerousMs);

  Assert.IsTrue(LFuture.IsOk, 'a task that finishes in time still succeeds');
  Assert.IsFalse(LFuture.IsErr, 'and carries no error');
  Assert.AreEqual('inside the deadline', LFuture.Ok<String>);
end;

procedure TTesTStd.TestAwaitInfiniteIsUnchanged;
var
  LProcFuture: TFuture;
  LFuncFuture: TFuture;
  LExecuted: Boolean;
begin
  // INFINITE is the DEFAULT of the parameter: this is the path every existing caller takes,
  // and it must keep waiting forever and succeeding, no matter how long the task takes.
  LExecuted := False;
  LProcFuture := Async(procedure
                       begin
                         Sleep(CTaskSleepMs);
                         LExecuted := True;
                       end)
                .Await;
  Assert.IsTrue(LProcFuture.IsOk, 'INFINITE waits for the procedure, however long it takes');
  Assert.IsTrue(LProcFuture.Ok<Boolean>);
  Assert.IsTrue(LExecuted, 'the procedure really ran to completion');

  LFuncFuture := Async(function: TValue
                       begin
                         Sleep(CTaskSleepMs);
                         Result := 'waited it out';
                       end)
                .Await(INFINITE);
  Assert.IsTrue(LFuncFuture.IsOk, 'explicit INFINITE behaves the same as the default');
  Assert.AreEqual('waited it out', LFuncFuture.Ok<String>);
end;

procedure TTesTStd.TestAwaitTaskExceptionKeepsItsMessage;
var
  LFuture: TFuture;
begin
  // Unchanged semantics: a task that raises turns into an error carrying ITS message.
  LFuture := Async(function: TValue
                   begin
                     raise Exception.Create('task blew up');
                   end)
            .Await;

  Assert.IsTrue(LFuture.IsErr, 'a task that raises produces an error future');
  Assert.AreEqual('task blew up', LFuture.Err, 'the task message is preserved verbatim');
  Assert.IsFalse(IsAwaitTimeout(LFuture), 'a failure is not a timeout');
end;

procedure TTesTStd.TestIsAwaitTimeoutClassifiesWithoutStringSniffing;
var
  LAsync: TAsync;
  LTimedOut: TFuture;
  LTaskFailed: TFuture;
  LSucceeded: TFuture;
begin
  // The whole point of IsAwaitTimeout: consumers used to write Pos('TIMEOUT', LFuture.Err),
  // which misfires on any task message that merely CONTAINS the word. The classification is
  // anchored at the start of the message, so a task that raises with the word in it is still
  // a task failure.
  LTaskFailed := Async(procedure
                       begin
                         raise Exception.Create('gateway said TIMEOUT while reading the socket');
                       end)
                .Await;
  Assert.IsTrue(LTaskFailed.IsErr, 'the task raised, so the future is red');
  Assert.IsFalse(IsAwaitTimeout(LTaskFailed),
    'a task message that merely mentions TIMEOUT is NOT an await timeout');

  LSucceeded := Async(procedure
                      begin
                      end)
               .Await(CGenerousMs);
  Assert.IsTrue(LSucceeded.IsOk);
  Assert.IsFalse(IsAwaitTimeout(LSucceeded), 'a green future is never a timeout');

  LAsync := Async(procedure
                  begin
                    Sleep(CTaskSleepMs);
                  end);
  LTimedOut := LAsync.Await(CDeadlineMs);
  try
    Assert.IsTrue(IsAwaitTimeout(LTimedOut), 'and the real thing still classifies as one');
  finally
    Sleep(CDrainMs);
  end;
end;

procedure TTesTStd.TestAwaitTaskExceptionWinsWhenTaskFinishedInTime;
var
  LFuture: TFuture;
begin
  // PRECEDENCE, documented side: the task finished (by raising) inside the deadline, so the
  // future reports the TASK's failure, not a timeout. The other side of the rule - deadline
  // expired first - is covered above: there the worker is still running and its message
  // cannot be read without a data race, so TIMEOUT wins.
  LFuture := Async(procedure
                   begin
                     raise Exception.Create('failed fast');
                   end)
            .Await(CGenerousMs);

  Assert.IsTrue(LFuture.IsErr);
  Assert.AreEqual('failed fast', LFuture.Err,
    'the task failed within the deadline: its own message is what surfaces');
end;

{ Shared state

  The task holds a reference-counted state object, never a pointer to the TAsync record, and the
  lock that guards it is never held across ITask.Wait. Each test below failed before that change:
  Status blocked for the whole Await (#13), Run + Await executed the routine twice (#15), and an
  Await with a finite deadline on a temporary TAsync left the orphan task with a dangling pointer. }

procedure TTesTStd.TestStatusDoesNotBlockDuringAwait;
var
  LAsync: TAsync;
  LWaiter: TThread;
  LWatch: TStopwatch;
  LStatus: TTaskStatus;
begin
  LAsync := Async(procedure
                  begin
                    Sleep(1500);
                  end);
  LWaiter := TThread.CreateAnonymousThread(procedure
                                           begin
                                             LAsync.Await;
                                           end);
  LWaiter.FreeOnTerminate := False;
  LWaiter.Start;
  try
    Sleep(150);
    LWatch := TStopwatch.StartNew;
    LStatus := LAsync.Status;
    LWatch.Stop;
    Assert.IsTrue(LWatch.ElapsedMilliseconds < 200,
      Format('Status must not wait for the Await of another thread (took %d ms)', [LWatch.ElapsedMilliseconds]));
    Assert.IsTrue(LStatus in [TTaskStatus.WaitingToRun, TTaskStatus.Running],
      'the task is still running while it is awaited');
  finally
    LWaiter.WaitFor;
    LWaiter.Free;
  end;
end;

procedure TTesTStd.TestCancelReachesTaskDuringAwait;
var
  LAsync: TAsync;
  LCanceller: TAsync;
  LWatch: TStopwatch;
  LFuture: TFuture;
begin
  // The routine checks for cancellation cooperatively; Cancel comes from another task while
  // this thread is inside Await. Before the fix Cancel blocked until the routine finished.
  LAsync := Async(procedure
                  var
                    LIndex: Integer;
                  begin
                    for LIndex := 1 to 300 do
                    begin
                      Sleep(10);
                      LAsync.CheckCanceled;
                    end;
                  end);
  LCanceller := Async(procedure
                      begin
                        Sleep(150);
                        LAsync.Cancel;
                      end);
  LCanceller.Run;
  LWatch := TStopwatch.StartNew;
  LFuture := LAsync.Await(CGenerousMs);
  LWatch.Stop;
  LCanceller.Await;
  Assert.IsTrue(LFuture.IsErr, 'a cancelled routine ends in error');
  Assert.IsFalse(IsAwaitTimeout(LFuture), 'cancellation is not a timeout');
  Assert.IsTrue(LWatch.ElapsedMilliseconds < 1500,
    Format('Cancel reached the routine during Await (took %d ms of 3000)', [LWatch.ElapsedMilliseconds]));
end;

procedure TTesTStd.TestRunThenAwaitExecutesOnce;
var
  LAsync: TAsync;
  LCount: Integer;
  LFuture: TFuture;
begin
  LCount := 0;
  LAsync := Async(procedure
                  begin
                    Sleep(100);
                    TInterlocked.Increment(LCount);
                  end);
  Assert.IsTrue(LAsync.Run.IsOk);
  LFuture := LAsync.Await(CGenerousMs);
  Assert.IsTrue(LFuture.IsOk);
  Sleep(200);
  Assert.AreEqual(1, LCount, 'Await after Run waits for the running task; it does not start another');
end;

procedure TTesTStd.TestAwaitTwiceExecutesOnce;
var
  LAsync: TAsync;
  LCount: Integer;
begin
  LCount := 0;
  LAsync := Async(function: TValue
                  begin
                    Result := TInterlocked.Increment(LCount);
                  end);
  Assert.AreEqual(1, LAsync.Await.Ok<Integer>);
  Assert.AreEqual(1, LAsync.Await.Ok<Integer>, 'a second Await returns the same outcome');
  Assert.AreEqual(1, LCount, 'and the routine ran once');
end;

type
  { Sets the flag it points to when it is destroyed: proves a capture was released }
  TReleaseSentinel = class(TInterfacedObject)
  private
    FFreed: PInteger;
  public
    constructor Create(AFreed: PInteger);
    destructor Destroy; override;
  end;

constructor TReleaseSentinel.Create(AFreed: PInteger);
begin
  inherited Create;
  FFreed := AFreed;
end;

destructor TReleaseSentinel.Destroy;
begin
  TInterlocked.Exchange(FFreed^, 1);
  inherited;
end;

procedure AwaitWithCapturedSentinel(AFreed: PInteger);
var
  LSentinel: IInterface;
begin
  LSentinel := TReleaseSentinel.Create(AFreed);
  Async(procedure
        begin
          if LSentinel = nil then
            Abort;
        end)
  .Await;
end;

procedure TTesTStd.TestFinishedTaskReleasesWhatItCaptured;
var
  LFreed: Integer;
  LWatch: TStopwatch;
begin
  // The state holds the task and the task holds the routine: once the routine has finished and
  // the TAsync is gone, nothing may keep the closure - and what it captured - alive.
  LFreed := 0;
  AwaitWithCapturedSentinel(@LFreed);
  LWatch := TStopwatch.StartNew;
  while (TInterlocked.CompareExchange(LFreed, 0, 0) = 0) and (LWatch.ElapsedMilliseconds < 3000) do
    Sleep(10);
  Assert.AreEqual(1, LFreed, 'the routine and its captures are released after the task completes');
end;

procedure TTesTStd.TestFluentAwaitTimeoutIsSafe;
var
  LFuture: TFuture;
  LDone: Integer;
begin
  // The fluent form on a temporary used to be documented as WRONG with a finite deadline: the
  // orphan dereferenced the dead record. The orphan now owns a reference to the shared state.
  LDone := 0;
  LFuture := Async(procedure
                   begin
                     Sleep(CTaskSleepMs);
                     TInterlocked.Exchange(LDone, 1);
                   end)
            .Await(CDeadlineMs);
  Assert.IsTrue(IsAwaitTimeout(LFuture));
  Sleep(CDrainMs);
  Assert.AreEqual(1, LDone, 'the orphan ran to completion without touching freed memory');
end;

{ Continuation (#14)

  The continuation used to be posted with TThread.Queue: on the main thread that runs at once,
  on any other thread it was queued to the main thread and, in a console app or a service,
  never ran. It now runs inline on the thread that called Await. }

procedure TTesTStd.TestContinuationRunsOnAwaitingThread;
var
  LWorker: TThread;
  LRan: Boolean;
  LContinueThread, LWorkerThread: TThreadID;
  LFailed: TFuture;
begin
  LRan := False;
  LContinueThread := 0;
  LWorkerThread := 0;
  LWorker := TThread.CreateAnonymousThread(
    procedure
    begin
      LWorkerThread := TThread.CurrentThread.ThreadID;
      Async(procedure
            begin
            end)
      .Await(procedure
             begin
               LRan := True;
               LContinueThread := TThread.CurrentThread.ThreadID;
             end);
      LFailed := Async(procedure
                       begin
                       end)
                 .Await(procedure
                        begin
                          raise Exception.Create('continuation failed');
                        end);
    end);
  LWorker.FreeOnTerminate := False;
  LWorker.Start;
  LWorker.WaitFor;
  LWorker.Free;
  Assert.IsTrue(LRan, 'the continuation ran before Await returned, off the main thread');
  Assert.AreEqual(LWorkerThread, LContinueThread, 'on the thread that called Await');
  Assert.IsTrue(LFailed.IsErr, 'an exception in the continuation is the error of the future');
  Assert.AreEqual('continuation failed', LFailed.Err);
end;

{ Fire-and-forget failures (#16)

  The routine's exception is caught inside the task, so the ITask always ended Completed and the
  error was lost. Status now reports Exception and a later Await returns the error. }

procedure TTesTStd.TestNoAwaitFailureIsObservable;
var
  LAsync: TAsync;
  LWatch: TStopwatch;
  LFuture: TFuture;
begin
  LAsync := Async(procedure
                  begin
                    raise Exception.Create('background failure');
                  end);
  Assert.IsTrue(LAsync.NoAwait.IsOk, 'NoAwait itself only starts the task');
  LWatch := TStopwatch.StartNew;
  while (LAsync.Status <> TTaskStatus.Exception) and (LWatch.ElapsedMilliseconds < 3000) do
    Sleep(5);
  Assert.AreEqual(Ord(TTaskStatus.Exception), Ord(LAsync.Status), 'Status reports the failure');
  LFuture := LAsync.Await;
  Assert.IsTrue(LFuture.IsErr);
  Assert.AreEqual('background failure', LFuture.Err, 'a later Await returns the error');
end;

{ AwaitAll / AwaitAny (#17)

  Await starts and waits, so awaiting N tasks in a loop ran them one after another.
  AwaitAll starts every task first and waits under one shared deadline (like asyncio.gather or
  futures::join_all, results in order); AwaitAny returns the first to finish. As with Await, an
  expired deadline does not cancel anything - unlike asyncio.wait_for and tokio::time::timeout,
  which cancel; the frozen Await contract of this unit is kept. }

procedure TTesTStd.TestAwaitAllRunsConcurrently;
var
  LWatch: TStopwatch;
  LFutures: TArray<TFuture>;
  LIndex: Integer;

  function Work(AValue: Integer): TAsync;
  begin
    Result := Async(function: TValue
                    begin
                      Sleep(300);
                      Result := AValue;
                    end);
  end;

begin
  LWatch := TStopwatch.StartNew;
  LFutures := AwaitAll([Work(10), Work(20), Work(30), Work(40)], CGenerousMs);
  LWatch.Stop;
  Assert.AreEqual(NativeInt(4), Length(LFutures));
  for LIndex := 0 to 3 do
  begin
    Assert.IsTrue(LFutures[LIndex].IsOk);
    Assert.AreEqual((LIndex + 1) * 10, LFutures[LIndex].Ok<Integer>, 'results come back in order');
  end;
  Assert.IsTrue(LWatch.ElapsedMilliseconds < 900,
    Format('4 tasks of 300 ms ran concurrently (took %d ms; sequential would be 1200)', [LWatch.ElapsedMilliseconds]));
end;

procedure TTesTStd.TestAwaitAllSharesOneDeadline;
var
  LWatch: TStopwatch;
  LFutures: TArray<TFuture>;
begin
  LWatch := TStopwatch.StartNew;
  LFutures := AwaitAll([
    Async(function: TValue begin Result := 'fast'; end),
    Async(procedure begin Sleep(CTaskSleepMs); end),
    Async(procedure begin Sleep(CTaskSleepMs); end)],
    CDeadlineMs);
  LWatch.Stop;
  try
    Assert.IsTrue(LFutures[0].IsOk);
    Assert.AreEqual('fast', LFutures[0].Ok<String>);
    Assert.IsTrue(IsAwaitTimeout(LFutures[1]), 'a task still running at the deadline times out');
    Assert.IsTrue(IsAwaitTimeout(LFutures[2]), 'the deadline is shared, not restarted per task');
    Assert.IsTrue(Pos(IntToStr(CDeadlineMs) + ' ms', LFutures[2].Err) > 0,
      'the message quotes the deadline the caller asked for: ' + LFutures[2].Err);
    Assert.IsTrue(LWatch.ElapsedMilliseconds < CTaskSleepMs,
      Format('AwaitAll returned at the deadline (took %d ms)', [LWatch.ElapsedMilliseconds]));
  finally
    Sleep(CDrainMs);
  end;
end;

procedure TTesTStd.TestAwaitAnyReturnsFirstToFinish;
var
  LIndex: Integer;
  LFuture: TFuture;
begin
  LFuture := AwaitAny([
    Async(function: TValue begin Sleep(CTaskSleepMs); Result := 'slow'; end),
    Async(function: TValue begin Sleep(20); Result := 'quick'; end)],
    LIndex, CGenerousMs);
  try
    Assert.AreEqual(1, LIndex, 'the quick task finished first');
    Assert.AreEqual('quick', LFuture.Ok<String>);
  finally
    Sleep(CDrainMs);
  end;

  LFuture := AwaitAny([Async(procedure begin Sleep(CTaskSleepMs); end)], LIndex, CDeadlineMs);
  try
    Assert.AreEqual(-1, LIndex, 'no task finished inside the deadline');
    Assert.IsTrue(IsAwaitTimeout(LFuture));
  finally
    Sleep(CDrainMs);
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTesTStd);

end.
