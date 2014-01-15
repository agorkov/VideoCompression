unit UMerge;

interface

function Merge(f1n, f2n, fbn: shortstring; EraseFiles: boolean): int64;
function GetRandomName(len: byte): shortstring;

implementation

uses
  UGlobal, Classes, System.SysUtils, UElem;

var
  f1, f2, fb: TFileStream;
  fl1, fl2: boolean;
  frag1, frag2, frag: TRElem;
  c1, c2, cb, uniq: int64;

procedure ReadFragment(var _FS: TFileStream; var F: TRElem; var Count: int64);
begin
  _FS.Read(F, sizeof(TRElem));
  Count := Count + F.Count;
end;

procedure CreateFragment(var frag1, frag2, F: TRElem; var fl1, fl2: boolean);
begin
  if UElem.CompareElem(frag1.elem, frag2.elem) = 0 then
  begin
    F.elem := frag1.elem;
    F.Count := frag1.Count;
    fl1 := true;
    fl2 := false;
  end;
  if UElem.CompareElem(frag1.elem, frag2.elem) = 1 then
  begin
    F.elem := frag1.elem;
    F.Count := frag1.Count + frag2.Count;
    fl1 := true;
    fl2 := true;
  end;
  if UElem.CompareElem(frag1.elem, frag2.elem) = 2 then
  begin
    F.elem := frag2.elem;
    F.Count := frag2.Count;
    fl1 := false;
    fl2 := true;
  end;
  if UElem.CompareElem(F.elem, frag1.elem) = 1 then
    frag1.Count := 0;
  if UElem.CompareElem(F.elem, frag2.elem) = 1 then
    frag2.Count := 0;
end;

procedure WriteFragment(F: TRElem; var Count: int64);
begin
  fb.Write(F, sizeof(TRElem));
  Count := Count + F.Count;
  uniq := uniq + 1;
end;

function Merge(f1n, f2n, fbn: shortstring; EraseFiles: boolean): int64;
begin
  c1 := 0;
  c2 := 0;
  cb := 0;
  uniq := 0;

  f1 := TFileStream.Create(string(f1n) + '.base', fmOpenRead);
  f2 := TFileStream.Create(string(f2n) + '.base', fmOpenRead);
  fb := TFileStream.Create(string(fbn) + '.base', fmCreate);

  fl1 := true;
  fl2 := true;
  while (not(f1.Position >= f1.Size)) and (not(f2.Position >= f2.Size)) do
  begin
    if fl1 then
      ReadFragment(f1, frag1, c1);
    if fl2 then
      ReadFragment(f2, frag2, c2);
    CreateFragment(frag1, frag2, frag, fl1, fl2);
    WriteFragment(frag, cb);
    if f1.Position >= f1.Size then
      fl1 := false;
    if f2.Position >= f2.Size then
      fl2 := false;
  end;

  if (frag1.Count > 0) and (frag2.Count > 0)then
  begin
    CreateFragment(frag1,frag2,frag,fl1,fl2);
    WriteFragment(frag,cb);
  end;
  if frag1.Count > 0 then
    WriteFragment(frag1, cb);
  if frag2.Count > 0 then
    WriteFragment(frag2, cb);

  while not(f1.Position >= f1.Size) do
  begin
    ReadFragment(f1, frag1, c1);
    WriteFragment(frag1, cb);
  end;
  while not(f2.Position >= f2.Size) do
  begin
    ReadFragment(f2, frag2, c2);
    WriteFragment(frag2, cb);
  end;

  f1.Free;
  f2.Free;
  fb.Free;

  if (cb = (c1 + c2)) and (EraseFiles) then
  begin
    DeleteFile(string(f1n + '.base'));
    DeleteFile(string(f2n + '.base'));
  end;

  Merge := uniq;
end;

function GetRandomName(len: byte): shortstring;
var
  i: byte;
  R: shortstring;
begin
  Randomize;
  R := '';
  for i := 1 to len do
    R := R + shortstring(chr(65 + random(26)));
  GetRandomName := R;
end;

end.
