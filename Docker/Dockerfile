FROM ruby:latest

# Instalar dependencias del sistema
RUN apt-get update -qq && apt-get install -y \
    nodejs \
    build-essential \
    sqlite3 \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# Instalar Node 22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs

# Instalar Yarn
RUN npm install -g yarn


# Crear directorio de trabajo
WORKDIR /app

# Copiar Gemfile y Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Instalar gems
RUN bundle install

# Copiar package.json y yarn.lock
COPY package.json yarn.lock ./

# Instalar dependencias
RUN yarn install

# Copiar el resto de la aplicación
COPY . .

# Exponer puerto
EXPOSE 3000 5173

# Comando por defecto
CMD ["foreman", "start", "-f", "Procfile.dev"]