unit ufrmProductos;

interface

uses
  Windows, Forms, ExtCtrls, DBCtrls, Classes, Controls, Grids, DBGrids,
  ComCtrls, ToolWin, ImgList, DBClientActns, DBActns, ActnList, StdCtrls,
  Mask, SysUtils, Dialogs, cxStyles, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, DB, cxDBData, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxControls, cxGridCustomView, cxGrid, ButtonComps, Graphics, Variants,
  Messages, ComObj;

type
  TfrmProductos = class(TForm)
    Panel1: TPanel;
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
    DataSetRefresh1: TDataSetRefresh;
    ImageList1: TImageList;
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
    ToolButton13: TToolButton;
    ToolButton12: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
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
    budu: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ClientDataSetUndo1Execute(Sender: TObject);
    procedure DataSetInsert1Execute(Sender: TObject);
    procedure DataSetPost1Execute(Sender: TObject);
    procedure DataSetEdit1Execute(Sender: TObject);
    procedure DataSetDelete1Execute(Sender: TObject);
    procedure DataSetCancel1Execute(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure Image4MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CreateParams(var Params: TCreateParams); override;
    procedure tb_cerrarClick(Sender: TObject);
    procedure ClientDataSetApply1Execute(Sender: TObject);
    procedure cxGridDBTableView39KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    old_producto : string;
    function Inicializar: Boolean; // nuevo método
  end;

implementation

{$R *.dfm}

uses uDatamodule, ufrmFactura, CustomMsgDlg, DBClient;

procedure TfrmProductos.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    WinClassName := 'RAJB_SRC';
    Style := (Style or WS_POPUP) and not WS_DLGFRAME;
  end;
end;

procedure TfrmProductos.cxGridDBTableView39KeyDown(Sender: TObject;
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
    //Abort;
  end;
end;

procedure TfrmProductos.ClientDataSetApply1Execute(Sender: TObject);
begin
  try
    if Assigned(budu) and budu.CanFocus then
      budu.SetFocus;
  except
  end;

  if not Assigned(dmCliente) then Exit;

  with dmCliente do
  begin
    cdsProductos.DisableControls;
    Screen.Cursor := crHourGlass;
    try
      //try
      //  cdsProductos.SaveToFile('delta_products.xml', dfXMLUTF8);
      //except
      //  on E: Exception do
      //    ShowMessage('Error guardando delta: ' + E.Message);
      //end;

      try
        GuardarCambios(cdsProductos, 'Productos');

      except
        on E: EOleSysError do
        begin
          CtmMsgDlg('EOleSysError', Format('EOleSysError: %d - %s', [E.ErrorCode, E.Message]), mtWarning, ['Aceptar'], 0, False);
          Exit;
        end;
        on E: EDatabaseError do
        begin
          CtmMsgDlg('Error al aplicar cambios', E.Message, mtWarning, ['Aceptar'], 0, False);
          Exit;
        end;
        on E: Exception do
        begin
          CtmMsgDlg('Error inesperado', E.Message, mtError, ['Aceptar'], 0, False);
          try
            cdsProductos.CancelUpdates;
          except
          end;
          Exit;
        end;
      end;

      try
        if cdsProductos.Active then
        begin
          cdsProductos.close;
          AbrirCDS(cdsProductos,'Productos');

        end;
      except
        on E: Exception do
          CtmMsgDlg('Advertencia', PChar('No fue posible refrescar productos: ' + E.Message), mtWarning, ['Aceptar'], 0, False);
      end;

    finally
      Screen.Cursor := crDefault;
      cdsProductos.EnableControls;
    end;
  end;
end;

procedure TfrmProductos.ClientDataSetUndo1Execute(Sender: TObject);
begin
  if Assigned(dmCliente) and Assigned(dmCliente.cdsProductos) then
  begin
    try
      dmCliente.cdsProductos.CancelUpdates;
    except
      on E: Exception do
        CtmMsgDlg('Error', PChar('No fue posible deshacer cambios: ' + E.Message), mtWarning, ['Aceptar'], 0, False);
    end;
  end;
end;

procedure TfrmProductos.DataSetCancel1Execute(Sender: TObject);
begin
  if Assigned(dmCliente) and Assigned(dmCliente.cdsProductos) then
  begin
    try
      if dmCliente.cdsProductos.State <> dsBrowse then
        dmCliente.cdsProductos.Cancel;
    except
      on E: Exception do
        CtmMsgDlg('Error', PChar('Cancelar edición: ' + E.Message), mtError, ['Aceptar'], 0, False);
    end;
  end;
  PageControl1.ActivePage := TabSheet1;
end;

procedure TfrmProductos.DataSetDelete1Execute(Sender: TObject);
var
  s: string;
  lSingle: Boolean;
begin
  if not Assigned(dmCliente) or not Assigned(dmCliente.cdsProductos) then Exit;

  lSingle := (cxGridDBTableView39.Controller.SelectedRowCount <= 1);

  if lSingle then
    s := '¿Desea eliminar el registro del producto [' + dmCliente.cdsProductos.FieldByName('nombre_producto').AsString + '] ?'
  else
    s := '¿Desea eliminar los registros seleccionados ?';

  if CtmMsgDlg('Eliminar registro', s, mtConfirmation, ['Si','No'], 0, False) = 0 then
  begin
    try
      if (dmCliente.cdsProductos.RecordCount = 1) or lSingle then
      begin
        if dmCliente.cdsProductos.CanModify and (dmCliente.cdsProductos.State = dsBrowse) then
          dmCliente.cdsProductos.Delete
        else
          CtmMsgDlg('Advertencia', 'No se puede eliminar en este momento.', mtWarning, ['Aceptar'], 0, False);
      end
      else
      begin
        try
          cxGridDBTableView39.Controller.DeleteSelection;
        except
          on E: Exception do
            CtmMsgDlg('Error', PChar('Eliminar selección: ' + E.Message), mtError, ['Aceptar'], 0, False);
        end;
      end;
    except
      on E: Exception do
        CtmMsgDlg('Error', PChar('Eliminar producto: ' + E.Message), mtError, ['Aceptar'], 0, False);
    end;
  end;

  try
    cxGridDBTableView39.Controller.ClearSelection;
  except
  end;
end;

procedure TfrmProductos.DataSetEdit1Execute(Sender: TObject);
begin
  if not Assigned(dmCliente) then Exit;

  PageControl1.ActivePage := TabSheet2;
  DBEdit1.Enabled := False;
  old_producto := dmCliente.cdsProductos.FieldByName('nombre_producto').AsString;
  try
    if dmCliente.cdsProductos.State = dsBrowse then
      dmCliente.cdsProductos.Edit;
  except
    on E: Exception do
      CtmMsgDlg('Error', PChar('No se pudo entrar en modo edición: ' + E.Message), mtError, ['Aceptar'], 0, False);
  end;
end;

procedure TfrmProductos.DataSetInsert1Execute(Sender: TObject);
begin
  if not Assigned(dmCliente) then Exit;

  PageControl1.ActivePage := TabSheet2;
  try
    dmCliente.cdsProductos.Append;
    DBEdit1.Enabled := True;
  except
    on E: Exception do
      CtmMsgDlg('Error', PChar('No fue posible iniciar nuevo registro: ' + E.Message), mtError, ['Aceptar'], 0, False);
  end;
end;

procedure TfrmProductos.DataSetPost1Execute(Sender: TObject);
var
  sError: string;
  vProd, vName: string;
begin
  // fuerza commit de cualquier control activo
  try
    if Assigned(budu) and budu.CanFocus then
      budu.SetFocus;
  except
  end;

  sError := EmptyStr;
  vProd := '';
  vName := '';

  if Assigned(DBEdit1.Field) then
    vProd := Trim(DBEdit1.Field.AsString);
  if Assigned(DBEdit2.Field) then
    vName := Trim(DBEdit2.Field.AsString);

  if (vProd = EmptyStr) then
    sError := 'El campo producto no puede ser vacío'
  else if (vName = EmptyStr) then
    sError := 'El campo nombre no puede ser vacío'
  else if Assigned(dmCliente) and (dmCliente.cdsProductos.State in [dsInsert]) and
          dmCliente.FoundField(dmCliente.cdsProductos, 'producto', VarArrayOf([DBEdit1.Field.Value])) then
    sError := 'Ya existe un producto con el mismo código'
  else if (old_producto <> vName) and
          dmCliente.FoundField(dmCliente.cdsProductos, 'nombre_producto', VarArrayOf([DBEdit2.Field.Value])) then
    sError := 'Ya existe un producto con el mismo nombre';

  if sError <> EmptyStr then
  begin
    CtmMsgDlg('', sError, mtError, ['Aceptar'], 0, False);
    Abort;
  end
  else
  begin
    try
      if Assigned(dmCliente) and (dmCliente.cdsProductos.State in [dsEdit, dsInsert]) then
        dmCliente.cdsProductos.Post;
      PageControl1.ActivePage := TabSheet1;
    except
      on E: Exception do
      begin
        CtmMsgDlg('Error', PChar('Guardar producto: ' + E.Message), mtError, ['Aceptar'], 0, False);
      end;
    end;
  end;
end;

procedure TfrmProductos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // desactivar datasets con protección
  if Assigned(dmCliente) then
  begin
    try
      if Assigned(dmCliente.cdsProductos) then
        dmCliente.cdsProductos.Active := False;
    except
    end;
  end;

  // liberar recursos de la forma
  Action := caFree;
end;

procedure TfrmProductos.FormCreate(Sender: TObject);
begin
  try
    if Assigned(dmCliente) and Assigned(dmCliente.cdsProductos) then
      dmCliente.cdsProductos.Active := True;
  except
    on E: Exception do
      CtmMsgDlg('Error', PChar('Iniciar dataset productos: ' + E.Message), mtError, ['Aceptar'], 0, False);
  end;
end;

procedure TfrmProductos.Image4MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  Perform(WM_SYSCOMMAND, $F012, 0);
end;

function TfrmProductos.Inicializar: Boolean;
begin
  Result := False;
  try
    if Assigned(dmCliente) and Assigned(dmCliente.cdsProductos) then
      dmCliente.cdsProductos.Active := True;

    Result := True;
  except
    on E: Exception do
      CtmMsgDlg('Error', PChar('No se pudo inicializar Productos: ' + E.Message), mtError, ['Aceptar'], 0, False);
  end;
end;

procedure TfrmProductos.PageControl1Change(Sender: TObject);
begin
  if PageControl1.ActivePage = TabSheet1 then
  begin
    if Assigned(dmCliente) and Assigned(dmCliente.cdsProductos) then
    begin
      try
        if dmCliente.cdsProductos.State <> dsBrowse then
          dmCliente.cdsProductos.Cancel;
      except
        on E: Exception do
          CtmMsgDlg('Error', PChar('Cancelar: ' + E.Message), mtError, ['Aceptar'], 0, False);
      end;
    end;
  end;
end;

procedure TfrmProductos.tb_cerrarClick(Sender: TObject);
var
  s: string;
begin
  if not Assigned(dmCliente) then
  begin
    ModalResult := mrOk;
    Exit;
  end;

  with dmCliente do
  begin
    try
      if (cdsProductos.Modified) or (cdsProductos.ChangeCount > 0) then
      begin
        s := '¿Desea guardar los cambios efectuados' + sLineBreak + 'en Registro de Productos?';
        if CtmMsgDlg('', s, mtConfirmation, ['Si','No'], 0, False) = 0 then
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

