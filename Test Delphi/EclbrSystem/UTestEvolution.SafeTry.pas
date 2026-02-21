unit UTestEvolution.SafeTry;

interface

uses
  DUnitX.TestFramework,
  Evolution.Safetry,
  SysUtils,
  Rtti;

type
  [TestFixture]
  TTestSafeTry = class
  public
    [Test]
    procedure TestTryExceptFinally_Ok;
    [Test]
    procedure TestTryExceptFinally_Exception;
    [Test]
    procedure TestTryOnly_Ok;
    [Test]
    procedure TestTryOnly_Exception;
    [Test]
    procedure TestTryFinally_Ok;
    [Test]
    procedure TestTryFinally_Exception;
    [Test]
    procedure TestFinallyOnly;
    [Test]
    procedure TestNoTry;
    [Test]
    procedure TestEndWithoutException;
    [Test]
    procedure TestEndWithException;
    [Test]
    procedure TestTryFuncInteger_Ok;
    [Test]
    procedure TestTryFuncInteger_Exception;
    [Test]
    procedure TestTryFuncString_Ok;
    [Test]
    procedure TestTryFuncString_Exception;
    [Test]
    procedure TestTryFuncDouble_Ok;
    [Test]
    procedure TestTryFuncDouble_Exception;
  end;

implementation

procedure TTestSafeTry.TestTryExceptFinally_Ok;
var
  LResult: TSafeResult;
begin
  LResult := &Try(procedure
                  begin
                    WriteLn('Executando try');
                  end)
            .&Except(procedure(E: Exception)
                     begin
                       WriteLn('Executando except');
                     end)
            .&Finally(procedure
                      begin
                        WriteLn('Executando finally');
                      end)
            .&End;

  Assert.IsTrue(LResult.IsOk);
  Assert.IsFalse(LResult.IsErr);
  Assert.IsTrue(LResult.AsType<Boolean>);
end;

procedure TTestSafeTry.TestTryExceptFinally_Exception;
var
  LResult: TSafeResult;
begin
  LResult := &Try(procedure
                  begin
                    raise Exception.Create('Erro no bloco try');
                  end)
            .&Except(procedure(E: Exception)
                     begin
                       WriteLn('Executando except');
                     end)
            .&Finally(procedure
                      begin
                        WriteLn('Executando finally');
                      end)
            .&End;

  Assert.IsTrue(LResult.IsErr);
  Assert.AreEqual('Erro no bloco try', LResult.ExceptionMessage);
end;

procedure TTestSafeTry.TestTryOnly_Ok;
var
  LResult: TSafeResult;
begin
  LResult := &Try(procedure
                  begin
                    WriteLn('Executando try');
                  end)
            .&End;

  Assert.IsTrue(LResult.IsOk);
  Assert.IsFalse(LResult.IsErr);
  Assert.IsTrue(LResult.AsType<Boolean>);
end;

procedure TTestSafeTry.TestTryOnly_Exception;
var
  LResult: TSafeResult;
begin
  LResult := &Try(procedure
                  begin
                    raise Exception.Create('Erro no bloco try');
                  end)
            .&End;

  Assert.IsTrue(LResult.IsErr);
  Assert.AreEqual('Erro no bloco try', LResult.ExceptionMessage);
end;

procedure TTestSafeTry.TestTryFinally_Ok;
var
  LResult: TSafeResult;
begin
  LResult := &Try(procedure
                  begin
                    WriteLn('Executando try');
                  end)
            .&Finally(procedure
                      begin
                        WriteLn('Executando finally');
                      end)
            .&End;

  Assert.IsTrue(LResult.IsOk);
  Assert.IsFalse(LResult.IsErr);
  Assert.IsTrue(LResult.AsType<Boolean>);
end;

procedure TTestSafeTry.TestTryFinally_Exception;
var
  LResult: TSafeResult;
begin
  LResult := &Try(procedure
                  begin
                    raise Exception.Create('Erro no bloco try');
                  end)
            .&Finally(procedure
                      begin
                        WriteLn('Executando finally');
                      end)
            .&End;

  Assert.IsTrue(LResult.IsErr);
  Assert.AreEqual('Erro no bloco try', LResult.ExceptionMessage);
end;

procedure TTestSafeTry.TestFinallyOnly;
var
  LResult: TSafeResult;
begin
  LResult := &Try
            .&Finally(procedure
                      begin
                        WriteLn('Executando finally');
                      end)
            .&End;

  Assert.IsTrue(LResult.IsOk);
  Assert.IsFalse(LResult.IsErr);
  Assert.IsTrue(LResult.AsType<Boolean>);
end;

procedure TTestSafeTry.TestNoTry;
var
  LResult: TSafeResult;
begin
  LResult := &Try
            .&End;

  Assert.IsTrue(LResult.IsOk);
  Assert.IsFalse(LResult.IsErr);
  Assert.IsTrue(LResult.AsType<Boolean>);
end;

procedure TTestSafeTry.TestEndWithoutException;
var
  LResult: TSafeResult;
begin
  LResult := &Try(procedure
                  begin
                    WriteLn('Executando try');
                  end)
            .&End;

  Assert.IsTrue(LResult.IsOk);
  Assert.IsFalse(LResult.IsErr);
  Assert.IsTrue(LResult.AsType<Boolean>);
end;

procedure TTestSafeTry.TestEndWithException;
var
  LResult: TSafeResult;
begin
  LResult := &Try(procedure
                  begin
                    raise Exception.Create('Erro no bloco try');
                  end)
            .&End;

  Assert.IsTrue(LResult.IsErr);
  Assert.AreEqual('Erro no bloco try', LResult.ExceptionMessage);
end;

procedure TTestSafeTry.TestTryFuncInteger_Ok;
var
  LResult: TSafeResult;
begin
  LResult := &Try(function: TValue
                  begin
                    WriteLn('Executando try com Integer');
                    Result := 42;
                  end)
            .&End;

  Assert.IsTrue(LResult.IsOk);
  Assert.IsFalse(LResult.IsErr);
  Assert.AreEqual(42, LResult.AsType<Integer>);
end;

procedure TTestSafeTry.TestTryFuncInteger_Exception;
var
  LResult: TSafeResult;
begin
  LResult := &Try(function: TValue
                  begin
                    raise Exception.Create('Erro no bloco try com Integer');
                    Result := 42;
                  end)
            .&End;

  Assert.IsTrue(LResult.IsErr);
  Assert.AreEqual('Erro no bloco try com Integer', LResult.ExceptionMessage);
end;

procedure TTestSafeTry.TestTryFuncString_Ok;
var
  LResult: TSafeResult;
begin
  LResult := &Try(function: TValue
                  begin
                    WriteLn('Executando try com String');
                    Result := 'Hello, SafeTry!';
                  end)
            .&End;

  Assert.IsTrue(LResult.IsOk);
  Assert.IsFalse(LResult.IsErr);
  Assert.AreEqual('Hello, SafeTry!', LResult.AsType<String>);
end;

procedure TTestSafeTry.TestTryFuncString_Exception;
var
  LResult: TSafeResult;
begin
  LResult := &Try(function: TValue
                  begin
                    raise Exception.Create('Erro no bloco try com String');
                    Result := 'Hello, SafeTry!';
                  end)
            .&End;

  Assert.IsTrue(LResult.IsErr);
  Assert.AreEqual('Erro no bloco try com String', LResult.ExceptionMessage);
end;

procedure TTestSafeTry.TestTryFuncDouble_Ok;
var
  LResult: TSafeResult;
  LValue: Double;
begin
  LValue := 3.14;
  LResult := &Try(function: TValue
                  begin
                    WriteLn('Executando try com Double');
                    Result := 3.14;
                  end)
            .&End;

  Assert.IsTrue(LResult.IsOk);
  Assert.IsFalse(LResult.IsErr);
  Assert.AreEqual(LValue, LResult.AsType<Double>);
end;

procedure TTestSafeTry.TestTryFuncDouble_Exception;
var
  LResult: TSafeResult;
begin
  LResult := &Try(function: TValue
                  begin
                    raise Exception.Create('Erro no bloco try com Double');
                    Result := 3.14;
                  end)
            .&End;

  Assert.IsTrue(LResult.IsErr);
  Assert.AreEqual('Erro no bloco try com Double', LResult.ExceptionMessage);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestSafeTry);

end.
