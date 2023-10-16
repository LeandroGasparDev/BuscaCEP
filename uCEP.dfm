object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 527
  ClientWidth = 534
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object Label1: TLabel
    Left = 8
    Top = 15
    Width = 112
    Height = 21
    Caption = 'Informe o CEP:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object edtCEP: TMaskEdit
    Left = 157
    Top = 13
    Width = 114
    Height = 23
    EditMask = '#####-###;1;_'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    MaxLength = 9
    ParentFont = False
    TabOrder = 0
    Text = '     -   '
  end
  object BitBtn1: TBitBtn
    Left = 277
    Top = 8
    Width = 121
    Height = 29
    Caption = 'Consultar CEP'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = BitBtn1Click
  end
  object mmResult: TMemo
    Left = 8
    Top = 43
    Width = 520
    Height = 480
    TabOrder = 2
  end
end
