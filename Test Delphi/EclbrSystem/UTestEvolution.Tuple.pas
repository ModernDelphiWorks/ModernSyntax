unit UTestEvolution.Tuple;

interface

uses
  Rtti,
  SysUtils,
  Variants,
  DUnitX.TestFramework,
  Evolution.Tuple,
  Evolution.Match,
  Evolution.ResultPair;

type
  TPessoa = class
  private
    FName: String;
  public
    property Name: String read FName write FName;
  end;

  [TestFixture]
  TestTuple = class
  private
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestStrIntTupla;
    [Test]
    procedure TestIntDoubleTupla;
    [Test]
    procedure TestStrIntTuplaNew;
    [Test]
    procedure TestIntDoubleTuplaNew;
    [Test]
    procedure TestMatchTupla;
    [Test]
    procedure TestMatchTuplaAsterisco;
    [Test]
    procedure TestNewTuple;
    [Test]
    procedure TestTupleGet;
    [Test]
    procedure TestTupleEquality;
    [Test]
    procedure TestTupleEquality_2;
    [Test]
    procedure TestTupleDestructuringPointers2;  // Teste com 2 elementos
    [Test]
    procedure TestTupleDestructuringPointers3;  // Teste com 3 elementos
    [Test]
    procedure TestTupleDestructuringPointersError;  // Teste de erro
  end;

implementation

uses
  Evolution.ArrowFun;

{ TestTuple }

procedure TestTuple.Setup;
begin
end;

procedure TestTuple.TearDown;
begin
end;

procedure TestTuple.TestIntDoubleTupla;
var
  LTuplaIntDouble: TTuple<Integer>;
  LValueDouble: Double;
begin
  LTuplaIntDouble := TTuple<Integer>.New([1, 2, 3], [False, 2.2, 3.3]);
  Assert.IsTrue(LTuplaIntDouble[2].AsExtended > 0);
  LValueDouble := LTuplaIntDouble[2].AsExtended;
  Assert.AreEqual(2.2, LValueDouble, 0.01);
end;

procedure TestTuple.TestStrIntTupla;
var
  LTuplaStrInt: TTuple<String>;
  LValueInt: Integer;
begin
  LTuplaStrInt := TTuple<String>.New(['A', 'B', 'C'], [1, 2, '3']);
  Assert.IsTrue(LTuplaStrInt['B'].AsInteger > 0);
  LValueInt := LTuplaStrInt['B'].AsInteger;
  Assert.AreEqual(2, LValueInt);
end;

procedure TestTuple.TestIntDoubleTuplaNew;
var
  LTuplaIntDouble: TTuple<Integer>;
begin
  LTuplaIntDouble := LTuplaIntDouble.New([1, 2, 3], [1.1, 2.2, True]);
  Assert.IsTrue(LTuplaIntDouble[2].AsExtended > 0);
  Assert.AreEqual(2.2, LTuplaIntDouble[2].AsExtended);
end;

procedure TestTuple.TestMatchTupla;
var
  LTuple: Tuple;
  LResult: TResultPair<String, String>;
begin
  LTuple := ['Idade', 25];
  LResult := TMatch<Tuple>.Value(LTuple)
    .CaseEq(['_', 'Alice'], TArrow.Result('Personagem'))
    .CaseEq(['_', 25],      TArrow.Result('Jovem'))
    .CaseEq(['_', False],   TArrow.Result('Fria'))
    .Default(               TArrow.Result('Default'))
    .Execute<String>;
  Assert.AreEqual('Jovem', LResult.ValueSuccess);
  Assert.AreEqual(LTuple[0].AsString, 'Idade');
  Assert.AreEqual(LTuple[1].AsInteger, 25);
end;

procedure TestTuple.TestMatchTuplaAsterisco;
var
  LTuple: Tuple;
  LResult: TResultPair<String, String>;
begin
  LTuple := ['Idade', 25];
  LResult := TMatch<Tuple>.Value(LTuple)
    .CaseEq(['Nome', '_*'],   TArrow.Result('Personagem'))
    .CaseEq(['Idade', '_*'],  TArrow.Result('Jovem'))
    .CaseEq(['Cidade', '_*'], TArrow.Result('Fria'))
    .Default(                 TArrow.Result('Default'))
    .Execute<String>;
  Assert.AreEqual('Jovem', LResult.ValueSuccess);
  Assert.AreEqual('Jovem', TArrow.Value<String>);
end;

procedure TestTuple.TestNewTuple;
var
  LTuple: TTuple;
begin
  LTuple := TTuple.New([10, 'Hello', 3.14]);
  Assert.AreEqual(3, LTuple.Count);
  Assert.AreEqual(10, LTuple[0].AsInteger);
  Assert.AreEqual('Hello', LTuple[1].AsString);
  Assert.AreEqual(3.14, LTuple[2].AsExtended);
end;

procedure TestTuple.TestStrIntTuplaNew;
var
  LTuplaStrInt: TTuple<String>;
begin
  LTuplaStrInt := TTuple<String>.New(['A', 'B', 'C'], ['1', 2.3, 3]);
  Assert.IsTrue(LTuplaStrInt['B'].AsExtended > 0);
  Assert.AreEqual(3, LTuplaStrInt['C'].AsInteger);
end;

procedure TestTuple.TestTupleEquality;
var
  LTuple1: TTuple;
  LTuple2: TTuple;
begin
  LTuple1 := TTuple.New([15, 'Hello Word']);
  LTuple2 := TTuple.New([15, 'Hello Word']);
  Assert.IsTrue(LTuple1 = LTuple2);
  Assert.IsFalse(LTuple1 <> LTuple2);
end;

procedure TestTuple.TestTupleEquality_2;
var
  LTuple1: TTuple;
  LTuple2: TTuple;
begin
  LTuple1 := [10, 'Hello'];
  LTuple2 := [10, 'Hello'];
  Assert.IsTrue(LTuple1 = LTuple2);
  Assert.IsFalse(LTuple1 <> LTuple2);
end;

procedure TestTuple.TestTupleGet;
var
  LTuple: TTuple;
  LValue: Integer;
begin
  LTuple := TTuple.New([10, 'Hello', 3.14]);
  LValue := LTuple.Get<Integer>(0);
  Assert.AreEqual(10, LValue);
end;

procedure TestTuple.TestTupleDestructuringPointers2;
var
  LTuple: TTuple;
  LN: Integer;
  LName: String;
begin
//  LN := 0;
//  LName := '';
  LTuple := [1, 'isaque'];
  LTuple.Dest([@LN, @LName]);
  Assert.AreEqual(1, LN, 'LN deve ser 1');
  Assert.AreEqual('isaque', LName, 'LName deve ser isaque');
  Writeln('TestTupleDestructuringPointers2: LN = ' + IntToStr(LN) + ', LName = ' + LName);
end;

procedure TestTuple.TestTupleDestructuringPointers3;
var
  LTuple: TTuple;
  LN: Integer;
  LValue: Double;
  LPessoa: TPessoa;
begin
  LN := 0;
  LValue := 0.0;
  LPessoa := TPessoa.Create;
  try
    LTuple := [1, 'isaque', 3.14];
    LTuple.Dest([@LN, @LPessoa.Name, @LValue]);
    Assert.AreEqual(1, LN, 'LN deve ser 1');
    Assert.AreEqual('isaque', LPessoa.Name, 'LName deve ser isaque');
    Assert.AreEqual(3.14, LValue, 0.001, 'LValue deve ser 3.14');
    Writeln('TestTupleDestructuringPointers3: LN = ' + IntToStr(LN) + ', LName = ' + LPessoa.Name + ', LValue = ' + FloatToStr(LValue));
  finally
    LPessoa.Free;
  end;
end;

procedure TestTuple.TestTupleDestructuringPointersError;
var
  LTuple: TTuple;
  LN: Integer;
  LName: String;
begin
  LN := 0;
  LName := '';
  LTuple := [1, 'isaque', 3.14];  // 3 elementos
  Assert.WillRaise(
    procedure
    begin
      LTuple.Dest([@LN, @LName]);  // Só 2 ponteiros, deve dar erro
    end,
    Exception,
    'Deveria lançar exceção por número de ponteiros incompatível'
  );
  Writeln('TestTupleDestructuringPointersError: Exceção de tamanho verificada');
end;

initialization
  TDUnitX.RegisterTestFixture(TestTuple);

end.

