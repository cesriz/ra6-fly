FROM php:8.2-cli

# Instalar dependencias para PostgreSQL (PDO + cliente psql)
RUN apt-get update && apt-get install -y \
    libpq-dev \
    postgresql-client \
  && docker-php-ext-install pdo pdo_pgsql pgsql \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar archivos (todos al mismo nivel en tu repo)
COPY index.php /app/index.php
COPY init.sql /app/init.sql

# Crear entrypoint que inicializa la BD y luego arranca el servidor PHP
RUN printf '%s\n' \
'#!/bin/sh' \
'set -e' \
'' \
'echo "== Iniciando contenedor ==" ' \
'' \
'if [ -z "$DATABASE_URL" ]; then' \
'  echo "ERROR: DATABASE_URL no está definida."' \
'  exit 1' \
'fi' \
'' \
'echo "DATABASE_URL (sin ocultar): $DATABASE_URL"' \
'echo "Contenido de /app:"' \
'ls -l /app' \
'' \
'if [ -f /app/init.sql ]; then' \
'  echo "Inicializando base de datos con /app/init.sql ..."' \
'  psql "$DATABASE_URL" -f /app/init.sql' \
'  echo "Init.sql ejecutado correctamente."' \
'else' \
'  echo "ERROR: No se encontró /app/init.sql"' \
'  exit 1' \
'fi' \
'' \
'echo "Arrancando PHP en puerto ${PORT:-8080}..."' \
'exec php -S 0.0.0.0:${PORT:-8080} /app/index.php' \
> /usr/local/bin/entrypoint.sh \
&& chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]


