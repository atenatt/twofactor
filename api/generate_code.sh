#!/bin/bash

# Função para gerar um código aleatório de 6 dígitos
generate_code() {
    echo $((RANDOM % 900000 + 100000))
}

# Função para salvar o código no Postgres
store_code_in_db() {
    local code=$1
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c \
        "INSERT INTO auth_codes (code, created_at) VALUES ($code, NOW()) ON CONFLICT (id) DO UPDATE SET code = $code, created_at = NOW();"
}

# Preparação do banco de dados (caso a tabela ainda não exista)
PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c \
    "CREATE TABLE IF NOT EXISTS auth_codes (id SERIAL PRIMARY KEY, code INT, created_at TIMESTAMP);"

# Loop de atualização do código a cada 30 segundos
while true; do
    code=$(generate_code)
    echo "Código de Autenticação Gerado: $code"
    store_code_in_db "$code"

    # Exibe o código no dialog apenas em um terminal interativo
    if [ -t 0 ]; then
        dialog --msgbox "Código de Autenticação:\n\n         $code" 7 28
    fi

    # Esperar 30 segundos antes de gerar um novo código
    sleep 30
clear
done
