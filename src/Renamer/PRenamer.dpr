program PRenamer;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils, UGlobal in '..\Shared units\UGlobal.pas';

begin
  try
    readln;
    RenameFile('GetBaseInfo.exe', 'GBI_' + inttostr(UGlobal.FragH) + 'x' + inttostr(UGlobal.FragW) + '.exe');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
