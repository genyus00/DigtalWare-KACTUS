unit uFrmPrincipal;

interface

uses
  Windows, Forms, Controls, StdCtrls, ExtCtrls, Classes, uFrmClientes,
  ufrmFactura, ufrmProductos, ufrmViewFactura, SysUtils, ufrmClienteAPI;

type
  TFrmPrincipal = class(TForm)
    Button1: TButton;
    RadioGroup1: TRadioGroup;
    memoLog: TMemo;
    tmrLogUpdate: TTimer;
    pnlTop: TPanel;
    edtServidor: TLabeledEdit;
    btnConectar: TButton;
    btnDesconectar: TButton;
    rgTipoConexion: TRadioGroup;
    Label1: TLabel;
    btnEstadoConexion: TButton;
    tmrVerificarConexion: TTimer;
    pnlEstadoConexion: TLabel;
    grpLog: TGroupBox;
    btnLimpiarLog: TButton;
    btnDetenerLog: TButton;
    btnIniciarLog: TButton;
    btnActualizarLog: TButton;
    Button2: TButton;
    RadioGroup2: TRadioGroup;
    procedure Button1Click(Sender: TObject);
    procedure btnActualizarLogClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnIniciarLogClick(Sender: TObject);
    procedure btnDetenerLogClick(Sender: TObject);
    procedure btnLimpiarLogClick(Sender: TObject);
    procedure tmrLogUpdateTimer(Sender: TObject);
    procedure btnConectarClick(Sender: TObject);
    procedure btnDesconectarClick(Sender: TObject);
    procedure btnEstadoConexionClick(Sender: TObject);
    procedure tmrVerificarConexionTimer(Sender: TObject);
    procedure rgTipoConexionClick(Sender: TObject);
    procedure edtServidorChange(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    FLastLogCount: Integer;

    procedure ActualizarLog;
    procedure IniciarMonitorLog;
    procedure DetenerMonitorLog;
    procedure Log(const AMensaje: string);

    procedure ConectarAlServidor;
    procedure DesconectarDelServidor;
    procedure ActualizarEstadoConexion;
    procedure HabilitarControlesConexion;
    function VerificarConexion: Boolean;
    procedure ConfigurarCampoServidor;
    function ObtenerNombreServidor: string;
  public
    { Public declarations }
    frmFactura: TfrmFactura;
    frmProductos: TfrmProductos;
    FrmClientes: TFrmClientes;
    FrmViewFactura : TFrmViewFactura;
    frmClienteAPI : TfrmClienteAPI;
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

uses uDatamodule, DB, CustomMsgDlg, Dialogs, Graphics, StrUtils, 
  ServidorDatos_TLB;

{$R *.dfm}

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  // Configurar el sistema de logging
  memoLog.Clear;
  Log('Formulario principal iniciado');
  
  // Inicializar configuración de conexión
  ConfigurarCampoServidor;  // Configurar estado inicial
  
  // Inicializar variables de control para el timer
  FLastLogCount := 0;
  if Assigned(dmCliente) then
    FLastLogCount := dmCliente.LogCount;
  
  // Iniciar el monitor de log con timer
  IniciarMonitorLog;
  
  // Actualizar estado inicial de la conexión
  ActualizarEstadoConexion;
end;

procedure TFrmPrincipal.Log(const AMensaje: string);
begin
  // Agregar línea al memo con timestamp
  memoLog.Lines.Add(FormatDateTime('hh:nn:ss', Now) + ' - ' + AMensaje);
  
  // Auto-scroll
  memoLog.SelStart := Length(memoLog.Text);
  memoLog.SelLength := 0;
end;

procedure TFrmPrincipal.rgTipoConexionClick(Sender: TObject);
begin
  ConfigurarCampoServidor;
end;

procedure TFrmPrincipal.ConfigurarCampoServidor;
begin
  // Habilitar/deshabilitar y configurar el campo de servidor
  case rgTipoConexion.ItemIndex of
    0: begin // Local
      edtServidor.Enabled := False;
      edtServidor.Text := 'localhost';
      edtServidor.Color := clBtnFace;
      edtServidor.EditLabel.Enabled := False;
    end;
    1: begin // Remota
      edtServidor.Enabled := True;
      edtServidor.Text := '192.168.5.103'; // Valor por defecto
      edtServidor.Color := clWindow;
      edtServidor.EditLabel.Enabled := True;
    end;
  end;
end;

function TFrmPrincipal.ObtenerNombreServidor: string;
begin
  case rgTipoConexion.ItemIndex of
    0: Result := ''; // Local - string vacío para conexión local
    1: Result := Trim(edtServidor.Text); // Remoto - usar el texto del edit
  else
    Result := '';
  end;
end;

procedure TFrmPrincipal.tmrVerificarConexionTimer(Sender: TObject);
begin
  HabilitarControlesConexion;
end;

procedure TFrmPrincipal.tmrLogUpdateTimer(Sender: TObject);
begin
  ActualizarLog;
end;

procedure TFrmPrincipal.ActualizarEstadoConexion;
var
  Estado: string;
begin
  if not Assigned(dmCliente) then
  begin
    Log('DataModule no disponible para verificar estado');
    Exit;
  end;

  if dmCliente.Conexion.Connected then
    Estado := 'CONECTADO'
  else
    Estado := 'DESCONECTADO';

  Log('Estado de conexión: ' + Estado);
  HabilitarControlesConexion;
end;

function TFrmPrincipal.VerificarConexion: Boolean;
begin
  Result := False;
  if not Assigned(dmCliente) then
  begin
    Log('ERROR: DataModule no asignado para verificar conexión');
    CtmMsgDlg('','No se puede verificar la conexión: DataModule no disponible',mtError,['Aceptar'],0,False);
    Exit;
  end;

  Result := dmCliente.Conexion.Connected;

  if not Result then
  begin
    Log('No hay conexión al servidor');
    CtmMsgDlg('','Primero debe conectar al servidor',mtError,['Aceptar'],0,False);
  end;
end;

procedure TFrmPrincipal.ActualizarLog;
begin
  if not Assigned(dmCliente) then
    Exit;

  // Versión simple: Reemplazar todo el contenido
  memoLog.Lines.Text := dmCliente.LogContent;
  
  // Auto-scroll al final
  memoLog.SelStart := Length(memoLog.Text);
  memoLog.SelLength := 0;
  
  // Actualizar el contador
  FLastLogCount := dmCliente.LogCount;
end;

procedure TFrmPrincipal.IniciarMonitorLog;
begin
  tmrLogUpdate.Enabled := True;

  // Sincronizar el contador de logs
  if Assigned(dmCliente) then
    FLastLogCount := dmCliente.LogCount;

  Log('Sistema de logging activado (actualización cada ' +
      IntToStr(tmrLogUpdate.Interval) + ' ms)');

  CtmMsgDlg('','Logging activado. Actualizando cada ' +
              IntToStr(tmrLogUpdate.Interval) + ' ms',mtInformation,['Aceptar'],0,False);
end;

procedure TFrmPrincipal.DesconectarDelServidor;
begin
  if not Assigned(dmCliente) then
  begin
    Log('ERROR: DataModule no asignado');
    Exit;
  end;

  try
    Log('Desconectando del servidor...');
    dmCliente.DesconectarServidor;
    Log('Desconexión exitosa');
    CtmMsgDlg('','Desconectado del servidor',mtInformation,['Aceptar'],0,False);

    ActualizarEstadoConexion;

  except
    on E: Exception do
    begin
      Log('Error al desconectar: ' + E.Message);
      CtmMsgDlg('','Error al desconectar: ' + E.Message,mtError,['Aceptar'],0,False);
    end;
  end;
end;

procedure TFrmPrincipal.DetenerMonitorLog;
begin
  tmrLogUpdate.Enabled := False;
  Log('Sistema de logging desactivado');
  CtmMsgDlg('','Logging desactivado. Timer detenido.',mtInformation,['Aceptar'],0,False);
end;

procedure TFrmPrincipal.edtServidorChange(Sender: TObject);
begin
  // Validación básica: no permitir vacío en modo remoto
  if (rgTipoConexion.ItemIndex = 1) and (Trim(edtServidor.Text) = '') then
  begin
    edtServidor.Color := clRed;
    btnConectar.Enabled := False;
  end
  else
  begin
    edtServidor.Color := clWindow;
    btnConectar.Enabled := True;
  end;
end;

procedure TFrmPrincipal.btnActualizarLogClick(Sender: TObject);
begin
  ActualizarLog;
end;

procedure TFrmPrincipal.btnConectarClick(Sender: TObject);
begin
  ConectarAlServidor;
end;

procedure TFrmPrincipal.btnDesconectarClick(Sender: TObject);
begin
  DesconectarDelServidor;
end;

procedure TFrmPrincipal.btnDetenerLogClick(Sender: TObject);
begin
  DetenerMonitorLog;
end;

procedure TFrmPrincipal.btnEstadoConexionClick(Sender: TObject);
var
  InfoServidor: string;
begin
  if not Assigned(dmCliente) then
    Exit;

  InfoServidor := IfThen(dmCliente.Conexion.ComputerName = '',
    'LOCAL', dmCliente.Conexion.ComputerName);
    
  CtmMsgDlg('',Format('Estado de conexión:' + sLineBreak +
                    'Servidor: %s' + sLineBreak +
                    'Conectado: %s' + sLineBreak +
                    'GUID: %s' + sLineBreak +
                    'Nombre: %s',
    [InfoServidor,
     BoolToStr(dmCliente.Conexion.Connected, True),
     dmCliente.Conexion.ServerGUID,
     dmCliente.Conexion.ServerName]),mtInformation,['Aceptar'],0,False);
     
  ActualizarEstadoConexion;
end;

procedure TFrmPrincipal.btnIniciarLogClick(Sender: TObject);
begin
  IniciarMonitorLog;
end;

procedure TFrmPrincipal.btnLimpiarLogClick(Sender: TObject);
begin
  memoLog.Clear;
  Log('Log limpiado manualmente');
end;

procedure TFrmPrincipal.Button1Click(Sender: TObject);
begin
  if not VerificarConexion then
    Exit;

  case RadioGroup1.ItemIndex of
    0: begin
      frmProductos := TfrmProductos.Create(Self);
      try
        if frmProductos.Inicializar then
          frmProductos.ShowModal;
      finally
        FreeAndNil(frmProductos);
      end;
    end;

    1: begin
      FrmClientes := TFrmClientes.Create(Self);
      try
        if FrmClientes.Inicializar then
          FrmClientes.ShowModal;
      finally
        FreeAndNil(FrmClientes);
      end;
    end;

    2: begin
      frmFactura := TfrmFactura.Create(Self);
      try
        if frmFactura.Inicializar then
          frmFactura.ShowModal;
      finally
        FreeAndNil(frmFactura);
      end;
    end;
  end;
end;

procedure TFrmPrincipal.Button2Click(Sender: TObject);
begin
//  if not VerificarConexionAPI then
//    Exit;

  case RadioGroup2.ItemIndex of
    0: begin
      frmClienteAPI := TfrmClienteAPI.Create(Self);
      try
        if frmClienteAPI.Inicializar then
          frmClienteAPI.ShowModal;
      finally
        FreeAndNil(frmClienteAPI);
      end;
    end;

    1: begin
      FrmViewFactura:= TFrmViewFactura.Create(Self);
      try
        if FrmViewFactura.Inicializar then
          FrmViewFactura.ShowModal;
      finally
        FreeAndNil(FrmViewFactura);
      end;
    end;
  end;
end;

procedure TFrmPrincipal.ConectarAlServidor;
var
  Servidor: string;

  ServidorDCOM: IServidorDCOM;
  Respuesta: WideString;
begin
  if not Assigned(dmCliente) then
  begin
    Log('ERROR: DataModule no asignado');
    CtmMsgDlg('','DataModule no está disponible',mtWarning,['Aceptar'],0,False);
    Exit;
  end;

  try
    // Obtener el nombre del servidor según la selección
    Servidor := ObtenerNombreServidor;

    Log(Format('Intentando conectar al servidor: %s',
        [IfThen(Servidor = '', 'LOCAL', Servidor)]));

    // Configurar el ComputerName en el DataModule
    dmCliente.Conexion.ComputerName := Servidor;

    if dmCliente.ConectarServidor then
    begin
      Log('Conexión al servidor exitosa');

      try
        ServidorDCOM := CoServidorDCOM.CreateRemote(dmCliente.Conexion.ComputerName);
        Respuesta := ServidorDCOM.Saludar('Rodolfo');
        CtmMsgDlg('','Respuesta del servidor: ' + Respuesta,mtInformation,['Aceptar'],0,False);
      except
        on E: Exception do
          CtmMsgDlg('','Error llamando a Saludar: ' + E.Message,mtError,['Aceptar'],0,False);
      end;

      CtmMsgDlg('',Format('Conexión establecida correctamente a %s',
        [IfThen(Servidor = '', 'servidor local', Servidor)]),mtinformation,['Aceptar'],0,False);
    end
    else
    begin
      Log('No se pudo conectar al servidor');
      CtmMsgDlg('','No se pudo establecer la conexión',mtError,['Aceptar'],0,False);
    end;
    
    ActualizarEstadoConexion;
    
  except
    on E: Exception do
    begin
      Log('Error al conectar: ' + E.Message);
      ctmMsgDlg('','Error al conectar: ' + E.Message,mtError,['Aceptar'],0,False);
    end;
  end;
end;

procedure TFrmPrincipal.FormDestroy(Sender: TObject);
begin
  // Desactivar el timer al cerrar
  tmrLogUpdate.Enabled := False;
  Log('Aplicación finalizada');
end;

procedure TFrmPrincipal.HabilitarControlesConexion;
var
  EstaConectado: Boolean;
begin
  if not Assigned(dmCliente) then
    Exit;

  EstaConectado := dmCliente.Conexion.Connected;
  
  // Controles de conexión
  btnConectar.Enabled := not EstaConectado;
  btnDesconectar.Enabled := EstaConectado;
  btnEstadoConexion.Enabled := True;

  // Controles de operaciones de datos
  Button1.Enabled := EstaConectado;

  // Controles de log (siempre habilitados)
  btnActualizarLog.Enabled := True;
  btnIniciarLog.Enabled := True;
  btnDetenerLog.Enabled := True;
  btnLimpiarLog.Enabled := True;

  // Feedback visual
  if EstaConectado then
  begin
    pnlEstadoConexion.Color := clLime;
    pnlEstadoConexion.Font.Color := clBlack;
  end
  else
  begin
    pnlEstadoConexion.Color := clRed;
    pnlEstadoConexion.Font.Color := clWhite;
  end;
end;

end.
