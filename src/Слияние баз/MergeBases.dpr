program MergeBases;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  UGlobal in '..\Shared units\UGlobal.pas',
  UMerge in '..\Shared units\UMerge.pas',
  UFrag in '..\Shared units\UFrag.pas';

type
  TBase = record
    BaseName: string;
    Uniq: int64;
  end;
  TBaseList = array [1..10000] of TBase;

function GetUniqCount(BaseName: string): int64;
var
f: TextFile;
Uniq: int64;
begin
  Uniq:=0;
  AssignFile(f,BaseName);
  reset(f);
    while not EOF(f) do
    begin
      readln(f);
      Uniq:=Uniq+1;
    end;
  CloseFile(f);
  GetUniqCount:=Uniq;
end;

procedure Sort(var BL:TBaseList; BC: word);
var
i,can: word;
tmp: TBase;
begin
  for i:=1 to BC-1 do
    for can:=i+1 to BC do
      if BL[i].Uniq<BL[can].Uniq then
      begin
        tmp:=BL[i];
        BL[i]:=BL[can];
        BL[can]:=tmp;
      end;
end;

const
  MergePrefix = 'mergetemp';

var
BL: TBaseList;
BC: word;
i: word;
tmpname: string;
begin
  try
    BC:=ParamCount-1;
    if BC>1 then
    begin
      for i:=1 to BC do
      begin
        writeln('Загрузка информации о базе: ',paramstr(i));
        BL[i].BaseName:=ParamStr(i);
        BL[i].Uniq:=GetUniqCount(ParamStr(i));
        writeln(BL[i].BaseName,' ',BL[i].Uniq);
      end;
    end;

    i:=0;
    while BC>1 do
    begin
      i:=i+1;
      tmpname:=MergePrefix+inttostr(i)+'.base';
      Sort(BL,BC);
      writeln('Начат процесс слияния: ',BL[BC-1].BaseName,' (',BL[BC-1].Uniq,') и ',BL[BC].BaseName,' (',BL[BC].Uniq,')');
      BL[BC-1].Uniq:=UMerge.Merge(BL[BC-1].BaseName,BL[BC].BaseName,tmpname,false);
      BL[BC-1].BaseName:=tmpName;
      writeln(BL[BC-1].BaseName,' ',BL[BC-1].Uniq);
      BL[BC].BaseName:=''; BL[BC].Uniq:=0; BC:=BC-1;
    end;
    RenameFile(BL[1].BaseName,ParamStr(ParamCount));
    for i:=1 to ParamCount do
      if FileExists(MergePrefix+inttostr(i)+'.base') then
        DeleteFile(MergePrefix+inttostr(i)+'.base');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
