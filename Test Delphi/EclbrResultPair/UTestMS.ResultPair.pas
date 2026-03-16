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
  LResultPair: TResultPair<Integer, String>;
begin
  LResultPair := TResultPair<Integer, String>.Failure('Error');
  Assert.IsFalse(LResultPair.IsSuccess);
  Assert.IsTrue(LResultPair.IsFailure);
  Assert.AreEqual('Error', LResultPair.ValueFailure);
end;

procedure TTestTResultPair.TestFlatMap;
var
  LResultPair: TResultPair<Integer, String>;
begin
  LResultPair := TResultPair<Integer, String>.Success(FSuccessValue)
    .FlatMap<Integer>(
      function(Value: Integer): Integer
      var
        LResult: TResultPair<Integer, String>;
      begin
        LResult := TResultPair<Integer, String>.Success(Value * 2);
        Result := LResult.ValueSuccess;
      end);

  Assert.IsTrue(LResultPair.IsSuccess);
  Assert.AreEqual(FSuccessValue * 2, LResultPair.ValueSuccess);
end;

procedure TTestTResultPair.TestFlatMapFailure;
var
  LResultPair: TResultPair<Integer, String>;
begin
  LResultPair := TResultPair<Integer, String>.Failure(FFailureValue)
    .FlatMap<String>(
      function(Error: String): String
      var
        LResult: TResultPair<Integer, String>;
      begin
        LResult := TResultPair<Integer, String>.Failure(Error + 'Handled');
        Result := LResult.ValueFailure;
      end);

  Assert.IsTrue(LResultPair.IsFailure);
  Assert.AreEqual(FFailureValue + 'Handled', LResultPair.ValueFailure);
end;

procedure TTestTResultPair.TestMap;
var
  LResultPair: TResultPair<Double, String>;
  LResult: Double;
begin
  LResultPair := TResultPair<Double, String>
    .Success(FDividend div FDivisor)
    .Map<Double>(function(Value: Double): Double
                 begin
                   Result := Value * 2.5;
                 end);

  LResult := (FDividend div FDivisor) * 2.5;
  Assert.AreEqual(LResultPair.ValueSuccess, LResult, '');
end;

procedure TTestTResultPair.TestMapTryException;
var
  LResultPair: TResultPair<Double, String>;
  LResult: Double;
begin
  LResultPair := TResultPair<Double, String>
    .Success(42)
    .Map<Double>(function(Value: Double): Double
                 begin
                   Result := Value * 2.5;
                 end);

  LResult := 42 * 2.5;
  Assert.AreEqual(LResultPair.ValueSuccess, LResult);
end;

procedure TTestTResultPair.TestSuccess;
var
  LResultPair: TResultPair<Integer, String>;
begin
  LResultPair := TResultPair<Integer, String>.Success(42);
  Assert.IsTrue(LResultPair.IsSuccess);
  Assert.IsFalse(LResultPair.IsFailure);
  Assert.AreEqual(42, LResultPair.ValueSuccess);
end;

procedure TTestTResultPair.TestTryException;
var
  LResultPair: TResultPair<Integer, String>;
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
    function (Value: String): Boolean
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
  LResultPair := TResultPair<Integer, String>.Success(FSuccessValue);
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
  LResultPair := TResultPair<String, Integer>.Failure(42);
  Assert.AreEqual(LResultPair.FailureOrDefault, 42);
end;

procedure TTestTResultPair.TestGetFailureOrDefaultWithDefault;
var
  LResultPair: TResultPair<String, Integer>;
begin
  LResultPair := TResultPair<String, Integer>.Failure(42);
  Assert.AreEqual(LResultPair.FailureOrDefault(100), 42);
end;

procedure TTestTResultPair.TestGetFailureOrElse;
var
  LResultPair: TResultPair<String, Integer>;
begin
  LResultPair := TResultPair<String, Integer>.Failure(42);
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
  LResultPair := TResultPair<String, Integer>.Success('');
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
  LResultPair := TResultPair<Integer, String>.Success(42);
  Assert.AreEqual(LResultPair.SuccessOrDefault, 42);
end;

procedure TTestTResultPair.TestGetSuccessOrDefaultWithDefault;
var
  LResultPair: TResultPair<Integer, String>;
begin
  LResultPair := TResultPair<Integer, String>.Success(42);
  Assert.AreEqual(LResultPair.SuccessOrDefault(100), 42);
end;

procedure TTestTResultPair.TestGetSuccessOrElse;
var
  LResultPair: TResultPair<Integer, String>;
begin
  LResultPair := TResultPair<Integer, String>.Success(42);
  Assert.AreEqual(LResultPair.SuccessOrElse(
    function(Value: Integer): Integer
    begin
      Result := Value * 2;
    end
  ), 42);
end;

procedure TTestTResultPair.TestGetSuccessOrException;
var
  LResultPair: TResultPair<Integer, String>;
begin
  LResultPair := TResultPair<Integer, String>.Failure('42');
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
  LResultPair := TResultPair<Integer, String>.Failure(FFailureValue);
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
  LResultPair := TResultPair<TStringList, String>.Success(TStringList.Create);
  Assert.IsTrue(LResultPair.IsSuccess);
end;

procedure TTestTResultPair.TestValueSuccessNil;
var
  LResultPair: TResultPair<TObject, String>;
  LSum: Integer;
begin
  LResultPair.SetSuccess(nil);

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
  Result := TResultPair<TObject, String>.Success(nil);
  if Result.ValueSuccess = nil then
    Exit;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTResultPair);
end.
