program ServidorDatos;

uses
  Vcl.Forms,
  MidasLib,
  frm_principal in 'frm_principal.pas' {f_Principal},
  ServidorDatos_TLB in 'ServidorDatos_TLB.pas',
  UServidorDCOM in 'UServidorDCOM.pas' {ServidorDCOM: TRemoteDataModule} {ServidorDCOM: CoClass},
  uCustomMsgDlg in 'uComunes\uCustomMsgDlg.pas',
  uFunciones in 'uComunes\uFunciones.pas';

{$R *.TLB}
{$R *.res}

begin
  // Para compatibilidad con Windows XP
  Application.Initialize;
  Application.Title := 'ServidorDatos';

  // Windows XP no soporta bien MainFormOnTaskbar
  {$IFDEF DEBUG}
  Application.MainFormOnTaskbar := False; // Cambiado a False para XP
  Application.CreateForm(Tf_Principal, f_Principal);
  Application.ShowMainForm := True;
  Application.Run;
  {$ELSE}
  // En Release no hay UI, solo COM server
  try
    ComServer.Start;
    // Mantener la aplicación ejecutándose
    while True do
      Application.ProcessMessages;
  except
    on E: Exception do
    begin
      // Log del error si es necesario
      Halt(1);
    end;
  end;
  {$ENDIF}
end.
