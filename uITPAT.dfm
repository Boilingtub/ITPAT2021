object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 299
  ClientWidth = 350
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 336
    Height = 33
    Caption = 'Koos se Epic Program!'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Unispace'
    Font.Style = [fsBold, fsUnderline]
    ParentFont = False
  end
  object Button1: TButton
    Left = 109
    Top = 175
    Width = 129
    Height = 65
    Caption = 'Open Encryptor    (Manual Sign in)'
    TabOrder = 0
    WordWrap = True
    OnClick = Button1Click
  end
  object BitBtn1: TBitBtn
    Left = 8
    Top = 266
    Width = 334
    Height = 25
    DoubleBuffered = True
    Kind = bkClose
    ParentDoubleBuffered = False
    TabOrder = 1
  end
  object Button2: TButton
    Left = 120
    Top = 72
    Width = 97
    Height = 65
    Caption = 'Feature Test Button'
    TabOrder = 2
    WordWrap = True
  end
end
