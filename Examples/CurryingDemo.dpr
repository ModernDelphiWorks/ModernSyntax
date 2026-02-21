program CurryingDemo;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  SysUtils,
  UCurryingDemo in 'UCurryingDemo.pas',
  Evolution.Currying in '..\Source\Evolution.Currying.pas';

begin
  try
    Writeln('=== Demonstracao do TCurrying ===');
    Writeln('');

    ExampleOpByte;
    ExampleOpShortInt;
    ExampleOpWord;
    ExampleOpSmallInt;
    ExampleOpLongWord;
    ExampleOpInt64;
    ExampleOpSingle;
    ExampleOpDouble;
    ExampleOpInteger;
    ExampleOpExtended;
    ExampleOpBoolean;
    ExampleOpDateTime;
    ExampleOpString;
    ExampleOpCurrency;

    Writeln('');
    Writeln('=== Fim da Demonstracao ===');
    Writeln('Pressione Enter para sair...');
    Readln;
  except
    on E: Exception do
    begin
      Writeln('Erro: ' + E.Message);
      Writeln('Pressione Enter para sair...');
      Readln;
    end;
  end;
end.

