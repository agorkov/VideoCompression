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

function GetEntropy(var NBase, NFilm: int64; k: int64): double;
var
  elem: TPElem;
  P_i, Ent: double;
begin
  elem := DLF^.next;
  NFilm := 0;
  NBase := 0;
  while elem <> DLL do
  begin
    if elem^.ID > k then
    begin
      NBase := NBase + elem^.count;
      NFilm := NFilm + elem^.ID * elem^.count;
    end;
    elem := elem^.next;
  end;

  elem := DLF^.next;
  Ent := 0;
  while elem <> DLL do
  begin
    if elem^.ID > k then
    begin
      P_i := elem^.ID / NFilm;
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
  FS := TFileStream.Create(Paramstr(1) + '.base', fmOpenRead);
  while not(FS.Position >= FS.Size) do
  begin
    FS.Read(tmpFrag, sizeof(TRFrag));
    m := tmpFrag.count;
    AddID(m);
  end;
  FS.Free;
end;
{ procedure CreateList;
  var
  F: TextFile;
  tmpFrag: TRFrag;
  m, i: int64;
  begin
  InitList;
  AssignFile(F, '1.txt');
  reset(F);
  while not EOF(F) do
  begin
  readln(F, m, i);
  while i > 0 do
  begin
  AddID(m);
  i := i - 1;
  end;
  end;
  CloseFile(f);
  end; }

function CompLevel(NBase, NFilm, NaturalCount: int64; entropy: double): double;
begin
  CompLevel := NBase / NFilm * (UGlobal.FragSize * UGlobal.bpp + 2) / (UGlobal.FragSize * UGlobal.bpp) + entropy / (UGlobal.FragSize * UGlobal.bpp) + NaturalCount / NFilm;
end;

procedure FindOptNatural(var NaturalCount: int64; var CompressLevel: double);
var
  PreviousCompressionLevel, CompressionLevel: double;
  NBase, NFilm, k: int64;
  entropy: double;
  elem: TPElem;
begin
  entropy := GetEntropy(NBase, NFilm, 0);
  NaturalCount := 0;
  CompressionLevel := CompLevel(NBase, NFilm, NaturalCount, entropy);
  PreviousCompressionLevel := CompressionLevel;
  k := 0;
  writeln(k, ' ', NFilm, ' ', NBase, ' ', entropy:5:4, ' ', NaturalCount / NFilm:5:4, ' ', CompressionLevel:5:4);
  while CompressionLevel <= PreviousCompressionLevel do
  begin
    k := k + 1;
    PreviousCompressionLevel := CompressionLevel;
    NaturalCount := 0;
    elem := DLF^.next;
    while elem <> DLL do
    begin
      if elem^.ID <= k then
        NaturalCount := NaturalCount + elem^.ID * elem^.count;
      elem := elem^.next;
    end;
    AddID(NaturalCount);
    entropy := GetEntropy(NBase, NFilm, k);
    DelID(NaturalCount);
    CompressionLevel := CompLevel(NBase, NFilm, NaturalCount, entropy);
    writeln(k, ' ', NFilm, ' ', NBase, ' ', entropy:5:4, ' ', NaturalCount / NFilm:5:4, ' ', CompressionLevel:5:4, ' ', (PreviousCompressionLevel - CompressionLevel):5:4);
    readln;
  end;
  NaturalCount := k;
  CompressLevel := PreviousCompressionLevel;
end;

procedure WriteBaseInfo;
var
  F: TextFile;
  elem: TPElem;
  entropy, codeLength: double;
  NBase, NFilm, k: int64;
begin
  entropy := GetEntropy(NBase, NFilm, 0);
  codeLength := entropy;
  AssignFile(F, Paramstr(1) + '.txt');
  rewrite(F);
  writeln(F, 'Кадр                                   ', UGlobal.PicH, 'x', UGlobal.PicW);
  writeln(F, 'Окно                                   ', UGlobal.FragH, 'x', UGlobal.FragW);
  writeln(F, 'Бит на пиксел                          ', UGlobal.bpp);
  writeln(F, 'Количество элементов в передаче        ', NFilm, ' (', floattostrf(NFilm * UGlobal.FragSize / (UGlobal.PicW * UGlobal.PicH), ffFixed, 8, 2), ' кадров)');
  writeln(F, 'Количество уникальных элементов в базе ', NBase);
  writeln(F, 'Энтропия базы                          ', floattostrf(entropy, ffFixed, 3, 5));
  writeln(F, 'Средняя длина кода                     ', floattostrf(codeLength, ffFixed, 3, 5));
  writeln(F, 'Ожидаемая степень сжатия               ', floattostrf(CompLevel(NBase, NFilm, 0, entropy), ffFixed, 3, 5));
  FindOptNatural(k, entropy);
  writeln(F, 'Ожидаемая степень сжатия               ', k, ' ', floattostrf(entropy, ffFixed, 3, 5));
  elem := DLF^.next;
  while elem <> DLL do
  begin
    writeln(F, elem^.ID, ' ', elem^.count);
    elem := elem^.next;
  end;
  CloseFile(F);
end;

begin
  try
    CreateList;
    writeln('Данные считаны. Вычисление энтропии...');
    WriteBaseInfo;
  except
    on E: Exception do
      writeln(E.ClassName, ': ', E.Message);
  end;

end.
