program GetBaseInfo;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils, UGlobal in '..\Shared units\UGlobal.pas', Math, Classes, UElem in '..\Shared units\UElem.pas', UStatList in '..\Shared units\UStatList.pas';

procedure ReadFromFile();
var
  FS: TFileStream;
  tmpElem, o: UElem.TRElem;
  m: int64;
begin
  FS := TFileStream.Create(Paramstr(1) + '.base', fmOpenRead);

  FS.Read(tmpElem, sizeof(TRElem));
  m := tmpElem.count;
  AddID(m);
  o := tmpElem;
  while not(FS.Position >= FS.Size) do
  begin
    FS.Read(tmpElem, sizeof(TRElem));
    m := tmpElem.count;
    AddID(m);
    if UElem.CompareElem(o.elem, tmpElem.elem) <> 0 then
    begin
      writeln('Нарушение упорядоченности');
      readln;
    end;
    o := tmpElem;
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
