object FMain: TFMain
  Left = 0
  Top = 0
  Caption = #1057#1086#1079#1076#1072#1085#1080#1077' '#1073#1072#1079#1099' '#1091#1085#1080#1082#1072#1083#1100#1085#1099#1093' '#1088#1072#1079#1085#1086#1089#1090#1077#1081
  ClientHeight = 548
  ClientWidth = 1303
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Icon.Data = {
    0000010001002020100000000000E80200001600000028000000200000004000
    0000010004000000000080020000000000000000000000000000000000000000
    000000008000008000000080800080000000800080008080000080808000C0C0
    C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF009999
    9999999999999999999999999999999999999999999999999999999999999900
    0000000000000000000000000099990000009999999999999999000000999900
    0000999999999999999900000099990000009999999999999999000000999900
    0000999999999999999900000099990000009999900000009999000000999900
    0000999990000000999900000099990000009999900000009999000000999900
    0000999990000000999900000099990000009999900099999999000000999900
    0000999990009999999900000099990000009999900099999999000000999900
    0000999990009999999900000099990000009999900099999999000000999900
    0000999990000000000000000099990000009999900000000000000000999900
    0000999990000000000000000099990000009999900000000000000000999900
    0000999990000000000000000099990000009999900000009999000000999900
    0000999990000000999900000099990000009999900000009999000000999900
    0000999990000000999900000099990000009999999999999999000000999900
    0000999999999999999900000099990000009999999999999999000000999900
    0000999999999999999900000099990000000000000000000000000000999999
    9999999999999999999999999999999999999999999999999999999999990000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    000000000000000000000000000000000000000000000000000000000000}
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 654
    Top = 8
    Width = 640
    Height = 480
  end
  object Gauge1: TGauge
    Left = 8
    Top = 517
    Width = 1286
    Height = 20
    Progress = 0
  end
  object MP: TMediaPlayer
    Left = 8
    Top = 490
    Width = 0
    Height = 30
    VisibleButtons = [btPlay]
    AutoEnable = False
    AutoRewind = False
    Display = PVideo
    Visible = False
    TabOrder = 0
  end
  object PVideo: TPanel
    Left = 8
    Top = 8
    Width = 640
    Height = 480
    TabOrder = 1
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 494
    Width = 1286
    Height = 17
    TabOrder = 2
  end
end
