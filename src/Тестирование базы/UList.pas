unit UList;

interface

type
  TPElem = ^TRElem;

  TRElem = record
    ID, count: int64;
    next, prev: TPElem;
  end;

  TRList = record
    DLF, DLL: TPElem;
  end;

procedure InitList(var L: TRList);
procedure AddID(var L: TRList; ID, count: int64);
function GetEntropy(L: TRList): double;
function FingOptimalGlueInd(InList: TRList): int64;
function CompLevel(L: TRList; GlueCount: int64): double;
function GetNBase(L: TRList): int64;
function GetNFilm(L: TRList): int64;
function FingGlueCompLevel(InList: TRList; GlueID: int64): double;
function GetIDbyInd(L: TRList; ind: int64): int64;

implementation

uses
  Math, UGlobal;

procedure InitList(var L: TRList);
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

procedure InsertBefore(var elem: TPElem; newID, newCount: int64);

var
  NewElem, tmp: TPElem;
begin
  New(NewElem);
  NewElem^.ID := newID;
  NewElem^.count := newCount;
  tmp := elem^.prev;
  tmp^.next := NewElem;
  NewElem^.next := elem;
  elem^.prev := NewElem;
  NewElem^.prev := tmp;
end;

procedure AddID(var L: TRList; ID, count: int64);

var
  elem: TPElem;
begin
  elem := L.DLF^.next;
  while (elem <> L.DLL) and (elem^.ID < ID) do
    elem := elem^.next;
  if elem^.ID = ID then
    elem^.count := elem^.count + count
  else
    InsertBefore(elem, ID, count);
end;

procedure DeleteElem(var elem: TPElem);

var
  before, after: TPElem;
begin
  before := elem^.prev;
  after := elem^.next;
  before^.next := after;
  after^.prev := before;
  Dispose(elem);
end;

procedure EmptyList(var L: TRList);
begin
  while L.DLF^.next^.next <> L.DLL do
    DeleteElem(L.DLF^.next);
end;

procedure DecID(var L: TRList; ID: int64);

var
  elem: TPElem;
begin
  elem := L.DLF^.next;
  while (elem <> L.DLL) and (elem^.ID < ID) do
    elem := elem^.next;
  if elem^.ID = ID then
    elem^.count := elem^.count - 1;
  if elem^.count = 0 then
    DeleteElem(elem);
end;

function GetNFilm(L: TRList): int64;
var
  NFilm: int64;
  elem: TPElem;
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

function GetNBase(L: TRList): int64;
var
  NBase: int64;
  elem: TPElem;
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

function GetEntropy(L: TRList): double;
var
  elem: TPElem;
  P_i, Ent: double;
  NFilm: int64;
begin
  elem := L.DLF^.next;
  Ent := 0;
  NFilm := GetNFilm(L);
  while elem <> L.DLL do
  begin
    P_i := elem^.ID / NFilm;
    Ent := Ent - P_i * log2(P_i) * elem^.count;
    elem := elem^.next;
  end;
  GetEntropy := Ent;
end;

function GlueElem(InList: TRList; k: int64): TRList;
var
  OutList: TRList;
  elem: TPElem;
  GlueCount: int64;
begin
  InitList(OutList);
  GlueElem := OutList;
  GlueCount := 0;
  elem := InList.DLF^.next;
  while elem <> InList.DLL do
  begin
    if elem^.ID <= k then
      GlueCount := GlueCount + elem^.ID * elem^.count
    else
      AddID(OutList, elem^.ID, elem^.count);
    elem := elem^.next;
  end;
  AddID(OutList, GlueCount, 1);
  GlueElem := OutList;
end;

function CompLevel(L: TRList; GlueCount: int64): double;
var
  Entropy: double;
  NBase, NFilm: int64;
begin
  NBase := GetNBase(L);
  NFilm := GetNFilm(L);
  Entropy := GetEntropy(L);
  if Entropy < 1 then
    Entropy := Entropy + 1;
  CompLevel := NBase / NFilm * (UGlobal.ElemSize * UGlobal.bpp + 2) / (UGlobal.ElemSize * UGlobal.bpp) + Entropy / (UGlobal.ElemSize * UGlobal.bpp) + GlueCount / NFilm;
end;

function GetIDbyInd(L: TRList; ind: int64): int64;
var
  elem: TPElem;
begin
  elem := L.DLF;
  while ind > 0 do
  begin
    elem := elem^.next;
    ind := ind - 1;
  end;
  GetIDbyInd := elem^.ID;
end;

function GetGlueCount(L: TRList; maxInd: int64): int64;
var
  sum: int64;
  elem: TPElem;
begin
  sum := 0;
  elem := L.DLF^.next;
  while maxInd > 0 do
  begin
    sum := sum + elem^.ID * elem^.count;
    maxInd := maxInd - 1;
    elem := elem^.next;
  end;
  GetGlueCount := sum;
end;

function FingOptimalGlueInd(InList: TRList): int64;
var
  PreviousCompressionLevel, CompressionLevel: double;
  GlueID: int64;

  GlueCount: int64;
  k: int64;
  tmpList: TRList;
begin
  CompressionLevel := CompLevel(InList, 0);
  PreviousCompressionLevel := CompressionLevel;
  writeln(0, ' ', GetNFilm(InList), ' ', GetNBase(InList), ' ', GetEntropy(InList):5:4, ' ', 0, ' ', CompressionLevel:5:4);
  k := 0;
  while CompressionLevel <= PreviousCompressionLevel do
  begin
    k := k + 1;
    PreviousCompressionLevel := CompressionLevel;

    GlueID := GetIDbyInd(InList, k);
    GlueCount := GetGlueCount(InList, k);
    InitList(tmpList);
    tmpList := GlueElem(InList, GlueID);
    CompressionLevel := CompLevel(tmpList, GlueCount);
    writeln(GlueID, ' ', GetNFilm(tmpList), ' ', GetNBase(tmpList), ' ', GetEntropy(tmpList):5:4, ' ', GlueCount, ' ', CompressionLevel:5:4);
    EmptyList(tmpList);
  end;
  k := k - 1;
  if k <> 0 then
    k := GetIDbyInd(InList, k);
  FingOptimalGlueInd := k;
end;

function FingGlueCompLevel(InList: TRList; GlueID: int64): double;
var
  CompressionLevel: double;
  GlueCount: int64;
  tmpList: TRList;
begin
  GlueCount := GetGlueCount(InList, GlueID);
  InitList(tmpList);
  tmpList := GlueElem(InList, GlueID);
  CompressionLevel := CompLevel(tmpList, GlueCount);
  EmptyList(tmpList);
  FingGlueCompLevel := CompressionLevel;
end;

end.
