@echo off
echo =========================================
echo Registro / Desregistro de Servidor DCOM
echo =========================================

REM Definir ruta del ejecutable en la misma carpeta que el .bat
set exePath="%~dp0ServidorDatos.exe"

REM Verificar que el archivo existe
if not exist %exePath% (
    echo ERROR: No se encontro el archivo %exePath%
    pause
    exit /b
)

REM Preguntar acción
echo.
echo Seleccione una opcion:
echo 1 - Registrar servidor
echo 2 - Desregistrar servidor
set /p opcion=Ingrese opcion (1 o 2): 

REM Evaluar opción
if "%opcion%"=="1" (
    echo Registrando servidor...
    %exePath% /regserver
    echo Servidor registrado.
) else (
    if "%opcion%"=="2" (
        echo Desregistrando servidor...
        %exePath% /unregserver
        echo Servidor desregistrado.
    ) else (
        echo Opcion invalida.
    )
)

pause
