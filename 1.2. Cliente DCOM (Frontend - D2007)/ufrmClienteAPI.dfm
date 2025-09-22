object frmClienteAPI: TfrmClienteAPI
  Left = 0
  Top = 0
  Caption = 'Test Web Api .NET'
  ClientHeight = 135
  ClientWidth = 349
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object grpClientes: TGroupBox
    Left = 8
    Top = 8
    Width = 329
    Height = 121
    Caption = 'Clientes'
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 24
      Width = 47
      Height = 13
      Caption = 'Cliente ID'
    end
    object lbl1: TLabel
      Left = 16
      Top = 52
      Width = 37
      Height = 13
      Caption = 'Nombre'
    end
    object lbl2: TLabel
      Left = 16
      Top = 80
      Width = 43
      Height = 13
      Caption = 'Direcci'#243'n'
    end
    object edtidcliente: TEdit
      Left = 104
      Top = 20
      Width = 100
      Height = 21
      TabOrder = 0
    end
    object edtnombrecliente: TEdit
      Left = 104
      Top = 48
      Width = 200
      Height = 21
      TabOrder = 1
    end
    object edtdireccioncliente: TEdit
      Left = 104
      Top = 76
      Width = 200
      Height = 21
      TabOrder = 2
    end
    object BtnCrearCliente: TButton
      Left = 210
      Top = 18
      Width = 94
      Height = 25
      Caption = 'Crear Cliente'
      TabOrder = 3
      OnClick = BtnCrearClienteClick
    end
  end
end
