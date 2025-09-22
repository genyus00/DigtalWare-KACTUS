@echo off
echo =========================================
echo Registro / Desregistro de Type Library DCOM
echo =========================================
echo.

REM Detectar arquitectura del sistema
set "arch=x86"
if defined ProgramFiles(x86) set "arch=x64"

REM Ruta del TLB en la misma carpeta que el .bat
set "tlbPath=%~dp0ServidorDatos.tlb"

REM Verificar que el archivo existe
if not exist "%tlbPath%" (
    echo ERROR: No se encontro el archivo "%tlbPath%"
    pause
    exit /b
)

REM Usar regtlibv12.exe según arquitectura
if "%arch%"=="x64" (
    set "regtlibPath=C:\Windows\Microsoft.NET\Framework64\v4.0.30319\regtlibv12.exe"
) else (
    set "regtlibPath=C:\Windows\Microsoft.NET\Framework\v4.0.30319\regtlibv12.exe"
)

REM Verificar existencia de regtlibv12.exe
if not exist "%regtlibPath%" (
    echo ERROR: No se encontro regtlibv12.exe en "%regtlibPath%"
    pause
    exit /b
)

echo.
echo Seleccione una opcion:
echo 1 - Registrar TLB
echo 2 - Desregistrar TLB
set /p "opcion=Ingrese opcion (1 o 2): "

if "%opcion%"=="1" (
    echo Registrando libreria de tipos...
    "%regtlibPath%" "%tlbPath%"
    echo Registro completado.
) else if "%opcion%"=="2" (
    echo Desregistrando libreria de tipos...
    "%regtlibPath%" /u "%tlbPath%"
    echo Desregistro completado.
) else (
    echo Opcion invalida.
)

echo.
pause
