unit UServidorDCOM;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, Messages, Classes, ComServ, ComObj, VCLCom, DataBkr,
  DBClient, ServidorDatos_TLB, StdVcl, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.PG,
  FireDAC.Phys.PGDef, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, Datasnap.Provider, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.SysUtils, TypInfo,Registry;

type
  TServidorDCOM = class(TRemoteDataModule, IServidorDCOM)
    FDConnection1: TFDConnection;
    FDTransaction1: TFDTransaction;
    qryProductos: TFDQuery;
    qryProductosproducto: TIntegerField;
    qryDetalle_Factura: TFDQuery;
    qryFacturas: TFDQuery;
    qryClientes: TFDQuery;
    qryClientescliente: TIntegerField;
    dtpProductos: TDataSetProvider;
    dtpDetalle_Factura: TDataSetProvider;
    dtpFacturas: TDataSetProvider;
    dtpClientes: TDataSetProvider;
    qryFacturasnumero: TIntegerField;
    qryFacturasfecha: TDateField;
    qryFacturascliente: TIntegerField;
    qryFacturastotal: TFloatField;
    qryDetalle_Facturanumero: TIntegerField;
    qryDetalle_Facturaproducto: TIntegerField;
    qryDetalle_Facturacantidad: TIntegerField;
    qryDetalle_Facturavalor: TFloatField;
    qryConsulta: TFDQuery;
    dtpConsulta: TDataSetProvider;
    qryClientesnombre_cliente: TWideStringField;
    qryClientesdireccion: TWideStringField;
    qryProductosvalor: TFloatField;
    qryProductosnombre_producto: TWideStringField;
    procedure FDConnection1BeforeConnect(Sender: TObject);
    procedure dtpProductosUpdateError(Sender: TObject;
      DataSet: TCustomClientDataSet; E: EUpdateError; UpdateKind: TUpdateKind;
      var Response: TResolverResponse);
    procedure RemoteDataModuleCreate(Sender: TObject);	  
  private
    { Private declarations }
  protected
    class procedure UpdateRegistry(Register: Boolean; const ClassID, ProgID: string); override;
    procedure Activar; safecall;
    procedure Desactivar; safecall;
    function Saludar(Nombre: OleVariant): OleVariant; safecall;

  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  Vcl.Forms, Vcl.Dialogs, uCustomMsgDlg, System.Variants;

{$R *.DFM}

constructor TServidorDCOM.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  // Configuración específica para Windows XP
  FDConnection1.LoginPrompt := False;
end;

procedure TServidorDCOM.RemoteDataModuleCreate(Sender: TObject);
begin
  // Configuración adicional si es necesaria
end;

function TServidorDCOM.Saludar(Nombre: OleVariant): OleVariant;
begin
  Result := '¡Hola ' + VarToStr(Nombre) + '! Te saludo desde el servidor DCOM.';
end;

procedure TServidorDCOM.FDConnection1BeforeConnect(Sender: TObject);
var
  rutaDB: string;
  iniFile: TStringList;
begin
  rutaDB := ExtractFilePath(Application.ExeName) + 'FDConnection1.Params';

  if not FileExists(rutaDB) then
  begin
    // Crear archivo de configuración por defecto para XP
    iniFile := TStringList.Create;
    try
      iniFile.Add('DriverID=PG');
      iniFile.Add('Server=localhost');
      iniFile.Add('Database=DBDW_Test');
      iniFile.Add('User_Name=postgres');
      iniFile.Add('Password=Asdf1234$');
      iniFile.Add('Port=5432');
      iniFile.SaveToFile(rutaDB);
    finally
      iniFile.Free;
    end;
  end;

  FDConnection1.Params.LoadFromFile(rutaDB);
end;

class procedure TServidorDCOM.UpdateRegistry(Register: Boolean; const ClassID, ProgID: string);
var
  Reg: TRegistry;
begin
  if Register then
  begin
    inherited UpdateRegistry(Register, ClassID, ProgID);
    // Para Windows XP, usar solo socket transport
    EnableSocketTransport(ClassID);

    // Configuración específica para DCOM en XP
    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_CLASSES_ROOT;
      if Reg.OpenKey('AppID\' + ClassID, True) then
      begin
        Reg.WriteString('RunAs', 'Interactive User');
        Reg.CloseKey;
      end;
    finally
      Reg.Free;
    end;
  end
  else
  begin
    DisableSocketTransport(ClassID);
    inherited UpdateRegistry(Register, ClassID, ProgID);
  end;
end;

procedure TServidorDCOM.Activar;
begin
  if not FDConnection1.Connected then
    FDConnection1.Connected := True;
end;

procedure TServidorDCOM.Desactivar;
begin
  if FDConnection1.Connected then
    FDConnection1.Connected := False;
end;

procedure TServidorDCOM.dtpProductosUpdateError(Sender: TObject;
  DataSet: TCustomClientDataSet; E: EUpdateError; UpdateKind: TUpdateKind;
  var Response: TResolverResponse);
begin
  ShowMessage(
    'Error en ApplyUpdates:' + sLineBreak +
    'UpdateKind: ' + GetEnumName(TypeInfo(TUpdateKind), Ord(UpdateKind)) + sLineBreak +
    'Mensaje: ' + E.Message
  );
  Response := rrAbort;
end;

initialization
{$IFDEF DEBUG}
  TComponentFactory.Create(ComServer, TServidorDCOM,
    Class_ServidorDCOM, ciMultiInstance, tmApartment);//cada cliente tiene su propia instancia.
{$ELSE}
  TComponentFactory.Create(ComServer, TServidorDCOM,
    Class_ServidorDCOM, ciSingleInstance, tmApartment);//todos comparten la misma (mucho más eficiente)
{$ENDIF}
end.
