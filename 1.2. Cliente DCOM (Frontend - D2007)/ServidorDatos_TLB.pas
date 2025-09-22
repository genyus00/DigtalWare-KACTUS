unit ServidorDatos_TLB;

// ************************************************************************ //
// WARNING
// -------
// The types declared in this file were generated from data read from a
// Type Library. If this type library is explicitly or indirectly (via
// another type library referring to this type library) re-imported, or the
// 'Refresh' command of the Type Library Editor activated while editing the
// Type Library, the contents of this file will be regenerated and all
// manual modifications will be lost.
// ************************************************************************ //

// $Rev: 52393 $
// File generated on 20/09/2025 11:02:10 p. m. from Type Library described below.

// ************************************************************************  //
// Type Lib: F:\1T Documentos\TRABAJOS\2021 DigitalWare\Prueba Desarrollador Delphi Expert 2025\3.2 Codigo Fuente\3.2.1. ServidorDatos (Backend - DTokyo)\ServidorDatos (1)
// LIBID: {2D8B5D2B-8351-4679-B6E6-F7F8CB8AE3CF}
// LCID: 0
// Helpfile:
// HelpString: ServidorDatos Library
// DepndLst:
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
//   (2) v1.0 Midas, (midas.dll)
// SYS_KIND: SYS_WIN32
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers.
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}

interface

uses Windows, Midas, Classes, Variants, StdVCL, Graphics, OleServer, ActiveX;



// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:
//   Type Libraries     : LIBID_xxxx
//   CoClasses          : CLASS_xxxx
//   DISPInterfaces     : DIID_xxxx
//   Non-DISP interfaces: IID_xxxx
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  ServidorDatosMajorVersion = 1;
  ServidorDatosMinorVersion = 0;

  LIBID_ServidorDatos: TGUID = '{2D8B5D2B-8351-4679-B6E6-F7F8CB8AE3CF}';

  IID_IServidorDCOM: TGUID = '{AF876F13-DB2F-480F-8E8D-7989AACCD128}';
  CLASS_ServidorDCOM: TGUID = '{E807A848-27BB-4206-A6F3-728041D49D25}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary
// *********************************************************************//
  IServidorDCOM = interface;
  IServidorDCOMDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library
// (NOTE: Here we map each CoClass to its Default Interface)
// *********************************************************************//
  ServidorDCOM = IServidorDCOM;


// *********************************************************************//
// Interface: IServidorDCOM
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {AF876F13-DB2F-480F-8E8D-7989AACCD128}
// *********************************************************************//
  IServidorDCOM = interface(IAppServer)
    ['{AF876F13-DB2F-480F-8E8D-7989AACCD128}']
    procedure Activar; safecall;
    procedure Desactivar; safecall;
    function Saludar(Nombre: OleVariant): OleVariant; safecall;
  end;

// *********************************************************************//
// DispIntf:  IServidorDCOMDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {AF876F13-DB2F-480F-8E8D-7989AACCD128}
// *********************************************************************//
  IServidorDCOMDisp = dispinterface
    ['{AF876F13-DB2F-480F-8E8D-7989AACCD128}']
    procedure Activar; dispid 301;
    procedure Desactivar; dispid 302;
    function Saludar(Nombre: OleVariant): OleVariant; dispid 303;
    function AS_ApplyUpdates(const ProviderName: WideString; Delta: OleVariant; MaxErrors: SYSINT;
                             out ErrorCount: SYSINT; var OwnerData: OleVariant): OleVariant; dispid 20000000;
    function AS_GetRecords(const ProviderName: WideString; Count: SYSINT; out RecsOut: SYSINT;
                           Options: SYSINT; const CommandText: WideString; var Params: OleVariant;
                           var OwnerData: OleVariant): OleVariant; dispid 20000001;
    function AS_DataRequest(const ProviderName: WideString; Data: OleVariant): OleVariant; dispid 20000002;
    function AS_GetProviderNames: OleVariant; dispid 20000003;
    function AS_GetParams(const ProviderName: WideString; var OwnerData: OleVariant): OleVariant; dispid 20000004;
    function AS_RowRequest(const ProviderName: WideString; Row: OleVariant; RequestType: SYSINT;
                           var OwnerData: OleVariant): OleVariant; dispid 20000005;
    procedure AS_Execute(const ProviderName: WideString; const CommandText: WideString;
                         var Params: OleVariant; var OwnerData: OleVariant); dispid 20000006;
  end;

// *********************************************************************//
// The Class CoServidorDCOM provides a Create and CreateRemote method to
// create instances of the default interface IServidorDCOM exposed by
// the CoClass ServidorDCOM. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoServidorDCOM = class
    class function Create: IServidorDCOM;
    class function CreateRemote(const MachineName: string): IServidorDCOM;
  end;

implementation

uses ComObj;

class function CoServidorDCOM.Create: IServidorDCOM;
begin
  Result := CreateComObject(CLASS_ServidorDCOM) as IServidorDCOM;
end;

class function CoServidorDCOM.CreateRemote(const MachineName: string): IServidorDCOM;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ServidorDCOM) as IServidorDCOM;
end;

end.

