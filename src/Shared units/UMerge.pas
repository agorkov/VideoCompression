unit UMerge;

interface

function Merge(f1n, f2n, fbn: shortstring; EraseFiles: boolean): int64;

implementation

uses
  UGlobal, Classes, System.SysUtils, UFrag;

var
  f1, f2, fb: TFileStream;
  fl1, fl2: boolean;
  frag1, frag2, frag: TRFrag;
  c1, c2, cb, uniq: int64;

procedure ReadFragment(var _FS: TFileStream; var F: TRFrag; var Count: int64);
begin
  _FS.Read(F, sizeof(TRFrag));
  Count := Count + F.Count;
end;

procedure CreateFragment(var frag1, frag2, F: TRFrag; var fl1, fl2: boolean);
begin
  if UFrag.CompareFrag(frag1.frag, frag2.frag) = 0 then
  begin
    F.frag := frag1.frag;
    F.Count := frag1.Count;
    fl1 := true;
    fl2 := false;
  end;
  if UFrag.CompareFrag(frag1.frag, frag2.frag) = 1 then
  begin
    F.frag := frag1.frag;
    F.Count := frag1.Count + frag2.Count;
    fl1 := true;
    fl2 := true;
  end;
  if UFrag.CompareFrag(frag1.frag, frag2.frag) = 2 then
  begin
    F.frag := frag2.frag;
    F.Count := frag2.Count;
    fl1 := false;
    fl2 := true;
  end;
  if UFrag.CompareFrag(F.frag, frag1.frag) = 1 then
    frag1.Count := 0;
  if UFrag.CompareFrag(F.frag, frag2.frag) = 1 then
    frag2.Count := 0;
end;

procedure WriteFragment(F: TRFrag; var Count: int64);
begin
  fb.Write(F, sizeof(TRFrag));
  Count := Count + F.Count;
  uniq := uniq + 1;
end;

function Merge(f1n, f2n, fbn: shortstring; EraseFiles: boolean): int64;
begin
  c1 := 0;
  c2 := 0;
  cb := 0;
  uniq := 0;

  f1 := TFileStream.Create(string(f1n)+'.base', fmOpenRead);
  f2 := TFileStream.Create(string(f2n)+'.base', fmOpenRead);
  fb := TFileStream.Create(string(fbn)+'.base', fmCreate);

  fl1 := true;
  fl2 := true;
  while (not(f1.Position >= f1.Size)) or (not(f2.Position >= f2.Size)) do
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

  CreateFragment(frag1, frag2, frag, fl1, fl2);
  if frag.Count <> 0 then
    WriteFragment(frag, cb);
  CreateFragment(frag1, frag2, frag, fl1, fl2);
  if frag.Count <> 0 then
    WriteFragment(frag, cb);

  f1.Free;
  f2.Free;
  fb.Free;

  if (cb = (c1 + c2)) and (EraseFiles) then
  begin
    DeleteFile(f1n+'.base');
    DeleteFile(f2n+'.base');
  end;

  Merge := uniq;
end;

end.
