FROM php:8.2-cli

# PostgreSQL PDO + cliente psql
RUN apt-get update && apt-get install -y libpq-dev postgresql-client \
    && docker-php-ext-install pdo pdo_pgsql pgsql \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiamos los 3 archivos
COPY index.php /app/index.php
COPY init.sql /app/init.sql

# Entrypoint: inicializa BD y arranca PHP
RUN printf '%s\n' \
'#!/bin/sh' \
'set -e' \
'' \
'if [ -n "$DATABASE_URL" ] && [ -f /app/init.sql ]; then' \
'  echo "Inicializando base de datos..."' \
'  psql "$DATABASE_URL" -f /app/init.sql || true' \
'fi' \
'' \
'echo "Arrancando PHP en puerto ${PORT:-8080}..."' \
'exec php -S 0.0.0.0:${PORT:-8080} /app/index.php' \
> /usr/local/bin/entrypoint.sh \
&& chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

