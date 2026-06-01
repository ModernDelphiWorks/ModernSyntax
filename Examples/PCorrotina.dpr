program PCorrotina;

uses
  FastMM4,
  Vcl.Forms,
  UCorrotina in 'UCorrotina.pas' {Form2},
  ModernSyntax.Coroutine in '..\Source\ModernSyntax.Coroutine.pas',
  ModernSyntax.Std in '..\Source\ModernSyntax.Std.pas',
  ModernSyntax in '..\Source\ModernSyntax.pas',
  ModernSyntax.Async in '..\Source\ModernSyntax.Async.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
