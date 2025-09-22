object FrmPrincipal: TFrmPrincipal
  Left = 0
  Top = 0
  Caption = 'Principal'
  ClientHeight = 816
  ClientWidth = 843
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    843
    816)
  PixelsPerInch = 96
  TextHeight = 13
  object pnlEstadoConexion: TLabel
    Left = 16
    Top = 379
    Width = 113
    Height = 29
    Alignment = taCenter
    AutoSize = False
    Caption = 'Estado Conexion'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = False
  end
  object Button1: TButton
    Left = 16
    Top = 166
    Width = 113
    Height = 25
    Caption = 'Administrar'
    TabOrder = 0
    OnClick = Button1Click
  end
  object RadioGroup1: TRadioGroup
    Left = 16
    Top = 59
    Width = 113
    Height = 105
    Caption = ' Opciones '
    Items.Strings = (
      'Productos'
      'Clientes'
      'Facturas')
    TabOrder = 1
  end
  object memoLog: TMemo
    Left = 143
    Top = 63
    Width = 697
    Height = 745
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
  end
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 843
    Height = 57
    Align = alTop
    TabOrder = 3
    object Label1: TLabel
      Left = 542
      Top = 8
      Width = 172
      Height = 40
      Caption = 'Ing. Rodolfo Jimenez B.'#13#10'Cliente DCOM (Frontend )'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
    end
    object edtServidor: TLabeledEdit
      Left = 16
      Top = 21
      Width = 121
      Height = 21
      EditLabel.Width = 84
      EditLabel.Height = 13
      EditLabel.Caption = 'Servidor Remoto:'
      TabOrder = 0
      Text = 'localhost'
      OnChange = edtServidorChange
    end
    object btnConectar: TButton
      Left = 344
      Top = 19
      Width = 75
      Height = 25
      Caption = 'Conectar'
      TabOrder = 1
      OnClick = btnConectarClick
    end
    object btnDesconectar: TButton
      Left = 425
      Top = 19
      Width = 75
      Height = 25
      Caption = 'Desconectar'
      TabOrder = 2
      OnClick = btnDesconectarClick
    end
    object rgTipoConexion: TRadioGroup
      Left = 143
      Top = 9
      Width = 185
      Height = 45
      Caption = 'Tipo de Conexi'#243'n'
      Columns = 2
      ItemIndex = 0
      Items.Strings = (
        'Local'
        'Remota')
      TabOrder = 3
      OnClick = rgTipoConexionClick
    end
  end
  object btnEstadoConexion: TButton
    Left = 16
    Top = 345
    Width = 113
    Height = 25
    Caption = 'Estado Conexion'
    TabOrder = 4
    OnClick = btnEstadoConexionClick
  end
  object grpLog: TGroupBox
    Left = 16
    Top = 208
    Width = 113
    Height = 129
    Caption = ' Registro Log '
    TabOrder = 5
    object btnLimpiarLog: TButton
      Left = 6
      Top = 97
      Width = 102
      Height = 25
      Caption = 'Limpiar'
      TabOrder = 0
      OnClick = btnLimpiarLogClick
    end
    object btnDetenerLog: TButton
      Left = 6
      Top = 47
      Width = 102
      Height = 25
      Caption = 'Detener'
      TabOrder = 1
      OnClick = btnDetenerLogClick
    end
    object btnIniciarLog: TButton
      Left = 6
      Top = 23
      Width = 102
      Height = 25
      Caption = 'Iniciar'
      TabOrder = 2
      OnClick = btnIniciarLogClick
    end
    object btnActualizarLog: TButton
      Left = 6
      Top = 72
      Width = 102
      Height = 25
      Caption = 'Actualizar'
      TabOrder = 3
      OnClick = btnActualizarLogClick
    end
  end
  object Button2: TButton
    Left = 16
    Top = 498
    Width = 113
    Height = 25
    Caption = 'TEST GET / POST'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 6
    OnClick = Button2Click
  end
  object RadioGroup2: TRadioGroup
    Left = 16
    Top = 422
    Width = 113
    Height = 70
    Caption = ' Web API .NET'
    Items.Strings = (
      'Clientes (POST)'
      'Facturas (GET)')
    TabOrder = 7
  end
  object tmrLogUpdate: TTimer
    Interval = 300
    OnTimer = tmrLogUpdateTimer
    Left = 176
    Top = 88
  end
  object tmrVerificarConexion: TTimer
    Interval = 300
    OnTimer = tmrVerificarConexionTimer
    Left = 232
    Top = 88
  end
end
