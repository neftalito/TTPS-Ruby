# Integrantes
- Lautaro Tomas Budini
- Neftali Taiel Toledo Dicroce
- Nicolas Tenaglia

# Decisiones de diseno
- Se elimino la recuperacion de contrasena por mail de Devise para no depender de un servidor SMTP.
- Todo modelo eliminable tambien puede ser recuperado.
- Los productos sin stock se muestran en escala de grises en el frontstore.
- El stock es visible desde el frontstore para facilitar la demostracion del trabajo.
- El dashboard del backstore muestra ventas y ganancias del usuario actual, accesos rapidos, graficos de ventas, stock critico y ultimas ventas confirmadas.
- El modulo de reportes vive en una seccion separada de la gestion de ventas y solo considera ventas confirmadas.
- Los reportes se pueden filtrar por fecha, tipo de producto, genero musical y empleado.
- Los reportes muestran metricas numericas y graficas, junto con exportacion en CSV y PDF.
- Los productos admiten hasta 10 imagenes en formatos JPG, PNG, GIF y WEBP, con un máximo de 10 MB por imagen.
- Los audios para productos usados admiten formatos MP3, WAV, OGG, M4A y FLAC, con un máximo de 15 MB.
- La portada de un producto es siempre la primera imagen cargada.
- El precio de cada item de venta se toma automaticamente del precio actual del producto.
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

# Instalacion
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

5. Ejecutar la aplicacion con Foreman

```bash
foreman start -f Procfile.dev
```

6. Acceder a la aplicacion
- Frontstore: `http://localhost:3000`
- Backstore: `http://localhost:3000/admin`

# Modulo de reportes
## Como acceder
- Ingresar al backstore y abrir la seccion `Reportes` del sidebar.
- Tambien se puede entrar directamente en `http://localhost:3000/admin/reports`.

## Metricas y analisis que se muestran
- Total recaudado en el periodo filtrado.
- Cantidad de ventas realizadas.
- Promedio de importe por venta.
- Cantidad de productos vendidos.
- Grafico de ventas por tipo de producto (CD / Vinilo).
- Grafico de ventas por genero musical.
- Top 5 productos mas vendidos.

## Filtros disponibles
- Fecha desde / hasta.
- Tipo de producto.
- Genero musical.
- Empleado que realizo la venta.

## Exportacion
- El reporte actual se puede descargar en formato CSV.
- El mismo reporte tambien se puede exportar como PDF.

## Como generar datos de prueba
- Ejecutar `bin/rails db:seed` desde la carpeta `src`.
- Para recrear la base completa, ejecutar `bin/rails db:reset`.
- El seed genera productos, ventas confirmadas, ventas canceladas y un lote de ventas de demostracion pensado para visualizar correctamente las metricas y graficos.

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

## Ejecutar la aplicacion

```bash
foreman start -f Procfile.dev
```

## Linteo y formateo
### Verificar problemas

```bash
bundle exec rubocop
```

### Autoformatear codigo

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
