object FMain: TFMain
  Left = 0
  Top = 0
  Caption = #1057#1086#1079#1076#1072#1085#1080#1077' '#1073#1072#1079#1099' '#1091#1085#1080#1082#1072#1083#1100#1085#1099#1093' '#1088#1072#1079#1085#1086#1089#1090#1077#1081
  ClientHeight = 517
  ClientWidth = 1451
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
  object Label2: TLabel
    Left = 1300
    Top = 77
    Width = 87
    Height = 13
    Caption = #1055#1086#1088#1086#1075' '#1092#1080#1083#1100#1090#1088#1072' - '
  end
  object Label1: TLabel
    Left = 1300
    Top = 159
    Width = 61
    Height = 13
    Caption = #1047#1072#1084#1077#1076#1083#1077#1085#1080#1077
  end
  object MP: TMediaPlayer
    Left = 8
    Top = 246
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
  object CBShowResult: TCheckBox
    Left = 1300
    Top = 8
    Width = 141
    Height = 17
    Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1088#1077#1079#1091#1083#1100#1090#1072#1090
    Checked = True
    State = cbChecked
    TabOrder = 3
  end
  object CBSaveResults: TCheckBox
    Left = 1300
    Top = 31
    Width = 141
    Height = 17
    Caption = #1057#1086#1093#1088#1072#1085#1103#1090#1100' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1099
    TabOrder = 4
  end
  object TrackBar2: TTrackBar
    Left = 1300
    Top = 96
    Width = 138
    Height = 45
    Enabled = False
    Max = 100
    Min = 1
    Position = 100
    TabOrder = 5
    OnChange = TrackBar2Change
  end
  object CBWindowsFilter: TCheckBox
    Left = 1300
    Top = 54
    Width = 138
    Height = 17
    Caption = #1054#1082#1086#1085#1085#1099#1081' '#1092#1080#1083#1100#1090#1088
    TabOrder = 6
    OnClick = CBWindowsFilterClick
  end
  object CBMedianFilter: TCheckBox
    Left = 1300
    Top = 140
    Width = 138
    Height = 17
    Caption = #1052#1077#1076#1080#1072#1085#1085#1099#1081' '#1092#1080#1083#1100#1090#1088
    TabOrder = 7
    OnClick = CBMedianFilterClick
  end
  object TrackBar1: TTrackBar
    Left = 1297
    Top = 178
    Width = 150
    Height = 45
    Max = 1000
    Position = 500
    TabOrder = 8
  end
  object CheckBox1: TCheckBox
    Left = 1300
    Top = 229
    Width = 37
    Height = 17
    Caption = '1'
    Checked = True
    State = cbChecked
    TabOrder = 9
    OnClick = CheckBox1Click
  end
  object CheckBox2: TCheckBox
    Left = 1300
    Top = 252
    Width = 37
    Height = 17
    Caption = '2'
    Checked = True
    State = cbChecked
    TabOrder = 10
    OnClick = CheckBox2Click
  end
  object CheckBox3: TCheckBox
    Left = 1300
    Top = 275
    Width = 37
    Height = 17
    Caption = '3'
    Checked = True
    State = cbChecked
    TabOrder = 11
    OnClick = CheckBox3Click
  end
  object CheckBox4: TCheckBox
    Left = 1300
    Top = 298
    Width = 37
    Height = 17
    Caption = '4'
    Checked = True
    State = cbChecked
    TabOrder = 12
    OnClick = CheckBox4Click
  end
  object CheckBox5: TCheckBox
    Left = 1343
    Top = 229
    Width = 37
    Height = 17
    Caption = '5'
    Checked = True
    State = cbChecked
    TabOrder = 13
    OnClick = CheckBox5Click
  end
  object CheckBox6: TCheckBox
    Left = 1343
    Top = 252
    Width = 37
    Height = 17
    Caption = '6'
    Checked = True
    State = cbChecked
    TabOrder = 14
    OnClick = CheckBox6Click
  end
  object CheckBox7: TCheckBox
    Left = 1343
    Top = 275
    Width = 37
    Height = 17
    Caption = '7'
    Checked = True
    State = cbChecked
    TabOrder = 15
    OnClick = CheckBox7Click
  end
  object CheckBox8: TCheckBox
    Left = 1343
    Top = 298
    Width = 37
    Height = 17
    Caption = '8'
    Checked = True
    State = cbChecked
    TabOrder = 16
    OnClick = CheckBox8Click
  end
end
