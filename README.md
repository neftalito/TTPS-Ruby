# Integrantes
- Lautaro Tomas Budini
- Neftalí Taiel Toledo Dicroce
- Nicolás Tenaglia

# Decisiones de diseno
- Se eliminó la recuperación de contraseña por mail de Devise para no depender de un servidor SMTP.
- Todo modelo eliminable también puede ser recuperado.
- Los productos sin stock se muestran en escala de grises en el frontstore.
- El stock es visible desde el frontstore para facilitar la demostración del trabajo.
- El dashboard del backstore muestra ventas y ganancias del usuario actual, accesos rapidos, gráficos de ventas, stock crítico y últimas ventas confirmadas.
- El modulo de reportes vive en una sección separada de la gestión de ventas y sólo considera ventas confirmadas.
- Los reportes se pueden filtrar por fecha, tipo de producto, género musical y empleado.
- Los reportes muestran métricas numéricas y gráficas, junto con exportación en CSV y PDF.
- Los productos admiten hasta 10 imágenes en formatos JPG, PNG, GIF y WEBP, con un máximo de 10 MB por imagen.
- Los audios para productos usados admiten formatos MP3, WAV, OGG, M4A y FLAC, con un máximo de 15 MB.
- La portada de un producto es siempre la primera imagen cargada.
- El precio de cada item de venta se toma automáticamente del precio actual del producto.
- El nombre visible del usuario autenticado se obtiene a partir del correo, usando el fragmento anterior al `@`.

# Usuarios creados por defecto en el seed
## Administrador
- Usuario: `admin@sistema.com`
- Contrasena: `admin123`

## Gerente
- Usuario: `manager@sistema.com`
- Contrasena: `manager123`

## Empleado
- Usuario: `empleado@sistema.com`
- Contrasena: `empleado123`

# Requisitos previos
- Ruby 3.4.7
- Sqlite3
- Node.js y npm

# Instalación
1. Clonar el repositorio

```bash
git clone https://github.com/neftalito/TTPS-Ruby
cd TTPS-Ruby/src
```

2. Instalar dependencias Ruby

```bash
bundle install
```

3. Instalar dependencias JavaScript

```bash
npm install
```

4. Inicializar la base de datos

```bash
bin/rails db:create db:migrate db:seed
```

Si necesitas reiniciar todo desde cero, podes usar:

```bash
bin/rails db:reset
```

5. Ejecutar la aplicación con Foreman

```bash
foreman start -f Procfile.dev
```

6. Acceder a la aplicacion
- Frontstore: `http://localhost:3000`
- Backstore: `http://localhost:3000/admin`

# Módulo de reportes
## Cómo acceder
- Ingresar al backstore y abrir la sección `Reportes` del sidebar.
- También se puede entrar directamente en `http://localhost:3000/admin/reports`.

## Métricas y análisis que se muestran
- Total recaudado en el periodo filtrado.
- Cantidad de ventas realizadas.
- Promedio de importe por venta.
- Cantidad de productos vendidos.
- Gráfico de ventas por tipo de producto (CD / Vinilo).
- Gráfico de ventas por género musical.
- Top 5 productos más vendidos.

## Filtros disponibles
- Fecha desde / hasta.
- Tipo de producto.
- Género musical.
- Empleado que realizó la venta.

## Exportación
- El reporte actual se puede descargar en formato CSV.
- El mismo reporte también se puede exportar como PDF.

## Cómo generar datos de prueba
- Ejecutar `bin/rails db:seed` desde la carpeta `src`.
- Para recrear la base completa, ejecutar `bin/rails db:reset`.
- El seed genera productos, ventas confirmadas, ventas canceladas y un lote de ventas de demostración pensado para visualizar correctamente las métricas y gráficos.

# Notas para desarrolladores
## Instalar dependencias Ruby

```bash
bundle install
```

## Instalar dependencias JavaScript

```bash
npm install
```

## Agregar una gema
- Editar `Gemfile` y luego ejecutar:

```bash
bundle install
```

## Agregar un paquete de JavaScript

```bash
npm install nombre-del-paquete
```

## Ejecutar la aplicación

```bash
foreman start -f Procfile.dev
```

## Linteo y formateo
### Verificar problemas

```bash
bundle exec rubocop
```

### Autoformatear código

```bash
bundle exec rubocop -a
```

## Base de datos
### Crear, migrar y cargar seeds

```bash
bin/rails db:create db:migrate db:seed
```

### Reiniciar desde cero

```bash
bin/rails db:reset
```
