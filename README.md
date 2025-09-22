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

