unit ufrmRegFactura;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ButtonComps, ExtCtrls, ComCtrls, ToolWin, Buttons, DBDateTimePicker,
  Grids, DCGrids, DCDBGrids, StdCtrls, Mask, DBCtrls,
  ImgList, uFrmClientes;

type
  TFrmRegFactura = class(TForm)
    BUDU: TEdit;
    ImgOpcionesNormal: TImageList;
    ImageList1: TImageList;
    Panel86: TPanel;
    Panel88: TPanel;
    Panel156: TPanel;
    Label2: TLabel;
    Panel163: TPanel;
    Label96: TLabel;
    Label62: TLabel;
    Label104: TLabel;
    Label66: TLabel;
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
    Shape5: TShape;
    NoFactura: TDBEdit;
    Panel1: TPanel;
    Shape1: TShape;
    Shape2: TShape;
    Label3: TLabel;
    Panel2: TPanel;
    DBFecha: TDBDateTimePicker;
    Panel95: TPanel;
    ToolBar2: TToolBar;
    bt_aplicar: TToolButton;
    bt_deshacer: TToolButton;
    bt_eliminar: TToolButton;
    ToolButton2: TToolButton;
    Panel9: TPanel;
    Image4: TImage;
    Label72: TLabel;
    Panel10: TPanel;
    Image5: TImage;
    tb_cerrar: TImageButton;
    Bevel1: TBevel;
    procedure FormClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure tb_cerrarClick(Sender: TObject);
    procedure bt_aplicarClick(Sender: TObject);
    procedure bt_deshacerClick(Sender: TObject);
    procedure bt_eliminarClick(Sender: TObject);
    procedure Image4MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure grd_detalleEnter(Sender: TObject);
    procedure grd_detalleKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CreateParams(var Params: TCreateParams); override;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    FrmClientes: TFrmClientes;
  end;

implementation

uses uDatamodule, uFrmPrincipal, CustomMsgDlg, DB, ufrmFactura;

{$R *.dfm}

procedure TFrmRegFactura.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    WinClassName := 'RAJB_SRC';
    Style := (Style or WS_POPUP) and not WS_DLGFRAME;
  end;
end;

procedure TFrmRegFactura.bt_aplicarClick(Sender: TObject);
begin
  try
    if Assigned(BUDU) and BUDU.CanFocus then
      BUDU.SetFocus;
  except
  end;

  if not Assigned(dmCliente) then
    Exit;

  with dmCliente do
  begin
    // Deshabilitar controles y mostrar cursor de espera
    cdsDetalle_Factura.DisableControls;
    Screen.Cursor := crHourGlass;
    try
      // aseguramos que el detalle esté en la última fila para calcular totales
      try
        if cdsDetalle_Factura.Active then
          cdsDetalle_Factura.Last;
      except
        // si falla Last, continuamos; el cálculo puede fallar después y será manejado
      end;

      try
        cdsFacturas.Edit;
        cdsFacturas.FieldByName('cliente').AsString := cdsClientes.FieldByName('cliente').AsString;
        // SUMTOT puede no existir o estar a null, validar
        try
          if cdsDetalle_Factura.Active and (not cdsDetalle_FacturaSUMTOT.IsNull) then
            cdsFacturasTOTAL.AsFloat := cdsDetalle_FacturaSUMTOT.Value
          else
            cdsFacturasTOTAL.AsFloat := 0;
        except
          cdsFacturasTOTAL.AsFloat := 0;
        end;

        // Intentar aplicar updates de forma segura
        try
          GuardarCambios(cdsFacturas, 'Facturas');
          GuardarCambios(cdsDetalle_Factura, 'Detalle Factura');

        except
          on E: EDatabaseError do
          begin
            CtmMsgDlg('Error al aplicar cambios', E.Message, mtWarning, ['Aceptar'], 0, False);
            Exit;
          end;
          on E: Exception do
          begin
            // rollback parcial: cancelar cambios de detalle y factura
            try
              cdsDetalle_Factura.CancelUpdates;
            except
            end;
            try
              cdsFacturas.Cancel;
            except
            end;
            CtmMsgDlg('Error inesperado', E.Message, mtError, ['Aceptar'], 0, False);
            Exit;
          end;
        end;

      except
        on E: EDatabaseError do
        begin
          CtmMsgDlg('Error de base de datos', E.Message, mtWarning, ['Aceptar'], 0, False);
          Exit;
        end;
        on E: Exception do
        begin
          CtmMsgDlg('Error', E.Message, mtError, ['Aceptar'], 0, False);
          // intentar restaurar estado
          try
            cdsDetalle_Factura.CancelUpdates;
          except
          end;
          try
            cdsFacturas.Cancel;
          except
          end;
          Exit;
        end;
      end;

    finally
      Screen.Cursor := crDefault;
      try
        cdsDetalle_Factura.EnableControls;
      except
      end;
    end;
  end;

  if Self.Tag = 1 then
    Close;
end;

procedure TFrmRegFactura.bt_deshacerClick(Sender: TObject);
begin
  if not Assigned(dmCliente) then
    Exit;

  with dmCliente do
  begin
    try
      if Assigned(cdsDetalle_Factura) then
        cdsDetalle_Factura.EnableControls;
    except
    end;

    try
      if Assigned(cdsFacturas) then
        cdsFacturas.CancelUpdates;
    except
      on E: Exception do
        CtmMsgDlg('Error', PChar('No fue posible deshacer cambios: ' + E.Message), mtWarning, ['Aceptar'], 0, False);
    end;
  end;

  if Self.Tag = 1 then
    Close;
end;

procedure TFrmRegFactura.bt_eliminarClick(Sender: TObject);
var
  s: string;
begin
  if not Assigned(dmCliente) then
    Exit;

  if (grd_detalle.SelectedRows.Count <= 1) then
    s := '¿Desea eliminar el registro seleccionado ?'
  else
    s := '¿Desea eliminar los registro seleccionados ?';

  if CtmMsgDlg('', s, mtConfirmation, ['Si', 'No'], 0, False) = 0 then
  begin
    with dmCliente do
    begin
      try
        if (cdsDetalle_Factura.RecordCount = 1) or (grd_detalle.SelectedRows.Count <= 1) then
          cdsDetalle_Factura.Delete
        else
          grd_detalle.SelectedRows.Delete;
      except
        on E: Exception do
          CtmMsgDlg('Error', PChar('Eliminar detalle: ' + E.Message), mtError, ['Aceptar'], 0, False);
      end;
    end;
  end;

  try
    grd_detalle.SelectedRows.Clear;
  except
  end;
end;

procedure TFrmRegFactura.FormClick(Sender: TObject);
begin
  if Assigned(dmCliente) then
  begin
    try
      if dmCliente.cdsProductos.Active then
      begin
        dmCliente.cdsProductos.Filter := '';
        dmCliente.cdsProductos.Close;
      end;
    except
    end;

    try
      if Assigned(dmCliente.cdsClientes) then
      begin
        if dmCliente.cdsClientes.Active then
          dmCliente.cdsClientes.close;

        dmCliente.AbrirCDS(dmCliente.cdsClientes, 'Clientes');
      end;
    except
    end;
  end;

  // Notificar al formulario padre que la creación fue cancelada
  if (Owner is TFrmFactura) then
    TFrmFactura(Owner).newfactura.Tag := 0;

  Self.Tag := 0;

  try
    DBFecha.Enabled := True;
  except
  end;
  try
    NoFactura.Enabled := True;
  except
  end;
  try
    RxCliente.Enabled := True;
  except
  end;
end;

procedure TFrmRegFactura.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    Perform(WM_NEXTDLGCTL, 0, 0);
  end;
end;

procedure TFrmRegFactura.grd_detalleEnter(Sender: TObject);
begin
  // proteger referencias nulas
  try
    bt_eliminar.Enabled := Assigned(dmCliente) and dmCliente.cdsDetalle_Factura.Active and
                            (dmCliente.cdsDetalle_Factura.RecordCount > 0);
  except
    bt_eliminar.Enabled := False;
  end;
end;

procedure TFrmRegFactura.grd_detalleKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_DELETE then
  begin
    if not Assigned(dmCliente) or not Assigned(dmCliente.cdsDetalle_Factura) then
    begin
      Key := 0;
      Exit;
    end;

    if not dmCliente.cdsDetalle_Factura.Active or (dmCliente.cdsDetalle_Factura.RecordCount = 0) then
    begin
      Key := 0;
      Exit;
    end;

    if not bt_eliminar.Enabled then
    begin
      Beep;
      Key := 0;
      Exit;
    end;

    // ejecutar la acción de eliminar de forma segura
    try
      bt_eliminar.OnClick(nil);
    except
      on E: Exception do
        CtmMsgDlg('Error', PChar('Eliminar registro: ' + E.Message), mtError, ['Aceptar'], 0, False);
    end;

    Key := 0;
  end;
end;

procedure TFrmRegFactura.Image4MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  Perform(WM_SYSCOMMAND, $F012, 0);
end;

procedure TFrmRegFactura.tb_cerrarClick(Sender: TObject);
var
  s: string;
begin
  if not Assigned(dmCliente) then
    Exit;

  with dmCliente do
  begin
    try
      if (cdsFacturas.Modified) or (cdsFacturas.ChangeCount > 0) then
      begin
        s := '¿Desea guardar los cambios efectuados' + sLineBreak + 'en Registro de Ventas?';
        if CtmMsgDlg('', s, mtConfirmation, ['Si', 'No'], 0, False) = 0 then
          bt_aplicar.OnClick(nil)
        else
          bt_deshacer.OnClick(nil);
      end
      else
        bt_deshacer.OnClick(nil);
    except
      on E: Exception do
        CtmMsgDlg('Error', PChar('Al cerrar: ' + E.Message), mtError, ['Aceptar'], 0, False);
    end;
  end;

  // asegurar tamaño correcto de la toolbar al cerrar
  try
    ToolBar2.Height := 40;
  except
  end;
end;

procedure TFrmRegFactura.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Asegurarse de liberar el formulario si fue creado dinámicamente
  Action := caFree;
end;

end.

