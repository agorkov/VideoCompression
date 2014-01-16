unit UStatList;

interface

type
  TPStatElem = ^TRStatElem;

  TRStatElem = record
    ID, count: int64;
    next, prev: TPStatElem;
  end;

  TRList = record
    DLF, DLL: TPStatElem;
  end;

procedure AddID(ID: int64);
procedure WriteBaseInfo(FileName: string);

implementation

uses
  Math, UGlobal;

var
  L: TRList;

procedure AddID(ID: int64);
  procedure InsertBefore(var elem: TPStatElem; newID: int64);

  var
    NewElem, tmp: TPStatElem;
  begin
    New(NewElem);
    NewElem^.ID := newID;
    NewElem^.count := 1;
    tmp := elem^.prev;
    tmp^.next := NewElem;
    NewElem^.next := elem;
    elem^.prev := NewElem;
    NewElem^.prev := tmp;
  end;

var
  elem: TPStatElem;
begin
  elem := L.DLF^.next;
  while (elem <> L.DLL) and (elem^.ID < ID) do
    elem := elem^.next;
  if elem^.ID = ID then
    elem^.count := elem^.count + 1
  else
    InsertBefore(elem, ID);
end;

function GetNFilm(): int64;
var
  NFilm: int64;
  elem: TPStatElem;
begin
  NFilm := 0;
  elem := L.DLF^.next;
  while elem <> L.DLL do
  begin
    NFilm := NFilm + elem^.ID * elem^.count;
    elem := elem^.next;
  end;
  GetNFilm := NFilm;
end;

function GetNBase(): int64;
var
  NBase: int64;
  elem: TPStatElem;
begin
  NBase := 0;
  elem := L.DLF^.next;
  while elem <> L.DLL do
  begin
    NBase := NBase + elem^.count;
    elem := elem^.next;
  end;
  GetNBase := NBase;
end;

function GetEntropy(): double;
var
  elem: TPStatElem;
  P_i, Ent: double;
  NFilm: int64;
begin
  elem := L.DLF^.next;
  Ent := 0;
  NFilm := GetNFilm();
  while elem <> L.DLL do
  begin
    P_i := elem^.ID / NFilm;
    Ent := Ent - P_i * log2(P_i) * elem^.count;
    elem := elem^.next;
  end;
  GetEntropy := Ent;
end;

function CompLevel(): double;
var
  Entropy: double;
  NBase, NFilm: int64;
  ElemBitLength: word;
begin
  NBase := GetNBase();
  NFilm := GetNFilm();
  Entropy := GetEntropy();
  ElemBitLength := UGlobal.ElemSize * UGlobal.bpp;
{$IF UGlobal.BaseType=btFrag}
  CompLevel := (NBase * (ElemBitLength + 2)) / (NFilm * ElemBitLength) + Entropy / ElemBitLength;
{$IFEND}
{$IF UGlobal.BaseType=btLDiff}
  CompLevel := (NBase * (ElemBitLength + 2)) / (NFilm * ElemBitLength) + Entropy / ElemBitLength;
{$IFEND}
{$IF UGlobal.BaseType=btMDiff}
  CompLevel := (NBase * (ElemBitLength + 2 + UGlobal.ElemSize)) / (NFilm * ElemBitLength) + Entropy / ElemBitLength;
{$IFEND}
end;

procedure InitList;
begin
  New(L.DLF);
  New(L.DLL);
  L.DLF^.ID := round(power(2, 32) - 1);
  L.DLF^.count := 0;
  L.DLF^.prev := nil;
  L.DLF^.next := L.DLL;
  L.DLL^.ID := round(power(2, 32) - 1);
  L.DLL^.count := 0;
  L.DLL^.prev := L.DLF;
  L.DLL^.next := nil;
end;

procedure EmptyList();
  procedure DeleteElem(var elem: TPStatElem);
  var
    before, after: TPStatElem;
  begin
    before := elem^.prev;
    after := elem^.next;
    before^.next := after;
    after^.prev := before;
    Dispose(elem);
  end;

begin
  while L.DLF^.next^.next <> L.DLL do
    DeleteElem(L.DLF^.next);
end;

procedure WriteBaseInfo(FileName: string);
var
  F: TextFile;
  elem: TPStatElem;
begin
  AssignFile(F, FileName);
  rewrite(F);
  writeln(F, 'Кадр                                   ', UGlobal.PicH, 'x', UGlobal.PicW);
  writeln(F, 'Окно                                   ', UGlobal.ElemH, 'x', UGlobal.ElemW);
  writeln(F, 'Бит на пиксел                          ', UGlobal.bpp);
  writeln(F, 'Количество элементов в передаче        ', GetNFilm(), ' (', GetNFilm() * UGlobal.ElemSize / (UGlobal.PicW * UGlobal.PicH):5:4, ' кадров)');
  writeln(F, 'Количество уникальных элементов в базе ', GetNBase());
  writeln(F, 'Энтропия базы                          ', GetEntropy():5:4);
  writeln(F, 'Ожидаемая степень сжатия               ', CompLevel():5:4);

  elem := L.DLF^.next;
  while elem <> L.DLL do
  begin
    writeln(F, elem^.ID, ' ', elem^.count);
    elem := elem^.next;
  end;
  CloseFile(F);
end;

initialization

InitList;

finalization

EmptyList;

end.
