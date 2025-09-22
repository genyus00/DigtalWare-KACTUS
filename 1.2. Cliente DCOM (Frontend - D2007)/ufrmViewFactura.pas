unit ufrmViewFactura;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ButtonComps, ExtCtrls, ComCtrls, ToolWin, Buttons, DBDateTimePicker,
  Grids, DCGrids, DCDBGrids, StdCtrls, Mask, DBCtrls,
  ImgList, DB, DBClient;

type
  TFrmViewFactura = class(TForm)
    BUDU: TEdit;
    Panel86: TPanel;
    Panel88: TPanel;
    Panel156: TPanel;
    Label2: TLabel;
    Panel163: TPanel;
    Label96: TLabel;
    Label104: TLabel;
    RxCliente: TDBEdit;
    Panel165: TPanel;
    StaticText1: TStaticText;
    grd_detalle: TDCDBGrid;
    cedula_c: TDBEdit;
    Panel4: TPanel;
    Shape4: TShape;
    Label4: TLabel;
    Panel5: TPanel;
    Shape8: TShape;
    DBEdit1: TDBEdit;
    Panel3: TPanel;
    Shape6: TShape;
    Panel1: TPanel;
    Shape1: TShape;
    Label3: TLabel;
    Panel95: TPanel;
    Panel9: TPanel;
    Image4: TImage;
    Label72: TLabel;
    Panel10: TPanel;
    Image5: TImage;
    tb_cerrar: TImageButton;
    Bevel1: TBevel;
    dsDetalle: TDataSource;
    dsFactura: TDataSource;
    cdsDetalle: TClientDataSet;
    cdsDetalleProducto: TStringField;
    cdsDetalleCantidad: TIntegerField;
    fltfldDetalleValorUnitario: TFloatField;
    fltfldDetalleSubtotal: TFloatField;
    cdsFactura: TClientDataSet;
    cdsFacturaNumero: TIntegerField;
    cdsFacturaFecha: TStringField;
    cdsFacturaClienteId: TIntegerField;
    cdsFacturaClienteNombre: TStringField;
    cdsFacturaDireccion: TStringField;
    cdsFacturaTotal: TFloatField;
    Direccion_c: TDBEdit;
    DBEdit2: TDBEdit;
    Label1: TLabel;
    BtnGetFactura: TButton;
    edtfacturaid: TEdit;
    dbedtFecha: TDBEdit;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure Image4MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CreateParams(var Params: TCreateParams); override;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnGetFacturaClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tb_cerrarClick(Sender: TObject);
  private
    { Private declarations }
    procedure GetFactura(const URL: string);
    procedure MostrarFacturaEnClientDataSet(const JsonStr: string);
    function TryISO8601ToDate(const ISOStr: string;
      out Date: TDateTime): Boolean;
  public
    { Public declarations }
    URL: string;
    function Inicializar: Boolean;
  end;

implementation

uses
  superobject, IdHTTP, CustomMsgDlg, ufunciones;

{$R *.dfm}

procedure TFrmViewFacTura.BtnGetFacturaClick(Sender: TObject);
var
  strURL: string;
begin
  cdsFactura.EmptyDataSet;
  cdsDetalle.EmptyDataSet;
  strURL := URL + '/facturas/' + edtfacturaid.Text;
  GetFactura(strURL);
end;

procedure TFrmViewFactura.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    WinClassName := 'RAJB_SRC';
    Style := (Style or WS_POPUP) and not WS_DLGFRAME;
  end;
end;

procedure TFrmViewFactura.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    Perform(WM_NEXTDLGCTL, 0, 0);
  end;
end;

procedure TFrmViewFactura.Image4MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  Perform(WM_SYSCOMMAND, $F012, 0);
end;

procedure TFrmViewFactura.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Asegurarse de liberar el formulario si fue creado dinámicamente
  cdsFactura.Close;
  cdsDetalle.Close;
  Action := caFree;
end;

procedure TFrmViewFacTura.FormCreate(Sender: TObject);
begin
//  cdsFactura.CreateDataSet;
//  cdsDetalle.CreateDataSet;
end;

procedure TFrmViewFactura.GetFactura(const URL: string);
var
  IdHTTP: TIdHTTP;
  RespStr: string;
  JsonResp: ISuperObject;
begin
  IdHTTP := TIdHTTP.Create(nil);
  try
    IdHTTP.HandleRedirects := True;
    IdHTTP.Request.Accept := 'application/json';

    try
      // Ejecutar GET
      RespStr := IdHTTP.Get(URL);

      // Procesar JSON una sola vez
      JsonResp := SO(RespStr);
      if Assigned(JsonResp) then
      begin
        MostrarFacturaEnClientDataSet(JsonResp.AsJSON); // llena los ClientDataSet
        //ShowMessage(JsonResp.S['message']);             // mostrar mensaje del servidor
      end
      else
        CtmMsgDlg('','Respuesta JSON no válida.',mtError,['Aceptar'],0,False);

    except
      on E: Exception do
        CtmMsgDlg('','Error GET /facturas: ' + E.Message,mtError,['Aceptar'],0,False);
    end;

  finally
    IdHTTP.Free;
  end;
end;

procedure TFrmViewFactura.MostrarFacturaEnClientDataSet(const JsonStr: string);
var
  JsonResp, JsonData, JsonCliente, JsonDetalle, JsonProd: ISuperObject;
  JsonArray: TSuperArray;
  i: Integer;
  Subtotal: Double;
  CodError: Integer;
  Msg, FechaStr: string;
  FechaDt: TDateTime;
  TmpStr: string;
begin
  // Parsear JSON
  JsonResp := SO(JsonStr);
  if JsonResp = nil then Exit;

  try
    // Leer código de error de manera segura
    TmpStr := JsonResp.S['codError'];
    if TmpStr <> '' then
      CodError := StrToIntDef(TmpStr, -1)
    else
      CodError := JsonResp.I['codError'];

    if CodError <> 0 then
    begin
      Msg := JsonResp.S['errorMsg'];
      CtmMsgDlg('','Código: ' + IntToStr(CodError) + sLineBreak + 'Mensaje: ' + Msg,mtError,['Aceptar'],0,False);
      Exit;
    end;

    // Leer objeto data
    JsonData := JsonResp.O['data'];
    if JsonData = nil then Exit;

    JsonCliente := JsonData.O['cliente'];

    // Llenar dataset de factura
    cdsFactura.Append;
    cdsFactura.FieldByName('Numero').AsInteger := JsonData.I['numero'];

    // Convertir fecha ISO8601
    FechaStr := JsonData.S['fecha'];
    if TryISO8601ToDate(FechaStr, FechaDt) then
      FechaStr := FormatDateTime('dd/mm/yyyy', FechaDt);

    cdsFactura.FieldByName('Fecha').AsString := FechaStr;
    cdsFactura.FieldByName('ClienteId').AsInteger := JsonData.I['clienteId'];

    if JsonCliente <> nil then
    begin
      cdsFactura.FieldByName('ClienteNombre').AsString := JsonCliente.S['nombreCliente'];
      cdsFactura.FieldByName('Direccion').AsString := JsonCliente.S['direccion'];
    end;

    cdsFactura.FieldByName('Total').AsFloat := JsonData.D['total'];
    cdsFactura.Post;

    // Llenar detalles
    JsonArray := JsonData.A['detalles'];
    if JsonArray <> nil then
    begin
      for i := 0 to JsonArray.Length - 1 do
      begin
        JsonDetalle := JsonArray.O[i];
        if JsonDetalle = nil then Continue;

        JsonProd := JsonDetalle.O['producto'];
        Subtotal := JsonDetalle.I['cantidad'] * JsonDetalle.D['valor'];

        cdsDetalle.Append;
        if JsonProd <> nil then
          cdsDetalle.FieldByName('Producto').AsString := JsonProd.S['nombreProducto']
        else
          cdsDetalle.FieldByName('Producto').AsString := 'N/A';

        cdsDetalle.FieldByName('Cantidad').AsInteger := JsonDetalle.I['cantidad'];
        cdsDetalle.FieldByName('ValorUnitario').AsFloat := JsonDetalle.D['valor'];
        cdsDetalle.FieldByName('Subtotal').AsFloat := Subtotal;
        cdsDetalle.Post;
      end;
    end;

  except
    on E: Exception do
      CtmMsgDlg('','Error procesando factura: ' + E.Message,mtError,['Aceptar'],0,False);
  end;
end;

procedure TFrmViewFactura.tb_cerrarClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

function TFrmViewFactura.TryISO8601ToDate(const ISOStr: string; out Date: TDateTime): Boolean;
var
  Year, Month, Day: Word;
begin
  Result := False;

  // Formato simple: YYYY-MM-DD
  if Length(ISOStr) >= 10 then
  begin
    try
      Year := StrToIntDef(Copy(ISOStr, 1, 4), 0);
      Month := StrToIntDef(Copy(ISOStr, 6, 2), 0);
      Day := StrToIntDef(Copy(ISOStr, 9, 2), 0);

      if (Year >= 1900) and (Month in [1..12]) and (Day in [1..31]) then
      begin
        Date := EncodeDate(Year, Month, Day);
        Result := True;
      end;
    except
      Result := False;
    end;
  end;
end;

function TFrmViewFactura.Inicializar: Boolean;
begin
  Result := False;
  try
    cdsFactura.CreateDataSet;
    cdsDetalle.CreateDataSet;
    URL := GetWebApiUrl(ExtractFilePath(Application.ExeName) + 'params.ini');
    Result := URL <> EmptyStr;
  except
    on E: Exception do
      CtmMsgDlg('Error', PChar('No se pudo inicializar Factura: ' + E.Message), mtError, ['Aceptar'], 0, False);
  end;
end;

end.

