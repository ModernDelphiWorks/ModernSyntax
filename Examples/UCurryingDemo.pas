unit UCurryingDemo;

interface

uses
  Rtti,
  SysUtils,
  Generics.Collections,
  DateUtils,
  Evolution.Currying;

procedure ExampleOpByte;
procedure ExampleOpShortInt;
procedure ExampleOpWord;
procedure ExampleOpSmallInt;
procedure ExampleOpLongWord;
procedure ExampleOpInt64;
procedure ExampleOpSingle;
procedure ExampleOpDouble;
procedure ExampleOpInteger;
procedure ExampleOpExtended;
procedure ExampleOpBoolean;
procedure ExampleOpDateTime;
procedure ExampleOpString;
procedure ExampleOpCurrency;

implementation

procedure ExampleOpByte;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Byte>(100));
  LResult := LCurrying.Op<Byte>(
    function(A, B: Byte): Byte begin Result := A + B; end
  )(50);
  Writeln('Exemplo Op<Byte>: 100 + 50 = ' + IntToStr(LResult.Value<Byte>));
end;

procedure ExampleOpShortInt;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<ShortInt>(50));
  LResult := LCurrying.Op<ShortInt>(
    function(A, B: ShortInt): ShortInt begin Result := A + B; end
  )(20);
  Writeln('Exemplo Op<ShortInt>: 50 + 20 = ' + IntToStr(LResult.Value<ShortInt>));
end;

procedure ExampleOpWord;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Word>(1000));
  LResult := LCurrying.Op<Word>(
    function(A, B: Word): Word begin Result := A + B; end
  )(500);
  Writeln('Exemplo Op<Word>: 1000 + 500 = ' + IntToStr(LResult.Value<Word>));
end;

procedure ExampleOpSmallInt;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<SmallInt>(1000));
  LResult := LCurrying.Op<SmallInt>(
    function(A, B: SmallInt): SmallInt begin Result := A + B; end
  )(500);
  Writeln('Exemplo Op<SmallInt>: 1000 + 500 = ' + IntToStr(LResult.Value<SmallInt>));
end;

procedure ExampleOpLongWord;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<LongWord>(100000));
  LResult := LCurrying.Op<LongWord>(
    function(A, B: LongWord): LongWord begin Result := A + B; end
  )(50000);
  Writeln('Exemplo Op<LongWord>: 100000 + 50000 = ' + IntToStr(LResult.Value<LongWord>));
end;

procedure ExampleOpInt64;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Int64>(1000000));
  LResult := LCurrying.Op<Int64>(
    function(A, B: Int64): Int64 begin Result := A + B; end
  )(500000);
  Writeln('Exemplo Op<Int64>: 1000000 + 500000 = ' + IntToStr(LResult.Value<Int64>));
end;

procedure ExampleOpSingle;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Single>(5.5));
  LResult := LCurrying.Op<Single>(
    function(A, B: Single): Single begin Result := A + B; end
  )(2.5);
  Writeln('Exemplo Op<Single>: 5.5 + 2.5 = ' + FloatToStr(LResult.Value<Single>));
end;

procedure ExampleOpDouble;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Double>(5.0));
  LResult := LCurrying.Op<Double>(
    function(A, B: Double): Double begin Result := A + B; end
  )(3.0);
  Writeln('Exemplo Op<Double>: 5 + 3 = ' + FloatToStr(LResult.Value<Double>));
end;

procedure ExampleOpInteger;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Integer>(5));
  LResult := LCurrying.Op<Integer>(
    function(A, B: Integer): Integer begin Result := A + B; end
  )(3);
  Writeln('Exemplo Op<Integer>: 5 + 3 = ' + IntToStr(LResult.Value<Integer>));
end;

procedure ExampleOpExtended;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Extended>(5.0));
  LResult := LCurrying.Op<Extended>(
    function(A, B: Extended): Extended begin Result := A + B; end
  )(3.0);
  Writeln('Exemplo Op<Extended>: 5 + 3 = ' + FloatToStr(LResult.Value<Extended>));
end;

procedure ExampleOpBoolean;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Boolean>(True));
  LResult := LCurrying.Op<Boolean>(
    function(A, B: Boolean): Boolean begin Result := A or B; end
  )(False);
  Writeln('Exemplo Op<Boolean>: True OR False = ' + BoolToStr(LResult.Value<Boolean>, True));
end;

procedure ExampleOpDateTime;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<TDateTime>(EncodeDate(2023, 1, 1)));
  LResult := LCurrying.Op<TDateTime>(
    function(A, B: TDateTime): TDateTime begin Result := A + B; end
  )(5);
  Writeln('Exemplo Op<TDateTime>: 01/01/2023 + 5 dias = ' + DateToStr(LResult.Value<TDateTime>));
end;

procedure ExampleOpString;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<string>('Hello'));
  LResult := LCurrying.Op<string>(
    function(A, B: string): string begin Result := A + B; end
  )(' World');
  Writeln('Exemplo Op<String>: Hello + World = ' + LResult.Value<string>);
end;

procedure ExampleOpCurrency;
var
  LCurrying, LResult: TCurrying;
begin
  LCurrying := TCurrying.Create(TValue.From<Currency>(100.00));
  LResult := LCurrying.Op<Currency>(
    function(A, B: Currency): Currency begin Result := A + B; end
  )(50.25);
  Writeln('Exemplo Op<Currency>: 100.00 + 50.25 = ' + CurrToStr(LResult.Value<Currency>));
end;

end.
