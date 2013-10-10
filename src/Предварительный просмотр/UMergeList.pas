unit UMergeList;

interface

procedure AddPartBase(FragCount: int64);
procedure MergePartBaseList;

implementation
uses
  USettings, UMerge, SysUtils, Windows;

type
  TRPartBase = record
    PartBaseNum: word;
    FragCount: int64;
  end;

  TARPartBaseList = array [1..10000] of TRPartBase;

var
PBList: TARPartBaseList;
PartBaseCount: word;

procedure AddPartBase(FragCount: int64);
begin
  PartBaseCount:=PartBaseCount+1;
  PBList[PartBaseCount].PartBaseNum:=PartBaseCount;
  PBList[PartBaseCount].FragCount:=FragCount;
end;

procedure MergePartBaseList;
  procedure SortList;
  var
  i,can: word;
  tmp: TRPartBase;
  begin
    for i:=1 to PartBaseCount-1 do
      for can:=i+1 to PartBaseCount do
        if PBList[i].FragCount<PBList[can].FragCount then
        begin
          tmp:=PBList[i];
          PBList[i]:=PBList[can];
          PBList[can]:=tmp;
        end;
  end;
var
b1n,b2n,brn: string;
newnum: word;
begin
  newnum:=PartBaseCount+1;
  while PartBaseCount>1 do
  begin
    SortList;
    b1n:=USettings.FileName+'_'+inttostr(PBList[PartBaseCount-1].PartBaseNum)+'.base';
    b2n:=USettings.FileName+'_'+inttostr(PBList[PartBaseCount].PartBaseNum)+'.base';
    brn:=USettings.FileName+'_'+inttostr(newnum)+'.base';
    PBList[PartBaseCount].PartBaseNum:=0;
    PBList[PartBaseCount].FragCount:=0;
    PBList[PartBaseCount-1].PartBaseNum:=newnum;
    PBList[PartBaseCount-1].FragCount:=UMerge.Merge(b1n,b2n,brn,true);
    PartBaseCount:=PartBaseCount-1;
    newnum:=newnum+1;
  end;
  RenameFile(USettings.FileName+'_'+inttostr(PBList[1].PartBaseNum)+'.base',USettings.FileName+'.base')
end;

initialization
  PartBaseCount:=0;

end.
