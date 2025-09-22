unit frm_principal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  Tf_Principal = class(TForm)
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  f_Principal: Tf_Principal;

implementation

{$R *.dfm}

uses UServidorDCOM, uFunciones;

procedure Tf_Principal.FormCreate(Sender: TObject);
begin
  //  Hide;
  Caption := 'Servidor DCOM - Versión: ' + GetAppVersion;
end;

end.
