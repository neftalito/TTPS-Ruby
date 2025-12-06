# Integrantes
- Lautaro Tomas Budini
- Neftalí Taiel Toledo Dicroce
- Nicolás Tenaglia

# Decisiones de diseño
- Se tomó la decisión de eliminar la funcionalidad provista por Devise de recuperar la contraseña por mail, debido a que la configuración de un servidor smtp funcional es compleja y requiere de un gasto de dinero
- Se decidió que todo modelo eliminable también puede ser recuperado
- Se tomó la decisión de que los productos que no tienen stock se vean con un filtro de escala de grises en el frontstore
- También se decidió que el stock sea visible desde el frontstore, para facilitar en la muestra del trabajo la actualización del mismo
- Dashboard: Se decidió a mostrar informacion util en el Dashboard del backstore mostrando:
  - Las cantidad de ventas y las ganancias generadas del empleado con le sesion iniciada,
  - Botones de acceso directo a: creacion de venta, inventario de discos, y reportes de ventas,
  - Tablas relacionadas con las ventas totales del negocio (ultimos 7 dias y por genero),
  - Tabla de stock critico, que muestra cuales son los discos (no usados) que tengan un stock <=5 y que al tocar en el titulo del disco te rediriga a la vista del mismo,
  - Tabla que muestra las ultimas ventas (no canceladas) que se hicieron y que al tocar el id de venta te rediriga a la vista de la venta
- Reportes de ventas: se decidio crear un apartado de reportes de ventas que muestra la inforamcion util de las ventas filtradas por espacio de tiempo (hoy, esta semana, este mes, este año, historico, y un personalizado que te permite elegir entre 2 fechas), mostrando:
  - Ingresos totales de las ventas
  - Cantidad de ventas confirmadas
  - Precio promedio por venta
  - Cantidad de discos vendidos
  - Ademas de un listado de los discos mas vendidos de la pagina que puede ser paginado en 5, 10, 25, 50, 100, todos
  - Ademas de poder exportar esa informacion filtrada en formato CSV y PDF
- Además, se tomó la decisión de limitar la cantidad de imágenes totales que un producto puede tener a 10; que los formatos permitidos sean JPG, PNG, GIF, WEBP; y que el tamaño máximo sea de 10Mb
- En los audios, para los productos usados, decidimos que el límite de tamaño sea de 15Mb y que los formatos permitidos sean MP3, WAV, OGG, M4A y FLAC
- También se tomó la decisión de que la imágen de portada de un producto va a ser la primer imágen que fue subida. En caso de ser eliminada, la siguiente imágen pasará a ser la portada
- tambien se decidió que el precio del producto al agregarlo en una venta, se obtiene automáticamente por el precio actual del producto, debido a que no se especifica si hay descuentos o cupones

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
