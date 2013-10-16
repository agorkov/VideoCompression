unit UMerge;

interface

function Merge(f1n,f2n,fbn: string; EraseFiles: boolean): int64;

implementation

uses
  UGlobal;

type
  TRFrag = record
    frag: string[UGlobal.FragSize*bpp];
    q: Int64;
  end;

var
f1,f2,fb: TextFile;
fl1,fl2: boolean;
frag1,frag2,frag: TRFrag;
c1,c2,cb,uniq: Int64;

procedure ReadFragment(var _file: TextFile; var F: TRFrag; var Count: int64);
begin
  read(_file,F.frag);
  readln(_file,F.q);
  Count:=Count+F.q;
end;

procedure CreateFragment(var Frag1,Frag2,F: TRFrag; var fl1,fl2: boolean);
begin
  F.frag:=''; F.q:=0;
  if Frag1.frag<Frag2.frag then
  begin
    F.frag:=Frag1.frag;
    F.q:=Frag1.q;
    fl1:=true;
    fl2:=false;
  end;
  if Frag1.frag=Frag2.frag then
  begin
    F.frag:=Frag1.frag;
    F.q:=Frag1.q+Frag2.q;
    fl1:=true;
    fl2:=true;
  end;
  if Frag1.frag>Frag2.frag then
  begin
    F.frag:=Frag2.frag;
    F.q:=Frag2.q;
    fl1:=false;
    fl2:=true;
  end;
  if F.frag=frag1.frag then
  begin
    frag1.frag:='z';
    frag1.q:=0;
  end;
  if F.frag=frag2.frag then
  begin
    frag2.frag:='z';
    frag2.q:=0;
  end;
end;

procedure WriteFragment(F: TRFrag; var Count: int64);
begin
  writeln(fb,F.frag,' ',F.q);
  Count:=Count+F.q;
  uniq:=uniq+1;
end;

function Merge(f1n,f2n,fbn: string; EraseFiles: boolean): int64;
begin
  c1:=0; c2:=0; cb:=0; uniq:=0;

  Assign(f1,f1n); reset(f1);
  Assign(f2,f2n); reset(f2);
  Assign(fb,fbn); rewrite(fb);

  fl1:=true; fl2:=true;
  while (not EOF(f1)) or (not EOF(f2)) do
  begin
    if fl1 then
      ReadFragment(f1,frag1,c1);
    if fl2 then
      ReadFragment(f2,frag2,c2);
    CreateFragment(frag1,frag2,frag,fl1,fl2);
    WriteFragment(frag,cb);
    if EOF(f1) then
      fl1:=false;
    if EOF(f2) then
      fl2:=false;
  end;

  CreateFragment(frag1,frag2,frag,fl1,fl2);
  if frag.frag<>'z' then
    WriteFragment(frag,cb);
  CreateFragment(frag1,frag2,frag,fl1,fl2);
  if frag.frag<>'z' then
    WriteFragment(frag,cb);

  CloseFile(f1);
  CloseFile(f2);
  CloseFile(fb);

  if (cb=(c1+c2)) and (EraseFiles) then
  begin
    Erase(f1);
    Erase(f2);
  end;

  Merge:=uniq;
end;

end.
