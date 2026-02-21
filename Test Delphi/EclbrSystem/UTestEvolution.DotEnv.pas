unit UTestEvolution.DotEnv;

interface

uses
  DUnitX.TestFramework,
  Classes,
  SysUtils,
  Evolution.DotEnv;

type
  [TestFixture]
  TTestDotEnv = class
  private
    FEnv: TDotEnv;
    FTempFile: String;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestCreateLoadsFile;
    [Test]
    procedure TestAddAndGetValue;
    [Test]
    procedure TestGetOrDefault;
    [Test]
    procedure TestSaveToFile;
    [Test]
    procedure TestDeleteVariable;
    [Test]
    procedure TestEnvCreateAndLoad;
    [Test]
    procedure TestEnvUpdate;
    [Test]
    procedure TestEnvDelete;
    [Test]
    procedure TestPropertyAccess;
    [Test]
    procedure TestPushChaining;
    [Test]
    procedure TestEmptyFile;
    [Test]
    procedure TestInterpolation;
    [Test]
    procedure TestLoadFiles;
    [Test]
    procedure TestTryGet;
    [Test]
    procedure TestSystemFallback;
  end;

implementation

procedure TTestDotEnv.Setup;
begin
  FTempFile := 'test.env';
  FEnv := TDotEnv.Create(FTempFile);
  Writeln('Setup: Created TDotEnv with file ' + FTempFile);
end;

procedure TTestDotEnv.TearDown;
begin
  FEnv.Free;
  if FileExists(FTempFile) then
    DeleteFile(FTempFile);
  if FileExists('test1.env') then
    DeleteFile('test1.env');
  if FileExists('test2.env') then
    DeleteFile('test2.env');
  Writeln('TearDown: Freed TDotEnv and deleted temp files');
end;

procedure TTestDotEnv.TestCreateLoadsFile;
var
  LLines: TStringList;
begin
  LLines := TStringList.Create;
  try
    LLines.Add('  PORT = 8080  ');
    LLines.Add('# Comment');
    LLines.Add('HOST=localhost');
    LLines.SaveToFile(FTempFile);
    Writeln('TestCreateLoadsFile: Created test.env with PORT=8080, HOST=localhost');
  finally
    LLines.Free;
  end;

  FEnv.Free;
  FEnv := TDotEnv.Create(FTempFile);
  Writeln('TestCreateLoadsFile: Loaded file, Variables Count = ' + IntToStr(FEnv.Count));

  Assert.AreEqual(8080, FEnv.Get<Integer>('PORT'), 'PORT should be 8080');
  Writeln('TestCreateLoadsFile: PORT = ' + IntToStr(FEnv.Get<Integer>('PORT')));
  Assert.AreEqual('localhost', FEnv.Get<String>('HOST'), 'HOST should be localhost');
  Writeln('TestCreateLoadsFile: HOST = ' + FEnv.Get<String>('HOST'));
end;

procedure TTestDotEnv.TestAddAndGetValue;
begin
  FEnv.Add('DB', 'mysql');
  Writeln('TestAddAndGetValue: Added DB=mysql');
  Assert.AreEqual('mysql', FEnv.Value<String>('DB'), 'DB should be mysql');
  Writeln('TestAddAndGetValue: DB = ' + FEnv.Value<String>('DB'));
end;

procedure TTestDotEnv.TestGetOrDefault;
begin
  Assert.AreEqual(8080, FEnv.GetOr<Integer>('PORT', 8080), 'PORT should default to 8080');
  Writeln('TestGetOrDefault: PORT (default) = ' + IntToStr(FEnv.GetOr<Integer>('PORT', 8080)));
  FEnv.Add('PORT', 3000);
  Assert.AreEqual(3000, FEnv.GetOr<Integer>('PORT', 8080), 'PORT should be 3000');
  Writeln('TestGetOrDefault: PORT (set) = ' + IntToStr(FEnv.GetOr<Integer>('PORT', 8080)));
end;

procedure TTestDotEnv.TestSaveToFile;
var
  LLines: TStringList;
begin
  FEnv.Add('PORT', 8080);
  FEnv.Add('HOST', 'localhost');
  FEnv.Save;
  Writeln('TestSaveToFile: Saved PORT=8080, HOST=localhost to ' + FTempFile);

  LLines := TStringList.Create;
  try
    LLines.LoadFromFile(FTempFile);
    Assert.AreEqual(2, LLines.Count, 'File should have 2 lines');
    Assert.AreEqual('PORT=8080', LLines[0], 'First line should be PORT=8080');
    Assert.AreEqual('HOST=localhost', LLines[1], 'Second line should be HOST=localhost');
    Writeln('TestSaveToFile: File lines = ' + LLines.Text);
  finally
    LLines.Free;
  end;
end;

procedure TTestDotEnv.TestDeleteVariable;
begin
  FEnv.Add('PORT', 8080);
  Writeln('TestDeleteVariable: Added PORT=8080');
  FEnv.Delete('PORT');
  Writeln('TestDeleteVariable: Deleted PORT');
  Assert.WillRaise(
    procedure begin FEnv.Value<Integer>('PORT') end,
    Exception,
    'PORT should be gone'
  );
end;

procedure TTestDotEnv.TestEnvCreateAndLoad;
begin
  FEnv.EnvCreate('TEST_VAR', '123');
  Writeln('TestEnvCreateAndLoad: Created TEST_VAR=123');
  Assert.AreEqual('123', FEnv.EnvLoad('TEST_VAR'), 'TEST_VAR should be 123');
  Writeln('TestEnvCreateAndLoad: Loaded TEST_VAR = ' + FEnv.EnvLoad('TEST_VAR'));
end;

procedure TTestDotEnv.TestEnvUpdate;
begin
  FEnv.EnvCreate('TEST_VAR', '123');
  Writeln('TestEnvUpdate: Created TEST_VAR=123');
  FEnv.EnvUpdate('TEST_VAR', '456');
  Writeln('TestEnvUpdate: Updated TEST_VAR=456');
  Assert.AreEqual('456', FEnv.EnvLoad('TEST_VAR'), 'TEST_VAR should be updated to 456');
  Writeln('TestEnvUpdate: Loaded TEST_VAR = ' + FEnv.EnvLoad('TEST_VAR'));
end;

procedure TTestDotEnv.TestEnvDelete;
begin
  FEnv.EnvCreate('TEST_VAR', '123');
  Writeln('TestEnvDelete: Created TEST_VAR=123');
  FEnv.EnvDelete('TEST_VAR');
  Writeln('TestEnvDelete: Deleted TEST_VAR');
  Assert.AreEqual('', FEnv.EnvLoad('TEST_VAR'), 'TEST_VAR should be deleted');
  Writeln('TestEnvDelete: Loaded TEST_VAR = ' + FEnv.EnvLoad('TEST_VAR'));
end;

procedure TTestDotEnv.TestPropertyAccess;
begin
  FEnv.Add('PORT', 8080);
  Writeln('TestPropertyAccess: Added PORT=8080');
  Assert.AreEqual(8080, FEnv['PORT'].AsInteger, 'Property access should return 8080');
  Writeln('TestPropertyAccess: PORT = ' + IntToStr(FEnv['PORT'].AsInteger));
end;

procedure TTestDotEnv.TestPushChaining;
begin
  FEnv.Push('PORT', 8080).Push('HOST', 'localhost');
  Writeln('TestPushChaining: Pushed PORT=8080, HOST=localhost');
  Assert.AreEqual(8080, FEnv['PORT'].AsInteger, 'PORT should be 8080');
  Assert.AreEqual('localhost', FEnv['HOST'].AsString, 'HOST should be localhost');
  Writeln('TestPushChaining: PORT = ' + IntToStr(FEnv['PORT'].AsInteger) + ', HOST = ' + FEnv['HOST'].AsString);
end;

procedure TTestDotEnv.TestEmptyFile;
begin
  if FileExists(FTempFile) then
    DeleteFile(FTempFile);
  Writeln('TestEmptyFile: Ensured no file exists');

  FEnv.Free;
  FEnv := TDotEnv.Create(FTempFile);
  Writeln('TestEmptyFile: Created with no file');

  Assert.AreEqual(0, FEnv.Count, 'Variables should be empty');
  Writeln('TestEmptyFile: Variables Count = ' + IntToStr(FEnv.Count));
end;

procedure TTestDotEnv.TestInterpolation;
begin
  FEnv.Push('USER', 'admin').Push('DB', 'postgres://${USER}@localhost');
  Writeln('TestInterpolation: Pushed USER=admin, DB=postgres://${USER}@localhost');
  Assert.AreEqual('postgres://admin@localhost', FEnv['DB'].AsString, 'DB should interpolate USER');
  Writeln('TestInterpolation: DB = ' + FEnv['DB'].AsString);
end;

procedure TTestDotEnv.TestLoadFiles;
var
  LLines: TStringList;
begin
  LLines := TStringList.Create;
  try
    LLines.Add('PORT=8080');
    LLines.SaveToFile('test1.env');
    Writeln('TestLoadFiles: Created test1.env with PORT=8080');
    LLines.Clear;
    LLines.Add('PORT=3000');
    LLines.Add('HOST=localhost');
    LLines.SaveToFile('test2.env');
    Writeln('TestLoadFiles: Created test2.env with PORT=3000, HOST=localhost');
  finally
    LLines.Free;
  end;

  FEnv.Free;
  FEnv := TDotEnv.Create;
  FEnv.LoadFiles(['test1.env', 'test2.env']);
  Writeln('TestLoadFiles: Loaded test1.env and test2.env');

  Assert.AreEqual(3000, FEnv.Get<Integer>('PORT'), 'PORT should be 3000 from test2.env');
  Assert.AreEqual('localhost', FEnv.Get<String>('HOST'), 'HOST should be localhost from test2.env');
  Writeln('TestLoadFiles: PORT = ' + IntToStr(FEnv.Get<Integer>('PORT')) + ', HOST = ' + FEnv.Get<String>('HOST'));
end;

procedure TTestDotEnv.TestTryGet;
var
  LPort: Integer;
begin
  FEnv.Push('PORT', 8080);
  Writeln('TestTryGet: Pushed PORT=8080');
  Assert.IsTrue(FEnv.TryGet<Integer>('PORT', LPort), 'TryGet should succeed');
  Assert.AreEqual(8080, LPort, 'PORT should be 8080');
  Writeln('TestTryGet: PORT = ' + IntToStr(LPort));

  Assert.IsFalse(FEnv.TryGet<Integer>('MISSING', LPort), 'TryGet should fail');
  Writeln('TestTryGet: MISSING not found, LPort = ' + IntToStr(LPort));
end;

procedure TTestDotEnv.TestSystemFallback;
begin
  FEnv.EnvCreate('SYSTEM_VAR', 'test');
  Writeln('TestSystemFallback: Created SYSTEM_VAR=test in system');

  FEnv.Free;
  FEnv := TDotEnv.Create(FTempFile, True);  // Com fallback
  Assert.AreEqual('test', FEnv.Get<String>('SYSTEM_VAR'), 'Should fallback to system');
  Writeln('TestSystemFallback: With fallback, SYSTEM_VAR = ' + FEnv.Get<String>('SYSTEM_VAR'));

  FEnv.Free;
  FEnv := TDotEnv.Create(FTempFile, False);  // Sem fallback
  Assert.WillRaise(
    procedure begin FEnv.Value<String>('SYSTEM_VAR') end,
    Exception,
    'Should not fallback to system'
  );
  Writeln('TestSystemFallback: Without fallback, SYSTEM_VAR not found');
end;

initialization
  TDUnitX.RegisterTestFixture(TTestDotEnv);

end.
