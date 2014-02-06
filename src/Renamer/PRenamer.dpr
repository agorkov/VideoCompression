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
    case UGlobal.BaseType of
    btFrag: bt := 'FR';
    btLDiff: bt := 'LD';
    btMDiff: bt := 'MD';
    end;
    if UGlobal.GrayCode then
      bt := bt + '_GC';
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
