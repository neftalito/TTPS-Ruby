# Integrantes
- Lautaro Tomas Budini
- Neftalí Taiel Toledo Dicroce
- Nicolás Tenaglia

# Decisiones de diseño
- Se tomó la decisión de eliminar la funcionalidad provista por Devise de recuperar la contraseña por mail, debido a que la configuración de un servidor smtp funcional es compleja y requiere de un gasto de dinero
- Se decidió que todo modelo eliminable también puede ser recuperado
- Se tomó la decisión de que los productos que no tienen stock se vean con un filtro de escala de grises en el frontstore
- También se decidió que el stock sea visible desde el frontstore, para facilitar en la muestra del trabajo la actualización del mismo
- Dashboard: Se decidió a mostrar información útil en el Dashboard del backstore mostrando:
  - Las cantidad de ventas y las ganancias generadas del empleado con la sesion iniciada,
  - Botones de acceso directo a: creación de venta, inventario de discos, y reportes de ventas,
  - Tablas relacionadas con las ventas totales del negocio (ultimos 7 dias y por genero),
  - Tabla de stock crítico, que muestra cuáles son los discos (no usados) que tengan un stock menor o igual a 5; y que al tocar en el título del disco te redirija a la vista del mismo,
  - Tabla que muestra las últimas ventas (no canceladas) que se hicieron; y que al tocar el id de venta te redirija a la vista de la venta
- Reportes de ventas: se decidió crear un apartado de reportes de ventas que muestra la información útil de las ventas filtradas por rango de fechas (hoy, esta semana, este mes, este año, historico, y un personalizado que te permite elegir entre 2 fechas), mostrando:
  - Ingresos totales de las ventas
  - Cantidad de ventas confirmadas
  - Precio promedio por venta
  - Cantidad de discos vendidos
  - Ademas de un listado de los discos más vendidos de la pagina que puede ser paginado en 5, 10, 25, 50, 100 o todos
  - Ademas de poder exportar esa información filtrada en formato CSV y/o PDF
- Además, se tomó la decisión de limitar la cantidad de imágenes totales que un producto puede tener a 10; que los formatos permitidos sean JPG, PNG, GIF, WEBP; y que el tamaño máximo sea de 10Mb
- En los audios, para los productos usados, decidimos que el límite de tamaño sea de 15Mb y que los formatos permitidos sean MP3, WAV, OGG, M4A y FLAC
- También se tomó la decisión de que la imágen de portada de un producto va a ser la primer imágen que fue subida. En caso de ser eliminada, la siguiente imágen pasará a ser la portada
- También se decidió que el precio del producto, al agregarlo en una venta, se obtiene automáticamente por el precio actual del producto, debido a que no se especifica si hay descuentos o cupones
- Otra decisión de diseño tomada es que el nombre con el que se va a identificar al usuario (es decir, la forma en la que se mostrará qué usuario está con su sesión iniciada) será tomado automáticamente del correo electrónico utilizado durante el inicio de sesión. Específicamente, se extrae la parte antes del @ en un correo. Por ejemplo, si tuvieramos el correo "ttps@ruby.com", el nombre "ttps" va a ser utilizado para ser mostrado en el navbar y en el dashboard del usuario. Para no mostrar el email completo.

# Usuarios creados por defecto en el seed
## Administrador
- Usuario: `admin@sistema.com`
- Contraseña: `admin123`
## Gerente
- Usuario: `manager@sistema.com`
- Contraseña: `manager123`
## Empleado
- Usuario: `empleado@sistema.com`
- Contraseña: `empleado123`

# Requisitos previos
- **Ruby 3.4.7**
- **Sqlite3**
- **Node.js** y **npm**

# Cómo realizar la instalación
1. Clonar el repositorio
```bash
git clone https://github.com/neftalito/TTPS-Ruby
cd TTPS-Ruby/src
```
2. Instalar dependencias del Gemfile
```bash
bundle install
```
3. Instalar dependencias del package.json
```bash
npm install
```
4. Inicializar la base de datos
```bash
rails db:create db:migrate db:seed
```
Si necesitás reiniciar todo desde cero, podés usar `bin/rails db:reset` (NOTA: esto también corre los seeds)

5. Ejecutar la aplicación con Foreman
Desde la carpeta `/src` ejecutar:
```bash
foreman start -f Procfile.dev
```
6. Acceder a la aplicación
- Frontstore: `http://localhost:3000`
- Backstore: `http://localhost:3000/admin`

# Notas para desarrolladores
## Instalación de dependencias del Gemfile
```bash
bundle install
```

## Instalacion de dependencias del package.json
```bash
npm install
```

## Agregar una gema
- Editar el `Gemfile` y luego ejecutar
```bash
bundle install
```

## Agregar un packete de JavaScript
```bash
npm install nombre-del-paquete
````

## Ejecutar la aplicación con Foreman
- Desde /src
```bash
foreman start -f Procfile.dev
```

## Linteo y formateo
### Verificar problemas
```bash
bundle exec rubocop
```

### Autoformatear todo el código
**ADVERTENCIA**: Usar `-a` y no `-A`, dado que `-A` puede provocar correcciones que son inseguras y pueden romper código 
```bash
bundle exec rubocop -a
```

## Inicializar base de datos
- Crear, migrar y cargar seeds
```bash
bin/rails db:create db:migrate db:seed
```
- Reiniciar desde cero (también corre las seeds)
```bash
bin/rails db:reset
```
