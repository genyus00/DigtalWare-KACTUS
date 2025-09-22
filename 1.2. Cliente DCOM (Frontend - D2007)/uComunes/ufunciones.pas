unit ufunciones;

interface
uses
  IniFiles, SysUtils;

function GetWebApiUrl(const IniFilePath: string): string;

implementation

function GetWebApiUrl(const IniFilePath: string): string;
var
  Ini: TIniFile;
begin
  Result := '';
  if not FileExists(IniFilePath) then
    raise Exception.Create('No se encontró el archivo INI: ' + IniFilePath);

  Ini := TIniFile.Create(IniFilePath);
  try
    Result := Ini.ReadString('WEBAPI', 'url', '');
    if Result = '' then
      raise Exception.Create('No se encontró la clave "url" en la sección WEBAPI');
  finally
    Ini.Free;
  end;
end;

end.
