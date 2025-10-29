FROM ruby:latest

# Instalar dependencias del sistema
RUN apt-get update -qq && apt-get install -y \
    nodejs \
    build-essential \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio de trabajo
WORKDIR /app

# Copiar Gemfile y Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Instalar gems
RUN bundle install

# Copiar el resto de la aplicación
COPY . .

# Exponer puerto
EXPOSE 3000

# Comando por defecto
CMD ["rails", "server", "-b", "0.0.0.0"]