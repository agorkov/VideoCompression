program GetBase;

uses
  Vcl.Forms,
  UFMain in 'UFMain.pas' {FMain},
  UProcess in 'UProcess.pas',
  UGlobal in '..\Shared units\UGlobal.pas',
  USettings in 'USettings.pas',
  UElem in '..\Shared units\UElem.pas',
  UStatList in '..\Shared units\UStatList.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFMain, FMain);
  Application.Run;
end.
