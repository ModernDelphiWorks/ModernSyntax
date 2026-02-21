unit UTestEvolution.Option;

interface

uses
  DUnitX.TestFramework,
  SysUtils,
  Variants,
  Evolution.Option,
  Evolution.Resultpair;

type
  [TestFixture]
  TestTOption = class
  private
    FOptInt: TOption<Integer>;
    FOptStr: TOption<string>;
  public
    [Setup]
    procedure SetUp;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestSomeCreation;
    [Test]
    procedure TestNoneCreation;
    [Test]
    procedure TestIsSome;
    [Test]
    procedure TestIsNone;
    [Test]
    procedure TestUnwrapSuccess;
    [Test]
    procedure TestUnwrapFailure;
    [Test]
    procedure TestUnwrapOr;
    [Test]
    procedure TestUnwrapOrElse;
    [Test]
    procedure TestMapSome;
    [Test]
    procedure TestMapNone;
    [Test]
    procedure TestMatchSome;
    [Test]
    procedure TestMatchNone;
    [Test]
    procedure TestValuePropertySuccess;
    [Test]
    procedure TestValuePropertyFailure;
    [Test]
    procedure TestAndThenIntegerSome;
    [Test]
    procedure TestAndThenIntegerNone;
    [Test]
    procedure TestAndThenStringSome;
    [Test]
    procedure TestAndThenStringNone;
    [Test]
    procedure TestAndThenDoubleSome;
    [Test]
    procedure TestAndThenDoubleNone;
    [Test]
    procedure TestOtherwiseSome;
    [Test]
    procedure TestOtherwiseNone;
    [Test]
    procedure TestOrElseSome;
    [Test]
    procedure TestOrElseNone;
    [Test]
    procedure TestIsSomeAndTrue;
    [Test]
    procedure TestIsSomeAndFalse;
    [Test]
    procedure TestIsSomeAndNone;
    [Test]
    procedure TestContainsSomeTrue;
    [Test]
    procedure TestContainsSomeFalse;
    [Test]
    procedure TestContainsNone;
    [Test]
    procedure TestIfSomeSome;
    [Test]
    procedure TestIfSomeNone;
    [Test]
    procedure TestTakeSome;
    [Test]
    procedure TestTakeNone;
    [Test]
    procedure TestExpectSome;
    [Test]
    procedure TestExpectNone;
    [Test]
    procedure TestUnwrapOrDefaultSome;
    [Test]
    procedure TestUnwrapOrDefaultNone;
    [Test]
    procedure TestOkOrSome;
    [Test]
    procedure TestOkOrNone;
    [Test]
    procedure TestFlattenSomeSome;
    [Test]
    procedure TestFlattenSomeNone;
    [Test]
    procedure TestFlattenNone;
    [Test]
    procedure TestFlattenInvalidType;
    [Test]
    procedure TestReplaceSome;
    [Test]
    procedure TestZipSomeSome;
    [Test]
    procedure TestZipSomeNone;
    [Test]
    procedure TestZipNoneSome;
    [Test]
    procedure TestMatchWithSome;
    [Test]
    procedure TestMatchWithNone;
  end;

implementation

procedure TestTOption.SetUp;
begin
  FOptInt := TOption<Integer>.None;
  FOptStr := TOption<string>.None;
  Writeln('teste Setup: Inicializando FOptInt como None e FOptStr como None');
end;

procedure TestTOption.TearDown;
begin
  Writeln('teste Teardown: Finalizando execução do teste atual');
end;

procedure TestTOption.TestSomeCreation;
begin
  Writeln('teste TestSomeCreation: Criando TOption<Integer>.Some com valor 42');
  FOptInt := TOption<Integer>.Some(42);
  Assert.IsTrue(FOptInt.IsSome, 'Deveria ser Some');
  Assert.AreEqual(42, FOptInt.Unwrap, 'O valor deveria ser 42');
  Writeln('teste TestSomeCreation: Verificado que IsSome é True e Unwrap retorna ' + FOptInt.Unwrap.ToString);
end;

procedure TestTOption.TestNoneCreation;
begin
  Writeln('teste TestNoneCreation: Criando TOption<Integer>.None');
  FOptInt := TOption<Integer>.None;
  Assert.IsTrue(FOptInt.IsNone, 'Deveria ser None');
  Writeln('teste TestNoneCreation: Verificado que IsNone é True');
end;

procedure TestTOption.TestIsSome;
begin
  Writeln('teste TestIsSome: Criando Some(10) para verificar IsSome');
  FOptInt := TOption<Integer>.Some(10);
  Assert.IsTrue(FOptInt.IsSome, 'IsSome deveria ser True para Some');
  Writeln('teste TestIsSome: IsSome retornou True para Some(10)');
  Writeln('teste TestIsSome: Alterando para None para verificar IsSome');
  FOptInt := TOption<Integer>.None;
  Assert.IsFalse(FOptInt.IsSome, 'IsSome deveria ser False para None');
  Writeln('teste TestIsSome: IsSome retornou False para None');
end;

procedure TestTOption.TestIsNone;
begin
  Writeln('teste TestIsNone: Criando None para verificar IsNone');
  FOptInt := TOption<Integer>.None;
  Assert.IsTrue(FOptInt.IsNone, 'IsNone deveria ser True para None');
  Writeln('teste TestIsNone: IsNone retornou True para None');
  Writeln('teste TestIsNone: Alterando para Some(10) para verificar IsNone');
  FOptInt := TOption<Integer>.Some(10);
  Assert.IsFalse(FOptInt.IsNone, 'IsNone deveria ser False para Some');
  Writeln('teste TestIsNone: IsNone retornou False para Some(10)');
end;

procedure TestTOption.TestUnwrapSuccess;
begin
  Writeln('teste TestUnwrapSuccess: Criando Some(100) para testar Unwrap');
  FOptInt := TOption<Integer>.Some(100);
  Assert.AreEqual(100, FOptInt.Unwrap, 'Unwrap deveria retornar 100');
  Writeln('teste TestUnwrapSuccess: Unwrap retornou o valor esperado: ' + FOptInt.Unwrap.ToString);
end;

procedure TestTOption.TestUnwrapFailure;
begin
  Writeln('teste TestUnwrapFailure: Criando None para testar falha no Unwrap');
  FOptInt := TOption<Integer>.None;
  Assert.WillRaise(
    procedure
    begin
      FOptInt.Unwrap;
    end,
    Exception,
    'Unwrap em None deveria lançar uma exceção');
  Writeln('teste TestUnwrapFailure: Exceção lançada com sucesso ao tentar Unwrap em None');
end;

procedure TestTOption.TestUnwrapOr;
begin
  Writeln('teste TestUnwrapOr: Criando Some(50) para testar UnwrapOr');
  FOptInt := TOption<Integer>.Some(50);
  Assert.AreEqual(50, FOptInt.UnwrapOr(0), 'UnwrapOr deveria retornar 50 para Some');
  Writeln('teste TestUnwrapOr: UnwrapOr(0) retornou ' + FOptInt.UnwrapOr(0).ToString + ' para Some(50)');
  Writeln('teste TestUnwrapOr: Alterando para None para testar UnwrapOr');
  FOptInt := TOption<Integer>.None;
  Assert.AreEqual(0, FOptInt.UnwrapOr(0), 'UnwrapOr deveria retornar 0 para None');
  Writeln('teste TestUnwrapOr: UnwrapOr(0) retornou ' + FOptInt.UnwrapOr(0).ToString + ' para None');
end;

procedure TestTOption.TestUnwrapOrElse;
var
  Result: Integer;
begin
  Writeln('teste TestUnwrapOrElse: Criando Some(75) para testar UnwrapOrElse');
  FOptInt := TOption<Integer>.Some(75);
  Result := FOptInt.UnwrapOrElse(function: Integer begin Result := 1 end);
  Assert.AreEqual(75, Result, 'UnwrapOrElse deveria retornar 75 para Some');
  Writeln('teste TestUnwrapOrElse: UnwrapOrElse retornou ' + Result.ToString + ' para Some(75)');
  Writeln('teste TestUnwrapOrElse: Alterando para None para testar UnwrapOrElse');
  FOptInt := TOption<Integer>.None;
  Result := FOptInt.UnwrapOrElse(function: Integer begin Result := 1 end);
  Assert.AreEqual(1, Result, 'UnwrapOrElse deveria retornar 1 para None');
  Writeln('teste TestUnwrapOrElse: UnwrapOrElse retornou ' + Result.ToString + ' para None');
end;

procedure TestTOption.TestMapSome;
begin
  Writeln('teste TestMapSome: Criando Some(5) para mapear para string');
  FOptInt := TOption<Integer>.Some(5);
  FOptStr := FOptInt.Map<string>(
    function(Value: Integer): string
    begin
      Result := 'Valor: ' + Value.ToString;
    end);
  Assert.IsTrue(FOptStr.IsSome, 'Map deveria resultar em Some');
  Assert.AreEqual('Valor: 5', FOptStr.Unwrap, 'Map deveria transformar 5 em "Valor: 5"');
  Writeln('teste TestMapSome: Map transformou Some(5) em ' + FOptStr.Unwrap);
end;

procedure TestTOption.TestMapNone;
begin
  Writeln('teste TestMapNone: Criando None para testar Map');
  FOptInt := TOption<Integer>.None;
  FOptStr := FOptInt.Map<string>(
    function(Value: Integer): string
    begin
      Result := 'Valor: ' + Value.ToString;
    end);
  Assert.IsTrue(FOptStr.IsNone, 'Map em None deveria resultar em None');
  Writeln('teste TestMapNone: Map retornou None como esperado');
end;

procedure TestTOption.TestMatchSome;
var
  TestValue: Integer;
begin
  Writeln('teste TestMatchSome: Criando Some(123) para testar Match');
  FOptInt := TOption<Integer>.Some(123);
  TestValue := 0;
  FOptInt.Match(
    procedure(const Value: Integer)
    begin
      TestValue := Value;
      Writeln('teste TestMatchSome: Executou Some com valor = ' + Value.ToString);
    end,
    procedure
    begin
      TestValue := -1;
      Writeln('teste TestMatchSome: Executou None');
    end);
  Assert.AreEqual(123, TestValue, 'Match deveria executar o Some e definir TestValue como 123');
  Writeln('teste TestMatchSome: TestValue foi definido como ' + TestValue.ToString);
end;

procedure TestTOption.TestMatchWithNone;
var
  LResult: string;
begin
  // Arrange
  var LOptional := TOption<Integer>.None;

  // Act
  LResult := LOptional.Match<string>(
                         TSome(Format('has value %s', [LOptional.AsString])),
                         TNone('has no value')
                       );

  // Assert
  Assert.AreEqual('has no value', LResult, 'Deveria retornar a mensagem do caso None');
end;

procedure TestTOption.TestMatchWithSome;
var
  LOptional: TOption<Integer>;
  LResult: string;
begin
  // Arrange
  LOptional := TOption<Integer>.Some(9000);

  // Act
  LResult := LOptional.Match<string>(
                         TSome(Format('has value %s', [LOptional.AsString])),
                         TNone('has no value')
                       );

  // Assert
  Assert.AreEqual('has value 9000', LResult, 'Deveria retornar a mensagem formatada com o valor 9000');
end;

procedure TestTOption.TestMatchNone;
var
  TestValue: Integer;
begin
  Writeln('teste TestMatchNone: Criando None para testar Match');
  FOptInt := TOption<Integer>.None;
  TestValue := 0;
  FOptInt.Match(
    procedure(const Value: Integer)
    begin
      TestValue := Value;
      Writeln('teste TestMatchNone: Executou Some com valor = ' + Value.ToString);
    end,
    procedure
    begin
      TestValue := -1;
      Writeln('teste TestMatchNone: Executou None');
    end);
  Assert.AreEqual(-1, TestValue, 'Match deveria executar o None e definir TestValue como -1');
  Writeln('teste TestMatchNone: TestValue foi definido como ' + TestValue.ToString);
end;

procedure TestTOption.TestValuePropertySuccess;
begin
  Writeln('teste TestValuePropertySuccess: Criando Some(99) para testar propriedade Value');
  FOptInt := TOption<Integer>.Some(99);
  Assert.AreEqual(99, FOptInt.Value, 'Value deveria retornar 99 para Some');
  Writeln('teste TestValuePropertySuccess: Propriedade Value retornou ' + FOptInt.Value.ToString);
end;

procedure TestTOption.TestValuePropertyFailure;
begin
  Writeln('teste TestValuePropertyFailure: Criando None para testar falha na propriedade Value');
  FOptInt := TOption<Integer>.None;
  Assert.WillRaise(
    procedure
    begin
      FOptInt.Value;
    end,
    Exception,
    'Acessar Value em None deveria lançar uma exceção');
  Writeln('teste TestValuePropertyFailure: Exceção lançada com sucesso ao acessar Value em None');
end;

procedure TestTOption.TestAndThenIntegerSome;
var
  ResultOpt: TOption<Integer>;
begin
  Writeln('teste TestAndThenIntegerSome: Criando Some(7) para testar AndThen Integer');
  FOptInt := TOption<Integer>.Some(7);
  ResultOpt := FOptInt.AndThen<Integer>(
    function(const Value: Integer): TOption<Integer>
    begin
      Result := TOption<Integer>.Some(Value * 2);
    end);
  Assert.IsTrue(ResultOpt.IsSome, 'AndThen Integer deveria resultar em Some');
  Assert.AreEqual(14, ResultOpt.Unwrap, 'AndThen Integer deveria transformar 7 em 14');
  Writeln('teste TestAndThenIntegerSome: AndThen Integer transformou Some(7) em ' + ResultOpt.Unwrap.ToString);
end;

procedure TestTOption.TestAndThenIntegerNone;
var
  ResultOpt: TOption<Integer>;
begin
  Writeln('teste TestAndThenIntegerNone: Criando None para testar AndThen Integer');
  FOptInt := TOption<Integer>.None;
  ResultOpt := FOptInt.AndThen<Integer>(
    function(const Value: Integer): TOption<Integer>
    begin
      Result := TOption<Integer>.Some(Value * 2);
    end);
  Assert.IsTrue(ResultOpt.IsNone, 'AndThen Integer em None deveria resultar em None');
  Writeln('teste TestAndThenIntegerNone: AndThen Integer retornou None como esperado');
end;

procedure TestTOption.TestAndThenStringSome;
begin
  Writeln('teste TestAndThenStringSome: Criando Some(7) para testar AndThen String');
  FOptInt := TOption<Integer>.Some(7);
  FOptStr := FOptInt.AndThen<string>(
    function(const Value: Integer): TOption<string>
    begin
      Result := TOption<string>.Some('Numero: ' + Value.ToString);
    end);
  Assert.IsTrue(FOptStr.IsSome, 'AndThen String deveria resultar em Some');
  Assert.AreEqual('Numero: 7', FOptStr.Unwrap, 'AndThen String deveria transformar 7 em "Numero: 7"');
  Writeln('teste TestAndThenStringSome: AndThen String transformou Some(7) em ' + FOptStr.Unwrap);
end;

procedure TestTOption.TestAndThenStringNone;
begin
  Writeln('teste TestAndThenStringNone: Criando None para testar AndThen String');
  FOptInt := TOption<Integer>.None;
  FOptStr := FOptInt.AndThen<string>(
    function(const Value: Integer): TOption<string>
    begin
      Result := TOption<string>.Some('Numero: ' + Value.ToString);
    end);
  Assert.IsTrue(FOptStr.IsNone, 'AndThen String em None deveria resultar em None');
  Writeln('teste TestAndThenStringNone: AndThen String retornou None como esperado');
end;

procedure TestTOption.TestAndThenDoubleSome;
var
  ResultOpt: TOption<Double>;
begin
  Writeln('teste TestAndThenDoubleSome: Criando Some(5) para testar AndThen Double');
  FOptInt := TOption<Integer>.Some(5);
  ResultOpt := FOptInt.AndThen<Double>(
    function(const Value: Integer): TOption<Double>
    begin
      Result := TOption<Double>.Some(Value / 2.0);
    end);
  Assert.IsTrue(ResultOpt.IsSome, 'AndThen Double deveria resultar em Some');
  Assert.AreEqual(Double(2.5), ResultOpt.Unwrap, 'AndThen Double deveria transformar 5 em 2.5');
  Writeln('teste TestAndThenDoubleSome: AndThen Double transformou Some(5) em ' + FloatToStr(ResultOpt.Unwrap));
end;

procedure TestTOption.TestAndThenDoubleNone;
var
  ResultOpt: TOption<Double>;
begin
  Writeln('teste TestAndThenDoubleNone: Criando None para testar AndThen Double');
  FOptInt := TOption<Integer>.None;
  ResultOpt := FOptInt.AndThen<Double>(
    function(const Value: Integer): TOption<Double>
    begin
      Result := TOption<Double>.Some(Value / 2.0);
    end);
  Assert.IsTrue(ResultOpt.IsNone, 'AndThen Double em None deveria resultar em None');
  Writeln('teste TestAndThenDoubleNone: AndThen Double retornou None como esperado');
end;

procedure TestTOption.TestOtherwiseSome;
begin
  Writeln('teste TestOtherwiseSome: Criando Some(5) para testar Otherwise');
  FOptInt := TOption<Integer>.Some(5);
  FOptInt := FOptInt.Otherwise(TOption<Integer>.Some(10));
  Assert.IsTrue(FOptInt.IsSome, 'Otherwise deveria manter Some original');
  Assert.AreEqual(5, FOptInt.Unwrap, 'Otherwise deveria manter o valor original 5');
  Writeln('teste TestOtherwiseSome: Otherwise manteve Some(5) como ' + FOptInt.Unwrap.ToString);
end;

procedure TestTOption.TestOtherwiseNone;
begin
  Writeln('teste TestOtherwiseNone: Criando None para testar Otherwise');
  FOptInt := TOption<Integer>.None;
  FOptInt := FOptInt.Otherwise(TOption<Integer>.Some(10));
  Assert.IsTrue(FOptInt.IsSome, 'Otherwise deveria retornar o alternativo Some');
  Assert.AreEqual(10, FOptInt.Unwrap, 'Otherwise deveria retornar o valor alternativo 10');
  Writeln('teste TestOtherwiseNone: Otherwise transformou None em Some(10)');
end;

procedure TestTOption.TestOrElseSome;
begin
  Writeln('teste TestOrElseSome: Criando Some(5) para testar OrElse');
  FOptInt := TOption<Integer>.Some(5);
  FOptInt := FOptInt.OrElse(
    function: TOption<Integer>
    begin
      Result := TOption<Integer>.Some(10);
    end);
  Assert.IsTrue(FOptInt.IsSome, 'OrElse deveria manter Some original');
  Assert.AreEqual(5, FOptInt.Unwrap, 'OrElse deveria manter o valor original 5');
  Writeln('teste TestOrElseSome: OrElse manteve Some(5) como ' + FOptInt.Unwrap.ToString);
end;

procedure TestTOption.TestOrElseNone;
begin
  Writeln('teste TestOrElseNone: Criando None para testar OrElse');
  FOptInt := TOption<Integer>.None;
  FOptInt := FOptInt.OrElse(
    function: TOption<Integer>
    begin
      Result := TOption<Integer>.Some(10);
    end);
  Assert.IsTrue(FOptInt.IsSome, 'OrElse deveria retornar o alternativo Some');
  Assert.AreEqual(10, FOptInt.Unwrap, 'OrElse deveria retornar o valor alternativo 10');
  Writeln('teste TestOrElseNone: OrElse transformou None em Some(10)');
end;

procedure TestTOption.TestIsSomeAndTrue;
begin
  Writeln('teste TestIsSomeAndTrue: Criando Some(5) para testar IsSomeAnd com predicado verdadeiro');
  FOptInt := TOption<Integer>.Some(5);
  Assert.IsTrue(FOptInt.IsSomeAnd(
    function(Value: Integer): Boolean
    begin
      Result := Value > 0;
    end), 'IsSomeAnd deveria retornar True para Some(5) com predicado > 0');
  Writeln('teste TestIsSomeAndTrue: IsSomeAnd retornou True para Some(5) com predicado > 0');
end;

procedure TestTOption.TestIsSomeAndFalse;
begin
  Writeln('teste TestIsSomeAndFalse: Criando Some(-5) para testar IsSomeAnd com predicado falso');
  FOptInt := TOption<Integer>.Some(-5);
  Assert.IsFalse(FOptInt.IsSomeAnd(
    function(Value: Integer): Boolean
    begin
      Result := Value > 0;
    end), 'IsSomeAnd deveria retornar False para Some(-5) com predicado > 0');
  Writeln('teste TestIsSomeAndFalse: IsSomeAnd retornou False para Some(-45) com predicado > 0');
end;

procedure TestTOption.TestIsSomeAndNone;
begin
  Writeln('teste TestIsSomeAndNone: Criando None para testar IsSomeAnd');
  FOptInt := TOption<Integer>.None;
  Assert.IsFalse(FOptInt.IsSomeAnd(
    function(Value: Integer): Boolean
    begin
      Result := Value > 0;
    end), 'IsSomeAnd deveria retornar False para None');
  Writeln('teste TestIsSomeAndNone: IsSomeAnd retornou False para None');
end;

procedure TestTOption.TestContainsSomeTrue;
begin
  Writeln('teste TestContainsSomeTrue: Criando Some(5) para testar Contains com valor igual');
  FOptInt := TOption<Integer>.Some(5);
  Assert.IsTrue(FOptInt.Contains(5), 'Contains deveria retornar True para Some(5) com 5');
  Writeln('teste TestContainsSomeTrue: Contains retornou True para Some(5) com 5');
end;

procedure TestTOption.TestContainsSomeFalse;
begin
  Writeln('teste TestContainsSomeFalse: Criando Some(5) para testar Contains com valor diferente');
  FOptInt := TOption<Integer>.Some(5);
  Assert.IsFalse(FOptInt.Contains(10), 'Contains deveria retornar False para Some(5) com 10');
  Writeln('teste TestContainsSomeFalse: Contains retornou False para Some(5) com 10');
end;

procedure TestTOption.TestContainsNone;
begin
  Writeln('teste TestContainsNone: Criando None para testar Contains');
  FOptInt := TOption<Integer>.None;
  Assert.IsFalse(FOptInt.Contains(5), 'Contains deveria retornar False para None');
  Writeln('teste TestContainsNone: Contains retornou False para None');
end;

procedure TestTOption.TestIfSomeSome;
var
  TestValue: Integer;
begin
  Writeln('teste TestIfSomeSome: Criando Some(42) para testar IfSome');
  FOptInt := TOption<Integer>.Some(42);
  TestValue := 0;
  FOptInt.IfSome(
    procedure(const Value: Integer)
    begin
      TestValue := Value;
      Writeln('teste TestIfSomeSome: Executou ação com valor = ' + Value.ToString);
    end);
  Assert.AreEqual(42, TestValue, 'IfSome deveria executar a ação e definir TestValue como 42');
  Writeln('teste TestIfSomeSome: TestValue foi definido como ' + TestValue.ToString);
end;

procedure TestTOption.TestIfSomeNone;
var
  TestValue: Integer;
begin
  Writeln('teste TestIfSomeNone: Criando None para testar IfSome');
  FOptInt := TOption<Integer>.None;
  TestValue := 0;
  FOptInt.IfSome(
    procedure(const Value: Integer)
    begin
      TestValue := Value;
      Writeln('teste TestIfSomeNone: Executou ação com valor = ' + Value.ToString);
    end);
  Assert.AreEqual(0, TestValue, 'IfSome não deveria executar a ação e TestValue deveria permanecer 0');
  Writeln('teste TestIfSomeNone: TestValue permaneceu como ' + TestValue.ToString);
end;

procedure TestTOption.TestTakeSome;
var
  Taken: TOption<Integer>;
begin
  Writeln('teste TestTakeSome: Criando Some(5) para testar Take');
  FOptInt := TOption<Integer>.Some(5);
  Taken := FOptInt.Take(FOptInt);
  Assert.IsTrue(Taken.IsSome, 'Take deveria retornar Some');
  Assert.AreEqual(5, Taken.Unwrap, 'Take deveria retornar o valor 5');
  Assert.IsTrue(FOptInt.IsNone, 'FOptInt deveria virar None após Take');
  Writeln('teste TestTakeSome: Taken é Some(5) e FOptInt virou None');
end;

procedure TestTOption.TestTakeNone;
var
  Taken: TOption<Integer>;
begin
  Writeln('teste TestTakeNone: Criando None para testar Take');
  FOptInt := TOption<Integer>.None;
  Taken := FOptInt.Take(FOptInt);
  Assert.IsTrue(Taken.IsNone, 'Take deveria retornar None');
  Assert.IsTrue(FOptInt.IsNone, 'FOptInt deveria permanecer None após Take');
  Writeln('teste TestTakeNone: Taken é None e FOptInt permaneceu None');
end;

procedure TestTOption.TestExpectSome;
begin
  Writeln('teste TestExpectSome: Criando Some(42) para testar Expect');
  FOptInt := TOption<Integer>.Some(42);
  Assert.AreEqual(42, FOptInt.Expect('Não deveria falhar aqui'), 'Expect deveria retornar 42 para Some');
  Writeln('teste TestExpectSome: Expect retornou 42 para Some(42)');
end;

procedure TestTOption.TestExpectNone;
begin
  Writeln('teste TestExpectNone: Criando None para testar Expect');
  FOptInt := TOption<Integer>.None;
  Assert.WillRaise(
    procedure
    begin
      FOptInt.Expect('Valor esperado não encontrado');
    end,
    Exception,
    'Expect em None deveria lançar uma exceção com mensagem customizada');
  Writeln('teste TestExpectNone: Exceção lançada com sucesso ao tentar Expect em None');
end;

procedure TestTOption.TestUnwrapOrDefaultSome;
begin
  Writeln('teste TestUnwrapOrDefaultSome: Criando Some(42) para testar UnwrapOrDefault');
  FOptInt := TOption<Integer>.Some(42);
  Assert.AreEqual(42, FOptInt.UnwrapOrDefault, 'UnwrapOrDefault deveria retornar 42 para Some');
  Writeln('teste TestUnwrapOrDefaultSome: UnwrapOrDefault retornou 42 para Some(42)');
end;

procedure TestTOption.TestUnwrapOrDefaultNone;
begin
  Writeln('teste TestUnwrapOrDefaultNone: Criando None para testar UnwrapOrDefault');
  FOptInt := TOption<Integer>.None;
  Assert.AreEqual(0, FOptInt.UnwrapOrDefault, 'UnwrapOrDefault deveria retornar 0 para None');
  Writeln('teste TestUnwrapOrDefaultNone: UnwrapOrDefault retornou 0 para None');
end;

procedure TestTOption.TestOkOrSome;
var
  Res: TResultPair<Integer, string>;
begin
  Writeln('teste TestOkOrSome: Criando Some(5) para testar OkOr');
  FOptInt := TOption<Integer>.Some(5);
  Res := FOptInt.OkOr('Erro');
  Assert.IsTrue(Res.IsSuccess, 'OkOr deveria retornar Success para Some');
  Assert.AreEqual(5, Res.ValueSuccess, 'OkOr deveria retornar o valor 5');
  Writeln('teste TestOkOrSome: OkOr retornou Success(5) para Some(5)');
end;

procedure TestTOption.TestOkOrNone;
var
  Res: TResultPair<Integer, string>;
begin
  Writeln('teste TestOkOrNone: Criando None para testar OkOr');
  FOptInt := TOption<Integer>.None;
  Res := FOptInt.OkOr('Erro');
  Assert.IsTrue(Res.IsFailure, 'OkOr deveria retornar Failure para None');
  Assert.AreEqual('Erro', Res.ValueFailure, 'OkOr deveria retornar o erro "Erro"');
  Writeln('teste TestOkOrNone: OkOr retornou Failure("Erro") para None');
end;

procedure TestTOption.TestFlattenSomeSome;
var
  NestedOpt: TOption<TOption<Integer>>;
  Flattened: TOption<Integer>;
begin
  Writeln('teste TestFlattenSomeSome: Criando Some(Some(5)) para testar Flatten');
  NestedOpt := TOption<TOption<Integer>>.Some(TOption<Integer>.Some(5));
  Flattened := NestedOpt.Flatten<Integer>;
  Assert.IsTrue(Flattened.IsSome, 'Flatten deveria retornar Some');
  Assert.AreEqual(5, Flattened.Unwrap, 'Flatten deveria retornar 5');
  Writeln('teste TestFlattenSomeSome: Flatten transformou Some(Some(5)) em Some(5)');
end;

procedure TestTOption.TestFlattenSomeNone;
var
  NestedOpt: TOption<TOption<Integer>>;
  Flattened: TOption<Integer>;
begin
  Writeln('teste TestFlattenSomeNone: Criando Some(None) para testar Flatten');
  NestedOpt := TOption<TOption<Integer>>.Some(TOption<Integer>.None);
  Flattened := NestedOpt.Flatten<Integer>;
  Assert.IsTrue(Flattened.IsNone, 'Flatten deveria retornar None');
  Writeln('teste TestFlattenSomeNone: Flatten transformou Some(None) em None');
end;

procedure TestTOption.TestFlattenNone;
var
  NestedOpt: TOption<TOption<Integer>>;
  Flattened: TOption<Integer>;
begin
  Writeln('teste TestFlattenNone: Criando None para testar Flatten');
  NestedOpt := TOption<TOption<Integer>>.None;
  Flattened := NestedOpt.Flatten<Integer>;
  Assert.IsTrue(Flattened.IsNone, 'Flatten deveria retornar None');
  Writeln('teste TestFlattenNone: Flatten manteve None como None');
end;

procedure TestTOption.TestFlattenInvalidType;
var
  SimpleOpt: TOption<Integer>;
begin
  Writeln('teste TestFlattenInvalidType: Criando Some(5) simples pra testar Flatten com tipo inválido');
  SimpleOpt := TOption<Integer>.Some(5);
  Assert.WillRaise(
    procedure
    begin
      SimpleOpt.Flatten<Integer>;
    end,
    Exception,
    'Flatten em um TOption<Integer> simples deveria lançar exceção');
  Writeln('teste TestFlattenInvalidType: Exceção lançada com sucesso ao tentar Flatten em tipo inválido');
end;

procedure TestTOption.TestReplaceSome;
var
  Opt: TOption<Integer>;
  OldValue: TOption<Integer>;
begin
  Writeln('teste TestReplaceSome: Criando Some(5) para testar Replace');
  Opt := TOption<Integer>.Some(5);
  OldValue := Opt.Replace(Opt, 10);
  Assert.IsTrue(OldValue.IsSome, 'O valor antigo deveria ser Some');
  Assert.AreEqual(5, OldValue.Unwrap, 'O valor antigo deveria ser 5');
  Assert.IsTrue(Opt.IsSome, 'O novo valor deveria ser Some');
  Assert.AreEqual(10, Opt.Unwrap, 'O novo valor deveria ser 10');
  Writeln('teste TestReplaceSome: Replace trocou 5 por 10 e retornou Some(5)');
end;

procedure TestTOption.TestZipSomeSome;
var
  OptInt: TOption<Variant>;
  OptStr: TOption<Variant>;
  Zipped: TOption<Variant>;
  Pair: Variant;
begin
  Writeln('teste TestZipSomeSome: Criando Some(5) e Some("teste") pra testar Zip');
  OptInt := TOption<Variant>.Some(5);
  OptStr := TOption<Variant>.Some('teste');
  Zipped := TOption<Variant>.Zip(OptInt, OptStr);
  Assert.IsTrue(Zipped.IsSome, 'Zip deveria retornar Some');
  Pair := Zipped.Unwrap;
  Assert.AreEqual(5, Integer(Pair[0]), 'Primeiro valor deveria ser 5');
  Assert.AreEqual('teste', string(Pair[1]), 'Segundo valor deveria ser "teste"');
  Writeln('teste TestZipSomeSome: Zip transformou Some(5) e Some("teste") em Some([5, "teste"])');
end;

procedure TestTOption.TestZipSomeNone;
var
  OptInt: TOption<Variant>;
  OptStr: TOption<Variant>;
  Zipped: TOption<Variant>;
begin
  Writeln('teste TestZipSomeNone: Criando Some(5) e None pra testar Zip');
  OptInt := TOption<Variant>.Some(5);
  OptStr := TOption<Variant>.None;
  Zipped := TOption<Variant>.Zip(OptInt, OptStr);
  Assert.IsTrue(Zipped.IsNone, 'Zip deveria retornar None quando um dos lados é None');
  Writeln('teste TestZipSomeNone: Zip retornou None como esperado');
end;

procedure TestTOption.TestZipNoneSome;
var
  OptInt: TOption<Variant>;
  OptStr: TOption<Variant>;
  Zipped: TOption<Variant>;
begin
  Writeln('teste TestZipNoneSome: Criando None e Some("teste") pra testar Zip');
  OptInt := TOption<Variant>.None;
  OptStr := TOption<Variant>.Some('teste');
  Zipped := TOption<Variant>.Zip(OptInt, OptStr);
  Assert.IsTrue(Zipped.IsNone, 'Zip deveria retornar None quando um dos lados é None');
  Writeln('teste TestZipNoneSome: Zip retornou None como esperado');
end;

initialization
  TDUnitX.RegisterTestFixture(TestTOption);

end.
