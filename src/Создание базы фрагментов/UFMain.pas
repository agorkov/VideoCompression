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
    Gauge1: TGauge;
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
  T: TDateTime;
begin
  T := Now;
  if paramcount = 2 then
  begin
    USettings.FileName := ParamStr(1);
    FMain.Caption := USettings.FileName;
    FMain.Caption := FMain.Caption + ' ' + 'Создание базы элементов';

    FMain.Caption := FMain.Caption + ' ' + ParamStr(2);
    if ParamStr(2) = 'RGB.R' then
      USettings.BaseColor := RGB_R;
    if ParamStr(2) = 'RGB.G' then
      USettings.BaseColor := RGB_G;
    if ParamStr(2) = 'RGB.B' then
      USettings.BaseColor := RGB_B;
    if ParamStr(2) = 'YIQ.Y' then
      USettings.BaseColor := YIQ_Y;
    if ParamStr(2) = 'YIQ.I' then
      USettings.BaseColor := USettings.YIQ_I;
    if ParamStr(2) = 'YIQ.Q' then
      USettings.BaseColor := YIQ_Q;
  end;

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
        Gauge1.Progress := UProcess.BaseFull;
        Application.ProcessMessages;
      end;
      MP.Close;
    end;
    UProcess.DropToList;
  end;
  USettings.FileName := ParamStr(1) + '_';
  USettings.FileName := USettings.FileName + inttostr(UGlobal.FragH) + 'x' + inttostr(UGlobal.FragW) + '_';
  if UGlobal.BitNum > 1 then
    USettings.FileName := USettings.FileName + 'BP' + inttostr(UGlobal.BitNum)
  else
    USettings.FileName := USettings.FileName + 'COL' + inttostr(UGlobal.bpp);
  UProcess.WriteList;
  FMain.Close;
end;

end.
