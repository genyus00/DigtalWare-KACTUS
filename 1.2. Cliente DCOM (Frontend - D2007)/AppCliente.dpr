program AppCliente;

uses
  Forms,
  MidasLib,
  uFrmClientes in 'uFrmClientes.pas' {FrmClientes},
  ufrmFactura in 'ufrmFactura.pas' {frmFactura},
  uDatamodule in 'uDatamodule.pas' {dmCliente: TDataModule},
  ufrmProductos in 'ufrmProductos.pas' {frmProductos},
  uFrmPrincipal in 'uFrmPrincipal.pas' {FrmPrincipal},
  ufrmRegFactura in 'ufrmRegFactura.pas' {FrmRegFactura},
  CustomMsgDlg in 'CustomMsgDlg.pas',
  ServidorDatos_TLB in 'ServidorDatos_TLB.pas',
  ufrmViewFactura in 'ufrmViewFactura.pas' {FrmViewFactura},
  superobject in 'Json\superobject.pas',
  supertypes in 'Json\supertypes.pas',
  ufrmClienteAPI in 'ufrmClienteAPI.pas' {frmClienteAPI},
  ufunciones in 'uComunes\ufunciones.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TdmCliente, dmCliente);
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.Run;
end.
