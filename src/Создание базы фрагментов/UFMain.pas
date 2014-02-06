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
begin
  FMain.ClientWidth := 2 * PicW + 3 * 8;
  FMain.ClientHeight := PicH + 2 * 20 + 4 * 8;

  PVideo.Height := PicH;
  PVideo.Width := PicW;
  PVideo.Top := 8;
  PVideo.Left := 8;

  Image1.Height := PicH;
  Image1.Width := PicW;
  Image1.Top := 8;
  Image1.Left := 8 + PVideo.Width + 8;

  ProgressBar1.Width := 2 * PicW + 8;
  ProgressBar1.Left:=8;
  ProgressBar1.Top:=8+PicH+8;
  Gauge1.Width := 2 * PicW + 8;
  Gauge1.Left:=8;
  Gauge1.Top:=8+PicH+8+20+8;

  if paramcount = 1 then
  begin
    USettings.FileName := ParamStr(1);
    USettings.BaseName := USettings.FileName;
{$IF UGlobal.BaseType=btFrag}
    USettings.BaseName := USettings.BaseName + '_FR';
{$IFEND}
{$IF UGlobal.BaseType=btLDiff}
    USettings.BaseName := USettings.BaseName + '_LD';
{$IFEND}
{$IF UGlobal.BaseType=btMDiff}
    USettings.BaseName := USettings.BaseName + '_MD';
{$IFEND}
{$IF UGlobal.GrayCode}
    USettings.BaseName := USettings.BaseName + '_GC';
{$IFEND}
    USettings.BaseName := USettings.BaseName + '_' + inttostr(UGlobal.ElemH) + 'x' + inttostr(UGlobal.ElemW);
{$IF UGlobal.BitNum > 0}
    USettings.BaseName := USettings.BaseName + '_BP' + inttostr(UGlobal.BitNum);
{$IFEND}
    FMain.Caption := USettings.BaseName + ' создание базы элементов';
  end
  else
    Halt;

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
  end;
  UProcess.WriteList;
  FMain.Close;
end;

end.
