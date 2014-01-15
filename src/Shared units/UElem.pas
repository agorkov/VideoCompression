unit UElem;

interface

uses
  UGlobal;

type
  TElem = array [1 .. UGlobal.ElemSize] of integer;

  TPRElem = ^TRElem;

  TRElem = record
    elem: TElem;
    count: int64;
  end;

function CompareElem(f1, f2: TElem): byte;

implementation

function CompareElem(f1, f2: TElem): byte;
var
  i: byte;
  r: byte;
begin
  r := 1;
  i := 1;
  while (f1[i] = f2[i]) and (i < UGlobal.ElemSize) do
    i := i + 1;
  if f1[i] < f2[i] then
    r := 0;
  if f1[i] = f2[i] then
    r := 1;
  if f1[i] > f2[i] then
    r := 2;
  result := r;
end;

end.
