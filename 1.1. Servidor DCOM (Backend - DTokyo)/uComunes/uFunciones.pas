unit uFunciones;

interface

uses
  Windows, SysUtils;


function GetAppVersion: string;


implementation

function GetAppVersion: string;
var
  VerSize, VerHandle: DWORD;
  VerBuf: Pointer;
  FI: PVSFixedFileInfo;
  Len: UINT;
begin
  Result := '';
  VerSize := GetFileVersionInfoSize(PChar(ParamStr(0)), VerHandle);
  if VerSize > 0 then
  begin
    GetMem(VerBuf, VerSize);
    try
      if GetFileVersionInfo(PChar(ParamStr(0)), VerHandle, VerSize, VerBuf) then
      begin
        if VerQueryValue(VerBuf, '\', Pointer(FI), Len) then
        begin
          Result := Format('%d.%d.%d.%d',
            [HiWord(FI.dwFileVersionMS), // Major
             LoWord(FI.dwFileVersionMS), // Minor
             HiWord(FI.dwFileVersionLS), // Release
             LoWord(FI.dwFileVersionLS)] // Build
          );
        end;
      end;
    finally
      FreeMem(VerBuf);
    end;
  end;
end;

end.

