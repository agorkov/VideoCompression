program GetBase;

uses
  Vcl.Forms,
  UFMain in 'UFMain.pas' {FMain},
  UProcess in 'UProcess.pas',
  UGlobal in '..\Shared units\UGlobal.pas',
  UFrag in 'UFrag.pas',
  UMerge in '..\Shared units\UMerge.pas',
  UMergeList in 'UMergeList.pas',
  USettings in 'USettings.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFMain, FMain);
  Application.Run;
end.
