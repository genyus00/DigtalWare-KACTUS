unit CustomMsgDlg;

interface

{$IFDEF CONDITIONALEXPRESSIONS}
  {$IF CompilerVersion <= 21.0}        //Delphi 2010 y anteriores
    uses Dialogs, Forms, Windows, Classes, StdCtrls, ExtCtrls, Controls, SysUtils, Math, Graphics;
  {$IFEND}
  {$IF CompilerVersion > 21.0}        //Delphi XE y superiores
    uses Vcl.Dialogs, Vcl.Forms, Winapi.Windows, System.Classes, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Controls, System.SysUtils, System.Math, Vcl.Graphics;
  {$IFEND}
{$ENDIF}

type
  TMsgDlgCallBack = procedure;

// Muestra un cuadro de diálogo común.
function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones: array of string; Defecto: Integer = 0; onClose: Boolean = False): Integer; overload;

// Muestra un cuadro de diálogo común. Con definición de posición
function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones: array of string; Defecto: Integer = 0; Xpos: Integer = -1; YPos: Integer = -1; onClose: Boolean = False): Integer; overload;

// Muestra un cuadro de diálogo común, con Hints en los botones
function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; Defecto: Integer = 0; onClose: Boolean = False): Integer; overload;

// Muestra un cuadro de diálogo común, con Hints en los botones. Con definición de posición
function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; Defecto: Integer = 0; Xpos: Integer = -1; YPos: Integer = -1; onClose: Boolean = False): Integer; overload;

// Muestra un cuadro de diálogo y llama a una función callback al clickear el último botón.
function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones: array of string; CallBack: TMsgDlgCallBack;
  Defecto: Integer = 0; onClose: Boolean = False): Integer; overload;

// Muestra un cuadro de diálogo y llama a una función callback al clickear el último botón. Con definición de posición
function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones: array of string; CallBack: TMsgDlgCallBack;
  Defecto: Integer = 0; Xpos: Integer = -1; YPos: Integer = -1; onClose: Boolean = False): Integer; overload;

// Muestra un cuadro de diálogo y llama a una función callback al clickear el último botón, con Hints en los botones.
function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; CallBack: TMsgDlgCallBack;
  Defecto: Integer = 0; onClose: Boolean = False): Integer; overload;

// Muestra un cuadro de diálogo y llama a una función callback al clickear el último botón, con Hints en los botones. Con definición de posición
function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; CallBack: TMsgDlgCallBack;
  Defecto: Integer = 0; Xpos: Integer = -1; YPos: Integer = -1; onClose: Boolean = False): Integer; overload;

// Muestra un cuadro de diálogo con una CheckBox.
function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones: array of string; const TituloCheckBox: string;
  var CBChecked: Boolean; Defecto: Integer = 0; onClose: Boolean = False): Integer; overload;

// Muestra un cuadro de diálogo con una CheckBox. Con definición de posición
function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones: array of string; const TituloCheckBox: string;
  var CBChecked: Boolean; Defecto: Integer = 0; Xpos: Integer = -1; YPos: Integer = -1; onClose: Boolean = False): Integer; overload;

// Muestra un cuadro de diálogo con una CheckBox, con Hints en los botones.
function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; const TituloCheckBox: string;
  var CBChecked: Boolean; Defecto: Integer = 0; onClose: Boolean = False): Integer; overload;

// Muestra un cuadro de diálogo con una CheckBox, con Hints en los botones. Con definición de posición
function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; const TituloCheckBox: string;
  var CBChecked: Boolean; Defecto: Integer = 0; Xpos: Integer = -1; YPos: Integer = -1; onClose: Boolean = False): Integer; overload;

// Muestra un cuadro de diálogo con una CheckBox y con función callback.
function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones: array of string; const TituloCheckBox: string;
  var CBChecked: Boolean; CallBack: TMsgDlgCallBack; Defecto: Integer = 0; onClose: Boolean = False): Integer; overload;

// Muestra un cuadro de diálogo con una CheckBox y con función callback. Con definición de posición
function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones: array of string; const TituloCheckBox: string;
  var CBChecked: Boolean; CallBack: TMsgDlgCallBack; Defecto: Integer = 0; Xpos: Integer = -1; YPos: Integer = -1; onClose: Boolean = False): Integer; overload;

// Muestra un cuadro de diálogo con una CheckBox y con función callback, con Hints en los botones.
function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; const TituloCheckBox: string;
  var CBChecked: Boolean; CallBack: TMsgDlgCallBack; Defecto: Integer = 0; onClose: Boolean = False): Integer; overload;

// Muestra un cuadro de diálogo con una CheckBox y con función callback, con Hints en los botones. Con definición de posición
function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; const TituloCheckBox: string;
  var CBChecked: Boolean; CallBack: TMsgDlgCallBack; Defecto: Integer = 0; Xpos: Integer = -1; YPos: Integer = -1; onClose: Boolean = False): Integer; overload;


implementation

// Íconos estándares de cuadros de diálogo.
const
  IconIDs: array [TMsgDlgType] of PChar = (IDI_WARNING, IDI_ERROR, IDI_INFORMATION, IDI_QUESTION, IDI_WINLOGO);

  // Sonidos estándares de cuadros de diálogo.
const
  Sonidos: array [TMsgDlgType] of Integer = (MB_ICONEXCLAMATION, MB_ICONHAND, MB_ICONINFORMATION, MB_ICONQUESTION, MB_USERICON);

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
    procedure ShowEvent(Sender: TObject);
  public
    constructor Create(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
      const Botones, Hints: array of string; CallBack: TMsgDlgCallBack = nil;
      Defecto: Integer = 0; onClose: Boolean = False; Xpos: Integer = -1; YPos: Integer = -1); reintroduce;
    property BotonClic: Integer read FBotonClic;
    function ShowModal: Integer; override;
  end;

  { TFormaDialogo }

constructor TFormaDialogo.Create(const Titulo, Texto: string;
  TipoDialogo: TMsgDlgType; const Botones, Hints: array of string;
  CallBack: TMsgDlgCallBack = nil; Defecto: Integer = 0; onClose: Boolean = False; Xpos: Integer = -1; YPos: Integer = -1);
var
  ScrollBxMsg: TScrollBox;
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
  FormStyle        := fsStayOnTop;
  Self.TipoDialogo := TipoDialogo;
  OnKeyDown        := PresTecla;
  OnCloseQuery     := onCloseDlg;
  OnShow           := ShowEvent;
  KeyPreview       := True;
  BorderStyle      := bsDialog;

  if (Xpos = -1) and (YPos = -1) then
    Position       := poScreenCenter
  else
  begin
    Position       := poDesigned;
    Top            := Xpos;
    Left           := Ypos;
  end;

  SePuedeCerrar    := onClose;
  Color            := clWhite;
  FBotonClic       := -1;
  if trim(Titulo) = '' then
  begin
    case TipoDialogo of
      mtWarning:      Caption := 'Advertencia';
      mtError:        Caption := 'Error';
      mtInformation:  Caption := 'Información';
      mtConfirmation: Caption := 'Confirmación';
    end;
  end
  else
    Caption := Titulo;
  HeightBotones    := 0;
  WidthBotones     := 0;
  for i := 0 to Length(Botones) - 1 do
  begin
    if Canvas.TextWidth(Botones[i]) > WidthBotones then
      WidthBotones := Canvas.TextWidth(Botones[i]);
    if Canvas.TextHeight(Botones[i]) > HeightBotones then
      HeightBotones := Canvas.TextHeight(Botones[i]);
  end;
  WidthBotones      := Max(WidthBotones + 16, 75);
  HeightBotones     := Max(HeightBotones + 8, 25);
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
  ScrollBxMsg := TScrollBox.Create(Self);
  with ScrollBxMsg do
  begin
    Parent      := Self;
    BorderStyle := bsNone;
    AutoScroll  := True;
    Left        := Icono.Left + Icono.Width + 16;
    Top         := 16;
  end;

  LblTextoMsg := TLabel.Create(Self);
  with LblTextoMsg do
  begin
    Parent   := ScrollBxMsg; //Self;
    AutoSize := True;
    Caption  := Texto;
    Left     := 0; //Icono.Left + Icono.Width + 16;
    Top      := 0; //16;
  end;

  ScrollBxMsg.Width  := LblTextoMsg.Width;
  ScrollBxMsg.Height := LblTextoMsg.Height;

  //Asignación normal de tamaño de formulario
  ClientWidth  := Max(ScrollBxMsg.Width + ScrollBxMsg.Left + 16, 10 + WidthTotalBotones + 10); //Max(LblTextoMsg.Width + LblTextoMsg.Left + 16, 10 + WidthTotalBotones + 10);
  ClientHeight := Max(ScrollBxMsg.Height + ScrollBxMsg.Top, Icono.Height + Icono.Top) + 16 + HeightBotones + 12; //Max(LblTextoMsg.Height + LblTextoMsg.Top, Icono.Height + Icono.Top) + 16 + HeightBotones + 12;

  //Creación del panel para los botones
  PanelBotones := TPanel.Create(Self);
  with PanelBotones do
  begin
    Parent := Self;
    ParentColor := False;
    ParentBackground := False;
    BevelOuter := bvNone;
    Color := clBtnFace;
    Height := Self.Height - (Max(ScrollBxMsg.Height + ScrollBxMsg.Top, Icono.Top + Icono.Height) + 44); //Self.Height - (Max(LblTextoMsg.Height + LblTextoMsg.Top, Icono.Top + Icono.Height) + 44);
    Align := alBottom;
  end;

  //Validación de máximos permitidos en tamaño de formulario y redefinición de tamaños
  ClientWidth  := Min(ClientWidth, Screen.Width - 200);
  ClientHeight := Min(ClientHeight, Screen.Height - 200);

  if ScrollBxMsg.Width > (ClientWidth - ScrollBxMsg.Left - 1) then
  begin
    ScrollBxMsg.Height := ClientHeight - PanelBotones.Height;
    ClientHeight       := ClientHeight + 32;
  end
  else
    ScrollBxMsg.Height := ClientHeight - PanelBotones.Height - 16 - 16 ;

  ScrollBxMsg.Width := ClientWidth - ScrollBxMsg.Left - 1;

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
      Top :=  (Parent.Height - Height) div 2;
      if i <= iCantHints then
      begin
        ShowHint := True;
        Hint     := Hints[i];
      end;
      if Defecto = i then
        ActiveControl := Boton;
    end;
  end;

  Self.CallBack := CallBack;
  if Assigned(CallBack) then
    BotonCallBack :=  PanelBotones.Controls[PanelBotones.ControlCount - 1];
end;

procedure TFormaDialogo.ShowEvent(Sender: TObject);
begin
  SetWindowPos(Self.Handle,
              HWND_TOPMOST,
              0, 0, 0, 0,
              SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
end;

function TFormaDialogo.ShowModal: Integer;
begin
  MessageBeep(Sonidos[TipoDialogo]);
  Result := inherited ShowModal;
end;

procedure TFormaDialogo.ClickBoton(Sender: TObject);
begin
  if (TComponent(Sender) = BotonCallBack) and Assigned(CallBack) then
    CallBack;
  FBotonClic := TButton(Sender).Tag;
  SePuedeCerrar := True;
  Close;
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

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////  --- Cuadro de diálogo común.
function CtmMsgDlgComun(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; Defecto: Integer = 0; Xpos: Integer = -1; YPos: Integer = -1; onClose: Boolean = False): Integer;
var
  miCtmMsgDlg: TFormaDialogo;
begin
  if Length(Botones) = 0 then
    raise Exception.Create('CtmMsgDlg: Debe haber clic al menos en un botón.');
  miCtmMsgDlg := TFormaDialogo.Create(Titulo, Texto, TipoDialogo, Botones, Hints, nil, Defecto, onClose,YPos,Xpos);
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
  Result := CtmMsgDlgComun(Titulo, Texto, TipoDialogo, Botones, [], Defecto, -1, -1, onClose);
end;

function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones: array of string; Defecto: Integer = 0; Xpos: Integer = -1; YPos: Integer = -1; onClose: Boolean = False): Integer;
begin
  Result := CtmMsgDlgComun(Titulo, Texto, TipoDialogo, Botones, [], Defecto, Xpos, Ypos, onClose);
end;

function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; Defecto: Integer = 0; onClose: Boolean = False): Integer;
begin
  Result := CtmMsgDlgComun(Titulo, Texto, TipoDialogo, Botones, Hints, Defecto, -1, -1, onClose);
end;

// Muestra un cuadro de diálogo común, con Hints en los botones. Con definición de posición
function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; Defecto: Integer = 0; Xpos: Integer = -1; YPos: Integer = -1; onClose: Boolean = False): Integer;
begin
  Result := CtmMsgDlgComun(Titulo, Texto, TipoDialogo, Botones, Hints, Defecto, Xpos, Ypos, onClose);
end;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////  --- Cuadro de diálogo común con función Callback
function CtmMsgDlgComunCallBack(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; CallBack: TMsgDlgCallBack;
  Defecto: Integer = 0; Xpos: Integer = -1; YPos: Integer = -1; onClose: Boolean = False): Integer;
var
  miCtmMsgDlg: TFormaDialogo;
begin
  if Length(Botones) < 2 then
    raise Exception.Create('CtmMsgDlg: Debe haber clic al menos en dos botones.');
  miCtmMsgDlg := TFormaDialogo.Create(Titulo, Texto, TipoDialogo, Botones, Hints, CallBack, Defecto, onClose, YPos, Xpos);
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
  Result := CtmMsgDlgComunCallBack(Titulo, Texto, TipoDialogo, Botones, [], CallBack, Defecto, -1, -1, onClose);
end;

function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones: array of string; CallBack: TMsgDlgCallBack;
  Defecto: Integer = 0; Xpos: Integer = -1; YPos: Integer = -1; onClose: Boolean = False): Integer; overload;
begin
  Result := CtmMsgDlgComunCallBack(Titulo, Texto, TipoDialogo, Botones, [], CallBack, Defecto, Xpos, Ypos, onClose);
end;

function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; CallBack: TMsgDlgCallBack;
  Defecto: Integer = 0; onClose: Boolean = False): Integer;
begin
  Result := CtmMsgDlgComunCallBack(Titulo, Texto, TipoDialogo, Botones, Hints, CallBack, Defecto, -1, -1, onClose);
end;

function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; CallBack: TMsgDlgCallBack;
  Defecto: Integer = 0; Xpos: Integer = -1; YPos: Integer = -1; onClose: Boolean = False): Integer; overload;
begin
  Result := CtmMsgDlgComunCallBack(Titulo, Texto, TipoDialogo, Botones, Hints, CallBack, Defecto, Xpos, Ypos, onClose);
end;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////  --- Cuadro de diálogo con una CheckBox
function CtmMsgDlgCheck(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; const TituloCheckBox: string;
  var CBChecked: Boolean; Defecto: Integer = 0; Xpos: Integer = -1; YPos: Integer = -1; onClose: Boolean = False): Integer;
begin
  if Length(Botones) = 0 then
    raise Exception.Create('CtmMsgDlg: Debe haber clic al menos en un botón.');
  Result := CtmMsgDlg(Titulo, Texto, TipoDialogo, Botones, Hints, TituloCheckBox, CBChecked, nil, Defecto, Xpos, Ypos, onClose);
end;

function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones: array of string; const TituloCheckBox: string;
  var CBChecked: Boolean; Defecto: Integer = 0; onClose: Boolean = False): Integer;
begin
  Result := CtmMsgDlgCheck(Titulo, Texto, TipoDialogo, Botones, [], TituloCheckBox, CBChecked, Defecto, -1, -1, onClose);
end;

function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones: array of string; const TituloCheckBox: string;
  var CBChecked: Boolean; Defecto: Integer = 0; Xpos: Integer = -1; YPos: Integer = -1; onClose: Boolean = False): Integer; overload;
begin
  Result := CtmMsgDlgCheck(Titulo, Texto, TipoDialogo, Botones, [], TituloCheckBox, CBChecked, Defecto, Xpos, Ypos, onClose);
end;

function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; const TituloCheckBox: string;
  var CBChecked: Boolean; Defecto: Integer = 0; Xpos: Integer = -1; YPos: Integer = -1; onClose: Boolean = False): Integer; overload;
begin
  Result := CtmMsgDlgCheck(Titulo, Texto, TipoDialogo, Botones, Hints, TituloCheckBox, CBChecked, Defecto, Xpos, Ypos, onClose);
end;

function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; const TituloCheckBox: string;
  var CBChecked: Boolean; Defecto: Integer = 0; onClose: Boolean = False): Integer;
begin
  Result := CtmMsgDlgCheck(Titulo, Texto, TipoDialogo, Botones, Hints, TituloCheckBox, CBChecked, Defecto, -1, -1, onClose);
end;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////  --- Cuadro de diálogo con una CheckBox y con función Callback
function CtmMsgDlgCheckCallBack(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; const TituloCheckBox: string;
  var CBChecked: Boolean; CallBack: TMsgDlgCallBack; Defecto: Integer = 0; Xpos: Integer = -1; YPos: Integer = -1; onClose: Boolean = False): Integer;
var
  miCtmMsgDlg: TFormaDialogo;
  CB: TCheckBox;
begin
  if Assigned(CallBack) and (Length(Botones) < 2) then
    raise Exception.Create('CtmMsgDlg: Debe haber clic al menos en dos botones.');
  miCtmMsgDlg := TFormaDialogo.Create(Titulo, Texto, TipoDialogo, Botones, Hints, CallBack, Defecto, onClose, YPos, Xpos);
  CB := TCheckBox.Create(miCtmMsgDlg);
  try
    with CB do
    begin
      Parent  := miCtmMsgDlg;
      Left    := 8;
      Top     := miCtmMsgDlg.ClientHeight - 36;
      Width   := miCtmMsgDlg.Width;
      Caption := TituloCheckBox;
      Checked := CBChecked;
    end;
    miCtmMsgDlg.Height := miCtmMsgDlg.Height + CB.Height + 8;
    miCtmMsgDlg.ShowModal;
    CBChecked := CB.Checked;
    Result    := miCtmMsgDlg.BotonClic;
  finally
    FreeAndNil(miCtmMsgDlg);
  end;
end;

function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones: array of string; const TituloCheckBox: string;
  var CBChecked: Boolean; CallBack: TMsgDlgCallBack; Defecto: Integer = 0; onClose: Boolean = False)
  : Integer; overload;
begin
  Result := CtmMsgDlgCheckCallBack(Titulo, Texto, TipoDialogo, Botones, [], TituloCheckBox, CBChecked, CallBack, Defecto, -1, -1, onClose);
end;

function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones: array of string; const TituloCheckBox: string;
  var CBChecked: Boolean; CallBack: TMsgDlgCallBack; Defecto: Integer = 0; Xpos: Integer = -1; YPos: Integer = -1; onClose: Boolean = False): Integer; overload;
begin
  Result := CtmMsgDlgCheckCallBack(Titulo, Texto, TipoDialogo, Botones, [], TituloCheckBox, CBChecked, CallBack, Defecto, Xpos, Ypos, onClose);
end;

function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; const TituloCheckBox: string;
  var CBChecked: Boolean; CallBack: TMsgDlgCallBack; Defecto: Integer = 0; onClose: Boolean = False)
  : Integer; overload;
begin
  Result := CtmMsgDlgCheckCallBack(Titulo, Texto, TipoDialogo, Botones, Hints, TituloCheckBox, CBChecked, CallBack, Defecto, -1, -1, onClose);
end;

function CtmMsgDlg(const Titulo, Texto: string; TipoDialogo: TMsgDlgType;
  const Botones, Hints: array of string; const TituloCheckBox: string;
  var CBChecked: Boolean; CallBack: TMsgDlgCallBack; Defecto: Integer = 0; Xpos: Integer = -1; YPos: Integer = -1; onClose: Boolean = False): Integer; overload;
begin
  Result := CtmMsgDlgCheckCallBack(Titulo, Texto, TipoDialogo, Botones, Hints, TituloCheckBox, CBChecked, CallBack, Defecto, Xpos, Ypos, onClose);
end;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
end.

