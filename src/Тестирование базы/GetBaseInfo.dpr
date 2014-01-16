program GetBaseInfo;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils, UGlobal in '..\Shared units\UGlobal.pas', Math, Classes, UElem in '..\Shared units\UElem.pas', UStatList in '..\Shared units\UStatList.pas';

procedure ReadFromFile();
var
  FS: TFileStream;
  tmpElem: UElem.TRElem;
  m: int64;
begin
  FS := TFileStream.Create(Paramstr(1) + '.base', fmOpenRead);
  while not(FS.Position >= FS.Size) do
  begin
    FS.Read(tmpElem, sizeof(TRStatElem));
    m := tmpElem.count;
    AddID(m);
  end;
  FS.Free;
end;

begin
  try
    ReadFromFile();
    writeln('Данные считаны. Вычисление энтропии...');
    WriteBaseInfo(Paramstr(1) + '.txt');
  except
    on E: Exception do
      writeln(E.ClassName, ': ', E.Message);
  end;

end.
