program GetBaseInfo;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils, UGlobal in '..\Shared units\UGlobal.pas', Math, Classes, UFrag in '..\Shared units\UFrag.pas';

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
  Uniq, All: int64;

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

procedure Delete(elem: TPElem);
var
  before, after: TPElem;
begin
  before := elem^.prev;
  after := elem^.next;
  before^.next := after;
  after^.prev := before;
  Dispose(elem);
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

procedure DelID(ID: int64);
var
  elem: TPElem;
begin
  elem := DLF^.next;
  while (elem <> DLL) and (elem^.ID < ID) do
    elem := elem^.next;
  if elem^.ID = ID then
    elem^.count := elem^.count - 1;
  if elem^.count = 0 then
    Delete(elem);
end;

function GetEntropy(k: int64): double;
var
  elem: TPElem;
  P_i, Ent: double;
begin
  elem := DLF^.next;
  Ent := 0;
  while elem <> DLL do
  begin
    if elem^.ID > k then
    begin
      P_i := elem^.ID / All;
      Ent := Ent - P_i * log2(P_i) * elem^.count;
    end;
    elem := elem^.next;
  end;
  GetEntropy := Ent;
end;

procedure CreateList;
var
  FS: TFileStream;
  tmpFrag: TRFrag;
  m: int64;
begin
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
end;

procedure WriteBaseInfo;
var
  f: TextFile;
  elem: TPElem;
  entropy, codeLength: double;
begin
  entropy := GetEntropy(0);
  codeLength := entropy;
  AssignFile(f, Paramstr(1) + '.txt');
  rewrite(f);
  writeln(f, 'Кадр                                   ', UGlobal.PicH, 'x', UGlobal.PicW);
  writeln(f, 'Окно                                   ', UGlobal.FragH, 'x', UGlobal.FragW);
  writeln(f, 'Бит на пиксел                          ', UGlobal.bpp);
  writeln(f, 'Количество элементов в передаче        ', All, ' (', floattostrf(All * UGlobal.FragSize / (UGlobal.PicW * UGlobal.PicH), ffFixed, 8, 2), ' кадров)');
  writeln(f, 'Количество уникальных элементов в базе ', Uniq);
  writeln(f, 'Энтропия базы                          ', floattostrf(entropy, ffFixed, 3, 5));
  writeln(f, 'Средняя длина кода                     ', floattostrf(codeLength, ffFixed, 3, 5));
  writeln(f, 'Ожидаемая степень сжатия               ', floattostrf(Uniq / All + codeLength / (UGlobal.FragH * UGlobal.FragW * UGlobal.bpp), ffFixed, 3, 5));
  elem := DLF^.next;
  while elem <> DLL do
  begin
    writeln(f, elem^.ID, ' ', elem^.count);
    elem := elem^.next;
  end;
  CloseFile(f);
end;

begin
  try
    All := 0;
    Uniq := 0;
    CreateList;
    writeln('Данные считаны. Вычисление энтропии...');
    WriteBaseInfo;
    { ind := entropy / UGlobal.FragSize;
      prevind := ind;
      k := 1;
      writeln(0, ' ', entropy:5:4, ' ', ind:5:4);
      while ind <= prevind do
      begin
      prevind := ind;
      count := 0;
      elem := DLF^.next;
      while elem <> DLL do
      begin
      if elem^.ID <= k then
      count := count + elem^.ID * elem^.count;
      elem := elem^.next;
      end;
      AddID(count);
      entropy := GetEntropy(All, k);
      DelID(count);
      ind := entropy / UGlobal.FragSize + count / All;
      writeln(k, ' ', entropy:5:4, ' ', ind:5:4);
      k := k + 1;
      end;
      readln; }
  except
    on E: Exception do
      writeln(E.ClassName, ': ', E.Message);
  end;

end.
