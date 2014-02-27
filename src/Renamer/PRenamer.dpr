program PRenamer;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils, UGlobal in '..\Shared units\UGlobal.pas', USettings in '..\Создание базы фрагментов\USettings.pas';

var
  bt, size, bp: string;

begin
  try
    DeleteFile('GetBaseInfo.exe');
    DeleteFile('MergeBases.exe');

    size := inttostr(UGlobal.ElemH) + 'x' + inttostr(UGlobal.ElemW);
    RenameFile('GetBase.exe', 'GB_' + size + '.exe')
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
