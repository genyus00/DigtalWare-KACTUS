using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

var builder = WebApplication.CreateBuilder(args);

// ========================= CONFIGURACIÓN DEL SERVIDOR =========================

// Habilitar Kestrel para HTTP y HTTPS
// Esto permite que Delphi 2007 use HTTP local sin problemas de SSL
builder.WebHost.ConfigureKestrel(options =>
{
    options.ListenAnyIP(8084);       // HTTP para pruebas locales : ya no se ve swagger
    options.ListenAnyIP(5001, listenOptions =>
    {
        listenOptions.UseHttps();   // HTTPS para producción si se desea
    });
});

// ========================= CONFIGURACIÓN INICIAL =========================

// Swagger / OpenAPI para documentar y probar la API
builder.Services.AddEndpointsApiExplorer(); // Permite que Swagger explore los endpoints de Minimal API
builder.Services.AddSwaggerGen();           // Genera la documentación OpenAPI y la UI interactiva de Swagger

// Registrar DbContext con conexión a PostgreSQL
builder.Services.AddDbContext<MyDbContext>(opt =>
    opt.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// Configuración JSON para evitar referencias cíclicas y valores nulos innecesarios
builder.Services.AddControllers().AddJsonOptions(options =>
{
    options.JsonSerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles; // evita ciclos al serializar
    options.JsonSerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull; // ignora nulos
});

var app = builder.Build(); // Construye la aplicación web con todo lo configurado

// ========================= PIPELINE HTTP =========================
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();    // Activa Swagger solo en entorno desarrollo
    app.UseSwaggerUI();  // Activa la interfaz Swagger UI
    // No redirigir a HTTPS en desarrollo, permite que Delphi 2007 use HTTP
}
else
{
    app.UseHttpsRedirection(); // Fuerza a usar HTTPS siempre que sea posible
}

// Permitir CORS para cualquier origen, método y cabecera
// Esto es importante para apps nativas como Delphi
app.UseCors(c => c.AllowAnyHeader().AllowAnyOrigin().AllowAnyMethod());

// ========================= ENDPOINTS =========================

// ---------- POST /clientes ----------
// Crea un nuevo cliente en la base de datos
app.MapPost("/clientes", async (ClienteCreateDto clienteDto, MyDbContext db) =>
{
    // Validación simple
    if (string.IsNullOrWhiteSpace(clienteDto.NombreCliente))
    {
        return Results.Json(new
        {
            CodError = 400,
            ErrorMsg = "El nombre del cliente es obligatorio."
        });
    }

    // Verificar si el cliente ya existe
    var existingCliente = await db.Clientes.FindAsync(clienteDto.ClienteId);
    if (existingCliente != null)
    {
        return Results.Json(new
        {
            CodError = 409,
            ErrorMsg = $"El cliente con Id {clienteDto.ClienteId} ya existe."
        });
    }

    try
    {
        // Mapear DTO a entidad Cliente
        var cliente = new Cliente
        {
            ClienteId = clienteDto.ClienteId,
            NombreCliente = clienteDto.NombreCliente,
            Direccion = clienteDto.Direccion
        };

        db.Clientes.Add(cliente);       // Insertar en DbSet
        await db.SaveChangesAsync();    // Guardar en la base

        return Results.Json(new
        {
            CodError = 0,
            Message = "Cliente creado satisfactoriamente.",
            Data = new ClienteDto(cliente.ClienteId, cliente.NombreCliente, cliente.Direccion)
        });
    }
    catch (Exception ex)
    {
        return Results.Json(new
        {
            CodError = 500,
            ErrorMsg = "Error interno del servidor al registrar el cliente.",
            Error = ex.Message
        });
    }
})
.WithOpenApi()
.WithName("CreateCliente");


// ---------- GET /facturas/{numero} ----------
// Obtiene una factura por número, incluyendo su cliente y detalles con productos
app.MapGet("/facturas/{numero}", async (int numero, MyDbContext db) =>
{
    try
    {
        // Consulta con Include para traer cliente y productos relacionados
        var factura = await db.Facturas
            .Include(f => f.Cliente)               // Incluye los datos del cliente
            .Include(f => f.Detalles)              // Incluye los detalles
                .ThenInclude(d => d.Producto)      // Y dentro de detalles, incluir el producto
            .FirstOrDefaultAsync(f => f.Numero == numero);

        if (factura == null)
        {
            return Results.NotFound(new
            {
                CodError = 404,
                ErrorMsg = $"Factura con número '{numero}' no encontrada."
            });
        }

        // Mapear la entidad Factura a un DTO de salida
        var facturaDto = new FacturaDto
        {
            Numero = factura.Numero,
            Fecha = factura.Fecha,
            ClienteId = factura.ClienteId,
            Total = factura.Total,
            Cliente = factura.Cliente != null ? new ClienteDto(
                factura.Cliente.ClienteId,
                factura.Cliente.NombreCliente,
                factura.Cliente.Direccion
            ) : null,
            Detalles = factura.Detalles.Select(d => new DetalleFacturaDto
            {
                Numero = d.Numero,
                ProductoId = d.ProductoId,
                Cantidad = d.Cantidad,
                Valor = d.Valor,
                Producto = d.Producto != null ? new ProductoDto(
                    d.Producto.ProductoId,
                    d.Producto.NombreProducto,
                    d.Producto.Valor
                ) : null
            }).ToList()
        };

        return Results.Ok(new
        {
            CodError = 0,
            Message = "Factura recuperada satisfactoriamente.",
            Data = facturaDto
        });
    }
    catch (Exception ex)
    {
        return Results.Json(new
        {
            CodError = 500,
            ErrorMsg = "Error interno del servidor al obtener la factura.",
            Error = ex.Message
        }, statusCode: 500);
    }
})
.WithOpenApi()
.WithName("GetFactura");

app.Run(); // Arranca la aplicación y comienza a escuchar peticiones

// ========================= DTOs =========================
// Objetos de transferencia de datos (entrada/salida), evitan exponer directamente las entidades

// Para creación
public record ClienteCreateDto(int ClienteId, string? NombreCliente, string? Direccion);
public record ProductoCreateDto(string? NombreProducto, double Valor);
public record DetalleFacturaCreateDto(int ProductoId, int Cantidad, double Valor);
public record FacturaCreateDto(int ClienteId, List<DetalleFacturaCreateDto> Detalles);

// Para respuesta
public record ClienteDto(int ClienteId, string? NombreCliente, string? Direccion);
public record ProductoDto(int ProductoId, string? NombreProducto, double Valor);

// DTO detallado de una factura
public record DetalleFacturaDto
{
    public int Numero { get; set; }
    public int ProductoId { get; set; }
    public int Cantidad { get; set; }
    public double Valor { get; set; }
    public ProductoDto? Producto { get; set; } // Se anida el producto dentro del detalle
}

// Modelo Factura (cabeza_factura)
public class FacturaDto
{
    public int Numero { get; set; }
    public DateTime Fecha { get; set; }
    public int ClienteId { get; set; }
    public double Total { get; set; }
    public ClienteDto? Cliente { get; set; } // Incluye los datos del cliente
    public List<DetalleFacturaDto> Detalles { get; set; } = new(); // Lista de detalles
}

// ========================= MODELOS (Entidades) =========================
// Representan las tablas de la base de datos

class Cliente
{
    [Key]
    public int ClienteId { get; set; } // PK = "cliente" en SQL
    public string? NombreCliente { get; set; }
    public string? Direccion { get; set; }

    [JsonIgnore]
    public ICollection<Factura> Facturas { get; set; } = new List<Factura>(); // Relación 1 a muchos
}

class Factura
{
    [Key]
    public int Numero { get; set; } // PK = "numero" en SQL
    public DateTime Fecha { get; set; } = DateTime.Now;
    public int ClienteId { get; set; }
    public double Total { get; set; }

    public Cliente? Cliente { get; set; } // Relación con Cliente
    public ICollection<DetalleFactura> Detalles { get; set; } = new List<DetalleFactura>();
}

class DetalleFactura
{
    public int Numero { get; set; }     // Parte de la PK compuesta
    public int ProductoId { get; set; } // Parte de la PK compuesta
    public int Cantidad { get; set; }
    public double Valor { get; set; }

    public Factura? Factura { get; set; }  // Relación con Factura
    public Producto? Producto { get; set; } // Relación con Producto
}

class Producto
{
    [Key]
    public int ProductoId { get; set; } // PK = "producto" en SQL
    public string? NombreProducto { get; set; }
    public double Valor { get; set; }

    [JsonIgnore]
    public ICollection<DetalleFactura> Detalles { get; set; } = new List<DetalleFactura>();
}

// ========================= CONTEXTO =========================
// Representa la conexión con la base y define el mapeo de entidades/tablas

class MyDbContext : DbContext
{
    public MyDbContext(DbContextOptions<MyDbContext> options) : base(options) { }

    // DbSets = representan cada tabla de la BD
    public DbSet<Cliente> Clientes => Set<Cliente>();
    public DbSet<Factura> Facturas => Set<Factura>();
    public DbSet<DetalleFactura> DetalleFacturas => Set<DetalleFactura>();
    public DbSet<Producto> Productos => Set<Producto>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // ------------------- Mapeo de Tablas -------------------
        modelBuilder.Entity<Cliente>().ToTable("clientes");//indica que el DbSet Cliente corresponde a la tabla real.
        modelBuilder.Entity<Factura>().ToTable("cabeza_factura");//indica que el DbSet Factura corresponde a la tabla real.
        modelBuilder.Entity<DetalleFactura>().ToTable("detalle_factura");//indica que el DbSet DetalleFactura corresponde a la tabla real.
        modelBuilder.Entity<Producto>().ToTable("productos");//indica que el DbSet Producto corresponde a la tabla real.

        // ------------------- Mapeo de Columnas -------------------
        modelBuilder.Entity<Cliente>(entity =>
        {
            entity.Property(c => c.ClienteId).HasColumnName("cliente");
            entity.Property(c => c.NombreCliente).HasColumnName("nombre_cliente");
            entity.Property(c => c.Direccion).HasColumnName("direccion");
        });

        modelBuilder.Entity<Factura>(entity =>
        {
            entity.Property(f => f.Numero).HasColumnName("numero");
            entity.Property(f => f.Fecha).HasColumnName("fecha");
            entity.Property(f => f.ClienteId).HasColumnName("cliente");
            entity.Property(f => f.Total).HasColumnName("total");
        });

        modelBuilder.Entity<DetalleFactura>(entity =>
        {
            entity.Property(d => d.Numero).HasColumnName("numero");
            entity.Property(d => d.ProductoId).HasColumnName("producto");
            entity.Property(d => d.Cantidad).HasColumnName("cantidad");
            entity.Property(d => d.Valor).HasColumnName("valor");
        });

        modelBuilder.Entity<Producto>(entity =>
        {
            entity.Property(p => p.ProductoId).HasColumnName("producto");
            entity.Property(p => p.NombreProducto).HasColumnName("nombre_producto");
            entity.Property(p => p.Valor).HasColumnName("valor");
        });

        // ------------------- Configuración de claves -------------------
        modelBuilder.Entity<DetalleFactura>()
            .HasKey(df => new { df.Numero, df.ProductoId }); // PK compuesta

        // ------------------- Relaciones -------------------
        // Cliente -> Factura (1 a muchos)
        modelBuilder.Entity<Factura>()
            .HasOne(f => f.Cliente)
            .WithMany(c => c.Facturas)
            .HasForeignKey(f => f.ClienteId)
            .OnDelete(DeleteBehavior.Cascade);

        // Factura -> DetalleFactura (1 a muchos)
        modelBuilder.Entity<DetalleFactura>()
            .HasOne(df => df.Factura)
            .WithMany(f => f.Detalles)
            .HasForeignKey(df => df.Numero)
            .OnDelete(DeleteBehavior.Cascade);

        // Producto -> DetalleFactura (1 a muchos)
        modelBuilder.Entity<DetalleFactura>()
            .HasOne(df => df.Producto)
            .WithMany(p => p.Detalles)
            .HasForeignKey(df => df.ProductoId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
