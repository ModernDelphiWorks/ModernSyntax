unit UTestMS.StreamReader;

interface

uses
  DUnitX.TestFramework,
  Generics.Collections,
  SysUtils,
  Classes,
  System.Stream,
  System.Async;

type
  TPerson = class
  private
    FName: String;
    FAge: Integer;
    FDate: TDateTime;
  public
    constructor Create(const AName: String; const AAge: Integer; const ADate: TDateTime);
    function GetName: String;
    function GetAge: Integer;
    function GetDate: TDateTime;
  end;

  // Auxiliary class to implement the listener
  TTestListener = class
  private
    FLines: TStringList;
    FOperations: TStringList;
  public
    constructor Create(ALines: TStringList; AOperations: TStringList);
    procedure OnStreamOperation(const Line: String; const Operation: String);
  end;

  [TestFixture]
  TestStreamReader = class
  private
    FStreamReader: TEvolutionStreamReader;
    FSampleFile: TStringStream;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestMapLines;
    [Test]
    procedure TestFilterByGender;
    [Test]
    procedure TestReduce;
    [Test]
    procedure TestForEach;
//    [Test]
//    procedure TestGroupBy;
    [Test]
    procedure TestDistinct;
    [Test]
    procedure TestSkip;
    [Test]
    procedure TestSort;
    [Test]
    procedure TestTake;
    [Test]
    procedure TestConcat;
    [Test]
    procedure TestPartition;
//    [Test]
//    procedure TestMapListObject;
    [Test]
    procedure TestListenerNotification;
  end;

implementation

{ TPerson }

constructor TPerson.Create(const AName: String; const AAge: Integer; const ADate: TDateTime);
begin
  FName := AName;
  FAge := AAge;
  FDate := ADate;
end;

function TPerson.GetName: String;
begin
  Result := FName;
end;

function TPerson.GetAge: Integer;
begin
  Result := FAge;
end;

function TPerson.GetDate: TDateTime;
begin
  Result := FDate;
end;

{ TTestListener }

constructor TTestListener.Create(ALines: TStringList; AOperations: TStringList);
begin
  FLines := ALines;
  FOperations := AOperations;
end;

procedure TTestListener.OnStreamOperation(const Line: String; const Operation: String);
begin
  FLines.Add(Line);
  FOperations.Add(Operation);
end;

{ TestStreamReader }

procedure TestStreamReader.Setup;
begin
  FSampleFile := TStringStream.Create(
    'This is a sample text file.' + sLineBreak +
    'It contains multiple lines.' + sLineBreak +
    'Each line has some text.'
  );
  FStreamReader := TEvolutionStreamReader.New(FSampleFile);
end;

procedure TestStreamReader.TearDown;
begin
  FStreamReader.Free;
  FSampleFile.Free;
end;

procedure TestStreamReader.TestMapLines;
var
  LReader: TEvolutionStreamReader;
  LSampleFile: TStringStream;
begin
  Writeln('Executing TestMapLines');
  LSampleFile := TStringStream.Create(
    'linha 1 de teste' + sLineBreak +
    'linha 2 de teste' + sLineBreak +
    'linha 3 de teste'
  );
  try
    LReader := TEvolutionStreamReader.New(LSampleFile)
                              .Map(function(Line: String): String
                                   begin
                                     Result := UpperCase(Line);
                                   end);
    try
      Assert.AreEqual('LINHA 1 DE TESTE', LReader.AsLine);
      Assert.AreEqual('LINHA 2 DE TESTE', LReader.AsLine);
    finally
      LReader.Free;
    end;
  finally
    LSampleFile.Free;
  end;
end;

procedure TestStreamReader.TestFilterByGender;
var
  LDataStream: TStringStream;
  LReader: TEvolutionStreamReader;
begin
  Writeln('Executing TestFilterByGender');
  LDataStream := TStringStream.Create(
    'nome 1 masculino' + sLineBreak +
    'nome 2 feminino' + sLineBreak +
    'nome 3 masculino' + sLineBreak +
    'nome 4 feminino' + sLineBreak +
    'nome 5 masculino' + sLineBreak +
    'nome 6 feminino' + sLineBreak +
    'nome 7 masculino' + sLineBreak +
    'nome 8 feminino' + sLineBreak
  );
  LReader := TEvolutionStreamReader.New(LDataStream)
                            .Filter(function(Line: String): Boolean
                                    begin
                                      Result := Pos('feminino', Line) > 0;
                                    end);
  try
    Assert.AreEqual(
      'nome 2 feminino' + sLineBreak +
      'nome 4 feminino' + sLineBreak +
      'nome 6 feminino' + sLineBreak +
      'nome 8 feminino' + sLineBreak,
      LReader.AsString
    );
  finally
    LReader.Free;
    LDataStream.Free;
  end;
end;

procedure TestStreamReader.TestReduce;
var
  LTotalLength: Integer;
begin
  Writeln('Executing TestReduce');
  LTotalLength := FStreamReader.Reduce(
    function(Accumulator: Integer; Line: String): Integer
    begin
      Result := Accumulator + Length(Line);
    end,
    0);
  Assert.AreEqual(78, LTotalLength, 'Total length of lines is incorrect');
end;

procedure TestStreamReader.TestForEach;
var
  LLines: TStringList;
begin
  Writeln('Executing TestForEach');
  LLines := TStringList.Create;
  try
    FStreamReader.ForEach(
      procedure(Line: String)
      begin
        LLines.Add(Line);
      end
    );
    Assert.AreEqual(3, LLines.Count);
    Assert.AreEqual('This is a sample text file.', LLines[0]);
    Assert.AreEqual('It contains multiple lines.', LLines[1]);
    Assert.AreEqual('Each line has some text.', LLines[2]);
  finally
    LLines.Free;
  end;
end;

//procedure TestStreamReader.TestGroupBy;
//var
//  LSampleFile: TStringStream;
//  LStreamReader: TEvolutionStreamReader;
//  LGroups: TMap<String, TVector<String>>;
//begin
//  Writeln('Executing TestGroupBy');
//  LSampleFile := TStringStream.Create(
//    'Apple' + sLineBreak +
//    'Banana' + sLineBreak +
//    'Cherry' + sLineBreak +
//    'Banana' + sLineBreak +
//    'Date' + sLineBreak +
//    'Apple'
//  );
//  try
//    LStreamReader := TEvolutionStreamReader.New(LSampleFile);
//    try
//      LGroups := LStreamReader.GroupBy(
//        function(Line: String): String
//        begin
//          if Line <> '' then
//            Result := Line[1]
//          else
//            Result := 'Outros';
//        end
//      );
//      Assert.AreEqual(4, LGroups.Count);
//      Assert.AreEqual(2, LGroups['A'].Count);
//      Assert.AreEqual(2, LGroups['B'].Count);
//      Assert.AreEqual(1, LGroups['C'].Count);
//      Assert.AreEqual(1, LGroups['D'].Count);
//      Assert.IsFalse(LGroups.Contains('Outros'), 'Should not have "Outros" group');
//    finally
//      LStreamReader.Free;
//    end;
//  finally
//    LSampleFile.Free;
//  end;
//end;

procedure TestStreamReader.TestDistinct;
begin
  Writeln('Executing TestDistinct');
  Assert.AreEqual(
    'This is a sample text file.' + sLineBreak +
    'It contains multiple lines.' + sLineBreak +
    'Each line has some text.' + sLineBreak,
    FStreamReader.Distinct.AsString,
    'Distinct should return distinct lines'
  );
end;

procedure TestStreamReader.TestSkip;
var
  LStreamReader: TEvolutionStreamReader;
  LSampleFile: TStringStream;
begin
  Writeln('Executing TestSkip');
  LSampleFile := TStringStream.Create(
    'Line 1' + sLineBreak +
    'Line 2' + sLineBreak +
    'Line 3' + sLineBreak +
    'Line 4' + sLineBreak +
    'Line 5'
  );
  try
    LStreamReader := TEvolutionStreamReader.New(LSampleFile);
    try
      LStreamReader.Skip(3);
      Assert.AreEqual('Line 4', LStreamReader.AsLine);
      Assert.AreEqual('Line 5', LStreamReader.AsLine);
    finally
      LStreamReader.Free;
    end;
  finally
    LSampleFile.Free;
  end;
end;

procedure TestStreamReader.TestSort;
var
  LStreamReader: TEvolutionStreamReader;
  LSampleFile: TStringStream;
begin
  Writeln('Executing TestSort');
  LSampleFile := TStringStream.Create(
    'C' + sLineBreak +
    'A' + sLineBreak +
    'B'
  );
  try
    LStreamReader := TEvolutionStreamReader.New(LSampleFile);
    try
      LStreamReader.Sort;
      Assert.AreEqual('A', LStreamReader.AsLine);
      Assert.AreEqual('B', LStreamReader.AsLine);
      Assert.AreEqual('C', LStreamReader.AsLine);
    finally
      LStreamReader.Free;
    end;
  finally
    LSampleFile.Free;
  end;
end;

procedure TestStreamReader.TestTake;
var
  LStreamReader: TEvolutionStreamReader;
begin
  Writeln('Executing TestTake');
  LStreamReader := TEvolutionStreamReader.New(FSampleFile);
  try
    LStreamReader.Take(2);
    Assert.AreEqual('This is a sample text file.', LStreamReader.AsLine);
    Assert.AreEqual('It contains multiple lines.', LStreamReader.AsLine);
  finally
    LStreamReader.Free;
  end;
end;

procedure TestStreamReader.TestConcat;
var
  LSampleFile2: TStringStream;
  LStreamReader: TEvolutionStreamReader;
  LStreamReader2: TEvolutionStreamReader;
begin
  Writeln('Executing TestConcat');
  LStreamReader := TEvolutionStreamReader.New(FSampleFile);
  LSampleFile2 := TStringStream.Create(
    'Another line of text.' + sLineBreak +
    'Yet another line of text.'
  );
  try
    LStreamReader2 := TEvolutionStreamReader.New(LSampleFile2);
    try
      LStreamReader.Concat(LStreamReader2);
      Assert.AreEqual('This is a sample text file.', LStreamReader.AsLine);
      Assert.AreEqual('It contains multiple lines.', LStreamReader.AsLine);
      Assert.AreEqual('Each line has some text.', LStreamReader.AsLine);
      Assert.AreEqual('Another line of text.', LStreamReader.AsLine);
      Assert.AreEqual('Yet another line of text.', LStreamReader.AsLine);
    finally
      LStreamReader2.Free;
    end;
  finally
    LStreamReader.Free;
    LSampleFile2.Free;
  end;
end;

procedure TestStreamReader.TestPartition;
var
  LSampleFile: TStringStream;
  LStreamReader: TEvolutionStreamReader;
  LLeftStreamReader, LRightStreamReader: TEvolutionStreamReader;
  LPartitionResult: TPair<TEvolutionStreamReader, TEvolutionStreamReader>;
begin
  Writeln('Executing TestPartition');
  LSampleFile := TStringStream.Create(
    'Line 01' + sLineBreak +
    'Line 2' + sLineBreak +
    'Line 03' + sLineBreak +
    'Line 4' + sLineBreak +
    'Line 05' + sLineBreak
  );
  try
    LStreamReader := TEvolutionStreamReader.New(LSampleFile);
    try
      LPartitionResult := LStreamReader.Partition(function(Line: String): Boolean
                                                  begin
                                                    Result := Length(Line) mod 2 = 0;
                                                  end);
      LLeftStreamReader := LPartitionResult.Key;
      LRightStreamReader := LPartitionResult.Value;
      try
        Assert.AreEqual('Line 2', LLeftStreamReader.AsLine);
        Assert.AreEqual('Line 4', LLeftStreamReader.AsLine);
        Assert.AreEqual('Line 01', LRightStreamReader.AsLine);
        Assert.AreEqual('Line 03', LRightStreamReader.AsLine);
        Assert.AreEqual('Line 05', LRightStreamReader.AsLine);
      finally
        LLeftStreamReader.Free;
        LRightStreamReader.Free;
      end;
    finally
      LStreamReader.Free;
    end;
  finally
    LSampleFile.Free;
  end;
end;

//procedure TestStreamReader.TestMapListObject;
//var
//  LSampleFile: TStringStream;
//  LStreamReader: TEvolutionStreamReader;
//  LPersons: TList<TPerson>;
//  LPerson: TPerson;
//begin
//  Writeln('Executing TestMapListObject');
//  LSampleFile := TStringStream.Create(
//    'Name 1;15;09-11-2023' + sLineBreak +
//    'Name 2;22;09-11-2023' + sLineBreak +
//    'Name 3;33;09-11-2023' + sLineBreak +
//    'Name 4;44;09-11-2023' + sLineBreak
//  );
//  try
//    LStreamReader := TEvolutionStreamReader.New(LSampleFile);
//    try
//      LPersons := LStreamReader.Map<TVector<String>>(
//                    function(Line: String): TVector<String>
//                    var
//                      LArray: TArray<String>;
//                    begin
//                      LArray := Line.Split([';']);
//                      Result := TVector<String>.Create(LArray);
//                    end)
//                  .Map<TPerson>(
//                    function(Data: TVector<String>): TPerson
//                    begin
//                      Result := TPerson.Create(Data[0], StrToIntDef(Data[1], 0), StrToDateDef(Data[2], Date));
//                    end)
//                  .AsList;
//      try
//        Assert.IsTrue(LPersons.Count = 4);
//        Assert.AreEqual(15, LPersons[0].GetAge);
//        Assert.AreEqual(44, LPersons[3].GetAge);
//        Assert.AreEqual('Name 2', LPersons[1].GetName);
//      finally
//        for LPerson in LPersons do
//          LPerson.Free;
//        LPersons.Free;
//      end;
//    finally
//      LStreamReader.Free;
//    end;
//  finally
//    LSampleFile.Free;
//  end;
//end;

procedure TestStreamReader.TestListenerNotification;
var
  LLines: TStringList;
  LOperations: TStringList;
  LListener: TTestListener;
begin
  Writeln('Executing TestListenerNotification');
  LLines := TStringList.Create;
  LOperations := TStringList.Create;
  LListener := TTestListener.Create(LLines, LOperations);
  try
    FStreamReader.AddListener(LListener.OnStreamOperation);
    FStreamReader.Map(
      function(Line: String): String
      begin
        Result := UpperCase(Line);
      end);
    Assert.AreEqual(3, LLines.Count, 'Listener should be called for each line');
    Assert.AreEqual('This is a sample text file.', LLines[0]);
    Assert.AreEqual('Map', LOperations[0]);
    Assert.AreEqual('It contains multiple lines.', LLines[1]);
    Assert.AreEqual('Map', LOperations[1]);
    Assert.AreEqual('Each line has some text.', LLines[2]);
    Assert.AreEqual('Map', LOperations[2]);
  finally
    LListener.Free;
    LLines.Free;
    LOperations.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TestStreamReader);

end.
