# Crear el Gemfile inicial
echo "source 'https://rubygems.org'" > Gemfile
echo "gem 'rails', '~> 7.1'" >> Gemfile
touch Gemfile.lock

# Construir las imágenes
docker-compose build

# Crear la aplicación Rails (SQLite es el default)
docker-compose run --rm web rails new . --force --skip-bundle

# Instalar las dependencias
docker-compose run --rm web bundle install

# Crear la base de datos
docker-compose run --rm web rails db:create

# Levantar el servidor
docker-compose up

# Correr migraciones
docker-compose run --rm web rails db:migrate

# Instalar una nueva gema
# 1. Agrégala a tu Gemfile
# 2. Ejecuta:
docker-compose run --rm web bundle install

# Generar un scaffold
docker-compose run --rm web rails generate scaffold Post title:string body:text

# Consola de Rails
docker-compose run --rm web rails console

# Acceder al bash del contenedor
docker-compose exec web bash