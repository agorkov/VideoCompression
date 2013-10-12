unit UProcess;

interface

uses
  Vcl.Graphics;

var
  BM, BMR: TBitMap;

procedure ProcessFrame;
procedure WriteBASE;

implementation

uses
  UGlobal, USettings, UFrag, UMergeList, SysUtils, Windows, UFMain;

const
  MAX_BASE_COUNT = UGlobal.FrameBaseSize * 10000;
  FilterBase = 1;

var
  Frame, FrameOld: array [1 .. UGlobal.PicH, 1 .. UGlobal.PicW] of byte;
  FrameBase: array [1 .. UGlobal.FrameBaseSize] of UFrag.TRFrag;
  BASE_COUNT: LongWord;
  BASE: array [1 .. MAX_BASE_COUNT] of TRFrag;
  SAVED_BASE: LongWord;
  FrameNum: LongWord;

procedure WriteBASE;
  procedure QuickSort;
    procedure sort(L, R: LongWord);
    var
      w, x: UFrag.TRFrag;
      i, j: LongWord;
    begin
      i := L;
      j := R;
      x := BASE[(L + R) div 2];
      repeat
        while UFrag.CompareFrag(BASE[i].frag, x.frag) = 0 do
          i := i + 1;
        while UFrag.CompareFrag(x.frag, BASE[j].frag) = 0 do
          j := j - 1;
        if i <= j then
        begin
          w := BASE[i];
          BASE[i] := BASE[j];
          BASE[j] := w;
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
  f: TextFile;
  i, k: LongWord;
  UniqCount: int64;
begin
  QuickSort;
  k := 1;
  for i := 2 to BASE_COUNT do
  begin
    if UFrag.CompareFrag(BASE[i].frag, BASE[k].frag) = 1 then
    begin
      BASE[k].count := BASE[k].count + BASE[i].count;
      BASE[i].count := 0;
    end
    else
      k := i;
  end;

  SAVED_BASE := SAVED_BASE + 1;
  AssignFile(f, USettings.FileName + '_' + inttostr(SAVED_BASE) + '.base');
  rewrite(f);
  UniqCount := 0;
  for i := 1 to BASE_COUNT do
  begin
    if BASE[i].count <> 0 then
    begin
      writeln(f, UFrag.FragToString(BASE[i].frag), ' ', BASE[i].count);
      UniqCount := UniqCount + 1;
    end;
  end;
  UMergeList.AddPartBase(UniqCount);
  CloseFile(f);

  for i := 1 to BASE_COUNT do
    BASE[i].count := 0;
  BASE_COUNT := 0;
end;

procedure Init;
var
  i, j: LongWord;
begin
  BASE_COUNT := 0;
  SAVED_BASE := 0;
  FilterThresold := 25;

  for i := 1 to MAX_BASE_COUNT do
    BASE[i].count := 0;

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
      RGB_R: val := R;
      RGB_G: val := g;
      RGB_B: val := b;
      USettings.YIQ_Y: val := round(0.299 * R + 0.587 * g + 0.114 * b);
      USettings.YIQ_I: val := round(0.596 * R + 0.274 * g + 0.321 * b);
      USettings.YIQ_Q: val := round(0.211 * R + 0.523 * g + 0.311 * b);
    else val := 0;
      end;

      if val > 150 then
        Frame[i + 1, j + 1] := 15
      else
        Frame[i + 1, j + 1] := val div 10;
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
      if Frame[i + 1, j + 1] < 15 then
        val := 5 + Frame[i + 1, j + 1] * 10
      else
        val := 170;
      case USettings.BaseColor of
      RGB_R: pr[3 * j + 2] := val;
      RGB_G: pr[3 * j + 1] := val;
      RGB_B: pr[3 * j] := val;
      USettings.YIQ_Y, USettings.YIQ_I, USettings.YIQ_Q:
        begin
          pr[3 * j] := val;
          pr[3 * j + 1] := val;
          pr[3 * j + 2] := val;
        end;
      end;
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
  for i := 1 to 240 do
  begin
    for j := 1 to 320 do
      write(f, Frame[i, j]);
    writeln(f);
  end;
  CloseFile(f);
end;

procedure CreateLocalDiffBase;
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

  QuickSort;

  k := 1;
  for i := 2 to UGlobal.FrameBaseSize do
  begin
    if UFrag.CompareFrag(FrameBase[i].frag, FrameBase[k].frag) = 1 then
    begin
      FrameBase[k].count := FrameBase[k].count + 1;
      FrameBase[i].count := 0;
    end
    else
      k := i;
  end;
end;

procedure CreateLocalFragBase;
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

  QuickSort;

  k := 1;
  for i := 2 to UGlobal.FrameBaseSize do
  begin
    if UFrag.CompareFrag(FrameBase[i].frag, FrameBase[k].frag) = 1 then
    begin
      FrameBase[k].count := FrameBase[k].count + 1;
      FrameBase[i].count := 0;
    end
    else
      k := i;
  end;
end;

procedure AddToBase;
var
  i: LongWord;
begin
  if BASE_COUNT + UGlobal.FrameBaseSize > MAX_BASE_COUNT then
    WriteBASE;
  for i := 1 to UGlobal.FrameBaseSize do
    if FrameBase[i].count <> 0 then
    begin
      BASE_COUNT := BASE_COUNT + 1;
      BASE[BASE_COUNT].frag := FrameBase[i].frag;
      BASE[BASE_COUNT].count := FrameBase[i].count;
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
