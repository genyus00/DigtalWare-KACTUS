# DigitalWare - KACTUS  
Prueba Técnica: Desarrollo en Delphi + API .NET

Este proyecto implementa un **CRUD de clientes** y un **módulo de facturación**, integrando:  

- **Aplicación Delphi (3 capas con DCOM)**  
- **Servidor DCOM (Delphi DataSnap/RemObjects)**  
- **API REST en .NET 7/8 (C# + PostgreSQL)**  
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

### 🔹 Obtener Factura por Número  

**GET** `/facturas/{numero}`  

📤 **Respuesta de ejemplo:**

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

🖥️ Cliente Delphi
Funcionalidad

Consulta facturas desde la API (IdHTTP + SuperObject).

Muestra cabecera en cdsFactura.

Lista de detalles en cdsDetalle.

Casos soportados
Escenario en API	Resultado en Delphi
Factura no existe (404)	Muestra mensaje de error.
Factura sin detalles	cdsDetalle vacío.
Detalle sin producto	Campo Producto = 'N/A'.
Cliente nulo	Campos cliente vacíos.

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

- Cliente **Delphi 2007** tiene limitaciones con **HTTPS** (TLS moderno no soportado).  
- Actualmente se trabaja en **HTTP (puerto 8084)**.  

Para usar **HTTPS** se recomienda:  
- Configurar un **proxy inverso** (NGINX / Apache / IIS).  
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

