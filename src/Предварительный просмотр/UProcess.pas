unit UProcess;

interface
uses
  Vcl.Graphics;

var
  BM, BMR: TBitMap;

procedure ProcessFrame;

implementation

uses
  UGlobal, USettings, UFrag, UMergeList, SysUtils, Windows, UFMain;

const
  FilterBase = 1;

type
  TFrame = array [1..UGlobal.PicH,1..UGlobal.PicW] of byte;

var
FR, FRO, FG, FGO, FB, FBO: TFrame;
FrameNum: LongWord;

procedure Init(var Frame,FrameOld: TFrame);
var
i,j: LongWord;
begin
  for i:=1 to UGlobal.PicH do
    for j:=1 to UGlobal.PicW do
    begin
      Frame[i,j]:=0;
      FrameOld[i,j]:=0;
    end;
end;

procedure CopyFrame(var Frame,FrameOld: TFrame);
var
i,j: LongWord;
begin
  for i:=1 to UGlobal.PicH do
    for j:=1 to UGlobal.PicW do
      FrameOld[i,j]:=Frame[i,j];
end;

procedure CreateFrame(var Frame: TFrame);
var
i,j: LongWord;
r,g,b,val: byte;
p: pByteArray;
begin
  for i:=0 to UGlobal.PicH-1 do
  begin
    p:=BM.ScanLine[i];
    for j:=0 to UGlobal.PicW-1 do
    begin
      b:=p[3*j];
      g:=p[3*j+1];
      r:=p[3*j+2];

      case USettings.BaseColor of
        red: val:=r;
        green: val:=g;
        blue: val:=b;
        grayscale: val:=round(0.30*r+0.59*g+0.11*b);
        else val:=0;
      end;

      if val>150 then
        Frame[i+1,j+1]:=15
      else
        Frame[i+1,j+1]:=val div 10;
    end;
  end;
end;

procedure ShowResultFrame;
var
i,j: LongWord;
pr: pByteArray;
r,g,b: byte;
begin
  for i:=0 to UGlobal.PicH-1 do
  begin
    pr:=BMR.ScanLine[i];
    for j:=0 to UGlobal.PicW-1 do
    begin
      if FR[i+1,j+1]<15 then
        r:=5+FR[i+1,j+1]*10
      else
        r:=170;

      if FG[i+1,j+1]<15 then
        g:=5+FG[i+1,j+1]*10
      else
        g:=170;

      if FB[i+1,j+1]<15 then
        b:=5+FB[i+1,j+1]*10
      else
        b:=170;

      pr[3*j]:=b;
      pr[3*j+1]:=g;
      pr[3*j+2]:=r;
    end;
  end;
  UFMain.FMain.Image1.Picture.Bitmap:=BMR;
  if UFMain.FMain.CBSaveResults.Checked then
    UFMain.FMain.Image1.Picture.SaveToFile(inttostr(FrameNum)+'.bmp');
end;

procedure MedianFilter(var Frame: TFrame);
var
tmpArr: array [1..9] of byte;
i,j: integer;
k,l,m: byte;
FrameTmp: array [1..UGlobal.PicH,1..UGlobal.PicW] of byte;
begin
  for i:=1 to PicH do
    for j:=1 to PicW do
      FrameTmp[i,j]:=Frame[i,j];

  for i:=FilterBase to UGlobal.PicH-FilterBase do
  begin
    for j:=FilterBase to UGlobal.PicW-FilterBase do
    begin
      tmpArr[1]:=FrameTmp[i-1,j-1];
      tmpArr[2]:=FrameTmp[i-1,j];
      tmpArr[3]:=FrameTmp[i-1,j+1];
      tmpArr[4]:=FrameTmp[i,j-1];
      tmpArr[5]:=FrameTmp[i,j];
      tmpArr[6]:=FrameTmp[i,j+1];
      tmpArr[7]:=FrameTmp[i+1,j-1];
      tmpArr[8]:=FrameTmp[i+1,j];
      tmpArr[9]:=FrameTmp[i+1,j+1];
      for k:=1 to 8 do
        for l:=k+1 to 9 do
          if tmpArr[k]>tmpArr[l] then
          begin
            m:=tmpArr[k];
            tmpArr[k]:=tmpArr[l];
            tmpArr[l]:=m;
          end;
      Frame[i,j]:=tmpArr[5];
    end;
  end;
end;

procedure WindowFilter(var Frame, FrameOld: TFrame);
var
i,j,r,c: word;
count: word;
begin
  i:=1;
  j:=1;
  while i<PicH-FragH do
  begin
    while j<PicW-FragW do
    begin
      count:=0;
      for r:=i to i+(FragH-1) do
        for c:=j to j+(FragW-1) do
          if Frame[r,c]<>FrameOld[r,c] then
            count:=count+1;

      if count<FilterThresold then
        for r:=i to i+(FragH-1) do
          for c:=j to j+(FragW-1) do
            Frame[r,c]:=FrameOld[r,c];

      j:=j+UGlobal.FragW;
    end;
    i:=i+UGlobal.FragH;
    j:=1;
  end;
end;

procedure ProcessFrame;
begin
  CopyFrame(FR,FRO);
  CopyFrame(FG,FGO);
  CopyFrame(FB,FBO);

  BaseColor:=red;
  CreateFrame(FR);
  BaseColor:=green;
  CreateFrame(FG);
  BaseColor:=blue;
  CreateFrame(FB);

  if USettings.NeedWindowFilter then
  begin
    WindowFilter(FR,FRO);
    WindowFilter(FG,FGO);
    WindowFilter(FB,FBO);
  end;
  if USettings.NeedMedianFilter then
  begin
    MedianFilter(FR);
    MedianFilter(FG);
    MedianFilter(FB);
  end;

  ShowResultFrame;

  FrameNum:=FrameNum+1;
end;

initialization
  FrameNum:=0;
  BM:=Vcl.Graphics.TBitmap.Create;
  BM.Width:=UGlobal.PicW;
  BM.Height:=UGlobal.PicH;
  BM.PixelFormat:=pf24bit;

  BMR:=Vcl.Graphics.TBitmap.Create;
  BMR.Width:=UGlobal.PicW;
  BMR.Height:=UGlobal.PicH;
  BMR.PixelFormat:=pf24bit;

  Init(FR,FRO);
  Init(FG,FGO);
  Init(FB,FBO);
finalization
  BM.Free;
  BMR.Free;
end.
