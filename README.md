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


