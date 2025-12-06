# Integrantes
- Lautaro Tomas Budini
- Neftalí Taiel Toledo Dicroce
- Nicolás Tenaglia

# Decisiones de diseño
- Se tomó la decisión de eliminar la funcionalidad provista por Devise de recuperar la contraseña por mail, debido a que la configuración de un servidor smtp funcional es compleja y requiere de un gasto de dinero
- Se decidió que todo modelo eliminable también puede ser recuperado
- Se tomó la decisión de que los productos que no tienen stock se vean con un filtro de escala de grises en el frontstore
- También se decidió que el stock sea visible desde el frontstore, para facilitar en la muestra del trabajo la actualización del mismo
- Otra decisión que se tomó es la de hacer un dashboard de productos, que contiene las ventas totales generadas por el usuario con la sesión iniciada, tiene botones para crear ventas, ver el inventario, ver los reportes de ventas. También contiene gráficos para ver la cantidad de ventas en los útlimos 7 días y las ventas por género. Además, tiene un listado dcon las últimas ventas y un listado con los productos que tienen "stock crítico". Como "stock crítico" consideramos a  cualquier producto con stock <= 5
- Además, se tomó la decisión de limitar la cantidad de imágenes totales que un producto puede tener a 10; que los formatos permitidos sean JPG, PNG, GIF, WEBP; y que el tamaño máximo sea de 10Mb
- En los audios, para los productos usados, decidimos que el límite de tamaño sea de 15Mb y que los formatos permitidos sean MP3, WAV, OGG, M4A y FLAC

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