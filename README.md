# DigitalWare - KACTUS  
Prueba Técnica: Desarrollo en Delphi + API .NET

Este proyecto implementa un **CRUD de clientes** y un **módulo de facturación**, integrando:  

- **Aplicación Delphi (3 capas con DCOM)**  
- **Servidor DCOM (Delphi DataSnap/RemObjects)**  
- **API REST en .NET 8 (C# + PostgreSQL)**  
- **Base de datos PostgreSQL**  

---

## Objetivos de la prueba

1. Construir un CRUD de clientes en Delphi usando arquitectura en tres capas:  
   - **Presentación** (forms/activeform).  
   - **Lógica de Negocio** (DataModule remoto, ejecutable independiente).  
   - **Acceso a Datos** (PostgreSQL).  

2. Usar protocolo **DCOM** para la comunicación entre cliente y servidor de datos.  

3. Generar una **API REST en .NET** que:  
   - Permita crear clientes (**POST /clientes**).  
   - Permita consultar facturas con su detalle y productos (**GET /facturas/{numero}**).  

4. Permitir la interacción entre el cliente Delphi y la API .NET.  

---

## Estructura del Proyecto

```plaintext
/api-net
├── Program.cs              # Minimal API .NET
├── Models/                 # Entidades EF Core
├── Dtos/                   # DTOs de entrada/salida
└── MyDbContext.cs          # Contexto EF Core para PostgreSQL

/servidor-dcom
├── ServidorDatos.exe       # Servidor remoto DCOM
├── FDConnection1.Params    # Config BD PostgreSQL
├── RegistrarServidor.bat   # Registro / Desregistro DCOM
├── libpq.dll, midas.dll    # Dependencias necesarias

/cliente-delphi
├── AppCliente.exe          # Cliente Delphi
├── params.ini              # Config conexión DCOM + API
├── RegistrarTLB.bat        # Registro librería TLB
└── ServidorDatos.tlb       # Librería de tipos DCOM
```

---

## Base de Datos

### Modelo Entidad-Relación

- **Clientes** (clienteId, nombreCliente, direccion)  
- **Cabeza_Factura** (numero, fecha, clienteId, total)  
- **Productos** (productoId, nombreProducto, valor)  
- **Detalle_Factura** (numero, productoId, cantidad, valor)  

### Script ejemplo

```sql
CREATE TABLE clientes (
    cliente INT PRIMARY KEY,
    nombre_cliente VARCHAR(100),
    direccion VARCHAR(200)
);

CREATE TABLE cabeza_factura (
    numero INT PRIMARY KEY,
    fecha TIMESTAMP,
    cliente INT REFERENCES clientes(cliente),
    total NUMERIC
);

CREATE TABLE productos (
    producto INT PRIMARY KEY,
    nombre_producto VARCHAR(100),
    valor NUMERIC
);

CREATE TABLE detalle_factura (
    numero INT REFERENCES cabeza_factura(numero),
    producto INT REFERENCES productos(producto),
    cantidad INT,
    valor NUMERIC,
    PRIMARY KEY (numero, producto)
);
```

---

# API .NET (C# Minimal API) + Cliente Delphi

## Configuración

### `appsettings.json`

```json
"ConnectionStrings": {
  "DefaultConnection": "Host=localhost;Database=DBDW_Test;Username=postgres;Password=Asdf1234$"
}
```

## Endpoints principales
### Crear Cliente

**POST** `/clientes`

**Body de ejemplo:**

```json
{
  "clienteId": 1,
  "nombreCliente": "ACME S.A.",
  "direccion": "Calle 123"
}
```

### Obtener Factura por Número  

**GET** `/facturas/{numero}`  

**Respuesta de ejemplo:**

```json
{
  "CodError": 0,
  "Message": "Factura recuperada satisfactoriamente.",
  "Data": {
    "Numero": 123,
    "Fecha": "2025-09-24T08:30:00",
    "ClienteId": 1,
    "Total": 5000,
    "Cliente": {
      "ClienteId": 1,
      "NombreCliente": "ACME S.A.",
      "Direccion": "Calle 123"
    },
    "Detalles": [
      {
        "Numero": 123,
        "ProductoId": 10,
        "Cantidad": 2,
        "Valor": 1500,
        "Producto": {
          "ProductoId": 10,
          "NombreProducto": "Mouse",
          "Valor": 1500
        }
      }
    ]
  }
}
```

## Cliente Delphi  

El cliente está desarrollado en **Delphi 2007**, originalmente para conectarse vía **DCOM** al servidor legado en XP, y extendido para consumir también la **API REST** expuesta en el host W10.  

---

### Funcionalidad
- Consulta facturas y registra clientes desde la **API .NET** usando `IdHTTP + SuperObject`.  
- Consumo de servicios vía **DCOM** con `TDCOMConnection` y `TClientDataSet`.  
- Manejo de datasets locales (`cdsClientes`, `cdsProductos`, `cdsFacturas`, `cdsDetalle_Factura`).  
- Control de errores y logging centralizado en el `DataModule`.  

---

### Conexiones soportadas
#### **DCOM (legado)**
- Conecta con `ServidorDatos.exe` en la VM XP.  
- Requiere `midas.dll` y `libpq.dll` en el cliente.  
- Configuración en `params.ini`:
  ```ini
  [PARAMS]
  ComputerName=localhost
  ServerGUID={E807A848-27BB-4206-A6F3-728041D49D25}
  ServerName=ServidorDatos.ServidorDCOM
  ```

#### **API REST (nuevo)**
  - Consulta facturas y registra clientes vía HTTP.
  - Implementado con **Indy (IdHTTP)** + **SuperObject**.
  - Configuración en `params.ini`:
    ```ini
    [WEBAPI]
    url=http://192.168.5.101:8084
    ```
---

### Flujo de conexión (DCOM)

1. **Configuración inicial**  
   - Se lee `Params.ini` para obtener:  
     - `ComputerName` (host del servidor XP).  
     - `ServerName` y `ServerGUID`.  

2. **DataModule (uDatamodule.pas)**  
   - Implementa conexión segura con logging (`LogLines`).  
   - Métodos principales:  
     - `ConectarServidor / DesconectarServidor`  
     - `AbrirCDS(cds, Nombre)`  
     - `GuardarCambios(cds, Nombre)`  
     - `ExisteFacturaConNumero(numero)`  

3. **Errores comunes tratados**  
   - Duplicación de claves primarias.  
   - Violación de integridad referencial.  
   - Eliminación de registros con dependencias.  
   - Factura con número duplicado (valida en dataset + BD).  

---

### Formularios principal (Acceso)
- **`uFrmPrincipal.pas`**

### Formularios principales (DCOM)
- **`uFrmClientes.pas`**
- **`ufrmFactura.pas`**
- **`ufrmProductos.pas`**
- **`ufrmRegFactura.pas`**

### Formularios principales (API REST)
- **`ufrmViewFactura.pas`**
  - Botón **Consultar Factura** (`BtnGetFactura`).
  - Ejecuta `GET /facturas/{id}` contra la API.
  - Respuesta JSON se parsea con **SuperObject**.
  - Los datos se cargan en `cdsFactura` (cabecera) y `cdsDetalle` (productos).

- **`ufrmClienteAPI.pas`**
  - Formulario para registro de clientes.
  - Botón **Crear Cliente** (`BtnCrearCliente`).
  - Ejecuta `POST /clientes` enviando JSON con:
    ```json
    {
      "ClienteId": 1,
      "NombreCliente": "ACME S.A.",
      "Direccion": "Calle 123"
    }
    ```
  - Muestra en pantalla el resultado según `codError`, `message` o `errorMsg`.

---

### Librerías requeridas
- **Indy** (`IdHTTP`, `IdSSL`).
- **SuperObject** (manejo de JSON).
- **midas.dll** y **libpq.dll** (para compatibilidad DCOM/DataSnap).

---

### Casos soportados (API y DCOM)

| Escenario en API/DCOM         | Resultado en Delphi |
|-------------------------------|---------------------|
| Factura no existe (`404` / no encontrada en BD) | Mensaje de error. |
| Factura sin detalles          | `cdsDetalle` vacío. |
| Detalle sin producto          | Campo **Producto = 'N/A'**. |
| Cliente nulo                  | Campos cliente vacíos. |
| Número de factura duplicado   | Mensaje de validación y aborta inserción. |

---

### Logging  

Cada acción relevante se registra en memoria (`TStringList`).  

#### Ejemplo de log
```text
[2025-09-24 10:30:15] Conectado a Servidor DCOM en localhost  
[2025-09-24 10:31:02] GET /facturas/123 → OK  
[2025-09-24 10:31:05] POST /clientes → Cliente ACME S.A. creado  
```

## De esta forma el cliente Delphi puede:
- Seguir usando **DCOM** para compatibilidad con el servidor XP.
- O consumir la **API REST** en W10 para nuevas integraciones.
 
---

## Infraestructura y despliegue  

### Esquema de conexiones  

- **W10 (Host)** → PostgreSQL + API .NET (puerto 8084).  
- **WXP (VM)** → Servidor DCOM (conexión PostgreSQL).  
- **W7 (VM)** → Cliente Delphi, conectado a:  
  - Servidor DCOM en XP (via DCOM).  
  - API .NET en W10 (via HTTP:8084).  

---

### Archivos clave  

- `ServidorDatos.exe` → Servidor DCOM.  
- `RegistrarServidor.bat` → Registro DCOM (`/regserver` y `/unregserver`).  
- `RegistrarTLB.bat` → Registro de librería de tipos en cliente.  
- `params.ini` → Configuración de cliente:  

```ini
[PARAMS]
ComputerName=localhost
ServerGUID={E807A848-27BB-4206-A6F3-728041D49D25}
ServerName=ServidorDatos.ServidorDCOM

[WEBAPI]
url=http://192.168.5.101:8084
```

---

## Consideraciones de seguridad  
- Actualmente se usa **HTTP plano (puerto 8084)**: Delphi 2007 no soporta TLS moderno.
- Para HTTPS se recomienda:
  - Configurar **Proxy inverso** (NGINX / Apache / IIS).
  - Migrar a **Delphi más reciente** con soporte TLS 1.2/1.3.

---

## Requisitos  

### Servidor (W10)  
- Windows 10 con PostgreSQL.  
- .NET 7/8 SDK.  

### Servidor DCOM (VM XP)  
- Delphi (compilado con DataSnap/DCOM).  
- PostgreSQL Client (`libpq.dll`).  

### Cliente (VM W7 / Delphi 2007)  
- Indy + SuperObject.  
- `midas.dll` y `libpq.dll`.  

---

## Arquitectura del sistema

```mermaid
flowchart TD

  subgraph Cliente_W7["💻 Cliente Delphi (Windows 7)"]
    A1[AppCliente.exe]
    A2[params.ini]
  end

  subgraph Servidor_XP["🖥️ Servidor DCOM (Windows XP)"]
    B1[ServidorDatos.exe]
    B2[ServidorDatos.tlb]
    B3[FDConnection1.Params]
  end

  subgraph Servidor_W10["🖥️ Host (Windows 10)"]
    C1[API .NET WebAPI.exe :8084]
    C2[PostgreSQL DB]
  end

  %% Conexiones
  A1 -- DCOM --> Servidor_XP
  A1 -- HTTP:8084 --> C1
  B1 -- PostgreSQL --> C2
  C1 -- EF Core --> C2

