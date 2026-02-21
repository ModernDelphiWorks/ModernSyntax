unit UTestEvolution.Currying;

interface

uses
  DUnitX.TestFramework,
  SysUtils,
  Rtti,
  Generics.Collections,
  Generics.Defaults,
  System.Diagnostics,
  System.Classes,
  DateUtils,
  Evolution.Currying;

type

  [TestFixture]
  TTestCurrying = class
  public
    [Test]
    procedure TestConstructorAndValue;
    [Test]
    procedure TestSumOperationDouble;
    [Test]
    procedure TestSumOperationInteger;
    [Test]
    procedure TestSumOperationExtended;
    [Test]
    procedure TestSubtractOperationDouble;
    [Test]
    procedure TestSubtractOperationInteger;
    [Test]
    procedure TestMultiplyOperationDouble;
    [Test]
    procedure TestMultiplyOperationInteger;
    [Test]
    procedure TestDivideOperationDouble;
    [Test]
    procedure TestDivideOperationInteger;
    [Test]
    procedure TestDivideByZeroDouble;
    [Test]
    procedure TestDivideByZeroInteger;
    [Test]
    procedure TestPowerOperationDouble;
    [Test]
    procedure TestPowerOperationInteger;
    [Test]
    procedure TestModulusOperationDouble;
    [Test]
    procedure TestModulusOperationInteger;
    [Test]
    procedure TestConcatOperation;
    [Test]
    procedure TestComposeFunctions;
    [Test]
    procedure TestPipeline;
    [Test]
    procedure TestMemoize;
    [Test]
    procedure TestCurryAndUnCurry;
    [Test]
    procedure TestPipeWithMultipleOperations;
    [Test]
    procedure TestPartialWithFixFirstFalse;
    [Test]
    procedure TestMemoizeThreadSafety;
    [Test]
    procedure TestMapIntegerToString;
    [Test]
    procedure TestFilterEvenNumbers;
    [Test]
    procedure TestFoldSumIntegers;
    [Test]
    procedure TestTakeFirstThree;
    [Test]
    procedure TestDropFirstThree;
    [Test]
    procedure TestZipIntegersAndStrings;
    [Test]
    procedure TestAnyHasEvenNumbers;
    [Test]
    procedure TestAllPositiveNumbers;
    [Test]
    procedure TestGroupByParity;
    [Test]
    procedure TestTakeWhileLessThanFive;
    [Test]
    procedure TestDropWhileLessThanThree;
    [Test]
    procedure TestDistinctRemoveDuplicates;
    [Test]
    procedure TestReverseList;
    [Test]
    procedure TestSortList;
    [Test]
    procedure TestCountEvenNumbers;
    [Test]
    procedure TestFirstEvenNumber;
    [Test]
    procedure TestLastEvenNumber;
    [Test]
    procedure TestStringRepeatOperation;
    [Test]
    procedure TestListConcatOperation;
    [Test]
    procedure TestConcatLists;
    [Test]
    procedure TestPartitionByParity;
    [Test]
    procedure TestFlattenLists;
    [Test]
    procedure TestSequenceEqual;
    [Test]
    procedure TestBooleanOperation;
    [Test]
    procedure TestDateTimeOperation;
    [Test]
    procedure TestStringOperation;
    [Test]
    procedure TestCurrencyOperation;
    [Test]
    procedure TestByteOperation;
    [Test]
    procedure TestShortIntOperation;
    [Test]
    procedure TestWordOperation;
    [Test]
    procedure TestSmallIntOperation;
    [Test]
    procedure TestLongWordOperation;
    [Test]
    procedure TestInt64Operation;
    [Test]
    procedure TestSingleOperation;
  end;

implementation

uses
  System.Math;

procedure TTestCurrying.TestConstructorAndValue;
var
  LCurrying: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Double>(10.0));
  Assert.AreEqual(Double(10.0), LCurrying.Value<Double>);

  Writeln('TestConstructorAndValue: Valor inicial = ' +
    FloatToStr(LCurrying.Value<Double>));
end;

procedure TTestCurrying.TestSumOperationDouble;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Double>(5.0));
  LResult := LCurrying.Op<Double>(
    function(A, B: Double): Double
    begin
      Result := A + B;
    end)(3.0);

  Assert.AreEqual(Double(8.0), LResult.Value<Double>);

  Writeln('TestSumOperationDouble: 5 + 3 = ' +
    FloatToStr(LResult.Value<Double>));
end;

procedure TTestCurrying.TestSumOperationInteger;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Integer>(5));
  LResult := LCurrying.Op<Integer>(
    function(A, B: Integer): Integer
    begin
      Result := A + B;
    end)(3);

  Assert.AreEqual(8, LResult.Value<Integer>);

  Writeln('TestSumOperationInteger: 5 + 3 = ' +
    IntToStr(LResult.Value<Integer>));
end;

procedure TTestCurrying.TestSumOperationExtended;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Extended>(5.0));
  LResult := LCurrying.Op<Extended>(
    function(A, B: Extended): Extended
    begin
      Result := A + B;
    end)(3.0);

  Assert.AreEqual(Extended(8.0), LResult.Value<Extended>);

  Writeln('TestSumOperationExtended: 5 + 3 = ' +
    FloatToStr(LResult.Value<Extended>));
end;

procedure TTestCurrying.TestSubtractOperationDouble;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Double>(10.0));
  LResult := LCurrying.Op<Double>(
    function(A, B: Double): Double
    begin
      Result := A - B;
    end)(4.0);

  Assert.AreEqual(Double(6.0), LResult.Value<Double>);

  Writeln('TestSubtractOperationDouble: 10 - 4 = ' +
    FloatToStr(LResult.Value<Double>));
end;

procedure TTestCurrying.TestSubtractOperationInteger;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Integer>(10));
  LResult := LCurrying.Op<Integer>(
    function(A, B: Integer): Integer
    begin
      Result := A - B;
    end)(4);

  Assert.AreEqual(6, LResult.Value<Integer>);

  Writeln('TestSubtractOperationInteger: 10 - 4 = ' +
    IntToStr(LResult.Value<Integer>));
end;

procedure TTestCurrying.TestMultiplyOperationDouble;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Double>(3.0));
  LResult := LCurrying.Op<Double>(
    function(A, B: Double): Double
    begin
      Result := A * B;
    end)(2.0);

  Assert.AreEqual(Double(6.0), LResult.Value<Double>);

  Writeln('TestMultiplyOperationDouble: 3 * 2 = ' +
    FloatToStr(LResult.Value<Double>));
end;

procedure TTestCurrying.TestMultiplyOperationInteger;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Integer>(3));
  LResult := LCurrying.Op<Integer>(
    function(A, B: Integer): Integer
    begin
      Result := A * B;
    end)(2);

  Assert.AreEqual(6, LResult.Value<Integer>);

  Writeln('TestMultiplyOperationInteger: 3 * 2 = ' +
    IntToStr(LResult.Value<Integer>));
end;

procedure TTestCurrying.TestDivideOperationDouble;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Double>(12.0));
  LResult := LCurrying.Op<Double>(
    function(A, B: Double): Double
    begin
      if B = 0 then
        raise EDivByZero.Create('Division by zero');
      Result := A / B;
    end)(2.0);

  Assert.AreEqual(Double(6.0), LResult.Value<Double>);

  Writeln('TestDivideOperationDouble: 12 / 2 = ' +
    FloatToStr(LResult.Value<Double>));
end;

procedure TTestCurrying.TestDivideOperationInteger;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Integer>(12));
  LResult := LCurrying.Op<Integer>(
    function(A, B: Integer): Integer
    begin
      if B = 0 then
        raise EDivByZero.Create('Division by zero');
      Result := A div B;
    end)(2);

  Assert.AreEqual(6, LResult.Value<Integer>);

  Writeln('TestDivideOperationInteger: 12 / 2 = ' +
    IntToStr(LResult.Value<Integer>));
end;

procedure TTestCurrying.TestDivideByZeroDouble;
var
  LCurrying: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Double>(10.0));

  Assert.WillRaise(
    procedure
    begin
      LCurrying.Op<Double>(
        function(A, B: Double): Double
        begin
          if B = 0 then
            raise EDivByZero.Create('Division by zero');
          Result := A / B;
        end)(0.0);
    end, EDivByZero, 'Deveria lançar exceção de divisão por zero');

  Writeln('TestDivideByZeroDouble: Exceção de divisão por zero verificada');
end;

procedure TTestCurrying.TestDivideByZeroInteger;
var
  LCurrying: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Integer>(10));

  Assert.WillRaise(
    procedure
    begin
      LCurrying.Op<Integer>(
        function(A, B: Integer): Integer
        begin
          if B = 0 then
            raise EDivByZero.Create('Division by zero');
          Result := A div B;
        end)(0);
    end, EDivByZero, 'Deveria lançar exceção de divisão por zero');

  Writeln('TestDivideByZeroInteger: Exceção de divisão por zero verificada');
end;

procedure TTestCurrying.TestPowerOperationDouble;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Double>(2.0));
  LResult := LCurrying.Op<Double>(
    function(A, B: Double): Double
    begin
      Result := Power(A, B);
    end)(2.0);

  Assert.AreEqual(Double(4.0), LResult.Value<Double>);

  Writeln('TestPowerOperationDouble: 2 ^ 2 = ' +
    FloatToStr(LResult.Value<Double>));
end;

procedure TTestCurrying.TestPowerOperationInteger;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Integer>(2));
  LResult := LCurrying.Op<Integer>(
    function(A, B: Integer): Integer
    var
      LBase, LExponent, LResult: Integer;
    begin
      LBase := A;
      LExponent := B;
      LResult := 1;
      while LExponent > 0 do
      begin
        LResult := LResult * LBase;
        Dec(LExponent);
      end;
      Result := LResult;
    end)(2);
  Assert.AreEqual(4, LResult.Value<Integer>);
  Writeln('TestPowerOperationInteger: 2 ^ 2 = ' +
    IntToStr(LResult.Value<Integer>));
end;

procedure TTestCurrying.TestModulusOperationDouble;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Double>(10.0));
  LResult := LCurrying.Op<Double>(
    function(A, B: Double): Double
    begin
      if B = 0 then
        raise EDivByZero.Create('Modulus by zero');
      Result := Trunc(A) mod Trunc(B);
    end)(3.0);
  Assert.AreEqual(Double(1.0), LResult.Value<Double>);
  Writeln('TestModulusOperationDouble: 10 mod 3 = ' +
    FloatToStr(LResult.Value<Double>));
end;

procedure TTestCurrying.TestModulusOperationInteger;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Integer>(10));
  LResult := LCurrying.Op<Integer>(
    function(A, B: Integer): Integer
    begin
      if B = 0 then
        raise EDivByZero.Create('Modulus by zero');
      Result := A mod B;
    end)(3);
  Assert.AreEqual(1, LResult.Value<Integer>);
  Writeln('TestModulusOperationInteger: 10 mod 3 = ' +
    IntToStr(LResult.Value<Integer>));
end;

procedure TTestCurrying.TestConcatOperation;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<string>('Hello'));
  LResult := LCurrying.Concat()(' World');
  Assert.AreEqual('Hello World', LResult.Value<string>);
  Writeln('TestConcatOperation: Concatenado = ' + LResult.Value<string>);
end;

procedure TTestCurrying.TestComposeFunctions;
var
  LDouble: TFunc<Integer, Integer>;
  LAddOne: TFunc<Integer, Integer>;
  LComposed: TFunc<Integer, Integer>;
  LResult: Integer;
begin
  LDouble := function(X: Integer): Integer
    begin
      Result := X * 2;
    end;
  LAddOne := function(X: Integer): Integer
    begin
      Result := X + 1;
    end;
  LComposed := TCurrying.Compose<Integer, Integer, Integer>(LDouble, LAddOne);
  LResult := LComposed(2);
  Assert.AreEqual(6, LResult);
  Writeln('TestComposeFunctions: (2 + 1) * 2 = ' + IntToStr(LResult));
end;

procedure TTestCurrying.TestPipeline;
var
  LPipeline: TPipeline<Integer>;
  LStopwatch: TStopwatch;
  LTime: Int64;
begin
  LStopwatch := TStopwatch.StartNew;
  LPipeline := TCurrying.Pipe<Integer>(5).Apply<Integer>(
    function(X: Integer): Integer
    begin
      Result := X * 2;
    end).Thn<Integer>(
    function(X: Integer): Integer
    begin
      Result := X + 3;
    end);
  LTime := LStopwatch.ElapsedMilliseconds;
  Assert.AreEqual(13, LPipeline.Value, 'Resultado deve ser 13');
  Assert.IsTrue(LTime < 50, 'Pipeline deve ser executado rapidamente (< 50ms)');
  Writeln('TestPipeline: (5 * 2) + 3 = ' + IntToStr(LPipeline.Value) +
    ', Tempo = ' + IntToStr(LTime) + ' ms');
end;

procedure TTestCurrying.TestMemoize;
var
  LSlowFunc: TFunc<Integer, Integer>;
  LMemoized: TFunc<Integer, Integer>;
  LStopwatch: TStopwatch;
  LFirstCallTime, LSecondCallTime: Int64;
begin
  LSlowFunc := function(X: Integer): Integer
    begin
      Sleep(100);
      Result := X * 2;
    end;

  LMemoized := TCurrying.Memoize<Integer, Integer>(LSlowFunc);

  LStopwatch := TStopwatch.StartNew;
  Assert.AreEqual(4, LMemoized(2), 'Resultado da primeira chamada deve ser 4');
  LFirstCallTime := LStopwatch.ElapsedMilliseconds;
  Assert.IsTrue(LFirstCallTime >= 90, 'Primeira chamada deve levar pelo menos 90ms');
  Writeln('TestMemoize: Primeira chamada (2 * 2) = ' + IntToStr(LMemoized(2)) + ', Tempo = ' + IntToStr(LFirstCallTime) + ' ms');

  LStopwatch := TStopwatch.StartNew;
  Assert.AreEqual(4, LMemoized(2), 'Resultado da segunda chamada deve ser 4');
  LSecondCallTime := LStopwatch.ElapsedMilliseconds;
  Assert.IsTrue(LSecondCallTime < 10, 'Segunda chamada deve ser rápida (< 10ms)');
  Writeln('TestMemoize: Segunda chamada (cached) = ' + IntToStr(LMemoized(2)) + ', Tempo = ' + IntToStr(LSecondCallTime) + ' ms');
end;

procedure TTestCurrying.TestCurryAndUnCurry;
var
  LAdd: TFunc<Integer, Integer, Integer>;
  LCurried: TFunc<Integer, TFunc<Integer, Integer>>;
  LUnCurried: TFunc<Integer, Integer, Integer>;
  LCurryResult, LUnCurryResult: Integer;
begin
  LAdd := function(X, Y: Integer): Integer
    begin
      Result := X + Y;
    end;
  LCurried := TCurrying.Curry<Integer, Integer, Integer>(LAdd);
  LUnCurried := TCurrying.UnCurry<Integer, Integer, Integer>(LCurried);

  LCurryResult := LCurried(2)(3);
  LUnCurryResult := LUnCurried(2, 3);
  Assert.AreEqual(5, LCurryResult);
  Assert.AreEqual(5, LUnCurryResult);
  Writeln('TestCurryAndUnCurry: Curried(2)(3) = ' + IntToStr(LCurryResult) + ', UnCurried(2, 3) = ' + IntToStr(LUnCurryResult));
end;

procedure TTestCurrying.TestPipeWithMultipleOperations;
var
  LPipeline: TPipeline<Integer>;
  LStopwatch: TStopwatch;
  LTime: Int64;
begin
  LStopwatch := TStopwatch.StartNew;
  LPipeline := TCurrying.Pipe<Integer>(10).Map<Integer>(
    function(X: Integer): Integer
    begin
      Result := X * 2;
    end).Apply<Integer>(
    function(X: Integer): Integer
    begin
      Result := X + 5;
    end).Thn<Integer>(
    function(X: Integer): Integer
    begin
      Result := X - 3;
    end);
  LTime := LStopwatch.ElapsedMilliseconds;
  Assert.AreEqual(22, LPipeline.Value, 'Resultado deve ser 22');
  Assert.IsTrue(LTime < 50, 'Pipeline com múltiplas operações deve ser rápido (< 50ms)');
  Writeln('TestPipeWithMultipleOperations: ((10 * 2) + 5) - 3 = ' + IntToStr(LPipeline.Value) + ', Tempo = ' + IntToStr(LTime) + ' ms');
end;

procedure TTestCurrying.TestPartialWithFixFirstFalse;
var
  LSubtract: TFunc<Integer, Integer, Integer>;
  LPartialFunc: TFunc<Integer, Integer>;
  LResult: Integer;
begin
  LSubtract := function(X, Y: Integer): Integer
    begin
      Result := X - Y;
    end;
  LPartialFunc := TCurrying.Partial<Integer, Integer>(LSubtract, 3, False);
  LResult := LPartialFunc(10);
  Assert.AreEqual(7, LResult, '10 - 3 = 7 com FixFirst = False');
  Writeln('TestPartialWithFixFirstFalse: 10 - 3 = ' + IntToStr(LResult));
end;

procedure TTestCurrying.TestMemoizeThreadSafety;
var
  LSlowFunc: TFunc<Integer, Integer>;
  LMemoized: TFunc<Integer, Integer>;
  LThreads: array [1 .. 10] of TThread;
  LIndex: Integer;

  function CreateThreadProc(ThreadIndex: Integer): TProc;
  begin
    Result := procedure
      var
        LResult: Integer;
      begin
        LResult := LMemoized(2);
        Assert.AreEqual(4, LResult);
        Writeln('Thread ' + IntToStr(ThreadIndex) + ': Resultado = ' + IntToStr(LResult));
      end;
  end;

begin
  LSlowFunc := function(X: Integer): Integer
    begin
      Sleep(100);
      Result := X * 2;
    end;

  LMemoized := TCurrying.Memoize<Integer, Integer>(LSlowFunc);

  for LIndex := 1 to 10 do
  begin
    LThreads[LIndex] := TThread.CreateAnonymousThread(CreateThreadProc(LIndex));
    LThreads[LIndex].FreeOnTerminate := False;
  end;

  for LIndex := 1 to 10 do
    LThreads[LIndex].Start;

  for LIndex := 1 to 10 do
  begin
    LThreads[LIndex].WaitFor;
    LThreads[LIndex].Free;
  end;

  LMemoized := nil;

  Writeln('TestMemoizeThreadSafety: Todas as threads concluídas');
end;

procedure TTestCurrying.TestMapIntegerToString;
var
  LInput: TList<Integer>;
  LOutput: TList<string>;
  LFor: Integer;
begin
  LInput := TList<Integer>.Create;
  try
    LInput.AddRange([1, 2, 3, 4, 5]);
    LOutput := TCurrying.Map<Integer, string>(LInput,
      function(X: Integer): string
      begin
        Result := IntToStr(X * 2);
      end);
    try
      Assert.AreEqual(5, LOutput.Count, 'Deve ter 5 elementos');
      for LFor := 0 to 4 do
        Assert.AreEqual(IntToStr((LFor + 1) * 2), LOutput[LFor], 'Elemento ' + IntToStr(LFor) + ' incorreto');
      Writeln('TestMapIntegerToString: [' + TCurrying.ArrayToString<string> (LOutput.ToArray) + ']');
    finally
      LOutput.Free;
    end;
  finally
    LInput.Free;
  end;
end;

procedure TTestCurrying.TestFilterEvenNumbers;
var
  LInput, LOutput: TList<Integer>;
begin
  LInput := TList<Integer>.Create;
  try
    LInput.AddRange([1, 2, 3, 4, 5, 6]);
    LOutput := TCurrying.Filter<Integer>(LInput,
      function(X: Integer): Boolean
      begin
        Result := X mod 2 = 0;
      end);
    try
      Assert.AreEqual(3, LOutput.Count, 'Deve ter 3 elementos pares');
      Assert.AreEqual(2, LOutput[0], 'Primeiro elemento incorreto');
      Assert.AreEqual(4, LOutput[1], 'Segundo elemento incorreto');
      Assert.AreEqual(6, LOutput[2], 'Terceiro elemento incorreto');
      Writeln('TestFilterEvenNumbers: [' + TCurrying.ArrayToString<Integer>(LOutput.ToArray) + ']');
    finally
      LOutput.Free;
    end;
  finally
    LInput.Free;
  end;
end;

procedure TTestCurrying.TestFoldSumIntegers;
var
  LInput: TList<Integer>;
  LSum: Integer;
begin
  LInput := TList<Integer>.Create;
  try
    LInput.AddRange([1, 2, 3, 4, 5]);
    LSum := TCurrying.Fold<Integer, Integer>(LInput, 0,
      function(Acc, X: Integer): Integer
      begin
        Result := Acc + X;
      end);

    Assert.AreEqual(15, LSum, 'Soma deve ser 15');
    Writeln('TestFoldSumIntegers: Soma = ' + IntToStr(LSum));
  finally
    LInput.Free;
  end;
end;

procedure TTestCurrying.TestTakeFirstThree;
var
  LInput, LOutput: TList<Integer>;
begin
  LInput := TList<Integer>.Create;
  try
    LInput.AddRange([1, 2, 3, 4, 5]);
    LOutput := TCurrying.Take<Integer>(LInput, 3);
    try
      Assert.AreEqual(3, LOutput.Count, 'Deve ter 3 elementos');
      Assert.AreEqual(1, LOutput[0], 'Primeiro elemento incorreto');
      Assert.AreEqual(2, LOutput[1], 'Segundo elemento incorreto');
      Assert.AreEqual(3, LOutput[2], 'Terceiro elemento incorreto');
      Writeln('TestTakeFirstThree: [' + TCurrying.ArrayToString<Integer>(LOutput.ToArray) + ']');
    finally
      LOutput.Free;
    end;
  finally
    LInput.Free;
  end;
end;

procedure TTestCurrying.TestDropFirstThree;
var
  LInput, LOutput: TList<Integer>;
begin
  LInput := TList<Integer>.Create;
  try
    LInput.AddRange([1, 2, 3, 4, 5]);
    LOutput := TCurrying.Drop<Integer>(LInput, 3);
    try
      Assert.AreEqual(2, LOutput.Count, 'Deve ter 2 elementos');
      Assert.AreEqual(4, LOutput[0], 'Primeiro elemento incorreto');
      Assert.AreEqual(5, LOutput[1], 'Segundo elemento incorreto');
      Writeln('TestDropFirstThree: [' + TCurrying.ArrayToString<Integer>(LOutput.ToArray) + ']');
    finally
      LOutput.Free;
    end;
  finally
    LInput.Free;
  end;
end;

procedure TTestCurrying.TestZipIntegersAndStrings;
var
  LNumbers: TList<Integer>;
  LWords: TList<string>;
  LPairs: TList<TPair<Integer, string>>;
  LFor: Integer;
begin
  LNumbers := TList<Integer>.Create;
  LWords := TList<string>.Create;
  try
    LNumbers.AddRange([1, 2, 3]);
    LWords.AddRange(['one', 'two', 'three']);
    LPairs := TCurrying.Zip<Integer, string>(LNumbers, LWords);
    try
      Assert.AreEqual(3, LPairs.Count, 'Deve ter 3 pares');
      for LFor := 0 to 2 do
      begin
        Assert.AreEqual(LFor + 1, LPairs[LFor].Key,
          'Chave do par ' + IntToStr(LFor) + ' incorreto');
        Assert.AreEqual(LWords[LFor], LPairs[LFor].Value,
          'Valor do par ' + IntToStr(LFor) + ' incorreto');
      end;

      Writeln('TestZipIntegersAndStrings: [' + TCurrying.ArrayToString<TPair<Integer, string>> (LPairs.ToArray, '; ') + ']');
    finally
      LPairs.Free;
    end;
  finally
    LWords.Free;
    LNumbers.Free;
  end;
end;

procedure TTestCurrying.TestAnyHasEvenNumbers;
var
  LInput: TList<Integer>;
  LResult: Boolean;
begin
  LInput := TList<Integer>.Create;
  try
    LInput.AddRange([1, 3, 5, 6, 7]);
    LResult := TCurrying.Any<Integer>(LInput,
      function(X: Integer): Boolean
      begin
        Result := X mod 2 = 0;
      end);

    Assert.IsTrue(LResult, 'Deve haver pelo menos um número par');
    Writeln('TestAnyHasEvenNumbers: Existe par = ' + BoolToStr(LResult, True));
  finally
    LInput.Free;
  end;
end;

procedure TTestCurrying.TestAllPositiveNumbers;
var
  LInput: TList<Integer>;
  LResult: Boolean;
begin
  LInput := TList<Integer>.Create;
  try
    LInput.AddRange([1, 2, 3, 4, 5]);
    LResult := TCurrying.All<Integer>(LInput,
      function(X: Integer): Boolean
      begin
        Result := X > 0;
      end);
    Assert.IsTrue(LResult, 'Todos os números devem ser positivos');
    Writeln('TestAllPositiveNumbers: Todos positivos = ' + BoolToStr(LResult, True));

    LInput.Clear;
    LInput.AddRange([1, 2, -3, 4, 5]);
    LResult := TCurrying.All<Integer>(LInput,
      function(X: Integer): Boolean
      begin
        Result := X > 0;
      end);

    Assert.IsFalse(LResult, 'Nem todos os números são positivos');
    Writeln('TestAllPositiveNumbers: Todos positivos (com negativo) = ' + BoolToStr(LResult, True));
  finally
    LInput.Free;
  end;
end;

procedure TTestCurrying.TestGroupByParity;
var
  LInput: TList<Integer>;
  LGroups: TDictionary<Integer, TList<Integer>>;
  LEvenList, LOddList: TList<Integer>;
begin
  LInput := TList<Integer>.Create;
  try
    LInput.AddRange([1, 2, 3, 4, 5, 6]);
    LGroups := TCurrying.GroupBy<Integer, Integer>(LInput,
      function(X: Integer): Integer
      begin
        Result := X mod 2;
      end);
    try
      Assert.AreEqual(2, LGroups.Count, 'Deve haver 2 grupos (par e ímpar)');

      Assert.IsTrue(LGroups.TryGetValue(0, LEvenList), 'Deve haver grupo de pares');
      Assert.AreEqual(3, LEvenList.Count, 'Deve haver 3 números pares');
      Assert.Contains<Integer>(LEvenList.ToArray, 2, 'Grupo de pares deve conter 2');
      Assert.Contains<Integer>(LEvenList.ToArray, 4, 'Grupo de pares deve conter 4');
      Assert.Contains<Integer>(LEvenList.ToArray, 6, 'Grupo de pares deve conter 6');

      Assert.IsTrue(LGroups.TryGetValue(1, LOddList), 'Deve haver grupo de ímpares');
      Assert.AreEqual(3, LOddList.Count, 'Deve haver 3 números ímpares');
      Assert.Contains<Integer>(LOddList.ToArray, 1, 'Grupo de ímpares deve conter 1');
      Assert.Contains<Integer>(LOddList.ToArray, 3, 'Grupo de ímpares deve conter 3');
      Assert.Contains<Integer>(LOddList.ToArray, 5, 'Grupo de ímpares deve conter 5');

      Writeln('TestGroupByParity: Pares = [' + TCurrying.ArrayToString<Integer>(LEvenList.ToArray) + ']');
      Writeln('TestGroupByParity: Ímpares = [' + TCurrying.ArrayToString<Integer>(LOddList.ToArray) + ']');
    finally
      for var LList in LGroups.Values do
        LList.Free;
      LGroups.Free;
    end;
  finally
    LInput.Free;
  end;
end;

procedure TTestCurrying.TestTakeWhileLessThanFive;
var
  LInput, LOutput: TList<Integer>;
begin
  LInput := TList<Integer>.Create;
  try
    LInput.AddRange([1, 2, 3, 4, 5, 6]);
    LOutput := TCurrying.TakeWhile<Integer>(LInput,
      function(X: Integer): Boolean
      begin
        Result := X < 5;
      end);
    try
      Assert.AreEqual(4, LOutput.Count, 'Deve ter 4 elementos menores que 5');
      Assert.AreEqual(1, LOutput[0], 'Primeiro elemento incorreto');
      Assert.AreEqual(2, LOutput[1], 'Segundo elemento incorreto');
      Assert.AreEqual(3, LOutput[2], 'Terceiro elemento incorreto');
      Assert.AreEqual(4, LOutput[3], 'Quarto elemento incorreto');
      Writeln('TestTakeWhileLessThanFive: [' + TCurrying.ArrayToString<Integer>(LOutput.ToArray) + ']');
    finally
      LOutput.Free;
    end;
  finally
    LInput.Free;
  end;
end;

procedure TTestCurrying.TestDropWhileLessThanThree;
var
  LInput, LOutput: TList<Integer>;
begin
  LInput := TList<Integer>.Create;
  try
    LInput.AddRange([1, 2, 3, 4, 5, 6]);
    LOutput := TCurrying.DropWhile<Integer>(LInput,
      function(X: Integer): Boolean
      begin
        Result := X < 3;
      end);
    try
      Assert.AreEqual(4, LOutput.Count, 'Deve ter 4 elementos a partir de 3');
      Assert.AreEqual(3, LOutput[0], 'Primeiro elemento incorreto');
      Assert.AreEqual(4, LOutput[1], 'Segundo elemento incorreto');
      Assert.AreEqual(5, LOutput[2], 'Terceiro elemento incorreto');
      Assert.AreEqual(6, LOutput[3], 'Quarto elemento incorreto');
      Writeln('TestDropWhileLessThanThree: [' + TCurrying.ArrayToString<Integer>(LOutput.ToArray) + ']');
    finally
      LOutput.Free;
    end;
  finally
    LInput.Free;
  end;
end;

procedure TTestCurrying.TestDistinctRemoveDuplicates;
var
  LInput, LOutput: TList<Integer>;
begin
  LInput := TList<Integer>.Create;
  try
    LInput.AddRange([1, 2, 2, 3, 3, 4, 1]);
    LOutput := TCurrying.Distinct<Integer>(LInput);
    try
      Assert.AreEqual(4, LOutput.Count, 'Deve ter 4 elementos únicos');
      Assert.Contains<Integer>(LOutput.ToArray, 1, 'Deve conter 1');
      Assert.Contains<Integer>(LOutput.ToArray, 2, 'Deve conter 2');
      Assert.Contains<Integer>(LOutput.ToArray, 3, 'Deve conter 3');
      Assert.Contains<Integer>(LOutput.ToArray, 4, 'Deve conter 4');
      Writeln('TestDistinctRemoveDuplicates: [' + TCurrying.ArrayToString<Integer>(LOutput.ToArray) + ']');
    finally
      LOutput.Free;
    end;
  finally
    LInput.Free;
  end;
end;

procedure TTestCurrying.TestReverseList;
var
  LInput, LOutput: TList<Integer>;
begin
  LInput := TList<Integer>.Create;
  try
    LInput.AddRange([1, 2, 3, 4, 5]);
    LOutput := TCurrying.Reverse<Integer>(LInput);
    try
      Assert.AreEqual(5, LOutput.Count, 'Deve ter 5 elementos');
      Assert.AreEqual(5, LOutput[0], 'Primeiro elemento incorreto');
      Assert.AreEqual(4, LOutput[1], 'Segundo elemento incorreto');
      Assert.AreEqual(3, LOutput[2], 'Terceiro elemento incorreto');
      Assert.AreEqual(2, LOutput[3], 'Quarto elemento incorreto');
      Assert.AreEqual(1, LOutput[4], 'Quinto elemento incorreto');
      Writeln('TestReverseList: [' + TCurrying.ArrayToString<Integer>(LOutput.ToArray) + ']');
    finally
      LOutput.Free;
    end;
  finally
    LInput.Free;
  end;
end;

procedure TTestCurrying.TestSortList;
var
  LInput, LOutput: TList<Integer>;
begin
  LInput := TList<Integer>.Create;
  try
    LInput.AddRange([3, 1, 4, 1, 5, 9, 2]);
    LOutput := TCurrying.Sort<Integer>(LInput);
    try
      Assert.AreEqual(7, LOutput.Count, 'Deve ter 7 elementos');
      Assert.AreEqual(1, LOutput[0], 'Primeiro elemento incorreto');
      Assert.AreEqual(1, LOutput[1], 'Segundo elemento incorreto');
      Assert.AreEqual(2, LOutput[2], 'Terceiro elemento incorreto');
      Assert.AreEqual(3, LOutput[3], 'Quarto elemento incorreto');
      Assert.AreEqual(4, LOutput[4], 'Quinto elemento incorreto');
      Assert.AreEqual(5, LOutput[5], 'Sexto elemento incorreto');
      Assert.AreEqual(9, LOutput[6], 'Sétimo elemento incorreto');
      Writeln('TestSortList: [' + TCurrying.ArrayToString<Integer>(LOutput.ToArray) + ']');
    finally
      LOutput.Free;
    end;
  finally
    LInput.Free;
  end;
end;

procedure TTestCurrying.TestCountEvenNumbers;
var
  LInput: TList<Integer>;
  LCount: Integer;
begin
  LInput := TList<Integer>.Create;
  try
    LInput.AddRange([1, 2, 3, 4, 5, 6]);
    LCount := TCurrying.Count<Integer>(LInput,
      function(X: Integer): Boolean
      begin
        Result := X mod 2 = 0;
      end);

    Assert.AreEqual(3, LCount, 'Deve haver 3 números pares');
    Writeln('TestCountEvenNumbers: Quantidade de pares = ' + IntToStr(LCount));
  finally
    LInput.Free;
  end;
end;

procedure TTestCurrying.TestFirstEvenNumber;
var
  LInput: TList<Integer>;
  LResult: Integer;
begin
  LInput := TList<Integer>.Create;
  try
    LInput.AddRange([1, 2, 3, 4, 5, 6]);
    LResult := TCurrying.First<Integer>(LInput,
      function(X: Integer): Boolean
      begin
        Result := X mod 2 = 0;
      end);

    Assert.AreEqual(2, LResult, 'O primeiro número par deve ser 2');
    Writeln('TestFirstEvenNumber: Primeiro par = ' + IntToStr(LResult));
  finally
    LInput.Free;
  end;
end;

procedure TTestCurrying.TestLastEvenNumber;
var
  LInput: TList<Integer>;
  LResult: Integer;
begin
  LInput := TList<Integer>.Create;
  try
    LInput.AddRange([1, 2, 3, 4, 5, 6]);
    LResult := TCurrying.Last<Integer>(LInput,
      function(X: Integer): Boolean
      begin
        Result := X mod 2 = 0;
      end);

    Assert.AreEqual(6, LResult, 'O último número par deve ser 6');
    Writeln('TestLastEvenNumber: Último par = ' + IntToStr(LResult));
  finally
    LInput.Free;
  end;
end;

procedure TTestCurrying.TestStringRepeatOperation;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<string>('Hi'));
  LResult := LCurrying.Op<string>(
    function(A, B: string): string
    begin
      Result := A + B;
    end)(' There');

  Assert.AreEqual('Hi There', LResult.Value<string>);
  Writeln('TestStringRepeatOperation: Resultado = ' + LResult.Value<string>);
end;

procedure TTestCurrying.TestListConcatOperation;
var
  LList1, LList2: TList<Integer>;
  LCurrying, LResult: TCurrying;
begin
  LList1 := TList<Integer>.Create;
  LList2 := TList<Integer>.Create;
  try
    LList1.AddRange([1, 2]);
    LCurrying := TCurrying.Create(TValue.From < TList < Integer >> (LList1));
    LList2.AddRange([3, 4]);
    LResult := LCurrying.Op < TList < Integer >> (
      function(A, B: TList<Integer>): TList<Integer>
      var
        LResultList: TList<Integer>;
        LFor: Integer;
      begin
        LResultList := TList<Integer>.Create;
        try
          for LFor in A do
            LResultList.Add(LFor);
          for LFor in B do
            LResultList.Add(LFor);
          Result := LResultList;
        except
          LResultList.Free;
          raise;
        end;
      end)(LList2);

    Assert.AreEqual(4, LResult.Value<TList<Integer>>.Count, 'Deve ter 4 elementos');
    Assert.Contains<Integer>(LResult.Value<TList<Integer>>.ToArray, 1, 'Deve conter 1');
    Assert.Contains<Integer>(LResult.Value<TList<Integer>>.ToArray, 2, 'Deve conter 2');
    Assert.Contains<Integer>(LResult.Value<TList<Integer>>.ToArray, 3, 'Deve conter 3');
    Assert.Contains<Integer>(LResult.Value<TList<Integer>>.ToArray, 4, 'Deve conter 4');
    Writeln('TestListConcatOperation: [' + TCurrying.ArrayToString<Integer>(LResult.Value < TList < Integer >>.ToArray) + ']');
  finally
    LResult.Value < TList < Integer >>.Free;
    LList2.Free;
    LList1.Free;
  end;
end;

procedure TTestCurrying.TestConcatLists;
var
  LInput1, LInput2, LOutput: TList<Integer>;
begin
  LInput1 := TList<Integer>.Create;
  LInput2 := TList<Integer>.Create;
  try
    LInput1.AddRange([1, 2]);
    LInput2.AddRange([3, 4]);
    LOutput := TCurrying.ConcatLists<Integer>(LInput1, LInput2);
    try
      Assert.AreEqual(4, LOutput.Count, 'Deve ter 4 elementos');
      Assert.AreEqual(1, LOutput[0], 'Primeiro elemento incorreto');
      Assert.AreEqual(2, LOutput[1], 'Segundo elemento incorreto');
      Assert.AreEqual(3, LOutput[2], 'Terceiro elemento incorreto');
      Assert.AreEqual(4, LOutput[3], 'Quarto elemento incorreto');
      Writeln('TestConcatLists: [' + TCurrying.ArrayToString<Integer>(LOutput.ToArray) + ']');
    finally
      LOutput.Free;
    end;
  finally
    LInput2.Free;
    LInput1.Free;
  end;
end;

procedure TTestCurrying.TestPartitionByParity;
var
  LInput: TList<Integer>;
  LPartition: TPair<TList<Integer>, TList<Integer>>;
begin
  LInput := TList<Integer>.Create;
  try
    LInput.AddRange([1, 2, 3, 4, 5, 6]);
    LPartition := TCurrying.Partition<Integer>(LInput,
      function(X: Integer): Boolean
      begin
        Result := X mod 2 = 0;
      end);
    try
      Assert.AreEqual(3, LPartition.Key.Count, 'Deve ter 3 números pares');
      Assert.Contains<Integer>(LPartition.Key.ToArray, 2, 'Pares deve conter 2');
      Assert.Contains<Integer>(LPartition.Key.ToArray, 4, 'Pares deve conter 4');
      Assert.Contains<Integer>(LPartition.Key.ToArray, 6, 'Pares deve conter 6');

      Assert.AreEqual(3, LPartition.Value.Count, 'Deve ter 3 números ímpares');
      Assert.Contains<Integer>(LPartition.Value.ToArray, 1, 'Ímpares deve conter 1');
      Assert.Contains<Integer>(LPartition.Value.ToArray, 3, 'Ímpares deve conter 3');
      Assert.Contains<Integer>(LPartition.Value.ToArray, 5, 'Ímpares deve conter 5');

      Writeln('TestPartitionByParity: Pares = [' + TCurrying.ArrayToString<Integer>(LPartition.Key.ToArray) + ']');
      Writeln('TestPartitionByParity: Ímpares = [' + TCurrying.ArrayToString<Integer>(LPartition.Value.ToArray) + ']');
    finally
      LPartition.Key.Free;
      LPartition.Value.Free;
    end;
  finally
    LInput.Free;
  end;
end;

procedure TTestCurrying.TestFlattenLists;
var
  LInput: TList<TList<Integer>>;
  LSubList1, LSubList2: TList<Integer>;
  LOutput: TList<Integer>;
begin
  LInput := TList < TList < Integer >>.Create;
  LSubList1 := TList<Integer>.Create;
  LSubList2 := TList<Integer>.Create;
  try
    LSubList1.AddRange([1, 2]);
    LSubList2.AddRange([3, 4]);
    LInput.Add(LSubList1);
    LInput.Add(LSubList2);
    LOutput := TCurrying.Flatten<Integer>(LInput);
    try
      Assert.AreEqual(4, LOutput.Count, 'Deve ter 4 elementos');
      Assert.AreEqual(1, LOutput[0], 'Primeiro elemento incorreto');
      Assert.AreEqual(2, LOutput[1], 'Segundo elemento incorreto');
      Assert.AreEqual(3, LOutput[2], 'Terceiro elemento incorreto');
      Assert.AreEqual(4, LOutput[3], 'Quarto elemento incorreto');
      Writeln('TestFlattenLists: [' + TCurrying.ArrayToString<Integer>(LOutput.ToArray) + ']');
    finally
      LOutput.Free;
    end;
  finally
    LSubList2.Free;
    LSubList1.Free;
    LInput.Free;
  end;
end;

procedure TTestCurrying.TestSequenceEqual;
var
  LInput1, LInput2, LInput3: TList<Integer>;
begin
  LInput1 := TList<Integer>.Create;
  LInput2 := TList<Integer>.Create;
  LInput3 := TList<Integer>.Create;
  try
    LInput1.AddRange([1, 2, 3]);
    LInput2.AddRange([1, 2, 3]);
    LInput3.AddRange([1, 2, 4]);

    Assert.IsTrue(TCurrying.SequenceEqual<Integer>(LInput1, LInput2), 'Listas iguais devem retornar True');
    Assert.IsFalse(TCurrying.SequenceEqual<Integer>(LInput1, LInput3), 'Listas diferentes devem retornar False');

    Writeln('TestSequenceEqual: L1 = [' + TCurrying.ArrayToString<Integer>(LInput1.ToArray) + ']');
    Writeln('TestSequenceEqual: L2 = [' + TCurrying.ArrayToString<Integer>(LInput2.ToArray) + ']');
    Writeln('TestSequenceEqual: L3 = [' + TCurrying.ArrayToString<Integer>(LInput3.ToArray) + ']');
    Writeln('TestSequenceEqual: L1 = L2? ' + BoolToStr(TCurrying.SequenceEqual<Integer>(LInput1, LInput2), True));
    Writeln('TestSequenceEqual: L1 = L3? ' + BoolToStr(TCurrying.SequenceEqual<Integer>(LInput1, LInput3), True));
  finally
    LInput3.Free;
    LInput2.Free;
    LInput1.Free;
  end;
end;

procedure TTestCurrying.TestBooleanOperation;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Boolean>(True));
  LResult := LCurrying.Op<Boolean>(
    function(A, B: Boolean): Boolean
    begin
      Result := A or B;
    end)(False);
  Assert.IsTrue(LResult.Value<Boolean>, 'True OR False deve ser True');
  Writeln('TestBooleanOperation: True OR False = ' + BoolToStr(LResult.Value<Boolean>, True));

  LCurrying := TCurrying.Create(TValue.From<Boolean>(True));
  LResult := LCurrying.Op<Boolean>(
    function(A, B: Boolean): Boolean
    begin
      Result := A and B;
    end)(False);

  Assert.IsFalse(LResult.Value<Boolean>, 'True AND False deve ser False');
  Writeln('TestBooleanOperation: True AND False = ' + BoolToStr(LResult.Value<Boolean>, True));
end;

procedure TTestCurrying.TestDateTimeOperation;
var
  LCurrying, LResult: TCurrying;
  LStartDate, LAddDays: TDateTime;
begin
  LStartDate := EncodeDate(2023, 1, 1);
  LAddDays := 5;
  LCurrying := TCurrying.Create(TValue.From<TDateTime>(LStartDate));
  LResult := LCurrying.Op<TDateTime>(
    function(A, B: TDateTime): TDateTime
    begin
      Result := A + B;
    end)(LAddDays);

  Assert.AreEqual(EncodeDate(2023, 1, 6), LResult.Value<TDateTime>, '1/1/2023 + 5 dias deve ser 6/1/2023');
  Writeln('TestDateTimeOperation: ' + DateToStr(LStartDate) + ' + 5 dias = ' + DateToStr(LResult.Value<TDateTime>));
end;

procedure TTestCurrying.TestStringOperation;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<string>('Hi'));
  LResult := LCurrying.Op<string>(
    function(A, B: string): string
    begin
      Result := A + B;
    end)(' There');

  Assert.AreEqual('Hi There', LResult.Value<string>, 'Hi + There deve ser Hi There');
  Writeln('TestStringOperation: Hi + There = ' + LResult.Value<string>);

  LCurrying := TCurrying.Create(TValue.From<string>('x'));
  LResult := LCurrying.Op<string>(
    function(A, B: string): string
    var
      LCount, LFor: Integer;
      LResult: string;
    begin
      LCount := Length(B);
      LResult := '';
      for LFor := 1 to LCount do
        LResult := LResult + A;
      Result := LResult;
    end)('abc');

  Assert.AreEqual('xxx', LResult.Value<string>, 'x * 3 deve ser xxx');
  Writeln('TestStringOperation: x * abc (3) = ' + LResult.Value<string>);
end;

procedure TTestCurrying.TestCurrencyOperation;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Currency>(10.50));
  LResult := LCurrying.Op<Currency>(
    function(A, B: Currency): Currency
    begin
      Result := A + B;
    end)(5.25);

  Assert.AreEqual(Currency(15.75), LResult.Value<Currency>, '10.50 + 5.25 deve ser 15.75');
  Writeln('TestCurrencyOperation: 10.50 + 5.25 = ' + CurrToStr(LResult.Value<Currency>));

  LCurrying := TCurrying.Create(TValue.From<Currency>(20.00));
  LResult := LCurrying.Op<Currency>(
    function(A, B: Currency): Currency
    begin
      Result := A * B;
    end)(2.00);

  Assert.AreEqual(Currency(40.00), LResult.Value<Currency>, '20.00 * 2.00 deve ser 40.00');
  Writeln('TestCurrencyOperation: 20.00 * 2.00 = ' + CurrToStr(LResult.Value<Currency>));
end;

procedure TTestCurrying.TestByteOperation;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Byte>(100));
  LResult := LCurrying.Op<Byte>(
    function(A, B: Byte): Byte
    begin
      Result := A + B;
    end)(50);

  Assert.AreEqual(Byte(150), LResult.Value<Byte>, '100 + 50 deve ser 150');
  Writeln('TestByteOperation: 100 + 50 = ' + IntToStr(LResult.Value<Byte>));
end;

procedure TTestCurrying.TestShortIntOperation;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<ShortInt>(50));
  LResult := LCurrying.Op<ShortInt>(
    function(A, B: ShortInt): ShortInt
    begin
      Result := A + B;
    end)(20);

  Assert.AreEqual(ShortInt(70), LResult.Value<ShortInt>, '50 + 20 deve ser 70');
  Writeln('TestShortIntOperation: 50 + 20 = ' + IntToStr(LResult.Value<ShortInt>));
end;

procedure TTestCurrying.TestWordOperation;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Word>(1000));
  LResult := LCurrying.Op<Word>(
    function(A, B: Word): Word
    begin
      Result := A + B;
    end)(500);

  Assert.AreEqual(Word(1500), LResult.Value<Word>, '1000 + 500 deve ser 1500');
  Writeln('TestWordOperation: 1000 + 500 = ' + IntToStr(LResult.Value<Word>));
end;

procedure TTestCurrying.TestSmallIntOperation;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<SmallInt>(1000));
  LResult := LCurrying.Op<SmallInt>(
    function(A, B: SmallInt): SmallInt
    begin
      Result := A + B;
    end)(500);

  Assert.AreEqual(SmallInt(1500), LResult.Value<SmallInt>, '1000 + 500 deve ser 1500');
  Writeln('TestSmallIntOperation: 1000 + 500 = ' + IntToStr(LResult.Value<SmallInt>));
end;

procedure TTestCurrying.TestLongWordOperation;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<LongWord>(100000));
  LResult := LCurrying.Op<LongWord>(
    function(A, B: LongWord): LongWord
    begin
      Result := A + B;
    end)(50000);

  Assert.AreEqual(LongWord(150000), LResult.Value<LongWord>, '100000 + 50000 deve ser 150000');
  Writeln('TestLongWordOperation: 100000 + 50000 = ' + IntToStr(LResult.Value<LongWord>));
end;

procedure TTestCurrying.TestInt64Operation;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Int64>(1000000));
  LResult := LCurrying.Op<Int64>(
    function(A, B: Int64): Int64
    begin
      Result := A + B;
    end)(500000);

  Assert.AreEqual(Int64(1500000), LResult.Value<Int64>, '1000000 + 500000 deve ser 1500000');
  Writeln('TestInt64Operation: 1000000 + 500000 = ' + IntToStr(LResult.Value<Int64>));
end;

procedure TTestCurrying.TestSingleOperation;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Single>(5.5));
  LResult := LCurrying.Op<Single>(
    function(A, B: Single): Single
    begin
      Result := A + B;
    end)(2.5);

  Assert.AreEqual(Single(8.0), LResult.Value<Single>, '5.5 + 2.5 deve ser 8.0');
  Writeln('TestSingleOperation: 5.5 + 2.5 = ' + FloatToStr(LResult.Value<Single>));
end;

initialization

TDUnitX.RegisterTestFixture(TTestCurrying);

end.
