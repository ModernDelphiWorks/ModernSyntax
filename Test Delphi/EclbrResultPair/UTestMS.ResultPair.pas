unit UTestMS.ResultPair;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  ModernSyntax.ResultPair,
  Rtti, Classes;

type
  TTestTResultPair = class
  private
    FDividend: Integer;
    FDivisor: Integer;
    FSuccessValue: Integer;
    FFailureValue: String;
    function _ResultTryExcept: TResultPair<Integer, String>;
    function _Result_Nivel_1: TResultPair<TObject, String>;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestMap;
    [Test]
    procedure TestMapTryException;
    [Test]
    procedure TestSuccess;
    [Test]
    procedure TestFailure;
    [Test]
    procedure TestTryException;
    [Test]
    procedure TestFlatMap;
    [Test]
    procedure TestFlatMapFailure;
    [Test]
    procedure TestReduceSuccess;
    [Test]
    procedure TestReduceFailure;
    [Test]
    procedure TestGetSuccessOrElse;
    [Test]
    procedure TestGetSuccessOrException;
    [Test]
    procedure TestGetSuccessOrDefaultNoDefault;
    [Test]
    procedure TestGetSuccessOrDefaultWithDefault;
    [Test]
    procedure TestGetFailureOrElse;
    [Test]
    procedure TestGetFailureOrException;
    [Test]
    procedure TestGetFailureOrDefaultNoDefault;
    [Test]
    procedure TestGetFailureOrDefaultWithDefault;
    [Test]
    procedure TestObjectCleanup;
    [Test]
    procedure TestValueSuccessNil;
    [Test]
    procedure TestValueSuccessNilSetFailure;
    // --- Dispose: idempotent, nil-safe and explicitly NOT automatic ---
    [Test]
    procedure TestDisposeFailureTwiceFreesOnlyOnce;
    [Test]
    procedure TestDisposeSuccessTwiceFreesOnlyOnce;
    [Test]
    procedure TestDisposeOnUnsetSlotDoesNotRaise;
    [Test]
    procedure TestDisposeOnNilObjectIsSafe;
    [Test]
    procedure TestDisposeLeavesNonClassValuesUntouched;
    [Test]
    procedure TestCopyingAndImplicitFreeNothingByThemselves;
    [Test]
    procedure TestLeavingScopeDoesNotFree;
  end;

implementation

function TTestTResultPair._ResultTryExcept: TResultPair<Integer, String>;
begin
  try
    Result.Success(42);
  except
    Result.Failure('Falilure');
  end;
end;

procedure TTestTResultPair.Setup;
begin
  FDividend := 10;
  FDivisor := 2;
  FSuccessValue := 42;
  FFailureValue := 'Error';
end;

procedure TTestTResultPair.TearDown;
begin
  // Não precisa de Dispose, liberação é automática
end;

procedure TTestTResultPair.TestFailure;
var
  LResultPair: TResultPair<Integer, string>;
begin
  LResultPair.Failure('Error');
  Assert.IsFalse(LResultPair.IsSuccess);
  Assert.IsTrue(LResultPair.IsFailure);
  Assert.AreEqual('Error', LResultPair.ValueFailure);
end;

procedure TTestTResultPair.TestFlatMap;
var
  LResultPair: TResultPair<Integer, string>;
begin
  LResultPair := TResultPair<Integer, string>.New.Success(FSuccessValue);
  LResultPair.FlatMap(
      function(Value: Integer): TResultValue
      begin
        Result.Success := Value * 2;
      end);

  Assert.IsTrue(LResultPair.IsSuccess);
  Assert.AreEqual(FSuccessValue * 2, LResultPair.ValueSuccess);
end;

procedure TTestTResultPair.TestFlatMapFailure;
var
  LResultPair: TResultPair<Integer, string>;
begin
  LResultPair := TResultPair<Integer, string>.New.Failure(FFailureValue);
  LResultPair.FlatMap(
      function(Error: string): TResultValue
      begin
        Result.Failure := Error + 'Handled';
      end);

  Assert.IsTrue(LResultPair.IsFailure);
  Assert.AreEqual(FFailureValue + 'Handled', LResultPair.ValueFailure);
end;

procedure TTestTResultPair.TestMap;
var
  LResultPair: TResultPair<Double, string>;
  LResult: Double;
begin
  LResultPair := TResultPair<Double, string>.New.Success(FDividend div FDivisor);
  LResultPair.Map<Double>(function(Value: Double): Double
                  begin
                    Result := Value * 2.5;
                  end);

  LResult := (FDividend div FDivisor) * 2.5;
  Assert.AreEqual(LResultPair.ValueSuccess, LResult, '');
end;

procedure TTestTResultPair.TestMapTryException;
var
  LResultPair: TResultPair<Double, string>;
  LResult: Double;
begin
  LResultPair := TResultPair<Double, string>.New.Success(42);
  LResultPair.Map<Double>(function(Value: Double): Double
                 begin
                   Result := Value * 2.5;
                 end);

  LResult := 42 * 2.5;
  Assert.AreEqual(LResultPair.ValueSuccess, LResult);
end;

procedure TTestTResultPair.TestSuccess;
var
  LResultPair: TResultPair<Integer, string>;
begin
  LResultPair.Success(42);
  Assert.IsTrue(LResultPair.IsSuccess);
  Assert.IsFalse(LResultPair.IsFailure);
  Assert.AreEqual(42, LResultPair.ValueSuccess);
end;

procedure TTestTResultPair.TestTryException;
var
  LResultPair: TResultPair<Integer, string>;
  LSuccessCalled: Boolean;
  LFailureCalled: Boolean;
begin
  LSuccessCalled := True;
  LFailureCalled := False;

  LResultPair := _ResultTryExcept;

  LResultPair.When<Boolean>(
    function (Value: Integer): Boolean
    begin
      LSuccessCalled := True;
      Result := True;
    end,
    function (Value: string): Boolean
    begin
      LFailureCalled := False;
      Result := False;
    end
  );

  Assert.IsTrue(LSuccessCalled);
  Assert.IsFalse(LFailureCalled);
end;

procedure TTestTResultPair.TestReduceSuccess;
var
  LResultPair: TResultPair<Integer, String>;
  LSum: Integer;
begin
  LResultPair.Success(FSuccessValue);
  LSum := LResultPair.Reduce<Integer>(
    function(Value: Integer; Error: String): Integer
    begin
      Result := Value + 5;
    end);

  Assert.AreEqual(47, LSum);
end;

procedure TTestTResultPair.TestGetFailureOrDefaultNoDefault;
var
  LResultPair: TResultPair<String, Integer>;
begin
  LResultPair.Failure(42);
  Assert.AreEqual(LResultPair.FailureOrDefault, 42);
end;

procedure TTestTResultPair.TestGetFailureOrDefaultWithDefault;
var
  LResultPair: TResultPair<String, Integer>;
begin
  LResultPair.Failure(42);
  Assert.AreEqual(LResultPair.FailureOrDefault(100), 42);
end;

procedure TTestTResultPair.TestGetFailureOrElse;
var
  LResultPair: TResultPair<String, Integer>;
begin
  LResultPair.Failure(42);
  Assert.AreEqual(LResultPair.FailureOrElse(
    function(Value: Integer): Integer
    begin
      Result := Value * 2;
    end
  ), 42);
end;

procedure TTestTResultPair.TestGetFailureOrException;
var
  LResultPair: TResultPair<String, Integer>;
begin
  LResultPair.Success('');
  Assert.WillRaise(
    procedure
    begin
      LResultPair.FailureOrException;
    end
  );
end;

procedure TTestTResultPair.TestGetSuccessOrDefaultNoDefault;
var
  LResultPair: TResultPair<Integer, String>;
begin
  LResultPair.Success(42);
  Assert.AreEqual(LResultPair.SuccessOrDefault, 42);
end;

procedure TTestTResultPair.TestGetSuccessOrDefaultWithDefault;
var
  LResultPair: TResultPair<Integer, String>;
begin
  LResultPair.Success(42);
  Assert.AreEqual(LResultPair.SuccessOrDefault(100), 42);
end;

procedure TTestTResultPair.TestGetSuccessOrElse;
var
  LResultPair: TResultPair<Integer, String>;
begin
  LResultPair.Success(42);
  Assert.AreEqual(LResultPair.SuccessOrElse(
    function(Value: Integer): Integer
    begin
      Result := Value * 2;
    end
  ), 42);
end;

procedure TTestTResultPair.TestGetSuccessOrException;
var
  LResultPair: TResultPair<Integer, string>;
begin
  LResultPair.Failure('42');
  Assert.WillRaise(
    procedure
    begin
      LResultPair.SuccessOrException;
    end
  );
end;

procedure TTestTResultPair.TestReduceFailure;
var
  LResultPair: TResultPair<Integer, String>;
  LDefaultValue: Integer;
begin
  LResultPair.Failure(FFailureValue);
  LDefaultValue := LResultPair.Reduce<Integer>(
    function(Value: Integer; Error: String): Integer
    begin
      Result := 0;
    end);

  Assert.AreEqual(0, LDefaultValue);
end;

procedure TTestTResultPair.TestObjectCleanup;
var
  LResultPair: TResultPair<TStringList, String>;
begin
  LResultPair.Success(TStringList.Create);
  Assert.IsTrue(LResultPair.IsSuccess);
end;

procedure TTestTResultPair.TestValueSuccessNil;
var
  LResultPair: TResultPair<TObject, String>;
  LSum: Integer;
begin
  LResultPair.Success(nil);

  Assert.IsNull(LResultPair.ValueSuccess);
end;


procedure TTestTResultPair.TestValueSuccessNilSetFailure;
var
  LResultPair: TResultPair<TObject, String>;
  LSum: Integer;
begin
  LResultPair := _Result_Nivel_1;
  if LResultPair.ValueSuccess = nil then
    LResultPair.Failure('Nil');

  Assert.IsTrue(LResultPair.ValueFailure = 'Nil');
end;

function TTestTResultPair._Result_Nivel_1: TResultPair<TObject, String>;
begin
  Result.Success(nil);
  if Result.ValueSuccess = nil then
    Exit;
end;

{ Dispose

  TResultPair owns nothing automatically: it is a plain record with NO class operator
  Finalize, so a class-typed Success/Failure value is released only by an explicit Dispose.
  That is deliberate - see the long note above _DestroyFailure in
  Source\ModernSyntax.ResultPair.pas - and these tests pin both halves of the contract:

    * Dispose is IDEMPOTENT and nil-safe: calling it twice on the same instance, on a slot
      that was never set, or on a slot holding nil, frees at most once and never raises;
    * copying (including through the Implicit operators) frees NOTHING by itself, and
      leaving scope frees NOTHING - which is exactly what consumers that already release
      the failure by hand depend on.

  LIMIT, stated out loud: idempotency is PER INSTANCE. Two separate copies of the same pair
  each holding the same object pointer will free it twice if Dispose is called on both -
  the same way calling Free on two variables pointing at one object does. Ownership is
  manual: one owner, one Dispose. }

type
  // The only way to prove a release is to count destructions.
  TSpyObject = class
  public
    destructor Destroy; override;
  end;

var
  GSpyDestroyed: Integer = 0;

destructor TSpyObject.Destroy;
begin
  Inc(GSpyDestroyed);
  inherited;
end;

procedure TTestTResultPair.TestDisposeFailureTwiceFreesOnlyOnce;
var
  LPair: TResultPair<String, TSpyObject>;
  LBefore: Integer;
begin
  LBefore := GSpyDestroyed;
  LPair := TResultPair<String, TSpyObject>.New.Failure(TSpyObject.Create);

  LPair.Dispose;
  Assert.AreEqual(LBefore + 1, GSpyDestroyed, 'the first Dispose releases the failure object');

  LPair.Dispose;
  Assert.AreEqual(LBefore + 1, GSpyDestroyed,
    'the second Dispose is a no-op - the slot was cleared BEFORE the object was freed, so ' +
    'nothing touches released memory and there is no double free');

  // Fail-fast side effect of clearing the slot: reading the value after Dispose raises
  // instead of handing back a dangling pointer.
  Assert.WillRaise(
    procedure
    begin
      LPair.ValueFailure;
    end,
    Exception,
    'after Dispose the slot is empty, not dangling');
end;

procedure TTestTResultPair.TestDisposeSuccessTwiceFreesOnlyOnce;
var
  LPair: TResultPair<TSpyObject, String>;
  LBefore: Integer;
begin
  LBefore := GSpyDestroyed;
  LPair := TResultPair<TSpyObject, String>.New.Success(TSpyObject.Create);

  LPair.Dispose;
  Assert.AreEqual(LBefore + 1, GSpyDestroyed, 'the first Dispose releases the success object');

  LPair.Dispose;
  Assert.AreEqual(LBefore + 1, GSpyDestroyed, 'the second Dispose frees nothing again');
end;

procedure TTestTResultPair.TestDisposeOnUnsetSlotDoesNotRaise;
var
  LBefore: Integer;
begin
  // Regression: _DestroySuccess used to call GetValue unconditionally, so Dispose on a pair
  // whose S is a class and whose SUCCESS slot was never filled raised 'Value is nil.'.
  // A cleanup routine must never be the thing that blows up.
  LBefore := GSpyDestroyed;
  Assert.WillNotRaise(
    procedure
    var
      LPair: TResultPair<TSpyObject, String>;
    begin
      LPair := TResultPair<TSpyObject, String>.New.Failure('no object was ever set');
      LPair.Dispose;
    end,
    Exception,
    'Dispose on an unset class slot is a no-op, not an error');
  Assert.AreEqual(LBefore, GSpyDestroyed, 'and nothing was released');
end;

procedure TTestTResultPair.TestDisposeOnNilObjectIsSafe;
var
  LPair: TResultPair<String, TSpyObject>;
  LBefore: Integer;
begin
  LBefore := GSpyDestroyed;
  LPair := TResultPair<String, TSpyObject>.New.Failure(nil);
  Assert.WillNotRaise(
    procedure
    begin
      LPair.Dispose;
      LPair.Dispose;
    end,
    Exception,
    'a slot explicitly holding nil survives Dispose, twice');
  Assert.AreEqual(LBefore, GSpyDestroyed, 'nil is nothing to release');
end;

procedure TTestTResultPair.TestDisposeLeavesNonClassValuesUntouched;
var
  LPair: TResultPair<String, TSpyObject>;
  LBefore: Integer;
begin
  // Dispose only ever touches CLASS slots: a string success value comes out intact.
  LBefore := GSpyDestroyed;
  LPair := TResultPair<String, TSpyObject>.New.Success('payload');

  LPair.Dispose;

  Assert.IsTrue(LPair.isSuccess, 'the result is still a success after Dispose');
  Assert.AreEqual('payload', LPair.ValueSuccess, 'and the success value is untouched');
  Assert.AreEqual(LBefore, GSpyDestroyed, 'nothing was released - there was no object');
end;

procedure TTestTResultPair.TestCopyingAndImplicitFreeNothingByThemselves;
var
  LPair: TResultPair<String, TSpyObject>;
  LCopy: TResultPair<String, TSpyObject>;
  LFromSlot: TResultPair<String, TSpyObject>;
  LSuccessSlot: TResultPairValue<String>;
  LFailureSlot: TResultPairValue<TSpyObject>;
  LBefore: Integer;
begin
  LBefore := GSpyDestroyed;
  LPair := TResultPair<String, TSpyObject>.New.Failure(TSpyObject.Create);

  // Plain copy, both Implicit directions, and the comparison operators (which take the
  // record by const and therefore copy nothing they can destroy).
  LCopy := LPair;
  LSuccessSlot := LPair;
  LFailureSlot := LPair;
  LFromSlot := LFailureSlot;
  Assert.IsFalse(LSuccessSlot.HasValue, 'the success slot of a failure pair carries no value');
  Assert.IsTrue(LFailureSlot.HasValue, 'the failure slot travels through Implicit');
  Assert.IsTrue(LFromSlot.ValueFailure = LPair.ValueFailure,
    'Implicit round-trip yields the same object, it does not clone or release it');

  Assert.AreEqual(LBefore, GSpyDestroyed,
    'the record is NOT managed: copying and Implicit release nothing, so no copy can turn ' +
    'into a double free on its own');

  // One owner, one Dispose - and it is LPair. LCopy/LFromSlot are aliases of the same
  // object and are deliberately NOT disposed here (see the LIMIT note above).
  LPair.Dispose;
  Assert.AreEqual(LBefore + 1, GSpyDestroyed, 'the single owner releases it exactly once');
end;

procedure TTestTResultPair.TestLeavingScopeDoesNotFree;
var
  LSpy: TSpyObject;
  LBefore: Integer;

  procedure _Scope;
  var
    LPair: TResultPair<String, TSpyObject>;
  begin
    LPair := TResultPair<String, TSpyObject>.New.Failure(LSpy);
    Assert.IsTrue(LPair.isFailure, 'failure pair built inside the scope');
  end;

begin
  // Contract lock: adding a class operator Finalize would make this pass silently while
  // double-freeing every consumer that already releases the failure by hand (and every
  // intermediate `Result := Self` copy inside the unit itself). The reference is kept
  // OUTSIDE the scope precisely because the record does not release it.
  LSpy := TSpyObject.Create;
  LBefore := GSpyDestroyed;

  _Scope;

  Assert.AreEqual(LBefore, GSpyDestroyed,
    'leaving scope releases NOTHING - ownership stays with the caller, on purpose');
  LSpy.Free;
  Assert.AreEqual(LBefore + 1, GSpyDestroyed, 'the caller is the one who releases it');
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTResultPair);
end.
