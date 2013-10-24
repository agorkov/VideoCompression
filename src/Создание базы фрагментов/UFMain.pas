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
    CBShowResult: TCheckBox;
    CBShowDiffPixels: TCheckBox;
    CBSaveResults: TCheckBox;
    Label2: TLabel;
    TrackBar2: TTrackBar;
    CBWindowsFilter: TCheckBox;
    CBMedianFilter: TCheckBox;
    Gauge1: TGauge;
    procedure FormActivate(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure CBWindowsFilterClick(Sender: TObject);
    procedure CBMedianFilterClick(Sender: TObject);
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
  UGlobal, USettings, UProcess, UMergeList;

function GetFullSegName(FileName: string; SegNum: word): string;
var
  FullSegName: string;
begin
  FullSegName := FileName + '.';
  if SegNum < 10 then
    FullSegName := FullSegName + '0';
  FullSegName := FullSegName + inttostr(SegNum) + '.avi';
  GetFullSegName := FullSegName;
end;

procedure TFMain.CBMedianFilterClick(Sender: TObject);
begin
  USettings.NeedMedianFilter := CBMedianFilter.Checked;
end;

procedure TFMain.CBWindowsFilterClick(Sender: TObject);
begin
  USettings.NeedWindowFilter := CBWindowsFilter.Checked;
  TrackBar2.Enabled := CBWindowsFilter.Checked;
end;

procedure TFMain.FormActivate(Sender: TObject);
var
  SegCount, SegNum: word;
  i: word;
begin
  //UProcess.WriteBase;
  if paramcount = 6 then
  begin
    USettings.FileName := ParamStr(1);
    FMain.Caption := USettings.FileName;
    FMain.Caption := FMain.Caption + ' ' + 'Создание базы уникальных';

    if ParamStr(2) = 'd' then
    begin
      USettings.ElemBase := DiffBase;
      FMain.Caption := FMain.Caption + ' ' + 'разностей';
    end;
    if ParamStr(2) = 'f' then
    begin
      USettings.ElemBase := FragBase;
      FMain.Caption := FMain.Caption + ' ' + 'фрагментов';
    end;

    FMain.Caption := FMain.Caption + ' ' + ParamStr(3);
    if ParamStr(3) = 'RGB.R' then
      USettings.BaseColor := RGB_R;
    if ParamStr(3) = 'RGB.G' then
      USettings.BaseColor := RGB_G;
    if ParamStr(3) = 'RGB.B' then
      USettings.BaseColor := RGB_B;
    if ParamStr(3) = 'YIQ.Y' then
      USettings.BaseColor := YIQ_Y;
    if ParamStr(3) = 'YIQ.I' then
      USettings.BaseColor := USettings.YIQ_I;
    if ParamStr(3) = 'YIQ.Q' then
      USettings.BaseColor := YIQ_Q;

    TrackBar2.Max := UGlobal.FragSize;
    TrackBar2.Position := 1;
    CBWindowsFilter.Checked := false;
    if pos('+W', ParamStr(4)) = 1 then
    begin
      CBWindowsFilter.Checked := true;
      TrackBar2.Position := strtoint(copy(ParamStr(4), 3, length(ParamStr(4))));
    end;

    if ParamStr(5) = '+M' then
      CBMedianFilter.Checked := true;
    if ParamStr(5) = '-M' then
      CBMedianFilter.Checked := false;
  end;

  SegCount := 0;
  while FileExists(GetFullSegName(USettings.FileName, SegCount)) do
    SegCount := SegCount + 1;
  if SegCount > 0 then
  begin
    SegCount := SegCount - 1;
    ProgressBar1.Max := 0;
    for SegNum := 0 to SegCount do
    begin
      MP.FileName := GetFullSegName(USettings.FileName, SegNum);
      MP.Open;
      ProgressBar1.Max := ProgressBar1.Max + MP.length;
      MP.Close;
    end;

    for SegNum := 0 to SegCount do
    begin
      MP.FileName := GetFullSegName(USettings.FileName, SegNum);
      MP.Open;
      MP.Frames := 1;
      i := 0;
      while i < MP.length do
      begin
        i := i + 1;
        MP.Step;
        UProcess.BM.Canvas.CopyRect(Rect(0, 0, UProcess.BM.Width, BM.Height), FMain.Canvas, Rect(PVideo.Left, PVideo.Top, PVideo.Left + PVideo.Width - 1, PVideo.Top + PVideo.Height - 1));
        UProcess.ProcessFrame;
        ProgressBar1.StepBy(1);
        Gauge1.Progress := UProcess.BaseFull;
        Application.ProcessMessages;
      end;
      MP.Close;
    end;
    UProcess.WriteBase;
  end;
  USettings.FileName := ParamStr(6);
  UMergeList.MergePartBaseList;

  FMain.Close;
end;

procedure TFMain.TrackBar2Change(Sender: TObject);
begin
  USettings.FilterThresold := TrackBar2.Position;
  Label2.Caption := 'Порог фильтра - ' + inttostr(TrackBar2.Position);
end;

end.
