//******************************************************************************
// Nombre: UCustomMsgDlg
// Creada Por : Ing. Rodolfo A. Jimenez B.
// Fecha : 25/08/2016
// Descripcion: Unidad que implementa mensajes personalizados en un cuadro de
// diálogo común.
//******************************************************************************

unit UCustomMsgDlg;

interface

{$IFDEF CONDITIONALEXPRESSIONS}
  {$IF CompilerVersion <= 22.0}        //Delphi 2010 y anteriores
    uses Dialogs, Forms, Windows, Classes, StdCtrls, ExtCtrls, Controls, SysUtils, Math, Graphics;
  {$IFEND}
  {$IF CompilerVersion > 22.0}        //Delphi XE y superiores
    uses Vcl.Dialogs, Vcl.Forms, Winapi.Windows, System.Classes, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Controls, System.SysUtils, System.Math, Vcl.Graphics;
  {$IFEND}
{$ENDIF} 

type
  TMsgDlgCallBack = procedure;

// Muestra un cuadro de diálogo común.
function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones: array of string; Defecto: Integer = 0; onClose: Boolean = False): Integer; overload;

// Muestra un cuadro de diálogo común, con Hints en los botones
function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; Defecto: Integer = 0; onClose: Boolean = False): Integer; overload;

// Muestra un cuadro de diálogo y llama a una función callback al clickear el último botón.
function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones: array of string; CallBack: TMsgDlgCallBack;
  Defecto: Integer = 0; onClose: Boolean = False): Integer; overload;

// Muestra un cuadro de diálogo y llama a una función callback al clickear el último botón, con Hints en los botones.
function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; CallBack: TMsgDlgCallBack;
  Defecto: Integer = 0; onClose: Boolean = False): Integer; overload;

// Muestra un cuadro de diálogo con una CheckBox.
function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones: array of string; const TituloCheckBox: string;
  var CBChecked: Boolean; Defecto: Integer = 0; onClose: Boolean = False): Integer; overload;

// Muestra un cuadro de diálogo con una CheckBox, con Hints en los botones.
function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; const TituloCheckBox: string;
  var CBChecked: Boolean; Defecto: Integer = 0; onClose: Boolean = False): Integer; overload;

// Muestra un cuadro de diálogo con una CheckBox y con función callback.
function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones: array of string; const TituloCheckBox: string;
  var CBChecked: Boolean; CallBack: TMsgDlgCallBack; Defecto: Integer = 0; onClose: Boolean = False): Integer; overload;

// Muestra un cuadro de diálogo con una CheckBox y con función callback, con Hints en los botones.
function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; const TituloCheckBox: string;
  var CBChecked: Boolean; CallBack: TMsgDlgCallBack; Defecto: Integer = 0; onClose: Boolean = False): Integer; overload;

implementation

// iconos estándares de cuadros de diálogo.
const
  IconIDs: array [TMsgDlgType] of PChar = (IDI_WARNING, IDI_ERROR, IDI_INFORMATION, IDI_QUESTION, IDI_WINLOGO);

// Sonidos estándares de cuadros de diálogo.
const
  Sonidos: array [TMsgDlgType] of Integer = (MB_ICONEXCLAMATION, MB_ICONHAND,
    MB_ICONINFORMATION, MB_ICONQUESTION, MB_USERICON);

type
  TFormaDialogo = class(TForm)
  protected
    FBotonClic: Integer;
    TipoDialogo: TMsgDlgType;
    SePuedeCerrar: Boolean;
    BotonCallBack: TComponent;
    CallBack: TMsgDlgCallBack;
    procedure PresTecla(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ClickBoton(Sender: TObject);
    procedure onCloseDlg(Sender: TObject; var CanClose: Boolean);
  public
    constructor Create(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
      const Botones, Hints: array of string; CallBack: TMsgDlgCallBack = nil;
      Defecto: Integer = 0; onClose: Boolean = False); reintroduce;
    property BotonClic: Integer read FBotonClic;
    function ShowModal: Integer; override;
  end;

{ TFormaDialogo }
constructor TFormaDialogo.Create(const Titulo, Texto: string;
  TipoDialogo: TMsgDlgType; const Botones, Hints: array of string;
  CallBack: TMsgDlgCallBack = nil; Defecto: Integer = 0; onClose: Boolean = False);
var
  LblTextoMsg: TLabel;
  Icono: TImage;
  Boton: TButton;
  HeightBotones: Integer;
  WidthBotones: Integer;
  WidthTotalBotones: Integer;
  Aux: Integer;
  PanelBotones: TPanel;
  i: Integer;
  iCantHints: Integer;
begin
  inherited CreateNew(Application);
  Self.TipoDialogo := TipoDialogo;
  OnKeyDown := PresTecla;
  OnCloseQuery := onCloseDlg;
  KeyPreview := True;
  BorderStyle := bsDialog;
  Position := poScreenCenter;
  SePuedeCerrar := onClose;
  Color := clWhite;
  FBotonClic := -1;
  if trim(Titulo) = '' then
    case TipoDialogo of
      mtWarning:
        Caption := 'Advertencia';
      mtError:
        Caption := 'Error';
      mtInformation:
        Caption := 'Información';
      mtConfirmation:
        Caption := 'Confirmación';
    end
  else
    Caption := Titulo;

  HeightBotones := 0;
  WidthBotones := 0;

  for i := 0 to Length(Botones) - 1 do
  begin
    if Canvas.TextWidth(Botones[i]) > WidthBotones then
      WidthBotones := Canvas.TextWidth(Botones[i]);
    if Canvas.TextHeight(Botones[i]) > HeightBotones then
      HeightBotones := Canvas.TextHeight(Botones[i]);
  end;

  WidthBotones := Max(WidthBotones + 16, 75);
  HeightBotones := Max(HeightBotones + 8, 25);
  WidthTotalBotones := Length(Botones) * (WidthBotones + 8) - 8;

 //Creación de la imagen del msg
  Icono := TImage.Create(Self);
  with Icono do
  begin
    Parent := Self;
    Picture.Icon.Handle := LoadIcon(0, IconIDs[TipoDialogo]);
    SetBounds(11, 11, 32, 32);
  end;

 //Creación del texto del msg
  LblTextoMsg := TLabel.Create(Self);
  with LblTextoMsg do
  begin
    Parent := Self;
    AutoSize := True;
    Caption := Texto;
    Left := Icono.Left + Icono.Width + 16;
    Top := 16;
  end;

  ClientWidth := Max(LblTextoMsg.Width + LblTextoMsg.Left + 16, 10 + WidthTotalBotones + 10);
  ClientHeight := Max(LblTextoMsg.Height + LblTextoMsg.Top, Icono.Height + Icono.Top) + 16 + HeightBotones + 12;

 //Creación del panel para los botones
  PanelBotones := TPanel.Create(Self);
  with PanelBotones do
  begin
    Parent := Self;
    ParentColor := False;
    ParentBackground := False;
    BevelOuter := bvNone;
    Color := clBtnFace;
    Height := Self.Height - (Max(LblTextoMsg.Height + LblTextoMsg.Top, Icono.Top + Icono.Height) + 44);
    Align := alBottom;
  end;

 //Creación de los botones
  Aux := ClientWidth div 2 - (WidthTotalBotones) div 2;
  iCantHints := Length(Hints) - 1;

  for i := 0 to Length(Botones) - 1 do
  begin
    Boton := TButton.Create(Self);
    with Boton do
    begin
      Parent := PanelBotones;
      Caption := Botones[i];
      Tag := i;
      OnClick := ClickBoton;
      Left := Aux + (WidthBotones + 8) * i;
      Width := WidthBotones;
      Top := (Parent.Height - Height) div 2;

      if i <= iCantHints then
      begin
        ShowHint := True;
        Hint := Hints[i];
      end;

      if Defecto = i then
        ActiveControl := Boton;
    end;
  end;

  Self.CallBack := CallBack;

  if Assigned(CallBack) then
    BotonCallBack := Controls[ControlCount - 1];
end;

function TFormaDialogo.ShowModal: Integer;
begin
  MessageBeep(Sonidos[TipoDialogo]);
  Result := inherited ShowModal;
end;

procedure TFormaDialogo.ClickBoton(Sender: TObject);
begin
  if (TComponent(Sender) = BotonCallBack) and Assigned(CallBack) then
    CallBack
  else
  begin
    FBotonClic := TButton(Sender).Tag;
    SePuedeCerrar := True;
    Close;
  end;
end;

procedure TFormaDialogo.PresTecla(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_F4) and (ssAlt in Shift) then
    Key := 0;
end;

procedure TFormaDialogo.onCloseDlg(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := SePuedeCerrar;
end;

//  --- Cuadro de diálogo común.
function CtmMsgDlgComun(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; Defecto: Integer = 0; onClose: Boolean = False): Integer;
var
  miCtmMsgDlg: TFormaDialogo;
begin
  if Length(Botones) = 0 then
    raise Exception.Create('CtmMsgDlg: Debe hacer clic al menos en un botón.');

  miCtmMsgDlg := TFormaDialogo.Create(Titulo, Texto, TipoDialogo, Botones, Hints, nil, Defecto, onClose);
  try
    miCtmMsgDlg.ShowModal;
    Result := miCtmMsgDlg.BotonClic;
  finally
    FreeAndNil(miCtmMsgDlg);
  end;
end;

function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones: array of string; Defecto: Integer = 0; onClose: Boolean = False): Integer;
begin
  Result := CtmMsgDlgComun(Titulo, Texto, TipoDialogo, Botones, [], Defecto, onClose);
end;

function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; Defecto: Integer = 0; onClose: Boolean = False): Integer;
begin
  Result := CtmMsgDlgComun(Titulo, Texto, TipoDialogo, Botones, Hints, Defecto, onClose);
end;

//  --- Cuadro de diálogo común con función Callback
function CtmMsgDlgComunCallBack(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; CallBack: TMsgDlgCallBack;
  Defecto: Integer = 0; onClose: Boolean = False): Integer;
var
  miCtmMsgDlg: TFormaDialogo;
begin
  if Length(Botones) < 2 then
    raise Exception.Create('CtmMsgDlg: Debe hacer clic al menos en dos botones.');

  miCtmMsgDlg := TFormaDialogo.Create(Titulo, Texto, TipoDialogo, Botones, Hints, CallBack, Defecto, onClose);
  try
    miCtmMsgDlg.ShowModal;
    Result := miCtmMsgDlg.BotonClic;
  finally
    FreeAndNil(miCtmMsgDlg);
  end;
end;

function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones: array of string; CallBack: TMsgDlgCallBack;
  Defecto: Integer = 0; onClose: Boolean = False): Integer;
begin
  Result := CtmMsgDlgComunCallBack(Titulo, Texto, TipoDialogo, Botones, [], CallBack, Defecto, onClose);
end;

function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; CallBack: TMsgDlgCallBack;
  Defecto: Integer = 0; onClose: Boolean = False): Integer;
begin
  Result := CtmMsgDlgComunCallBack(Titulo, Texto, TipoDialogo, Botones, Hints, CallBack, Defecto, onClose);
end;

//  --- Cuadro de diálogo con una CheckBox
function CtmMsgDlgCheck(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; const TituloCheckBox: string;
  var CBChecked: Boolean; Defecto: Integer = 0; onClose: Boolean = False): Integer;
begin
  if Length(Botones) = 0 then
    raise Exception.Create('CtmMsgDlg: Debe hacer clic al menos en un botón.');
  Result := CtmMsgDlg(Titulo, Texto, TipoDialogo, Botones, Hints, TituloCheckBox, CBChecked, nil, Defecto, onClose);
end;

function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones: array of string; const TituloCheckBox: string;
  var CBChecked: Boolean; Defecto: Integer = 0; onClose: Boolean = False): Integer;
begin
  Result := CtmMsgDlgCheck(Titulo, Texto, TipoDialogo, Botones, [], TituloCheckBox, CBChecked, Defecto, onClose);
end;

function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; const TituloCheckBox: string;
  var CBChecked: Boolean; Defecto: Integer = 0; onClose: Boolean = False): Integer;
begin
  Result := CtmMsgDlgCheck(Titulo, Texto, TipoDialogo, Botones, Hints, TituloCheckBox, CBChecked, Defecto, onClose);
end;

//  --- Cuadro de diálogo con una CheckBox y con función Callback
function CtmMsgDlgCheckCallBack(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; const TituloCheckBox: string;
  var CBChecked: Boolean; CallBack: TMsgDlgCallBack; Defecto: Integer = 0; onClose: Boolean = False)
  : Integer; overload;
var
  miCtmMsgDlg: TFormaDialogo;
  CB: TCheckBox;
begin
  if Assigned(CallBack) and (Length(Botones) < 2) then
    raise Exception.Create('CtmMsgDlg: Debe hacer clic al menos en dos botones.');

  miCtmMsgDlg := TFormaDialogo.Create(Titulo, Texto, TipoDialogo, Botones, Hints, CallBack, Defecto, onClose);
  CB := TCheckBox.Create(miCtmMsgDlg);

  try
    with CB do
    begin
      Parent := miCtmMsgDlg;
      Left := 8;
      Top := miCtmMsgDlg.ClientHeight - 36;
      Width := miCtmMsgDlg.Width;
      Caption := TituloCheckBox;
      Checked := CBChecked;
    end;

    miCtmMsgDlg.Height := miCtmMsgDlg.Height + CB.Height + 8;
    miCtmMsgDlg.ShowModal;
    CBChecked := CB.Checked;
    Result := miCtmMsgDlg.BotonClic;
  finally
    FreeAndNil(miCtmMsgDlg);
  end;
end;

function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones: array of string; const TituloCheckBox: string;
  var CBChecked: Boolean; CallBack: TMsgDlgCallBack; Defecto: Integer = 0; onClose: Boolean = False)
  : Integer; overload;
begin
  Result := CtmMsgDlgCheckCallBack(Titulo, Texto, TipoDialogo, Botones, [], TituloCheckBox, CBChecked, CallBack, Defecto, onClose);
end;

function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; const TituloCheckBox: string;
  var CBChecked: Boolean; CallBack: TMsgDlgCallBack; Defecto: Integer = 0; onClose: Boolean = False)
  : Integer; overload;
begin
  Result := CtmMsgDlgCheckCallBack(Titulo, Texto, TipoDialogo, Botones, Hints, TituloCheckBox, CBChecked, CallBack, Defecto, onClose);
end;

end.
