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

initialization
  TDUnitX.RegisterTestFixture(TTesTStd);

end.
