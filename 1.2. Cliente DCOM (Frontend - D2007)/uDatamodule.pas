unit uDatamodule;

interface

uses
  SysUtils, Classes, DB, DBClient, MConnect, Dialogs, IniFiles, StrUtils,
  ComObj, Variants, ActiveX;

type
  TdmCliente = class(TDataModule)
    Conexion: TDCOMConnection;
    cdsClientes: TClientDataSet;
    cdsProductos: TClientDataSet;
    cdsFacturas: TClientDataSet;
    cdsDetalle_Factura: TClientDataSet;
    cdsConsulta: TClientDataSet;
    dtssClientes: TDataSource;
    dtsProductos: TDataSource;
    dtsFacturas: TDataSource;
    dtsDetalle_Factura: TDataSource;
    cdsProductosproducto: TIntegerField;
    cdsFacturasnumero: TIntegerField;
    cdsFacturascliente: TIntegerField;
    cdsFacturasfecha: TDateField;
    cdsFacturastotal: TFloatField;
    cdsDetalle_Facturanumero: TIntegerField;
    cdsDetalle_Facturaproducto: TIntegerField;
    cdsDetalle_Facturacantidad: TIntegerField;
    cdsDetalle_Facturavalor: TFloatField;
    cdsDetalle_Facturaitem: TStringField;
    cdsFacturasCARTOT: TAggregateField;
    cdsDetalle_FacturaSUMTOT: TAggregateField;
    cdsDetalle_FacturaSUBT: TFloatField;
    cdsClientescliente: TIntegerField;
    cdsClientesnombre_cliente: TWideStringField;
    cdsClientesdireccion: TWideStringField;
    cdsProductosvalor: TFloatField;
    cdsProductosnombre_producto: TWideStringField;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure ConexionBeforeConnect(Sender: TObject);
    procedure cdsClientesDeleteError(DataSet: TDataSet; E: EDatabaseError; 
      var Action: TDataAction);
    procedure cdsProductosDeleteError(DataSet: TDataSet; E: EDatabaseError; 
      var Action: TDataAction);
    procedure cdsFacturasNewRecord(DataSet: TDataSet);
    procedure cdsFacturasPostError(DataSet: TDataSet; E: EDatabaseError; 
      var Action: TDataAction);
    procedure cdsDetalle_FacturaPostError(DataSet: TDataSet; E: EDatabaseError; 
      var Action: TDataAction);
    procedure cdsDetalle_FacturaCalcFields(DataSet: TDataSet);
    procedure cdsDetalle_FacturaAfterDelete(DataSet: TDataSet);
    procedure cdsDetalle_FacturaproductoChange(Sender: TField);
    procedure cdsFacturasnumeroChange(Sender: TField);
  private
    { Private declarations }
    FIniFilePath: string;
    FLogLines: TStringList;  // StringList para logging

    function LeerParametrosINI: Boolean;
    function ValidarConfiguracionINI: Boolean;
    function GetLogContent: string;

    procedure IntentaConectar;
    procedure ConfigurarConexionDesdeINI;
    procedure Log(const AMensaje: string);
    function GetLogCount: Integer;
    function GetLogLines: TStrings;

  public
    { Public declarations }
    procedure TratarExcepciones(DataSet: TDataSet; E: Exception; const Tabla: string);
    function FoundField(ADataSet: TClientDataSet; const AField: string; AValue: Variant): Boolean;
    function ExisteFacturaConNumero(ANumero: Integer): Boolean;

    // métodos seguros para operaciones con datasets
    function AbrirCDS(cds: TClientDataSet; const Nombre: string): Boolean;
    function GuardarCambios(cds: TClientDataSet; const Nombre: string): Boolean;
    function ConectarServidor: Boolean;
    procedure DesconectarServidor;
    procedure ClearLog;

    property IniFilePath: string read FIniFilePath;
    property LogContent: string read GetLogContent;
    property LogCount: Integer read GetLogCount;
    property LogLines: TStrings read GetLogLines;
  end;

var
  dmCliente: TdmCliente;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  CustomMsgDlg, Forms, uFrmPrincipal;

{ TdmCliente }

procedure TdmCliente.DataModuleCreate(Sender: TObject);
begin
  FLogLines := TStringList.Create;
  FIniFilePath := ExtractFilePath(Application.ExeName) + 'Params.ini';

  Log('DataModule creado. Ruta INI: ' + FIniFilePath);
  // Solo intentar conectar si el archivo INI existe y es válido
  if ValidarConfiguracionINI then
    IntentaConectar
  else
    Log('Archivo de configuración no encontrado');
end;

procedure TdmCliente.DataModuleDestroy(Sender: TObject);
begin
  DesconectarServidor;
  FLogLines.Free;
end;

function TdmCliente.ValidarConfiguracionINI: Boolean;
begin
  Result := FileExists(FIniFilePath);
  if not Result then
  begin
    CtmMsgDlg('Configuración', 
      'Archivo de configuración no encontrado.' + sLineBreak +
      'Se requiere el archivo: Params.ini', 
      mtWarning, ['Aceptar'], 0, False);
  end;
end;

procedure TdmCliente.ConexionBeforeConnect(Sender: TObject);
begin
  Log('Evento BeforeConnect ejecutado');
end;

function TdmCliente.LeerParametrosINI: Boolean;
begin
  Result := False;
  if not FileExists(FIniFilePath) then
    Exit;

  // Crear el TIniFile dentro del método de configuración
  ConfigurarConexionDesdeINI;
  Result := True;
end;

procedure TdmCliente.Log(const AMensaje: string);
var
  LogLine: string;
begin
  LogLine := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now) + ' - ' + AMensaje;
  FLogLines.Add(LogLine);
end;

function TdmCliente.GetLogCount: Integer;
begin
  Result := FLogLines.Count;
end;

function TdmCliente.GetLogLines: TStrings;
begin
  Result := FLogLines;
end;

procedure TdmCliente.ConfigurarConexionDesdeINI;
var
  MyIni: TIniFile;
  ComputerNameFromINI: string;
begin
  if not FileExists(FIniFilePath) then
  begin
    Log('ERROR: Archivo INI no existe: ' + FIniFilePath);
    Exit;
  end;

  MyIni := TIniFile.Create(FIniFilePath);
  try
    ComputerNameFromINI := MyIni.ReadString('PARAMS', 'ComputerName', '');
    
    // Solo usar el valor del INI si no está vacío
    if ComputerNameFromINI <> '' then
      Conexion.ComputerName := ComputerNameFromINI;

    Conexion.ServerName := MyIni.ReadString('PARAMS', 'ServerName', '');
    Conexion.ServerGUID := MyIni.ReadString('PARAMS', 'ServerGUID', '');
    
    Log(Format('Configuración DCOM: ComputerName=%s, ServerGUID=%s, ServerName=%s',
      [Conexion.ComputerName, Conexion.ServerGUID, Conexion.ServerName]));
    
  finally
    MyIni.Free;
  end;
end;

procedure TdmCliente.IntentaConectar;
begin
  if Conexion.Connected then
  begin
    Log('Conexión ya está activa');
    Exit;
  end;

  try
    if not LeerParametrosINI then
      raise Exception.Create('No se pudieron leer los parámetros de conexión.');

    // verificar configuración antes de conectar
    Log('Intentando conectar DCOM...');
    Log(Format('ComputerName: %s', [Conexion.ComputerName]));
    Log(Format('ServerName: %s', [Conexion.ServerName]));
    Log(Format('ServerGUID: %s', [Conexion.ServerGUID]));
    
    if ConectarServidor then
    begin
      Log('Conexión DCOM exitosa');
      Exit;
    end;
    
    // Si llegamos aquí, hubo error de conexión
    Log('ERROR: No se pudo conectar al servidor DCOM');
    CtmMsgDlg('Conexión', 
      'No se pudo conectar al servidor DCOM.' + sLineBreak +
      'Verifique que el servidor esté ejecutándose y la configuración sea correcta.',
      mtWarning, ['Aceptar'], 0, False);
      
  except
    on E: Exception do
    begin
      Log('EXCEPCIÓN al conectar: ' + E.Message);
      CtmMsgDlg('Error de conexión',
        'Error al conectar con el servidor:' + sLineBreak + E.Message,
        mtError, ['Aceptar'], 0, False);
    end;
  end;
end;

procedure TdmCliente.ClearLog;
begin
  FLogLines.Clear;
end;

function TdmCliente.ConectarServidor: Boolean;
const
  RPC_E_SERVERFAULT = LongInt($80010105);
  RPC_E_CALL_REJECTED = LongInt($80010001);
  RPC_E_SERVER_NOT_AVAILABLE = LongInt($800706BA);
begin
  try
    Log('ConectarServidor: Iniciando...');
    Log(Format('Configuración DCOM: ComputerName=%s, ServerGUID=%s, ServerName=%s', 
      [Conexion.ComputerName, Conexion.ServerGUID, Conexion.ServerName]));

    if not Conexion.Connected then
    begin
      Log('Estableciendo conexión DCOM...');
      Conexion.Connected := True;
      Result := True;
      Log('Conexión DCOM establecida');
    end
    else
    begin
      Result := True;
      Log('Conexión DCOM ya estaba activa');
    end;
      
  except
    on E: EOleSysError do
    begin
      Log(Format('ERROR DCOM (0x%x): %s', [Cardinal(E.ErrorCode), E.Message]));
      
      case E.ErrorCode of
        RPC_E_SERVERFAULT:
          raise Exception.Create('Error en el servidor DCOM. Verifique que esté ejecutándose.');
        RPC_E_SERVER_NOT_AVAILABLE:
          raise Exception.CreateFmt('Servidor no disponible: %s', [Conexion.ComputerName]);
        RPC_E_CALL_REJECTED:
          raise Exception.Create('Llamada rechazada. Verifique permisos DCOM.');
        else
          raise Exception.CreateFmt('Error DCOM (0x%x): %s', [Cardinal(E.ErrorCode), E.Message]);
      end;
    end;
    on E: Exception do
    begin
      Log('EXCEPCIÓN en ConectarServidor: ' + E.Message);
      raise;
    end;
  end;
end;

procedure TdmCliente.DesconectarServidor;
begin
  if Conexion.Connected then
    Conexion.Connected := False;
end;

function TdmCliente.AbrirCDS(cds: TClientDataSet; const Nombre: string): Boolean;
begin
  Result := False;
  try
    Log(Format('Abriendo dataset: %s', [Nombre]));
    
    if not Conexion.Connected then
      ConectarServidor;
      
    if not cds.Active then
      cds.Open;
      
    Result := True;
    Log(Format('Dataset %s abierto correctamente (%d registros)', [Nombre, cds.RecordCount]));
      
  except
    on E: Exception do
    begin
      Log(Format('ERROR al abrir %s: %s', [Nombre, E.Message]));
      CtmMsgDlg('Error', 
        Format('No se pudo abrir [%s]: %s', [Nombre, E.Message]),
        mtError, ['Aceptar'], 0, False);
    end;
  end;
end;


function TdmCliente.GetLogContent: string;
begin
  Result := FLogLines.Text;
end;

function TdmCliente.GuardarCambios(cds: TClientDataSet; const Nombre: string): Boolean;
begin
  Result := False;
  try
    Log(Format('Guardando cambios en: %s', [Nombre]));
    
    if not Conexion.Connected then
      ConectarServidor;
      
    if cds.State in [dsEdit, dsInsert] then
      cds.Post;
      
    if cds.ChangeCount > 0 then
    begin
      Log(Format('Aplicando %d cambios en %s', [cds.ChangeCount, Nombre]));
      cds.ApplyUpdates(0);
    end;
      
    Result := True;
    Log(Format('Cambios en %s guardados correctamente', [Nombre]));
      
  except
    on E: Exception do
    begin
      Log(Format('ERROR al guardar %s: %s', [Nombre, E.Message]));
      CtmMsgDlg('Error', 
        Format('No se pudo guardar cambios en [%s]: %s', [Nombre, E.Message]),
        mtError, ['Aceptar'], 0, False);
      cds.CancelUpdates;
    end;
  end;
end;

procedure TdmCliente.TratarExcepciones(DataSet: TDataSet; E: Exception; const Tabla: string);
const
  ErrorMessages: array[0..5] of record
    Pattern: string;
    Message: string;
  end = (
    (Pattern: 'must have a value'; Message: 'El campo [%s] no puede ser vacío.'),
    (Pattern: 'Key violation'; Message: 'Intentando duplicar un registro existente en %s.'),
    (Pattern: 'Record not found or changed by another user'; 
     Message: 'Registro eliminado o modificado por otro usuario.'),
    (Pattern: 'violation of PRIMARY or UNIQUE KEY'; 
     Message: 'Registro duplicado en %s.'),
    (Pattern: 'violation of FOREIGN KEY'; 
     Message: 'Violación de integridad referencial en %s.'),
    (Pattern: 'Linkfields to detail must be unique'; 
     Message: 'Registro duplicado en %s.')
  );
var
  I: Integer;
  Campo, Mensaje: string;
begin
  for I := Low(ErrorMessages) to High(ErrorMessages) do
  begin
    if ContainsText(E.Message, ErrorMessages[I].Pattern) then
    begin
      if I = 0 then // Campo requerido
      begin
        Campo := StringReplace(E.Message, 'Field', '', [rfReplaceAll]);
        Campo := StringReplace(Campo, 'must have a value', '', [rfReplaceAll]);
        Campo := Trim(Campo);
        Mensaje := Format(ErrorMessages[I].Message, [Campo]);
      end
      else
        Mensaje := Format(ErrorMessages[I].Message, [Tabla]);
        
      CtmMsgDlg('Error', Mensaje, mtError, ['Aceptar'], 0, False);
      Abort;
    end;
  end;
  
  // Error no manejado específicamente
  CtmMsgDlg('Error', E.Message, mtError, ['Aceptar'], 0, False);
  Abort;
end;

function TdmCliente.FoundField(ADataSet: TClientDataSet; const AField: String; AValue: Variant): Boolean;
var
  cdsClone: TClientDataSet;
begin
  Result := False;
  if not (ADataSet.Active) or (ADataSet.RecordCount = 0) then
    Exit;

  cdsClone := TClientDataSet.Create(nil);
  try
    cdsClone.CloneCursor(ADataSet, True);
    Result := cdsClone.Locate(AField, AValue, []);
  finally
    cdsClone.Free;
  end;
end;

function TdmCliente.ExisteFacturaConNumero(ANumero: Integer): Boolean;
begin
  try
    // Usar clone cursor es más eficiente que consulta directa a BD
    if FoundField(cdsFacturas, 'numero', ANumero) then
    begin
      Result := True;
      Log(Format('Factura número %d encontrada en dataset local', [ANumero]));
    end
    else
    begin
      // Solo consultar BD si no está en el dataset local
      cdsConsulta.Close;
      cdsConsulta.CommandText := Format('SELECT 1 FROM public.cabeza_factura WHERE numero = %d', [ANumero]);
      cdsConsulta.Open;
      Result := not cdsConsulta.IsEmpty;
      
      if Result then
        Log(Format('Factura número %d encontrada en base de datos', [ANumero]));
    end;
  except
    on E: Exception do
    begin
      Log(Format('ERROR al verificar factura número %d: %s', [ANumero, E.Message]));
      Result := False;
    end;
  end;
end;

procedure TdmCliente.cdsClientesDeleteError(DataSet: TDataSet; E: EDatabaseError; 
  var Action: TDataAction);
begin
  if ContainsText(E.Message, 'FOREIGN') or 
     ContainsText(E.Message, 'Cannot delete master record with details.') then
  begin
    CtmMsgDlg('Error', 
      'No puede eliminar este registro porque tiene registros asociados.',
      mtError, ['Aceptar'], 0, False);
    Action := daAbort;
  end;
end;

procedure TdmCliente.cdsProductosDeleteError(DataSet: TDataSet; E: EDatabaseError; 
  var Action: TDataAction);
begin
  cdsClientesDeleteError(DataSet, E, Action);
end;

procedure TdmCliente.cdsFacturasNewRecord(DataSet: TDataSet);
begin
  cdsFacturascliente.Value := cdsClientescliente.Value;
  cdsFacturasfecha.Value := Date;
  cdsFacturastotal.Value := 0.0;
end;

procedure TdmCliente.cdsFacturasPostError(DataSet: TDataSet; E: EDatabaseError; 
  var Action: TDataAction);
begin
  TratarExcepciones(cdsFacturas, E, 'Facturas');
end;

procedure TdmCliente.cdsDetalle_FacturaPostError(DataSet: TDataSet; E: EDatabaseError; 
  var Action: TDataAction);
begin
  TratarExcepciones(cdsDetalle_Factura, E, 'Detalle Factura');
end;

procedure TdmCliente.cdsDetalle_FacturaCalcFields(DataSet: TDataSet);
begin
  if not cdsDetalle_Facturaproducto.IsNull then
    cdsDetalle_FacturaSUBT.AsFloat := cdsDetalle_Facturavalor.AsFloat * 
                                     cdsDetalle_Facturacantidad.AsFloat;

  if (cdsFacturas.State in [dsInsert, dsEdit]) and 
     not cdsDetalle_FacturaSUMTOT.IsNull then
  begin
    cdsFacturas.Edit;
    cdsFacturastotal.Value := cdsDetalle_FacturaSUMTOT.Value;
    cdsFacturas.Post;
  end;
end;

procedure TdmCliente.cdsDetalle_FacturaAfterDelete(DataSet: TDataSet);
begin
  if cdsFacturas.State in [dsEdit, dsInsert] then
  begin
    cdsFacturas.Edit;
    cdsFacturastotal.Value := cdsDetalle_FacturaSUMTOT.Value;
    cdsFacturas.Post;
  end;
end;

procedure TdmCliente.cdsDetalle_FacturaproductoChange(Sender: TField);
begin
  if not cdsDetalle_Facturaproducto.IsNull then
  begin
    cdsDetalle_Facturavalor.AsFloat := cdsProductosvalor.AsFloat;
    if (cdsDetalle_Factura.State in [dsInsert, dsEdit]) and 
       not cdsDetalle_Facturacantidad.IsNull then
    begin
      cdsDetalle_Factura.Post;
    end;
  end;
end;

procedure TdmCliente.cdsFacturasnumeroChange(Sender: TField);
begin
  // Solo validar durante inserción y cuando el campo no esté vacío
  if (cdsFacturas.State in [dsInsert]) and not Sender.IsNull then
  begin
    // Usar la función optimizada que verifica local + BD
    if ExisteFacturaConNumero(Sender.AsInteger) then
    begin
      CtmMsgDlg('Error', 'Ya existe una factura con el mismo número.', 
                mtError, ['Aceptar'], 0, False);
      Sender.Clear;
      Abort; // Importante: abortar la operación
    end;
  end;
end;

end.
