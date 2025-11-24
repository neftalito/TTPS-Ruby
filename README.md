# Integrantes
- Lautaro Tomas Budini
- Neftalí Taiel Toledo Dicroce
- Nicolás Tenaglia

# Decisiones de diseño
- Se tomó la decisión de eliminar la funcionalidad provista por Devise de recuperar la contraseña por mail, debido a que la configuración de un servidor smtp funcional es compleja y requiere de un gasto de dinero



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