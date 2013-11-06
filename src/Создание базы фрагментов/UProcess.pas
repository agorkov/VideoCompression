unit UProcess;

interface

uses
  Vcl.Graphics;

var
  BM, BMR: TBitMap;
  FrameNum: LongWord;

procedure ProcessFrame;
procedure WriteBASE;
procedure SealGlobalBase;
function BaseFull: byte;

implementation

uses
  UGlobal, UFrag, UMergeList, SysUtils, Windows, UFMain, USettings;

const
  MAX_BASE_COUNT = 150000000;
  FilterBase = 1;

var
  Frame, FrameOld: array [1 .. UGlobal.PicH, 1 .. UGlobal.PicW] of byte;
  FrameBase: array [1 .. UGlobal.FrameBaseSize] of UFrag.TRFrag;
  BASE_COUNT: LongWord;
  GlobalBase: array [1 .. MAX_BASE_COUNT] of TPRFrag;

function BaseFull: byte;
begin
  BaseFull := round(BASE_COUNT / MAX_BASE_COUNT * 100);
end;

procedure SealGlobalBase;
  procedure QuickSort;
    procedure sort(L, R: LongWord);
    var
      w, x: UFrag.TRFrag;
      i, j: LongWord;
    begin
      i := L;
      j := R;
      x := GlobalBase[(L + R) div 2]^;
      repeat
        while UFrag.CompareFrag(GlobalBase[i]^.frag, x.frag) = 0 do
          i := i + 1;
        while UFrag.CompareFrag(x.frag, GlobalBase[j]^.frag) = 0 do
          j := j - 1;
        if i <= j then
        begin
          w := GlobalBase[i]^;
          GlobalBase[i]^ := GlobalBase[j]^;
          GlobalBase[j]^ := w;
          i := i + 1;
          j := j - 1;
        end;
      until i > j;
      if L < j then
        sort(L, j);
      if i < R then
        sort(i, R);
    end;

  begin
    sort(1, BASE_COUNT);
  end;

var
  i, k: LongWord;
begin
  QuickSort;

  k := 1;
  for i := 2 to BASE_COUNT do
  begin
    if UFrag.CompareFrag(GlobalBase[i]^.frag, GlobalBase[k]^.frag) = 1 then
      GlobalBase[k]^.count := GlobalBase[k]^.count + GlobalBase[i]^.count
    else
    begin
      k := k + 1;
      GlobalBase[k] := new(UFrag.TPRFrag);
      GlobalBase[k]^.frag := GlobalBase[i]^.frag;
      GlobalBase[k]^.count := GlobalBase[i]^.count;
    end;
    if i <> k then
    begin
      dispose(GlobalBase[i]);
      GlobalBase[i] := nil;
    end;
  end;
  BASE_COUNT := k;
end;

procedure WriteBASE;

var
  f: TextFile;
  i: LongWord;
  UniqCount: int64;
  FileName: shortstring;
begin
  FileName := USettings.FileName + '_' + GetRandomName + '.base';
  AssignFile(f, FileName);
  rewrite(f);
  UniqCount := 0;
  for i := 1 to BASE_COUNT do
  begin
    writeln(f, UFrag.FragToString(GlobalBase[i]^.frag), ' ', GlobalBase[i]^.count);
    UniqCount := UniqCount + 1;
  end;
  UMergeList.AddPartBase(FileName, UniqCount);
  CloseFile(f);

  for i := 1 to BASE_COUNT do
  begin
    dispose(GlobalBase[i]);
    GlobalBase[i] := nil;
  end;
  BASE_COUNT := 0;
end;

procedure Init;
var
  i, j: LongWord;
begin
  BASE_COUNT := 0;
  FilterThresold := 25;

  for i := 1 to MAX_BASE_COUNT do
  begin
    GlobalBase[i] := nil;
  end;

  for i := 1 to UGlobal.FrameBaseSize do
    FrameBase[i].count := 0;

  for i := 1 to UGlobal.PicH do
    for j := 1 to UGlobal.PicW do
    begin
      Frame[i, j] := 0;
      FrameOld[i, j] := 0;
    end;
end;

procedure CopyFrame;
var
  i, j: LongWord;
begin
  for i := 1 to UGlobal.PicH do
    for j := 1 to UGlobal.PicW do
      FrameOld[i, j] := Frame[i, j];
end;

function quantization(val: byte): byte;
begin
  quantization := val div UGlobal.quantizationStep;
end;

function dequantization(val: byte): byte;
begin
  dequantization := val * UGlobal.quantizationStep + UGlobal.quantizationStep div 2;
end;

procedure CreateFrame;
var
  i, j: LongWord;
  R, g, b, val: byte;
  p: pByteArray;
begin
  for i := 0 to UGlobal.PicH - 1 do
  begin
    p := BM.ScanLine[i];
    for j := 0 to UGlobal.PicW - 1 do
    begin
      b := p[3 * j];
      g := p[3 * j + 1];
      R := p[3 * j + 2];

      case USettings.BaseColor of
      USettings.RGB_R: val := R;
      USettings.RGB_G: val := g;
      USettings.RGB_B: val := b;
      USettings.YIQ_Y: val := round(0.299 * R + 0.587 * g + 0.114 * b);
      USettings.YIQ_I: val := round(0.596 * R + 0.274 * g + 0.321 * b);
      USettings.YIQ_Q: val := round(0.211 * R + 0.523 * g + 0.311 * b);
    else val := 0;
      end;

      Frame[i + 1, j + 1] := quantization(val);
    end;
  end;
end;

procedure ShowResultFrame;
var
  i, j: LongWord;
  pr: pByteArray;
  val: byte;
begin
  for i := 0 to UGlobal.PicH - 1 do
  begin
    pr := BMR.ScanLine[i];
    for j := 0 to UGlobal.PicW - 1 do
    begin
      pr[3 * j] := 0;
      pr[3 * j + 1] := 0;
      pr[3 * j + 2] := 0;
      val := dequantization(Frame[i + 1, j + 1]);

      pr[3 * j] := val;
      pr[3 * j + 1] := val;
      pr[3 * j + 2] := val;
    end;
  end;
  UFMain.FMain.Image1.Picture.Bitmap := BMR;
  if UFMain.FMain.CBSaveResults.Checked then
    UFMain.FMain.Image1.Picture.SaveToFile(inttostr(FrameNum) + '.bmp');
end;

procedure SaveFrame(FrameNum: LongWord);
var
  f: TextFile;
  i, j: LongWord;
begin
  AssignFile(f, inttostr(FrameNum) + '.txt');
  rewrite(f);
  for i := 1 to UGlobal.PicH do
  begin
    for j := 1 to UGlobal.PicW do
      write(f, Frame[i, j]);
    writeln(f);
  end;
  CloseFile(f);
end;

procedure SealLocalBase();
  procedure QuickSort;
    procedure sort(L, R: LongWord);
    var
      w, x: UFrag.TRFrag;
      i, j: LongWord;
    begin
      i := L;
      j := R;
      x := FrameBase[(L + R) div 2];
      repeat
        while UFrag.CompareFrag(FrameBase[i].frag, x.frag) = 0 do
          i := i + 1;
        while UFrag.CompareFrag(x.frag, FrameBase[j].frag) = 0 do
          j := j - 1;
        if i <= j then
        begin
          w := FrameBase[i];
          FrameBase[i] := FrameBase[j];
          FrameBase[j] := w;
          i := i + 1;
          j := j - 1;
        end;
      until i > j;
      if L < j then
        sort(L, j);
      if i < R then
        sort(i, R);
    end;

  begin
    sort(1, UGlobal.FrameBaseSize);
  end;

var
  i, k: LongWord;
begin
  QuickSort;
  k := 1;
  for i := 2 to UGlobal.FrameBaseSize do
  begin
    if UFrag.CompareFrag(FrameBase[i].frag, FrameBase[k].frag) = 1 then
      FrameBase[k].count := FrameBase[k].count + 1
    else
    begin
      k := k + 1;
      FrameBase[k].frag := FrameBase[i].frag;
      FrameBase[k].count := FrameBase[i].count;
    end;
    if i <> k then
      FrameBase[i].count := 0;
  end;
end;

procedure CreateLocalDiffBase;
var
  i, j, k, L, R, c, p: LongWord;
  str, strOld: UFrag.TFrag;
  frag, fragOld: UFrag.TFrag;
begin
  i := 1;
  j := 1;
  k := 1;
  while i <= UGlobal.PicH - (UGlobal.FragH - 1) do
  begin
    while j <= UGlobal.PicW - (UGlobal.FragW - 1) do
    begin
      p := 1;
      for R := i to i + (UGlobal.FragH - 1) do
        for c := j to j + (UGlobal.FragW - 1) do
        begin
          str[p] := Frame[R, c];
          strOld[p] := FrameOld[R, c];
          p := p + 1;
        end;
      frag := str;
      fragOld := strOld;
      for L := 1 to UGlobal.FragSize do
        frag[L] := frag[L] xor fragOld[L];
      FrameBase[k].frag := frag;
      FrameBase[k].count := 1;
      k := k + 1;
      j := j + UGlobal.FragW;
    end;
    i := i + UGlobal.FragH;
    j := 1;
  end;
  SealLocalBase;
end;

procedure CreateLocalFragBase;
var
  i, j, k, R, c, p: LongWord;
  frag: UFrag.TFrag;
begin
  i := 1;
  j := 1;
  k := 1;
  while i <= UGlobal.PicH - (UGlobal.FragH - 1) do
  begin
    while j <= UGlobal.PicW - (UGlobal.FragW - 1) do
    begin
      p := 1;
      for R := i to i + (UGlobal.FragH - 1) do
        for c := j to j + (UGlobal.FragW - 1) do
        begin
          frag[p] := Frame[R, c];
          p := p + 1;
        end;
      FrameBase[k].frag := frag;
      FrameBase[k].count := 1;
      k := k + 1;
      j := j + UGlobal.FragW;
    end;
    i := i + UGlobal.FragH;
    j := 1;
  end;
  SealLocalBase;
end;

procedure AddToBase;
var
  i: LongWord;
begin
  if BASE_COUNT + UGlobal.FrameBaseSize > MAX_BASE_COUNT then
  begin
    SealGlobalBase;
    if BaseFull >= 90 then
      WriteBASE;
  end;
  i := 1;
  while (FrameBase[i].count > 0) and (i <= UGlobal.FrameBaseSize) do
  begin
    BASE_COUNT := BASE_COUNT + 1;
    GlobalBase[BASE_COUNT] := new(UFrag.TPRFrag);
    GlobalBase[BASE_COUNT]^.frag := FrameBase[i].frag;
    GlobalBase[BASE_COUNT]^.count := FrameBase[i].count;
    i := i + 1;
  end;
  for i := 1 to UGlobal.FrameBaseSize do
    FrameBase[i].count := 0;
end;

procedure MedianFilter;
var
  tmpArr: array [1 .. 9] of byte;
  i, j: integer;
  k, L, m: byte;
  FrameTmp: array [1 .. UGlobal.PicH, 1 .. UGlobal.PicW] of byte;
begin
  for i := 1 to PicH do
    for j := 1 to PicW do
      FrameTmp[i, j] := Frame[i, j];

  for i := FilterBase to UGlobal.PicH - FilterBase do
  begin
    for j := FilterBase to UGlobal.PicW - FilterBase do
    begin
      tmpArr[1] := FrameTmp[i - 1, j - 1];
      tmpArr[2] := FrameTmp[i - 1, j];
      tmpArr[3] := FrameTmp[i - 1, j + 1];
      tmpArr[4] := FrameTmp[i, j - 1];
      tmpArr[5] := FrameTmp[i, j];
      tmpArr[6] := FrameTmp[i, j + 1];
      tmpArr[7] := FrameTmp[i + 1, j - 1];
      tmpArr[8] := FrameTmp[i + 1, j];
      tmpArr[9] := FrameTmp[i + 1, j + 1];
      for k := 1 to 8 do
        for L := k + 1 to 9 do
          if tmpArr[k] > tmpArr[L] then
          begin
            m := tmpArr[k];
            tmpArr[k] := tmpArr[L];
            tmpArr[L] := m;
          end;
      Frame[i, j] := tmpArr[5];
    end;
  end;
end;

procedure WindowFilter;
var
  i, j, R, c: word;
  count: word;
begin
  i := 1;
  j := 1;
  while i < PicH - FragH do
  begin
    while j < PicW - FragW do
    begin
      count := 0;
      for R := i to i + (FragH - 1) do
        for c := j to j + (FragW - 1) do
          if Frame[R, c] <> FrameOld[R, c] then
            count := count + 1;

      if count < FilterThresold then
        for R := i to i + (FragH - 1) do
          for c := j to j + (FragW - 1) do
            Frame[R, c] := FrameOld[R, c];

      j := j + UGlobal.FragW;
    end;
    i := i + UGlobal.FragH;
    j := 1;
  end;
end;

procedure ProcessFrame;
begin
  CopyFrame;
  CreateFrame;
  if USettings.NeedWindowFilter then
    WindowFilter;
  if USettings.NeedMedianFilter then
    MedianFilter;
  ShowResultFrame;
  // SaveFrame(FrameNum);
  case USettings.ElemBase of
  FragBase: CreateLocalFragBase;
  DiffBase: CreateLocalDiffBase;
  end;
  AddToBase;
  FrameNum := FrameNum + 1;
end;

initialization

FrameNum := 0;
BM := Vcl.Graphics.TBitMap.Create;
BM.Width := UGlobal.PicW;
BM.Height := UGlobal.PicH;
BM.PixelFormat := pf24bit;

BMR := Vcl.Graphics.TBitMap.Create;
BMR.Width := UGlobal.PicW;
BMR.Height := UGlobal.PicH;
BMR.PixelFormat := pf24bit;

Init;

finalization

BM.Free;
BMR.Free;

end.
