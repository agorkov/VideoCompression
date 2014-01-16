program PRenamer;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils, UGlobal in '..\Shared units\UGlobal.pas', USettings in '..\Создание базы фрагментов\USettings.pas';

var
  bt, size, bp: string;

begin
  try
    { if BitNum = 0 then
      RenameFile('GetBaseInfo.exe', 'GBI_COL_' + inttostr(UGlobal.ElemH) + 'x' + inttostr(UGlobal.ElemW) + '_' + inttostr(UGlobal.bpp) + '.exe')
      else
      RenameFile('GetBaseInfo.exe', 'GBI_BP_' + inttostr(UGlobal.ElemH) + 'x' + inttostr(UGlobal.ElemW) + '.exe');
      if BitNum = 0 then
      RenameFile('GetBase.exe', 'GB_COL_' + inttostr(UGlobal.ElemH) + 'x' + inttostr(UGlobal.ElemW) + '_' + inttostr(UGlobal.bpp) + '.exe')
      else
      RenameFile('GetBase.exe', 'GB_BP_' + inttostr(UGlobal.ElemH) + 'x' + inttostr(UGlobal.ElemW) + '_' + inttostr(BitNum) + '.exe');
      if BitNum = 0 then
      RenameFile('MergeBases.exe', 'MB_COL_' + inttostr(UGlobal.ElemH) + 'x' + inttostr(UGlobal.ElemW) + '_' + inttostr(UGlobal.bpp) + '.exe')
      else
      RenameFile('MergeBases.exe', 'MB_BP_' + inttostr(UGlobal.ElemH) + 'x' + inttostr(UGlobal.ElemW) + '.exe') }
    DeleteFile('GetBaseInfo.exe');
    DeleteFile('MergeBases.exe');
    case UGlobal.BaseType of
    btFrag: bt := 'FR';
    btLDiff: bt := 'LD';
    btMDiff: bt := 'MD';
    end;
    size := inttostr(UGlobal.ElemH) + 'x' + inttostr(UGlobal.ElemW);
    if UGlobal.BitNum = 0 then
      bp := ''
    else
      bp := '_BP' + inttostr(UGlobal.BitNum);

    RenameFile('GetBase.exe', 'GB_' + bt + '_' + size + bp + '.exe')
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
