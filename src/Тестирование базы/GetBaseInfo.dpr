program GetBaseInfo;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  UGlobal in '..\Shared units\UGlobal.pas',
  Math,
  Classes,
  UFrag in '..\Shared units\UFrag.pas';

const
  FragLength = UGlobal.FragH * UGlobal.FragW * UGlobal.bpp;

type
  TPElem = ^TRElem;

  TRElem = record
    ID, count: int64;
    next, prev: TPElem;
  end;

var
  DLF, DLL: TPElem;

procedure InsertBefore(elem: TPElem; newval: int64);
var
  NewElem, tmp: TPElem;
begin
  New(NewElem);
  NewElem^.ID := newval;
  NewElem^.count := 1;
  tmp := elem^.prev;
  tmp^.next := NewElem;
  NewElem^.next := elem;
  elem^.prev := NewElem;
  NewElem^.prev := tmp;
end;

procedure InitList;
begin
  New(DLF);
  New(DLL);
  DLF^.ID := round(power(2, 32) - 1);
  DLF^.count := 0;
  DLF^.prev := nil;
  DLF^.next := DLL;
  DLL^.ID := round(power(2, 32) - 1);
  DLL^.count := 0;
  DLL^.prev := DLF;
  DLL^.next := nil;
end;

procedure AddID(ID: int64);
var
  elem: TPElem;
begin
  elem := DLF^.next;
  while (elem <> DLL) and (elem^.ID < ID) do
    elem := elem^.next;
  if elem^.ID = ID then
    elem^.count := elem^.count + 1
  else
    InsertBefore(elem, ID);
end;

var
  FS: TFileStream;
  f: TextFile;
  tmpFrag: TRFrag;
  str: string[FragLength];
  m, Uniq, All: int64;
  P_i, entropy: double;
  elem: TPElem;
  FullMovie, Base, Codes: double;

begin
  try
    InitList;
    Uniq := 0;
    All := 0;
    FS := TFileStream.Create(Paramstr(1) + '.base', fmOpenRead);

    while not(FS.Position >= FS.Size) do
    begin
      FS.Read(tmpFrag, sizeof(TRFrag));
      m := tmpFrag.count;
      AddID(m);
      Uniq := Uniq + 1;
      All := All + m;
    end;
    FS.Free;
    writeln('������ �������. ���������� ��������...');

    elem := DLF^.next;
    entropy := 0;
    while elem <> DLL do
    begin
      P_i := elem^.ID / All;
      entropy := entropy - P_i * log2(P_i) * elem^.count;
      elem := elem^.next;
    end;

    FullMovie := All * UGlobal.FragSize * UGlobal.bpp;
    Base := Uniq * (UGlobal.FragSize * bpp + 2);
    Codes := All * entropy;

    AssignFile(f, Paramstr(1) + 'INFO.txt');
    rewrite(f);
    writeln(f, '����                                   ', Paramstr(1));
    writeln(f, '����                                   ', UGlobal.PicH, 'x', UGlobal.PicW);
    writeln(f, '����                                   ', UGlobal.FragH, 'x', UGlobal.FragW);
    writeln(f, '��� �� ������                          ', UGlobal.bpp);
    writeln(f, '���������� ��������� � ��������        ', All, ' (', floattostrf(All * UGlobal.FragSize / (UGlobal.PicW * UGlobal.PicH), ffFixed, 8, 2), ' ������)');
    writeln(f, '���������� ���������� ��������� � ���� ', Uniq);
    writeln(f, '�������� ����                          ', floattostrf(entropy, ffFixed, 3, 5));
    writeln(f, '��������� ������� ������               ', floattostrf(FullMovie / (Base + Codes), ffFixed, 3, 5));
    writeln(f, '���� ���� � ��������                   ', floattostrf(Base / (Base + Codes), ffFixed, 3, 5));
    writeln(f, '��������� �������� ���� � ������       ', floattostrf(Base / FullMovie, ffFixed, 3, 5));
    elem := DLF^.next;
    while elem <> DLL do
    begin
      writeln(f, elem^.ID, ' ', elem^.count);
      elem := elem^.next;
    end;
    CloseFile(f);
  except
    on E: Exception do
      writeln(E.ClassName, ': ', E.Message);
  end;

end.
