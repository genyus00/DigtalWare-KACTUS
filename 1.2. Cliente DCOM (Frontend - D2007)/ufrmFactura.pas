unit ufrmFactura;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, DB, DBCtrls, StdCtrls,
  Grids, DBGrids, ExtCtrls, ComCtrls, ToolWin, ImgList, DBClientActns, DBActns,
  ActnList, Mask, DBDateTimePicker, Spin, ufrmRegFactura, cxStyles,
  cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, cxDBData,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxControls, cxGridCustomView, cxGrid, ButtonComps;

type
  TfrmFactura = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Label1: TLabel;
    Panel4: TPanel;
    Panel5: TPanel;
    ActionList1: TActionList;
    DataSetFirst1: TDataSetFirst;
    DataSetPrior1: TDataSetPrior;
    DataSetNext1: TDataSetNext;
    DataSetLast1: TDataSetLast;
    ImageList1: TImageList;
    ActionList2: TActionList;
    DataSetFirst2: TDataSetFirst;
    DataSetPrior2: TDataSetPrior;
    DataSetNext2: TDataSetNext;
    DataSetLast2: TDataSetLast;
    DataSetRefresh2: TDataSetRefresh;
    ImageList2: TImageList;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolBar2: TToolBar;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    PageControl2: TPageControl;
    TabSheet3: TTabSheet;
    grd_factura1: TDBGrid;
    grd_detalle1: TDBGrid;
    DBLookupComboBox1: TDBLookupComboBox;
    newfactura: TButton;
    budu: TEdit;
    DataSetRefresh1: TDataSetRefresh;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    DataSetDelete1: TDataSetDelete;
    DataSetDelete2: TDataSetDelete;
    ToolButton8: TToolButton;
    ClientDataSetApply1: TClientDataSetApply;
    ClientDataSetUndo1: TClientDataSetUndo;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ClientDataSetApply2: TClientDataSetApply;
    ClientDataSetUndo2: TClientDataSetUndo;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton18: TToolButton;
    grd_factura: TcxGrid;
    cxGridDBTableView39: TcxGridDBTableView;
    cxGridDBfac_cliente: TcxGridDBColumn;
    cxGridDBfac_numero: TcxGridDBColumn;
    cxGridDBfac_fecha: TcxGridDBColumn;
    cxGridLevel39: TcxGridLevel;
    cxGridDBfac_total: TcxGridDBColumn;
    grd_detalle: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridDBDet_Factura: TcxGridDBColumn;
    cxGridDBFac_Producto: TcxGridDBColumn;
    cxGridDBFac_Cantidad: TcxGridDBColumn;
    cxGridDBFac_Valor: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    cxGridDBFac_Subtotal: TcxGridDBColumn;
    Panel9: TPanel;
    Image4: TImage;
    Label72: TLabel;
    Panel10: TPanel;
    Image5: TImage;
    tb_cerrar: TImageButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PageControl1Change(Sender: TObject);
    procedure PageControl2Change(Sender: TObject);
    procedure DataSetDelete1Execute(Sender: TObject);
    procedure DataSetCancel1Execute(Sender: TObject);
    procedure DataSetDelete2Execute(Sender: TObject);
    procedure DataSetCancel2Execute(Sender: TObject);
    procedure ClientDataSetUndo1Execute(Sender: TObject);
    procedure ClientDataSetUndo2Execute(Sender: TObject);
    procedure ClientDataSetApply2Execute(Sender: TObject);
    procedure newfacturaClick(Sender: TObject);
    procedure grd_factura1DblClick(Sender: TObject);
    procedure ClientDataSetApply1Execute(Sender: TObject);
    procedure cxGridDBTableView39KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cxGridDBTableView1EditKeyDown(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem; AEdit: TcxCustomEdit; var Key: Word;
      Shift: TShiftState);
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Image4MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tb_cerrarClick(Sender: TObject);
    procedure cxGridDBTableView1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    old_producto : string;
    FrmRegFactura: TFrmRegFactura;
    function Inicializar: Boolean;
  end;

implementation

{$R *.dfm}

uses uDatamodule, CustomMsgDlg;

procedure TfrmFactura.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    WinClassName := 'RAJB_SRC';
    Style := (Style or WS_POPUP) and not WS_DLGFRAME;
  end;
end;

procedure TfrmFactura.newfacturaClick(Sender: TObject);
var
  s: string;
  LFrmRegFactura: TFrmRegFactura;
begin
  newfactura.Tag := 1;
  LFrmRegFactura := nil;
  // Usar variable local para crear y liberar el formulario, evita fugas si se crean múltiples instancias
  try
    LFrmRegFactura := TFrmRegFactura.Create(nil);
    LFrmRegFactura.Tag := 1;

    // Asegurar datasets abiertos y consistentes
    if not Assigned(dmCliente) then
      raise Exception.Create('DataModule no está disponible');

    with dmCliente do
    begin
      try
        if not cdsClientes.Active then AbrirCDS(dmCliente.cdsClientes, 'Clientes');
        if not cdsProductos.Active then AbrirCDS(dmCliente.cdsProductos, 'Productos');
        if not cdsDetalle_Factura.Active then AbrirCDS(dmCliente.cdsDetalle_Factura, 'Detalle Factura');

        if not cdsFacturas.Active then
          cdsFacturas.Open
        else if (cdsFacturas.State in [dsEdit, dsInsert]) then
        begin
          try
            cdsFacturas.Post;
          except
            on E: EDatabaseError do
            begin
              CtmMsgDlg('Error', E.Message, mtWarning, ['Aceptar'], 0, False);
              Exit;
            end;
          end;
        end
        else if (cdsFacturas.ChangeCount = 0) then
          cdsClientes.Refresh
        else if (cdsFacturas.Modified) or (cdsFacturas.ChangeCount > 0) then
        begin
          s := '¿Desea guardar los cambios efectuados' + sLineBreak + 'en Registro de Facturación?';
          if CtmMsgDlg('', s, mtConfirmation, ['Si', 'No'], 0, False) = 0 then
          begin
            try
              GuardarCambios(cdsFacturas, 'Facturas');

            except
              on E: EDatabaseError do
              begin
                CtmMsgDlg('Error', E.Message, mtWarning, ['Aceptar'], 0, False);
                Exit;
              end;
              on E: Exception do
              begin
                CtmMsgDlg('Error', E.Message, mtError, ['Aceptar'], 0, False);
                try
                  cdsFacturas.CancelUpdates;
                except
                end;
                Exit;
              end;
            end;
          end
          else
            cdsFacturas.CancelUpdates;
        end;

        try
          cdsFacturas.Append;
        except
          on E: EDatabaseError do
          begin
            CtmMsgDlg('Error', E.Message, mtWarning, ['Aceptar'], 0, False);
            if Assigned(budu) then
              budu.SetFocus;
            Exit;
          end;
        end;

      except
        on E: Exception do
        begin
          CtmMsgDlg('Error', PChar('Inicializando datos: ' + E.Message), mtError, ['Aceptar'], 0, False);
          Exit;
        end;
      end;
    end;

    // Mostrar modal
    try
      LFrmRegFactura.ShowModal;
    finally
      // asegurarse de liberar la instancia creada localmente
      FreeAndNil(LFrmRegFactura);
    end;

  except
    on E: Exception do
    begin
      FreeAndNil(LFrmRegFactura);
      CtmMsgDlg('Error', PChar('newfactura: ' + E.Message), mtError, ['Aceptar'], 0, False);
    end;
  end;
end;

procedure TfrmFactura.ClientDataSetApply1Execute(Sender: TObject);
begin
  if not Assigned(dmCliente) then Exit;

  with dmCliente do
  begin
    cdsFacturas.DisableControls;
    Screen.Cursor := crHourGlass;
    try
      try
        GuardarCambios(cdsFacturas, 'Facturas');

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
            cdsFacturas.CancelUpdates;
          except
          end;
          Exit;
        end;
      end;

      try
        if cdsDetalle_Factura.Active then
          cdsDetalle_Factura.Refresh;
      except
        on E: Exception do
          CtmMsgDlg('Advertencia', PChar('Refrescar detalle: ' + E.Message), mtWarning, ['Aceptar'], 0, False);
      end;

    finally
      Screen.Cursor := crDefault;
      cdsFacturas.EnableControls;
    end;
  end;
end;

procedure TfrmFactura.ClientDataSetApply2Execute(Sender: TObject);
begin
  if not Assigned(dmCliente) then Exit;

  with dmCliente do
  begin
    cdsDetalle_Factura.DisableControls;
    Screen.Cursor := crHourGlass;
    try
      try
        GuardarCambios(cdsDetalle_Factura, 'Detalle Factura');

      except
        on E: EDatabaseError do
        begin
          CtmMsgDlg('Error al aplicar cambios detalle', E.Message, mtWarning, ['Aceptar'], 0, False);
          Exit;
        end;
        on E: Exception do
        begin
          CtmMsgDlg('Error inesperado', E.Message, mtError, ['Aceptar'], 0, False);
          try
            cdsDetalle_Factura.CancelUpdates;
          except
          end;
          Exit;
        end;
      end;

      try
        if cdsDetalle_Factura.Active then
          cdsDetalle_Factura.Refresh;
      except
        on E: Exception do
          CtmMsgDlg('Advertencia', PChar('Refrescar detalle: ' + E.Message), mtWarning, ['Aceptar'], 0, False);
      end;

    finally
      Screen.Cursor := crDefault;
      cdsDetalle_Factura.EnableControls;
    end;
  end;
end;

procedure TfrmFactura.ClientDataSetUndo1Execute(Sender: TObject);
begin
  if not Assigned(dmCliente) then Exit;
  try
    if Assigned(dmCliente.cdsDetalle_Factura) and (dmCliente.cdsDetalle_Factura.ChangeCount > 0) then
      dmCliente.cdsDetalle_Factura.CancelUpdates;
  except
    on E: Exception do
      CtmMsgDlg('Error', PChar('Deshacer detalle: ' + E.Message), mtWarning, ['Aceptar'], 0, False);
  end;

  try
    if Assigned(dmCliente.cdsFacturas) then
      dmCliente.cdsFacturas.CancelUpdates;
  except
    on E: Exception do
      CtmMsgDlg('Error', PChar('Deshacer facturas: ' + E.Message), mtWarning, ['Aceptar'], 0, False);
  end;
end;

procedure TfrmFactura.ClientDataSetUndo2Execute(Sender: TObject);
begin
  if not Assigned(dmCliente) then Exit;
  try
    dmCliente.cdsDetalle_Factura.CancelUpdates;
  except
    on E: Exception do
      CtmMsgDlg('Error', PChar('Deshacer detalle: ' + E.Message), mtWarning, ['Aceptar'], 0, False);
  end;
end;

procedure TfrmFactura.cxGridDBTableView1EditKeyDown(
  Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem;
  AEdit: TcxCustomEdit; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
  begin
    Key := 0;
    try
      DataSetDelete2Execute(nil);
    except
      on E: Exception do
        CtmMsgDlg('Error', PChar('Eliminar detalle: ' + E.Message), mtError, ['Aceptar'], 0, False);
    end;
  end;
end;

procedure TfrmFactura.cxGridDBTableView1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_DELETE then
  begin
    Key := 0;
    try
      DataSetDelete2Execute(nil);
    except
      on E: Exception do
        CtmMsgDlg('Error', PChar('Eliminar detalle: ' + E.Message), mtError, ['Aceptar'], 0, False);
    end;
  end;
end;

procedure TfrmFactura.cxGridDBTableView39KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_DELETE then
  begin
    Key := 0;
    try
      DataSetDelete1Execute(nil);
    except
      on E: Exception do
        CtmMsgDlg('Error', PChar('Eliminar factura: ' + E.Message), mtError, ['Aceptar'], 0, False);
    end;
  end;
end;

procedure TfrmFactura.DataSetCancel1Execute(Sender: TObject);
begin
  if Assigned(dmCliente) and Assigned(dmCliente.cdsFacturas) then
  begin
    try
      if dmCliente.cdsFacturas.State <> dsBrowse then
        dmCliente.cdsFacturas.Cancel;
    except
      on E: Exception do
        CtmMsgDlg('Error', PChar('Cancelar facturas: ' + E.Message), mtError, ['Aceptar'], 0, False);
    end;
  end;
  PageControl1.ActivePage := TabSheet1;
end;

procedure TfrmFactura.DataSetCancel2Execute(Sender: TObject);
begin
  if Assigned(dmCliente) and Assigned(dmCliente.cdsDetalle_Factura) then
  begin
    try
      if dmCliente.cdsDetalle_Factura.State <> dsBrowse then
        dmCliente.cdsDetalle_Factura.Cancel;
    except
      on E: Exception do
        CtmMsgDlg('Error', PChar('Cancelar detalle: ' + E.Message), mtError, ['Aceptar'], 0, False);
    end;
  end;
  PageControl2.ActivePage := TabSheet3;
end;

procedure TfrmFactura.DataSetDelete1Execute(Sender: TObject);
var
  s: string;
  lSingle: Boolean;
begin
  if not Assigned(dmCliente) then Exit;

  lSingle := (cxGridDBTableView39.Controller.SelectedRowCount <= 1);

  if lSingle then
    s := '¿Desea eliminar el registro de la factura [' + dmCliente.cdsFacturas.FieldByName('numero').AsString + '] ?'
  else
    s := '¿Desea eliminar los registro seleccionados ?';

  if CtmMsgDlg('Eliminar registro', s, mtConfirmation, ['Si', 'No'], 0, False) = 0 then
  begin
    try
      if (dmCliente.cdsFacturas.RecordCount = 1) or lSingle then
      begin
        if dmCliente.cdsFacturas.CanModify and (dmCliente.cdsFacturas.State = dsBrowse) then
          dmCliente.cdsFacturas.Delete
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
        CtmMsgDlg('Error', PChar('Eliminar factura: ' + E.Message), mtError, ['Aceptar'], 0, False);
    end;
  end;

  try
    cxGridDBTableView39.Controller.ClearSelection;
  except
  end;
end;

procedure TfrmFactura.DataSetDelete2Execute(Sender: TObject);
var
  s: string;
  lSingle: Boolean;
begin
  if not Assigned(dmCliente) then Exit;

  lSingle := (cxGridDBTableView1.Controller.SelectedRowCount <= 1);

  if lSingle then
    s := '¿Desea eliminar el registro detalle la factura [' + dmCliente.cdsDetalle_Factura.FieldByName('producto').AsString + '] ?'
  else
    s := '¿Desea eliminar los registro seleccionados ?';

  if CtmMsgDlg('Eliminar registro', s, mtConfirmation, ['Si', 'No'], 0, False) = 0 then
  begin
    try
      if (dmCliente.cdsDetalle_Factura.RecordCount = 1) or lSingle then
      begin
        if dmCliente.cdsDetalle_Factura.CanModify and (dmCliente.cdsDetalle_Factura.State = dsBrowse) then
          dmCliente.cdsDetalle_Factura.Delete
        else
          CtmMsgDlg('Advertencia', 'No se puede eliminar en este momento.', mtWarning, ['Aceptar'], 0, False);
      end
      else
      begin
        try
          cxGridDBTableView1.Controller.DeleteSelection;
        except
          on E: Exception do
            CtmMsgDlg('Error', PChar('Eliminar selección detalle: ' + E.Message), mtError, ['Aceptar'], 0, False);
        end;
      end;
    except
      on E: Exception do
        CtmMsgDlg('Error', PChar('Eliminar detalle: ' + E.Message), mtError, ['Aceptar'], 0, False);
    end;
  end;

  try
    cxGridDBTableView1.Controller.ClearSelection;
  except
  end;
end;

procedure TfrmFactura.grd_factura1DblClick(Sender: TObject);
var
  idf, s: string;
  LFrmRegFactura: TFrmRegFactura;
begin
  if not Assigned(dmCliente) then Exit;

  if not dmCliente.cdsFacturas.Active then Exit;

  if not dmCliente.cdsProductos.Active then
    dmCliente.cdsProductos.Open;

  if (dmCliente.cdsFacturas.Modified) or (dmCliente.cdsFacturas.ChangeCount > 0) then
  begin
    CtmMsgDlg('', 'Debe aplicar los cambios pendientes para poder ejecutar la accion solicitada!!', mtWarning, ['Aceptar'], 0, False);
    s := '¿Desea guardar los cambios efectuados' + sLineBreak + 'en Registro de Facturación?';
    if CtmMsgDlg('', s, mtConfirmation, ['Si', 'No'], 0, False) = 0 then
      ClientDataSetApply1Execute(nil)
    else
      ClientDataSetUndo1Execute(nil);
  end
  else
    ClientDataSetUndo1Execute(nil);

  if dmCliente.cdsFacturas.RecordCount > 0 then
  begin
    LFrmRegFactura := nil;
    try
      LFrmRegFactura := TFrmRegFactura.Create(nil);
      LFrmRegFactura.Tag := 1;
      LFrmRegFactura.rxcliente.Enabled := False;

      idf := dmCliente.cdsFacturas.FieldByName('numero').AsString;

      try
        dmCliente.cdsDetalle_Factura.Close;
        dmCliente.AbrirCDS(dmCliente.cdsDetalle_Factura, 'Detale Factura');//dmCliente.cdsDetalle_Factura.Open;
      except
      end;

      try
        dmCliente.cdsFacturas.Edit;
        dmCliente.cdsFacturas.Post;
      except
      end;

      LFrmRegFactura.DBFecha.Enabled := False;
      LFrmRegFactura.NoFactura.Enabled := False;

      try
        LFrmRegFactura.ShowModal;
      finally
        FreeAndNil(LFrmRegFactura);
      end;

    except
      on E: Exception do
      begin
        FreeAndNil(LFrmRegFactura);
        CtmMsgDlg('Error', PChar('Abrir registro: ' + E.Message), mtError, ['Aceptar'], 0, False);
      end;
    end;
  end;
end;

procedure TfrmFactura.Image4MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  Perform(WM_SYSCOMMAND, $F012, 0);
end;

function TfrmFactura.Inicializar: Boolean;
begin
  Result := False;
  try
    if Assigned(dmCliente) and Assigned(dmCliente.cdsClientes) then
      dmCliente.cdsClientes.Active := True;
    if Assigned(dmCliente) and Assigned(dmCliente.cdsProductos) then
      dmCliente.cdsProductos.Active := True;
    if Assigned(dmCliente) and Assigned(dmCliente.cdsFacturas) then
      dmCliente.cdsFacturas.Active := True;
    if Assigned(dmCliente) and Assigned(dmCliente.cdsDetalle_Factura) then
      dmCliente.cdsDetalle_Factura.Active := True;

    Result := True;
  except
    on E: Exception do
      CtmMsgDlg('Error', PChar('No se pudo inicializar Facturas: ' + E.Message), mtError, ['Aceptar'], 0, False);
  end;
end;

procedure TfrmFactura.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(dmCliente) then
  begin
    try
      if Assigned(dmCliente.cdsDetalle_Factura) then
        dmCliente.cdsDetalle_Factura.Active := False;
    except
    end;
    try
      if Assigned(dmCliente.cdsFacturas) then
        dmCliente.cdsFacturas.Active := False;
    except
    end;
    try
      if Assigned(dmCliente.cdsProductos) then
        dmCliente.cdsProductos.Active := False;
    except
    end;
    try
      if Assigned(dmCliente.cdsClientes) then
        dmCliente.cdsClientes.Active := False;
    except
    end;
  end;

  Action := caFree;
end;

procedure TfrmFactura.FormCreate(Sender: TObject);
begin
  try
    if Assigned(dmCliente) and Assigned(dmCliente.cdsClientes) then
      dmCliente.cdsClientes.Active := True;
    if Assigned(dmCliente) and Assigned(dmCliente.cdsProductos) then
      dmCliente.cdsProductos.Active := True;
    if Assigned(dmCliente) and Assigned(dmCliente.cdsFacturas) then
      dmCliente.cdsFacturas.Active := True;
    if Assigned(dmCliente) and Assigned(dmCliente.cdsDetalle_Factura) then
      dmCliente.cdsDetalle_Factura.Active := True;
  except
    on E: Exception do
      CtmMsgDlg('Error', PChar('Iniciar datasets: ' + E.Message), mtError, ['Aceptar'], 0, False);
  end;

  if Assigned(DBLookupComboBox1) and Assigned(dmCliente) and Assigned(dmCliente.cdsClientes) then
    DBLookupComboBox1.KeyValue := dmCliente.cdsClientes.FieldByName('cliente').Value;

  grd_factura.ShowHint := True;
end;

procedure TfrmFactura.PageControl1Change(Sender: TObject);
begin
  if PageControl1.ActivePage = TabSheet1 then
  begin
    if Assigned(dmCliente) and Assigned(dmCliente.cdsFacturas) then
    begin
      try
        if dmCliente.cdsFacturas.State <> dsBrowse then
          dmCliente.cdsFacturas.Cancel;
      except
        on E: Exception do
          CtmMsgDlg('Error', PChar('Cancelar: ' + E.Message), mtError, ['Aceptar'], 0, False);
      end;
    end;
  end;
end;

procedure TfrmFactura.PageControl2Change(Sender: TObject);
begin
  if PageControl2.ActivePage = TabSheet3 then
  begin
    if Assigned(dmCliente) and Assigned(dmCliente.cdsDetalle_Factura) then
    begin
      try
        if dmCliente.cdsDetalle_Factura.State <> dsBrowse then
          dmCliente.cdsDetalle_Factura.Cancel;
      except
        on E: Exception do
          CtmMsgDlg('Error', PChar('Cancelar detalle: ' + E.Message), mtError, ['Aceptar'], 0, False);
      end;
    end;
  end;
end;

procedure TfrmFactura.tb_cerrarClick(Sender: TObject);
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
      if (cdsDetalle_Factura.Modified) or (cdsDetalle_Factura.ChangeCount > 0) then
      begin
        s := '¿Desea guardar los cambios efectuados' + sLineBreak + 'en Listado detalle de Facturas?';
        if CtmMsgDlg('', s, mtConfirmation, ['Si', 'No'], 0, False) = 0 then
          ClientDataSetApply2Execute(nil)
        else
          ClientDataSetUndo2Execute(nil);
      end
      else
        ClientDataSetUndo2Execute(nil);

      if (cdsFacturas.Modified) or (cdsFacturas.ChangeCount > 0) then
      begin
        s := '¿Desea guardar los cambios efectuados' + sLineBreak + 'en Listado de Facturas?';
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
