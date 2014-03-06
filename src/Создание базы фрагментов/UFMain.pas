unit UFMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.MPlayer, Vcl.ComCtrls, Vcl.Samples.Gauges;

type
  TFMain = class(TForm)
    MP: TMediaPlayer;
    PVideo: TPanel;
    ProgressBar1: TProgressBar;
    Image1: TImage;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FMain: TFMain;

implementation

{$R *.dfm}

uses
  UGlobal, USettings, UProcess;

function GetFullSegmentName(FileName: string; SegNum: word): string;
var
  FullSegName: string;
begin
  FullSegName := FileName + '.';
  if SegNum < 10 then
    FullSegName := FullSegName + '0';
  FullSegName := FullSegName + inttostr(SegNum) + '.avi';
  GetFullSegmentName := FullSegName;
end;

procedure TFMain.FormActivate(Sender: TObject);
var
  SegCount, SegNum: word;
  i: word;
  tmp: string;
  f: TextFile;
  T: TDateTime;
begin
  FMain.ClientWidth := 2 * PicW + 3 * 8;
  FMain.ClientHeight := PicH +  20 + 3 * 8;

  PVideo.Height := PicH;
  PVideo.Width := PicW;
  PVideo.Top := 8;
  PVideo.Left := 8;

  Image1.Height := PicH;
  Image1.Width := PicW;
  Image1.Top := 8;
  Image1.Left := 8 + PVideo.Width + 8;

  ProgressBar1.Width := 2 * PicW + 8;
  ProgressBar1.Left := 8;
  ProgressBar1.Top := 8 + PicH + 8;

  if paramcount = 6 then
  begin
    USettings.FileName := ParamStr(1);
    USettings.BaseName := USettings.FileName;

    if ParamStr(2) = 'RGB.R' then
      UGlobal.BaseColor := RGB_R;
    if ParamStr(2) = 'RGB.G' then
      UGlobal.BaseColor := RGB_G;
    if ParamStr(2) = 'RGB.B' then
      UGlobal.BaseColor := RGB_B;
    if ParamStr(2) = 'YIQ.Y' then
      UGlobal.BaseColor := YIQ_Y;
    if ParamStr(2) = 'YIQ.I' then
      UGlobal.BaseColor := YIQ_I;
    if ParamStr(2) = 'YIQ.Q' then
      UGlobal.BaseColor := YIQ_Q;
    USettings.BaseName := USettings.BaseName + '_' + ParamStr(2);

    if ParamStr(3) = 'FR' then
      BaseType := btFrag;
    if ParamStr(3) = 'LD' then
      BaseType := btLDiff;
    if ParamStr(3) = 'MD' then
      BaseType := btMDiff;
    if UGlobal.BaseType = btFrag then
      USettings.BaseName := USettings.BaseName + '_FR';
    if UGlobal.BaseType = btLDiff then
      USettings.BaseName := USettings.BaseName + '_LD';
    if UGlobal.BaseType = btMDiff then
      USettings.BaseName := USettings.BaseName + '_MD';

    if ParamStr(4) = '+GC' then
      UGlobal.GrayCode := true
    else
      UGlobal.GrayCode := false;
    if UGlobal.GrayCode then
      USettings.BaseName := USettings.BaseName + '_GC';

    tmp := ParamStr(5);
    delete(tmp, 1, 2);
    UGlobal.BitNum := strtoint(tmp);
    if UGlobal.BitNum = 0 then
      UGlobal.bpp := 8
    else
      UGlobal.bpp := 1;
    USettings.BaseName := USettings.BaseName + '_BP' + inttostr(UGlobal.BitNum);

    tmp := ParamStr(6);
    if tmp[1] = 'A' then
    begin
      UGlobal.FilterType := ftAVG;
      USettings.BaseName := USettings.BaseName + '_' + tmp;
    end;
    if tmp[1] = 'M' then
    begin
      UGlobal.FilterType := ftMedian;
      USettings.BaseName := USettings.BaseName + '_' + tmp;
    end;
    if tmp[1] = 'T' then
    begin
      UGlobal.FilterType := ftThresold;
      USettings.BaseName := USettings.BaseName + '_' + tmp;
    end;
    delete(tmp, 1, 1);
    if length(tmp) > 0 then
      UGlobal.FilterParam := strtoint(tmp)
    else
      UGlobal.FilterParam := 0;

    USettings.BaseName := USettings.BaseName + '_' + inttostr(UGlobal.ElemH) + 'x' + inttostr(UGlobal.ElemW);
    FMain.Caption := USettings.BaseName + ' создание базы элементов';
  end
  else
    Halt;

  T := Now;
  SegCount := 0;
  while FileExists(GetFullSegmentName(string(USettings.FileName), SegCount)) do
    SegCount := SegCount + 1;
  if SegCount > 0 then
  begin
    SegCount := SegCount - 1;
    ProgressBar1.Max := 0;
    for SegNum := 0 to SegCount do
    begin
      MP.FileName := GetFullSegmentName(string(USettings.FileName), SegNum);
      MP.Open;
      ProgressBar1.Max := ProgressBar1.Max + MP.length;
      MP.Close;
    end;

    for SegNum := 0 to SegCount do
    begin
      MP.FileName := GetFullSegmentName(string(USettings.FileName), SegNum);
      MP.Open;
      MP.Frames := 1;
      i := 0;
      while i < MP.length do
      begin
        i := i + 1;
        MP.Step;
        UProcess.BMIn.Canvas.CopyRect(Rect(0, 0, UProcess.BMIn.Width, BMIn.Height), FMain.Canvas, Rect(PVideo.Left, PVideo.Top, PVideo.Left + PVideo.Width - 1, PVideo.Top + PVideo.Height - 1));
        UProcess.ProcessFrame;
        ProgressBar1.StepBy(1);
        Application.ProcessMessages;
      end;
      MP.Close;
    end;
  end;
  UProcess.WriteBase;
  T := Now - T;
  AssignFile(f, 'time.txt');
  if FileExists('time.txt') then
    Append(f)
  else
    rewrite(f);
  writeln(f, BaseName + ' ' + timetostr(T));
  CloseFile(f);
  FMain.Close;
end;

end.
