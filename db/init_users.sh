#!/bin/bash

# Cria a tabela `users` caso não exista
PGPASSWORD="$POSTGRES_PASSWORD" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c \
    "CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(255) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        auth_code INT
    );"

# Insere os usuários definidos no arquivo YAML
echo "Inicializando usuários..."

for user in $(yq e '.users[].username' /docker-entrypoint-initdb.d/users.yaml); do
    password=$(yq e ".users[] | select(.username == \"$user\") | .password" /docker-entrypoint-initdb.d/users.yaml)
    
    PGPASSWORD="$POSTGRES_PASSWORD" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c \
        "INSERT INTO users (username, password) VALUES ('$user', '$password') ON CONFLICT (username) DO NOTHING;"
done

echo "Usuários inicializados com sucesso."
