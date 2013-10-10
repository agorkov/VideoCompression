program Preview;

uses
  Vcl.Forms,
  UFMain in 'UFMain.pas' {FMain},
  UProcess in 'UProcess.pas',
  USettings in 'USettings.pas',
  UGlobal in '..\Shared units\UGlobal.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFMain, FMain);
  Application.Run;
end.
