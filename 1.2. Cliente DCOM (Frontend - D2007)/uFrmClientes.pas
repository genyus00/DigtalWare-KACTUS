unit uFrmClientes;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, DB, DBClient, MConnect, Grids, DBGrids, ExtCtrls, DBCtrls,
  cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit,
  cxDBData, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGridLevel, cxClasses, cxControls, cxGridCustomView, cxGrid, ImgList,
  ComCtrls, ToolWin, DBClientActns, DBActns, ActnList, StdCtrls, Mask,
  ButtonComps;

type
  TFrmClientes = class(TForm)
    ActionList1: TActionList;
    DataSetFirst1: TDataSetFirst;
    DataSetPrior1: TDataSetPrior;
    DataSetNext1: TDataSetNext;
    DataSetLast1: TDataSetLast;
    DataSetInsert1: TDataSetInsert;
    DataSetDelete1: TDataSetDelete;
    DataSetEdit1: TDataSetEdit;
    DataSetPost1: TDataSetPost;
    DataSetCancel1: TDataSetCancel;
    ClientDataSetApply1: TClientDataSetApply;
    ClientDataSetUndo1: TClientDataSetUndo;
    Panel1: TPanel;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ImageList1: TImageList;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    DataSetRefresh1: TDataSetRefresh;
    ToolButton13: TToolButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    ListadoClientes: TDBGrid;
    Label1: TLabel;
    DBEdit1: TDBEdit;
    Label2: TLabel;
    DBEdit2: TDBEdit;
    Label3: TLabel;
    DBEdit3: TDBEdit;
    grd_factura: TcxGrid;
    cxGridDBTableView39: TcxGridDBTableView;
    cxGridDBpro_producto: TcxGridDBColumn;
    cxGridDBpro_nombre: TcxGridDBColumn;
    cxGridDBpro_valor: TcxGridDBColumn;
    cxGridLevel39: TcxGridLevel;
    Panel9: TPanel;
    Image4: TImage;
    Label72: TLabel;
    Panel10: TPanel;
    Image5: TImage;
    tb_cerrar: TImageButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ClientDataSetUndo1Execute(Sender: TObject);
    procedure DataSetInsert1Execute(Sender: TObject);
    procedure DataSetDelete1Execute(Sender: TObject);
    procedure DataSetEdit1Execute(Sender: TObject);
    procedure DataSetPost1Execute(Sender: TObject);
    procedure DataSetCancel1Execute(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Image4MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ClientDataSetApply1Execute(Sender: TObject);
    procedure tb_cerrarClick(Sender: TObject);
    procedure cxGridDBTableView39KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    old_nombre : string;
    function Inicializar: Boolean;
  end;

implementation

{$R *.dfm}

uses uDatamodule, CustomMsgDlg;

procedure TFrmClientes.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    WinClassName := 'RAJB_SRC';
    Style := (Style or WS_POPUP) and not WS_DLGFRAME;
  end;
end;

procedure TFrmClientes.cxGridDBTableView39KeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
  begin
    Key := 0;
    try
      DataSetDelete1Execute(nil);
    except
      on E: Exception do
        CtmMsgDlg('Error', PChar('Eliminar: ' + E.Message), mtError, ['Aceptar'], 0, False);
    end;
  end;
end;

procedure TFrmClientes.ClientDataSetApply1Execute(Sender: TObject);
begin
  if not Assigned(dmCliente) then
    Exit;

  with dmCliente do
  begin
    cdsClientes.DisableControls;
    try
      Screen.Cursor := crHourGlass;
      try
        try
          GuardarCambios(cdsClientes, 'Clientes');

        except
          on E: EDatabaseError do
          begin
            CtmMsgDlg('Error al aplicar cambios', E.Message, mtWarning, ['Aceptar'], 0, False);
            Exit;
          end;
          on E: Exception do
          begin
            CtmMsgDlg('Error inesperado', E.Message, mtError, ['Aceptar'], 0, False);
            try
              if cdsClientes.UpdateStatus <> usUnmodified then
                cdsClientes.CancelUpdates;
            except
            end;
            Exit;
          end;
        end;

        try
          if cdsClientes.Active then
            cdsClientes.Refresh;

        except
          on E: Exception do
            CtmMsgDlg('Advertencia', PChar('No fue posible refrescar datos: ' + E.Message), mtWarning, ['Aceptar'], 0, False);
        end;

      finally
        Screen.Cursor := crDefault;
      end;
    finally
      cdsClientes.EnableControls;
    end;
  end;
end;

procedure TFrmClientes.ClientDataSetUndo1Execute(Sender: TObject);
begin
  if Assigned(dmCliente) and Assigned(dmCliente.cdsClientes) then
  begin
    try
      dmCliente.cdsClientes.CancelUpdates;
    except
      on E: Exception do
        CtmMsgDlg('Error', PChar('No pudo deshacerse los cambios: ' + E.Message), mtError, ['Aceptar'], 0, False);
    end;
  end;
end;

procedure TFrmClientes.DataSetCancel1Execute(Sender: TObject);
begin
  if Assigned(dmCliente) and Assigned(dmCliente.cdsClientes) then
  begin
    try
      if dmCliente.cdsClientes.State <> dsBrowse then
        dmCliente.cdsClientes.Cancel;
    except
      on E: Exception do
        CtmMsgDlg('Error', PChar('Cancelar edición: ' + E.Message), mtError, ['Aceptar'], 0, False);
    end;
  end;
  PageControl1.ActivePage := TabSheet1;
end;

procedure TFrmClientes.DataSetDelete1Execute(Sender: TObject);
var
  s: string;
  lSingle: Boolean;
begin
  if not Assigned(dmCliente) or not Assigned(dmCliente.cdsClientes) then
    Exit;

  lSingle := (cxGridDBTableView39.Controller.SelectedRowCount <= 1);

  if lSingle then
    s := '¿Desea eliminar el registro del cliente [' + dmCliente.cdsClientes.FieldByName('nombre_cliente').AsString + '] ?'
  else
    s := '¿Desea eliminar los registro seleccionados ?';

  if CtmMsgDlg('Eliminar registro', s, mtConfirmation, ['Si', 'No'], 0, False) = 0 then
  begin
    try
      if (dmCliente.cdsClientes.RecordCount = 1) or lSingle then
      begin
        if dmCliente.cdsClientes.CanModify and (dmCliente.cdsClientes.State = dsBrowse) then
          dmCliente.cdsClientes.Delete
        else
          CtmMsgDlg('Advertencia', 'No se puede eliminar en este momento.', mtWarning, ['Aceptar'], 0, False);
      end
      else
      begin
        try
          cxGridDBTableView39.Controller.DeleteSelection;
        except
          on E: Exception do
            CtmMsgDlg('Error', PChar('Eliminando múltiples registros: ' + E.Message), mtError, ['Aceptar'], 0, False);
        end;
      end;
    except
      on E: Exception do
        CtmMsgDlg('Error', PChar('Eliminar registro: ' + E.Message), mtError, ['Aceptar'], 0, False);
    end;
  end;

  try
    cxGridDBTableView39.Controller.ClearSelection;
  except
  end;
end;

procedure TFrmClientes.DataSetEdit1Execute(Sender: TObject);
begin
  if not Assigned(dmCliente) then
    Exit;

  PageControl1.ActivePage := TabSheet2; // edición
  DBEdit1.Enabled := False;
  old_nombre := dmCliente.cdsClientes.FieldByName('nombre_cliente').AsString;

  try
    if dmCliente.cdsClientes.State = dsBrowse then
      dmCliente.cdsClientes.Edit;
  except
    on E: Exception do
      CtmMsgDlg('Error', PChar('No se pudo entrar en modo edición: ' + E.Message), mtError, ['Aceptar'], 0, False);
  end;
end;

procedure TFrmClientes.DataSetInsert1Execute(Sender: TObject);
begin
  if not Assigned(dmCliente) then
    Exit;

  PageControl1.ActivePage := TabSheet2; // edición
  try
    dmCliente.cdsClientes.Append;
    DBEdit1.Enabled := True;
  except
    on E: Exception do
      CtmMsgDlg('Error', PChar('No fue posible iniciar nuevo registro: ' + E.Message), mtError, ['Aceptar'], 0, False);
  end;
end;

procedure TFrmClientes.DataSetPost1Execute(Sender: TObject);
var
  sError: string;
  vCliente, vNombre: string;
begin
  ToolBar1.SetFocus;
  sError := EmptyStr;

  if not Assigned(dmCliente) then
    Exit;

  vCliente := '';
  vNombre := '';
  if Assigned(DBEdit1.Field) then
    vCliente := Trim(DBEdit1.Field.AsString);
  if Assigned(DBEdit2.Field) then
    vNombre := Trim(DBEdit2.Field.AsString);

  if (vCliente = EmptyStr) then
    sError := 'El campo cliente no puede ser vacío'
  else if (vNombre = EmptyStr) then
    sError := 'El campo nombre no puede ser vacío'
  else if (dmCliente.cdsClientes.State in [dsInsert]) and
          dmCliente.FoundField(dmCliente.cdsClientes, 'cliente', VarArrayOf([vCliente])) then
    sError := 'Ya existe un cliente con el mismo código'
  else if (old_nombre <> vNombre) and
          dmCliente.FoundField(dmCliente.cdsClientes, 'nombre_cliente', VarArrayOf([vNombre])) then
    sError := 'Ya existe un cliente con el mismo nombre';

  if sError <> EmptyStr then
  begin
    CtmMsgDlg('', sError, mtError, ['Aceptar'], 0, False);
    Abort;
  end
  else
  begin
    try
      if dmCliente.cdsClientes.State in [dsEdit, dsInsert] then
        dmCliente.cdsClientes.Post;
      PageControl1.ActivePage := TabSheet1; // volver al listado
    except
      on E: Exception do
      begin
        CtmMsgDlg('Error', PChar('Guardar: ' + E.Message), mtError, ['Aceptar'], 0, False);
        // dejar en modo edición para que el usuario corrija
      end;
    end;
  end;
end;

procedure TFrmClientes.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Asegurar que dataset se cierre sin excepciones
  if Assigned(dmCliente) and Assigned(dmCliente.cdsClientes) then
  begin
    try
      dmCliente.cdsClientes.Active := False;
    except
      on E: Exception do
        CtmMsgDlg('Error', PChar('Cerrando dataset: ' + E.Message), mtWarning, ['Aceptar'], 0, False);
    end;
  end;
  Action := caFree;
end;

procedure TFrmClientes.FormCreate(Sender: TObject);
begin
  // Activar dataset de forma segura
  try
    if Assigned(dmCliente) and Assigned(dmCliente.cdsClientes) then
      dmCliente.cdsClientes.Active := True;
  except
    on E: Exception do
      CtmMsgDlg('Error', PChar('Iniciando dataset: ' + E.Message), mtError, ['Aceptar'], 0, False);
  end;
end;

procedure TFrmClientes.Image4MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  Perform(WM_SYSCOMMAND, $F012, 0);
end;

function TFrmClientes.Inicializar: Boolean;
begin
  Result := False;
  try
    if Assigned(dmCliente) and Assigned(dmCliente.cdsClientes) then
      dmCliente.cdsClientes.Active := True;

    Result := True;
  except
    on E: Exception do
      CtmMsgDlg('Error', PChar('No se pudo inicializar Clientes: ' + E.Message), mtError, ['Aceptar'], 0, False);
  end;
end;

procedure TFrmClientes.PageControl1Change(Sender: TObject);
begin
  if PageControl1.ActivePage = TabSheet1 then
  begin
    if Assigned(dmCliente) and Assigned(dmCliente.cdsClientes) then
    begin
      try
        if dmCliente.cdsClientes.State <> dsBrowse then
          dmCliente.cdsClientes.Cancel;
      except
        on E: Exception do
          CtmMsgDlg('Error', PChar('Cancelar: ' + E.Message), mtError, ['Aceptar'], 0, False);
      end;
    end;
  end;
end;

procedure TFrmClientes.tb_cerrarClick(Sender: TObject);
var
  s: string;
begin
  if not Assigned(dmCliente) or not Assigned(dmCliente.cdsClientes) then
  begin
    ModalResult := mrOk;
    Exit;
  end;

  with dmCliente do
  begin
    try
      if (cdsClientes.Modified) or (cdsClientes.ChangeCount > 0) then
      begin
        s := '¿Desea guardar los cambios efectuados' + sLineBreak + 'en Registro de Clientes?';

        if CtmMsgDlg('', s, mtConfirmation, ['Si', 'No'], 0, False) = 0 then
          ClientDataSetApply1Execute(nil)
        else
          ClientDataSetUndo1Execute(nil);
      end
      else
        ClientDataSetUndo1Execute(nil);
    except
      on E: Exception do
        CtmMsgDlg('Error', PChar('Al cerrar: ' + E.Message), mtError, ['Aceptar'], 0, False);
    end;
  end;

  ModalResult := mrOk;
end;

end.

