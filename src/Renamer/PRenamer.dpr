program PRenamer;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils, UGlobal in '..\Shared units\UGlobal.pas';

begin
  try
    if UGlobal.BitNum = 0 then
      RenameFile('GetBaseInfo.exe', 'GBI_COL' + inttostr(UGlobal.FragH) + 'x' + inttostr(UGlobal.FragW) + '_' + inttostr(UGlobal.bpp) + '.exe')
    else
      RenameFile('GetBaseInfo.exe', 'GBI_BP_' + inttostr(UGlobal.FragH) + 'x' + inttostr(UGlobal.FragW) + '.exe');
    if UGlobal.BitNum = 0 then
      RenameFile('GetBase.exe', 'GB_COL_' + inttostr(UGlobal.FragH) + 'x' + inttostr(UGlobal.FragW) + '_' + inttostr(UGlobal.bpp) + '.exe')
    else
      RenameFile('GetBase.exe', 'GB_BP_' + inttostr(UGlobal.FragH) + 'x' + inttostr(UGlobal.FragW) + '_' + inttostr(UGlobal.BitNum) + '.exe');
    if UGlobal.BitNum = 0 then
      RenameFile('MergeBases.exe', 'MB_COL_' + inttostr(UGlobal.FragH) + 'x' + inttostr(UGlobal.FragW) + '_' + inttostr(UGlobal.bpp) + '.exe')
    else
      RenameFile('MergeBases.exe', 'MB_BP_' + inttostr(UGlobal.FragH) + 'x' + inttostr(UGlobal.FragW) + '.exe')
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
