unit ufrmClienteAPI;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DB, DBClient, Grids, DBGrids, Mask, DBCtrls, IdHTTP, IdSSLOpenSSL, IdSSLOpenSSLHeaders,
  IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient;

type
  TfrmClienteAPI = class(TForm)
    grpClientes: TGroupBox;
    edtidcliente: TEdit;
    Label1: TLabel;
    edtnombrecliente: TEdit;
    lbl1: TLabel;
    edtdireccioncliente: TEdit;
    lbl2: TLabel;
    BtnCrearCliente: TButton;
    procedure BtnCrearClienteClick(Sender: TObject);
  private
    procedure ShowApiResponse(const JsonStr: string);
  public
    URL : string;
    function Inicializar:Boolean;
  end;

implementation

uses
  SuperObject, ufunciones;

{$R *.dfm}

procedure TfrmClienteAPI.BtnCrearClienteClick(Sender: TObject);
var
  JsonObj: ISuperObject;
  JsonString: string;
  Stream: TStringStream;
  strURL, RespStr: string;
  IdHTTP: TIdHTTP;
  // SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  // Crear objeto JSON con SuperObject
  JsonObj := SO;
  JsonObj.I['ClienteId'] := StrToIntDef(edtidcliente.Text, 0);
  JsonObj.S['NombreCliente'] := edtnombrecliente.Text;
  JsonObj.S['Direccion'] := edtdireccioncliente.Text;

  // Convertir a string JSON
  JsonString := JsonObj.AsJSon;

  // Configurar HTTP y SSL
  IdHTTP := TIdHTTP.Create(nil);
  // SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);

  try
    try
      // Configurar SSL
      // SSLHandler.SSLOptions.Method := sslvTLSv1;
      // SSLHandler.SSLOptions.Mode := sslmClient;
      // SSLHandler.SSLOptions.VerifyMode := [];
      // SSLHandler.SSLOptions.VerifyDepth := 0;
      // IdHTTP.IOHandler := SSLHandler;

      IdHTTP.HandleRedirects := True;
      IdHTTP.Request.ContentType := 'application/json';
      IdHTTP.Request.Accept := 'application/json';

      // Crear stream con el JSON
      Stream := TStringStream.Create(JsonString);
      try
        // Enviar POST
        strURL := URL + '/clientes';
        RespStr := IdHTTP.Post(strURL, Stream);
        ShowApiResponse(RespStr);
      finally
        Stream.Free;
      end;

    except
      on E: Exception do
        ShowMessage('Error POST /clientes: ' + E.Message);
    end;
  finally
    IdHTTP.Free;
    // SSLHandler se libera automáticamente al liberar IdHTTP
  end;
end;

function TfrmClienteAPI.Inicializar: Boolean;
begin
  try
    URL := GetWebApiUrl(ExtractFilePath(Application.ExeName) + 'params.ini');
    Result := URL <> EmptyStr;
   except
    Result := False;
  end;
end;

procedure TfrmClienteAPI.ShowApiResponse(const JsonStr: string);
var
  JsonObj: ISuperObject;
  CodError: Integer;
  Msg: string;
begin
  // Parsear JSON con SuperObject
  JsonObj := SO(JsonStr);
  
  if not Assigned(JsonObj) then
  begin
    ShowMessage('Respuesta no válida: ' + JsonStr);
    Exit;
  end;

  try
    // Leer valores del JSON
    CodError := JsonObj.I['codError'];  // Para integer
    // O si codError es string: CodError := StrToIntDef(JsonObj.S['codError'], -1);
    
    if CodError <> 0 then
    begin
      Msg := JsonObj.S['errorMsg'];     // Para string
      ShowMessage('Código: ' + IntToStr(CodError) + sLineBreak + 'Mensaje: ' + Msg);
      Exit;
    end;

    Msg := JsonObj.S['message'];
    ShowMessage(Msg);
  except
    on E: Exception do
      ShowMessage('Error leyendo JSON: ' + E.Message);
  end;
end;

end.

