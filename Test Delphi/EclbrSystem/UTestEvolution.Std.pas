unit UTestEvolution.Std;

interface

uses
  DUnitX.TestFramework,
  SysUtils,
  DateUtils,
  StrUtils,
  Classes,
  Generics.Collections,
  Evolution.Objects,
  Evolution.System,
  Evolution.Std,
  Evolution.Crypt;

type
  [TestFixture]
  TTestStd = class
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestJoinStrings_StringArray;
    [Test]
    procedure TestJoinStrings_StringList;
    [Test]
    procedure TestRemoveTrailingChars;
    [Test]
    procedure TestIso8601ToDateTime;
    [Test]
    procedure TestDateTimeToIso8601;
    [Test]
    procedure TestDecodeBase64;
    [Test]
    procedure TestEncodeBase64;
    [Test]
    procedure TestEncodeString;
    [Test]
    procedure TestDecodeString;
    [Test]
    procedure TestMinInteger;
    [Test]
    procedure TestMinDouble;
    [Test]
    procedure TestMinCurrency;
    [Test]
    procedure TestSplit;
  end;

implementation

procedure TTestStd.Setup;
begin
  Writeln('Setup: Initializing test environment');
end;

procedure TTestStd.TearDown;
begin
  Writeln('TearDown: Cleaning up test environment');
end;

procedure TTestStd.TestJoinStrings_StringArray;
var
  LStrings: TArray<String>;
  LSeparator, LResultString: String;
begin
  Writeln('TestJoinStrings_StringArray: Starting join test');
  LStrings := TArray<String>.Create('Hello', 'World', 'DUnitX', 'Testing');
  Writeln('TestJoinStrings_StringArray: Input array = [Hello, World, DUnitX, Testing]');
  LSeparator := ', ';
  LResultString := TStd.JoinStrings(LStrings, LSeparator);
  Assert.AreEqual('Hello, World, DUnitX, Testing', LResultString, 'Joined string should match');
  Writeln('TestJoinStrings_StringArray: Joined string = ' + LResultString);
end;

procedure TTestStd.TestJoinStrings_StringList;
var
  LSeparator, LResultString: String;
  LIAutoRef: TSmartPtr<TListString>;
begin
  Writeln('TestJoinStrings_StringList: Starting join test');
  LIAutoRef := TListString.Create;
  LIAutoRef.AsRef.Add('Hello');
  LIAutoRef.AsRef.Add('World');
  LIAutoRef.AsRef.Add('DUnitX');
  LIAutoRef.AsRef.Add('Testing');
  Writeln('TestJoinStrings_StringList: Input list = [Hello, World, DUnitX, Testing]');
  LSeparator := ', ';
  LResultString := TStd.JoinStrings(LIAutoRef.AsRef, LSeparator);
  Assert.AreEqual('Hello, World, DUnitX, Testing', LResultString, 'Joined string should match');
  Writeln('TestJoinStrings_StringList: Joined string = ' + LResultString);
end;

procedure TTestStd.TestRemoveTrailingChars;
var
  LInputString, LResultString: String;
  LTrailingChars: TSysCharSet;
begin
  Writeln('TestRemoveTrailingChars: Starting remove test');
  LInputString := 'Hello, World!!!';
  Writeln('TestRemoveTrailingChars: Input string = ' + LInputString);
  LTrailingChars := ['!', ','];
  LResultString := TStd.RemoveTrailingChars(LInputString, LTrailingChars);
  Assert.AreEqual('Hello, World', LResultString, 'String should have trailing chars removed');
  Writeln('TestRemoveTrailingChars: Result string = ' + LResultString);
end;

procedure TTestStd.TestIso8601ToDateTime;
var
  LIso8601DateString: String;
  LResultDateTime: TDateTime;
begin
  Writeln('TestIso8601ToDateTime: Starting ISO conversion test');
  LIso8601DateString := '2023-09-26T14:30:00';
  Writeln('TestIso8601ToDateTime: Input ISO string = ' + LIso8601DateString);
  LResultDateTime := TStd.Iso8601ToDateTime(LIso8601DateString, True);
  Assert.AreEqual(2023, YearOf(LResultDateTime), 'Year should be 2023');
  Assert.AreEqual(9, MonthOf(LResultDateTime), 'Month should be 9');
  Assert.AreEqual(26, DayOf(LResultDateTime), 'Day should be 26');
  Assert.AreEqual(14, HourOf(LResultDateTime), 'Hour should be 14');
  Assert.AreEqual(30, MinuteOf(LResultDateTime), 'Minute should be 30');
  Assert.AreEqual(0, SecondOf(LResultDateTime), 'Second should be 0');
  Writeln('TestIso8601ToDateTime: Converted datetime = ' + DateTimeToStr(LResultDateTime));
end;

procedure TTestStd.TestDateTimeToIso8601;
var
  LInputDateTime: TDateTime;
  LResultString: String;
begin
  Writeln('TestDateTimeToIso8601: Starting ISO conversion test');
  LInputDateTime := EncodeDateTime(2023, 9, 26, 14, 30, 0, 0);
  Writeln('TestDateTimeToIso8601: Input datetime = ' + DateTimeToStr(LInputDateTime));
  LResultString := TStd.DateTimeToIso8601(LInputDateTime, True);
  Assert.AreEqual('2023-09-26T14:30:00', LResultString, 'ISO string should match');
  Writeln('TestDateTimeToIso8601: Result ISO string = ' + LResultString);
end;

procedure TTestStd.TestDecodeBase64;
var
  LInputBase64: String;
  LResultBytes: TBytes;
  LDecodedString: String;
begin
  Writeln('TestDecodeBase64: Starting decode test');
  LInputBase64 := 'SGVsbG8sIFdvcmxkIQ==';
  Writeln('TestDecodeBase64: Input base64 = ' + LInputBase64);
  LResultBytes := TCrypt.DecodeBase64(LInputBase64);
  LDecodedString := StringOf(LResultBytes);
  Assert.AreEqual('Hello, World!', LDecodedString, 'Decoded string should match');
  Writeln('TestDecodeBase64: Decoded string = ' + LDecodedString);
end;

procedure TTestStd.TestEncodeBase64;
var
  LInputData: TBytes;
  LResultString: String;
begin
  Writeln('TestEncodeBase64: Starting encode test');
  SetLength(LInputData, 13);
  LInputData[0] := Ord('H'); LInputData[1] := Ord('e'); LInputData[2] := Ord('l');
  LInputData[3] := Ord('l'); LInputData[4] := Ord('o'); LInputData[5] := Ord(',');
  LInputData[6] := Ord(' '); LInputData[7] := Ord('W'); LInputData[8] := Ord('o');
  LInputData[9] := Ord('r'); LInputData[10] := Ord('l'); LInputData[11] := Ord('d');
  LInputData[12] := Ord('!');
  Writeln('TestEncodeBase64: Input string = Hello, World!');
  LResultString := TCrypt.EncodeBase64(@LInputData[0], Length(LInputData));
  Assert.AreEqual('SGVsbG8sIFdvcmxkIQ==', LResultString, 'Encoded base64 should match');
  Writeln('TestEncodeBase64: Encoded base64 = ' + LResultString);
end;

procedure TTestStd.TestEncodeString;
var
  LInputString, LResultString: String;
begin
  Writeln('TestEncodeString: Starting encode test');
  LInputString := 'Hello, World!';
  Writeln('TestEncodeString: Input string = ' + LInputString);
  LResultString := TCrypt.EncodeString(LInputString);
  Assert.AreEqual('SGVsbG8sIFdvcmxkIQ==', LResultString, 'Encoded base64 should match');
  Writeln('TestEncodeString: Encoded base64 = ' + LResultString);
end;

procedure TTestStd.TestDecodeString;
var
  LInputString, LResultString: String;
begin
  Writeln('TestDecodeString: Starting decode test');
  LInputString := 'SGVsbG8sIFdvcmxkIQ==';
  Writeln('TestDecodeString: Input base64 = ' + LInputString);
  LResultString := TCrypt.DecodeString(LInputString);
  Assert.AreEqual('Hello, World!', LResultString, 'Decoded string should match');
  Writeln('TestDecodeString: Decoded string = ' + LResultString);
end;

procedure TTestStd.TestMinInteger;
var
  LA, LB, LResultValue: Integer;
begin
  Writeln('TestMinInteger: Starting min test');
  LA := 5; LB := 10;
  Writeln('TestMinInteger: Input A = ' + IntToStr(LA) + ', B = ' + IntToStr(LB));
  LResultValue := TStd.Min(LA, LB);
  Assert.AreEqual(5, LResultValue, 'Min(A, B) should return 5');
  Writeln('TestMinInteger: Min result = ' + IntToStr(LResultValue));
end;

procedure TTestStd.TestMinDouble;
var
  LA, LB, LResultValue: Double;
begin
  Writeln('TestMinDouble: Starting min test');
  LA := 3.14; LB := 2.71;
  Writeln('TestMinDouble: Input A = ' + FloatToStr(LA) + ', B = ' + FloatToStr(LB));
  LResultValue := TStd.Min(LA, LB);
  Assert.AreEqual(2.71, LResultValue, 0.001, 'Min(A, B) should return 2.71');
  Writeln('TestMinDouble: Min result = ' + FloatToStr(LResultValue));
end;

procedure TTestStd.TestMinCurrency;
var
  LA, LB, LResultValue: Currency;
begin
  Writeln('TestMinCurrency: Starting min test');
  LA := 100.50; LB := 99.99;
  Writeln('TestMinCurrency: Input A = ' + CurrToStr(LA) + ', B = ' + CurrToStr(LB));
  LResultValue := TStd.Min(LA, LB);
  Assert.AreEqual(Currency(99.99), LResultValue, 'Min(A, B) should return 99.99');
  Writeln('TestMinCurrency: Min result = ' + CurrToStr(LResultValue));
end;

procedure TTestStd.TestSplit;
var
  LS: String;
  LResultArray: TArray<String>;
  LFor: Integer;
begin
  Writeln('TestSplit: Starting split test');
  LS := 'Hello,World';
  Writeln('TestSplit: Input string = ' + LS);
  LResultArray := TStd.Split(LS);
  Assert.AreEqual(11, Length(LResultArray), 'Split should return 11 elements');
  Writeln('TestSplit: Split array length = ' + IntToStr(Length(LResultArray)));
  Assert.AreEqual('H', LResultArray[0], 'Element[0] should be "H"');
  Assert.AreEqual('e', LResultArray[1], 'Element[1] should be "e"');
  Assert.AreEqual('l', LResultArray[2], 'Element[2] should be "l"');
  Assert.AreEqual('l', LResultArray[3], 'Element[3] should be "l"');
  Assert.AreEqual('o', LResultArray[4], 'Element[4] should be "o"');
  Assert.AreEqual(',', LResultArray[5], 'Element[5] should be ","');
  Assert.AreEqual('W', LResultArray[6], 'Element[6] should be "W"');
  Assert.AreEqual('o', LResultArray[7], 'Element[7] should be "o"');
  Assert.AreEqual('r', LResultArray[8], 'Element[8] should be "r"');
  Assert.AreEqual('l', LResultArray[9], 'Element[9] should be "l"');
  Assert.AreEqual('d', LResultArray[10], 'Element[10] should be "d"');
  for LFor := 0 to High(LResultArray) do
    Writeln('TestSplit: Element[' + IntToStr(LFor) + '] = ' + LResultArray[LFor]);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestStd);

end.
