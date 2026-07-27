unit UTestMS.Coroutine;

interface

uses
  DUnitX.TestFramework,
  Rtti,
  SysUtils,
  Classes,
  SyncObjs,
  ModernSyntax,
  ModernSyntax.Coroutine;

type
  [TestFixture]
  TTestScheduler = class
  private
    // A FIELD, not a local: in the abandon test the coroutine outlives the call that created
    // it, so the flag it writes has to outlive the call too.
    FBodyFinished: Boolean;
    procedure _RunUntilBusyThenRelease(const AEntered: TEvent; const AWorkMs: Cardinal;
      const AShutdownMs: Cardinal);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // --- Stop must REPORT whether it actually stopped ---
    [Test]
    procedure TestStopReportsStoppedWhenTheWorkerFinishes;
    [Test]
    procedure TestStopReportsNotStoppedWhenTheDeadlineBlows;
    [Test]
    procedure TestStopOnASchedulerThatNeverRanReportsStopped;

    // --- the destructor must not free what the worker can still touch ---
    [Test]
    procedure TestDestructorWaitsForABusyWorkerInsteadOfFreeingUnderIt;
    [Test]
    [IgnoreMemoryLeaks(True)]
    procedure TestDestructorAbandonsAWorkerThatWillNotStop;

    // --- Next: the deterministic, clock-free driver ---
    [Test]
    procedure TestNextDrivesTheSchedulerOneStepAtATimeWithoutAWorker;
  end;

implementation

{ DETERMINISM (no machine-speed dependency, on purpose)

  Every deadline in this fixture is compared against a Sleep, and Sleep never returns EARLY.
  A slow machine only widens the gap, so there is no flake window:

    * the "must not stop in time" tests block the coroutine for CSlowWorkMs and give Stop only
      CTightMs. The blocked body physically cannot finish inside the deadline;
    * nothing is timed from "when we called Run". Each test waits on an EVENT the coroutine
      signals as it enters its body, so the deadline is only started once the worker is
      provably inside the blocking call. Thread-pool scheduling latency cannot influence the
      outcome;
    * the "must succeed" waits use CGenerousMs, orders of magnitude above the work;
    * CBusyWorkMs sits deliberately between the OLD hardcoded destructor deadline (500 ms) and
      the new C_SHUTDOWN_TIMEOUT (5000 ms): the old destructor freed the coroutines, the list
      and the lock while the worker was still inside Next, the new one waits;
    * a test that leaves an orphan running drains it with CDrainMs before returning. }

const
  CTick            = 10;    // scheduler sleep between iterations: small, so tests stay quick
  CSlowWorkMs      = 1500;  // coroutine body that ALWAYS outlives the deadlines below
  CBusyWorkMs      = 800;   // > the old hardcoded 500 ms, << C_SHUTDOWN_TIMEOUT (5000 ms)
  CTightMs         = 50;    // deadline CSlowWorkMs physically cannot meet
  CGenerousMs      = 30000; // deadline a trivial coroutine cannot miss
  CShortShutdownMs = 100;   // per-instance shutdown budget, used only by the abandon test
  CDrainMs         = 2500;  // > CSlowWorkMs: lets an abandoned worker finish before we return

procedure TTestScheduler._RunUntilBusyThenRelease(const AEntered: TEvent;
  const AWorkMs: Cardinal; const AShutdownMs: Cardinal);
var
  LScheduler: IScheduler;
begin
  // The scheduler is built AND released inside this helper on purpose. Add and Run both return
  // IScheduler, and Delphi keeps the hidden interface temporaries a fluent API produces alive
  // until the enclosing method ends - so `LScheduler := nil` written in the test body would NOT
  // be the moment of destruction, and the test would prove nothing. Returning from here is the
  // moment of destruction, with no hidden references left.
  FBodyFinished := False;
  LScheduler := TScheduler.New(CTick, AShutdownMs);
  LScheduler.Add('worker',
    function(const ASendValue: TValue; const AValue: TValue): TFuture
    begin
      AEntered.SetEvent;
      Sleep(AWorkMs);
      FBodyFinished := True;   // written by the WORKER thread, read after destruction
      Result.SetOk(TCompletion);
    end,
    0);
  LScheduler.Run(nil);

  Assert.AreEqual(TWaitResult.wrSignaled, AEntered.WaitFor(CGenerousMs),
    'the worker has to be inside the coroutine body when the scheduler is released, ' +
    'otherwise nothing is being tested');
end;

procedure TTestScheduler.Setup;
begin
  TScheduler.ResetAbandonedCount;
  TScheduler.OnAbandon := nil;
end;

procedure TTestScheduler.TearDown;
begin
  TScheduler.OnAbandon := nil;
end;

procedure TTestScheduler.TestStopReportsStoppedWhenTheWorkerFinishes;
var
  LScheduler: IScheduler;
begin
  LScheduler := TScheduler.New(CTick);
  LScheduler.Add('trivial',
    function(const ASendValue: TValue; const AValue: TValue): TFuture
    begin
      Result.SetOk(TCompletion);
    end,
    0);
  LScheduler.Run(nil);

  Assert.IsTrue(LScheduler.Stop(CGenerousMs),
    'a scheduler whose worker really finished must report that it stopped');
  Assert.IsTrue(LScheduler.Stop(CGenerousMs),
    'Stop is idempotent: asking twice still reports stopped');
end;

procedure TTestScheduler.TestStopReportsNotStoppedWhenTheDeadlineBlows;
var
  LScheduler: IScheduler;
  LEntered: TEvent;
begin
  // Before this fix Stop was a procedure and threw away ITask.Wait's Boolean - the same defect
  // TAsync.Await had. The caller could not tell "stopped" from "gave up waiting", and then went
  // on to release things the coroutines were still using.
  LEntered := TEvent.Create(nil, True, False, '');
  try
    LScheduler := TScheduler.New(CTick);
    LScheduler.Add('stubborn',
      function(const ASendValue: TValue; const AValue: TValue): TFuture
      begin
        LEntered.SetEvent;
        Sleep(CSlowWorkMs);
        Result.SetOk(TCompletion);
      end,
      0);
    LScheduler.Run(nil);

    Assert.AreEqual(TWaitResult.wrSignaled, LEntered.WaitFor(CGenerousMs),
      'the worker has to be inside the coroutine body before the deadline is started');

    Assert.IsFalse(LScheduler.Stop(CTightMs),
      'the deadline blew with the worker still running: Stop must say so');

    // ...and a deadline that IS long enough reports the truth too.
    Assert.IsTrue(LScheduler.Stop(CGenerousMs),
      'given enough time the same scheduler does stop, and reports it');
  finally
    LScheduler := nil;
    LEntered.Free;
  end;
end;

procedure TTestScheduler.TestStopOnASchedulerThatNeverRanReportsStopped;
var
  LScheduler: IScheduler;
begin
  LScheduler := TScheduler.New(CTick);
  Assert.IsTrue(LScheduler.Stop(CTightMs),
    'there is no worker, so there is nothing still running: stopped');
end;

procedure TTestScheduler.TestDestructorWaitsForABusyWorkerInsteadOfFreeingUnderIt;
var
  LEntered: TEvent;
begin
  // THE REGRESSION TEST. The old destructor called Stop(500), ignored the answer and then freed
  // the coroutines, FCoroutines and FLock. With a body that takes CBusyWorkMs (> 500 ms) the
  // worker was still inside Next, walking memory that had just been released: use-after-free on
  // a background thread during shutdown. The destructor now waits C_SHUTDOWN_TIMEOUT.
  LEntered := TEvent.Create(nil, True, False, '');
  try
    _RunUntilBusyThenRelease(LEntered, CBusyWorkMs, C_SHUTDOWN_TIMEOUT);

    // THIS is the assertion that catches the old use-after-free. A UAF is silent - the old
    // destructor freed the list and the lock at 500 ms and usually got away with it because
    // nothing had reused the memory yet. What is NOT silent is the ordering: the destructor
    // must not return while the worker is still inside the body. With the old Stop(500) and a
    // body of CBusyWorkMs (800 ms) this flag is still False when the destructor has already
    // freed everything.
    Assert.IsTrue(FBodyFinished,
      'the destructor returned while the coroutine body was STILL RUNNING - everything it ' +
      'freed (coroutines, queue, lock, the instance itself) is memory the worker still uses');
    Assert.AreEqual(0, TScheduler.AbandonedCount,
      'and because it waited, the instance is freed normally rather than abandoned');
  finally
    LEntered.Free;
  end;
end;

procedure TTestScheduler.TestDestructorAbandonsAWorkerThatWillNotStop;
var
  LEntered: TEvent;
  LReportedTimeout: Cardinal;
begin
  // The other half of the contract. When the worker will NOT stop inside the budget, the only
  // two options are "free memory a live thread still dereferences" and "leak". It leaks - on
  // purpose, counted, and with a hook so the host can log it. That is why this test carries
  // [IgnoreMemoryLeaks]: one scheduler and its coroutine are deliberately never released.
  LReportedTimeout := 0;
  TScheduler.OnAbandon := procedure(const ATimeoutMs: Cardinal)
                          begin
                            LReportedTimeout := ATimeoutMs;
                          end;
  LEntered := TEvent.Create(nil, True, False, '');
  try
    // Returning from the helper is the moment of destruction; the body still has CSlowWorkMs
    // to go, so the CShortShutdownMs budget provably blows.
    _RunUntilBusyThenRelease(LEntered, CSlowWorkMs, CShortShutdownMs);

    Assert.IsFalse(FBodyFinished,
      'the premise of this test: the destructor gave up while the body was still running');
    Assert.AreEqual(1, TScheduler.AbandonedCount,
      'a worker that will not stop must be ABANDONED, never freed from under');
    Assert.AreEqual(Integer(CShortShutdownMs), Integer(LReportedTimeout),
      'the hook reports the deadline that was blown, so the host can log it');

    // No AV and no corruption is the actual assertion: the orphan below keeps running against
    // the instance, the coroutine list and the lock, all of which are still valid memory
    // precisely because the destructor refused to free them.
    Sleep(CDrainMs);
  finally
    TScheduler.OnAbandon := nil;
    LEntered.Free;
  end;
end;

procedure TTestScheduler.TestNextDrivesTheSchedulerOneStepAtATimeWithoutAWorker;
var
  LScheduler: IScheduler;
  LSteps: Integer;
begin
  // Next is the deterministic driver: no task, no clock, no sleep. One call, one step. This is
  // the path to use when a test needs to control time instead of waiting for it.
  LSteps := 0;
  LScheduler := TScheduler.New(CTick);
  LScheduler.Add('counter',
    function(const ASendValue: TValue; const AValue: TValue): TFuture
    begin
      Inc(LSteps);
      if LSteps >= 3 then
        Result.SetOk(TCompletion)
      else
        Result.SetOk(LSteps);
    end,
    0);

  Assert.AreEqual(1, Integer(LScheduler.Count), 'one coroutine queued, worker not started');

  LScheduler.Next;
  Assert.AreEqual(1, LSteps, 'one Next is exactly one step');
  LScheduler.Next;
  Assert.AreEqual(2, LSteps, 'and the step composes: the coroutine was re-queued');
  LScheduler.Next;
  Assert.AreEqual(3, LSteps, 'third step returns TCompletion and finishes the coroutine');

  Assert.AreEqual(0, Integer(LScheduler.Count),
    'a finished coroutine leaves the queue, so the driver knows when there is nothing left');

  LScheduler.Next;
  Assert.AreEqual(3, LSteps, 'Next on an empty scheduler is a no-op, not a fault');

  Assert.IsTrue(LScheduler.Stop(CTightMs),
    'no worker was ever started, so there is nothing left running');
end;

initialization
  TDUnitX.RegisterTestFixture(TTestScheduler);

end.
