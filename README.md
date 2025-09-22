# DigtalWare-KACTUS
Prueba Técnica: Desarrollo Delphi KACTUS

CRUD Clientes. Manejo de base de datos.
1. Crear las tablas del siguiente modelo entidad relación.
2. Construir un programa que permita insertar, modificar, eliminar y consultar filas.
Los siguientes puntos son un Plus para la prueba: (No son indispensables, pero de realizarlos genera puntos extra en el proceso de selección).
3. El programa debe estar construido usando arquitectura de tres capas:
∙ Presentación.
∙ Lógica de Negocio.
∙ Acceso a Datos.
4. La capa de presentación puede estar construida como se desee (activeform, form, etc.).
5. La capa de lógica debe implementarse usando datamodulo remoto (exe).
6. Se debe usar protocolo DCOM para comunicar capa de presentación a capa de lógica.
Datos de acceso a Base de Datos (si aplica):
Servidor: 192.168.5.101
Nombre BD: DBDW_Test
Usuario: postgres
Password: Asdf1234$
7- Generar un servicio web (API REST) en .Net (C#) que contenga 2 endpoints el primero con verbo POST para crear registros sobre la tabla clientes y un segundo endpoint que permita Consultar los el detalle de factura
8- Permitir la interacción entre el programa en Delphi y el servicio en .Net

**Elementos del diagrama:**
* PC con Windows 10 (HOST)
- Aplicación + Base de datos PostgreSQL
- Servidor Web API .NET (exe) — escucha en puerto 8084
- Se conecta a la base de datos local.

**VMWare: PC con Windows XP (servidor DCOM)**
- IP: 192.168.5.103
- Servidor DCOM
- Se conecta a la base de datos (supongo que también a PostgreSQL en W10).

**VMWare: PC con Windows 7 (cliente)**
- IP: 192.168.5.115
- Aplicación cliente
- Consume DCOM del XP
- Consume API .NET del W10 (puerto 8084)

**Relaciones / Conexiones:**
W10 → Base de datos (PostgreSQL)
WXP → Base de datos (PostgreSQL)
W7 → WXP (DCOM)
W7 → W10 (API .NET:8084)

**ServidorDatos (Backend - DTokyo)**
El proyecto cuenta con un Servidor de Datos llamado ServidorDatos, que actúa como backend de la aplicación DTokyo y se conecta a la base de datos PostgreSQL.
Archivo de Configuración

La conexión a la base de datos se configura mediante el archivo FDConnection1.Params, ubicado en la misma carpeta que el ejecutable del servidor.

Ejemplo de contenido:

DriverID=PG
Port=5432
Server=127.0.0.1
Password=Asdf1234$
Database=DBDW_Test
User_Name=postgres

Este archivo define:
- DriverID: Tipo de base de datos (PG para PostgreSQL)
- Port: Puerto de conexión (por defecto 5432)
- Server: Dirección del servidor de base de datos (127.0.0.1 para local)
- Database: Nombre de la base de datos
- User_Name y Password: Credenciales de acceso

Registro del Servidor DCOM
Para que ServidorDatos funcione correctamente como servidor DCOM, debe ser registrado en Windows. Esto se realiza mediante el archivo RegistrarServidor.bat, que se encuentra en la misma carpeta que el ejecutable.
- El script RegistrarServidor.bat permite:
- Registrar el servidor (/regserver)
- Desregistrar el servidor (/unregserver)

Funcionamiento del script
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


Al ejecutar el script, se solicitará seleccionar Registrar o Desregistrar el servidor.
El registro es necesario para que los clientes DCOM puedan conectarse a ServidorDatos.
Archivos requeridos en la misma carpeta
Para que el servidor funcione correctamente, la carpeta debe contener:
- ServidorDatos.exe → Ejecutable del servidor DCOM
- FDConnection1.Params → Configuración de conexión a la base de datos
- RegistrarServidor.bat → Script para registrar/desregistrar el servidor
- libpq.dll → Librería de PostgreSQL necesaria
- midas.dll → Librería de soporte para Delphi/C++ Builder


