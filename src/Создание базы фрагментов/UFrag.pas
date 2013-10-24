unit UFrag;

interface

uses
  UGlobal;

type
  TFrag = array [1 .. UGlobal.FragSize] of byte;

  // TCFrag = array [1..UGlobal.FragCSize] of byte;
  TRFrag = record
    frag: TFrag;
    count: int64;
  end;

function CompareFrag(f1, f2: TFrag): byte;
function FragToString(f: TFrag): string;

implementation

function CompareFrag(f1, f2: TFrag): byte;
var
  i: byte;
  r: byte;
begin
  r := 1;
  i := 1;
  while (f1[i] = f2[i]) and (i < UGlobal.FragSize) do
    i := i + 1;
  if f1[i] < f2[i] then
    r := 0;
  if f1[i] = f2[i] then
    r := 1;
  if f1[i] > f2[i] then
    r := 2;
  result := r;
end;

function Dec2Bin(DEC: LONGINT): string;
var
  BIN: string;
  i, j: LONGINT;
begin
  if DEC = 0 then
    BIN := '0'
  else
  begin
    BIN := '';
    i := 0;
    while (1 shl (i + 1)) <= DEC do
      i := i + 1;
    for j := 0 to i do
    begin
      if (DEC shr (i - j)) = 1 then
        BIN := BIN + '1'
      else
        BIN := BIN + '0';
      DEC := DEC and ((1 shl (i - j)) - 1);
    end;
  end;
  while length(BIN) < bpp do
    BIN := '0' + BIN;

  Dec2Bin := BIN;
end;

function FragToString(f: TFrag): string;
var
  i, j: byte;
  tmp, r: string;
begin
  r := '';
  for i := 1 to UGlobal.FragSize do
  begin
    tmp := Dec2Bin(f[i]);
    for j := 1 to length(tmp) do
      r := r + tmp[j];
  end;
  result := r;
end;

end.
