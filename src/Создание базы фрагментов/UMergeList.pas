unit UMergeList;

interface

procedure AddPartBase(FileName: shortString; FragCount: int64);
procedure MergePartBaseList;

implementation

uses
  USettings, UMerge, SysUtils, Windows;

type
  TRPartBase = record
    PartBaseName: shortString;
    FragCount: int64;
  end;

  TARPartBaseList = array [1 .. 10000] of TRPartBase;

var
  PBList: TARPartBaseList;
  PartBaseCount: word;

procedure AddPartBase(FileName: shortString; FragCount: int64);
begin
  PartBaseCount := PartBaseCount + 1;
  PBList[PartBaseCount].PartBaseName := FileName;
  PBList[PartBaseCount].FragCount := FragCount;
end;

procedure MergePartBaseList;
  procedure SortList;
  var
    i, can: word;
    tmp: TRPartBase;
  begin
    for i := 1 to PartBaseCount - 1 do
      for can := i + 1 to PartBaseCount do
        if PBList[i].FragCount < PBList[can].FragCount then
        begin
          tmp := PBList[i];
          PBList[i] := PBList[can];
          PBList[can] := tmp;
        end;
  end;

var
  b1n, b2n, brn: shortString;
begin
  while PartBaseCount > 1 do
  begin
    SortList;
    b1n := PBList[PartBaseCount - 1].PartBaseName;
    b2n := PBList[PartBaseCount].PartBaseName;
    brn := USettings.FileName + '_' + GetRandomName(10);
    PBList[PartBaseCount].PartBaseName := '';
    PBList[PartBaseCount].FragCount := 0;
    PBList[PartBaseCount - 1].PartBaseName := brn;
    PBList[PartBaseCount - 1].FragCount := UMerge.Merge(b1n, b2n, brn, true);
    PartBaseCount := PartBaseCount - 1;
  end;
  RenameFile(string(PBList[1].PartBaseName + '.base'), string(USettings.FileName + '.base'))
end;

initialization

PartBaseCount := 0;

end.
