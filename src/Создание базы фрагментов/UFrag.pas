unit UFrag;

interface

uses
  UGlobal;

type
  TFrag = array [1..UGlobal.FragSize] of byte;
  //TCFrag = array [1..UGlobal.FragCSize] of byte;
  TRFrag = record
    frag: TFrag;
    count: LongWord;
  end;

function CompareFrag(f1,f2: TFrag): byte;
function FragToString(f: TFrag): string;

implementation

function CompareFrag(f1,f2: TFrag): byte;
var
i: byte;
r: byte;
begin
  r:=1;
  i:=1;
  while (f1[i]=f2[i]) and (i<UGlobal.FragSize) do
    i:=i+1;
  if f1[i]<f2[i] then
    r:=0;
  if f1[i]=f2[i] then
    r:=1;
  if f1[i]>f2[i] then
    r:=2;
  result:=r;
end;

function Dec2Bin(DEC: LONGINT): string;
var
  BIN: string;
  I, J: LONGINT;
begin
  if DEC = 0 then
    BIN := '0'
  else
  begin
    BIN := '';
    I := 0;
    while (1 shl (I + 1)) <= DEC do
      I := I + 1;
    for J := 0 to I do
    begin
      if (DEC shr (I - J)) = 1 then
        BIN := BIN + '1'
      else
        BIN := BIN + '0';
      DEC := DEC and ((1 shl (I - J)) - 1);
    end;
  end;
  while length(BIN)<4 do
    BIN:='0'+BIN;

  DEC2BIN := BIN;
end;

function FragToString(f: TFrag): string;
var
i,j: byte;
tmp,r: string;
begin
  r:='';
  for i:=1 to UGlobal.FragSize do
  begin
    tmp:=Dec2Bin(f[i]);
    for j:=1 to length(tmp) do
      r:=r+tmp[j];
  end;
  Result:=r;
end;

end.
