# Instalación de dependencias del Gemfile
```bash
bundle install
```

# Instalacion de dependencias del package.json
```bash
npm install
```

# Agregar una gema
- Editar el `Gemfile` y luego ejecutar
```bash
bundle install
```

# Agregar un packete de JavaScript
```bash
npm install nombre-del-paquete
````

# Ejecutar la aplicación con Foreman
- Desde /src
```bash
foreman start -f Procfile.dev
```

# Linteo y formateo
## Verificar problemas
```bash
bundle exec rubocop
```

## Autoformatear todo el código
**ADVERTENCIA**: Usar `-a` y no `-A`, dado que `-A` puede provocar correcciones que son inseguras y pueden romper código 
```bash
bundle exec rubocop -a
```

# Inicializar base de datos
- Crear, migrar y cargar seeds
```bash
bin/rails db:create db:migrate db:seed
```
- Reiniciar desde cero
```bash
bin/rails db:drop db:create db:migrate db:seed
```