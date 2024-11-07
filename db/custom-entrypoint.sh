#!/bin/bash
echo "Executando custom-entrypoint.sh..."

echo "Iniciando o PostgreSQL em segundo plano..."
docker-entrypoint.sh postgres &

# Espera o banco de dados iniciar
until pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"; do
  echo "Esperando o banco de dados iniciar..."
  sleep 5
done

# Executa o script de inicialização para criar usuários
if [ ! -f /var/lib/postgresql/data/users_initialized ]; then
  echo "Criando tabela de usuários e inserindo dados..."

  # Cria a tabela `users` caso não exista
  PGPASSWORD="$POSTGRES_PASSWORD" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c \
      "CREATE TABLE IF NOT EXISTS users (
          id SERIAL PRIMARY KEY,
          username VARCHAR(255) UNIQUE NOT NULL,
          password VARCHAR(255) NOT NULL,
          auth_code INT
      );"
  echo "Tabela 'users' criada (se não existia)."

  # Insere cada usuário do arquivo YAML no banco de dados
  for user in $(yq e '.users[].username' /docker-entrypoint-initdb.d/users.yaml); do
      password=$(yq e ".users[] | select(.username == \"$user\") | .password" /docker-entrypoint-initdb.d/users.yaml)
      echo "Inserindo usuário $user..."
      PGPASSWORD="$POSTGRES_PASSWORD" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c \
          "INSERT INTO users (username, password) VALUES ('$user', '$password') ON CONFLICT (username) DO NOTHING;"
  done

  touch /var/lib/postgresql/data/users_initialized
  echo "Inicialização dos usuários concluída."
fi

# Mantém o processo do PostgreSQL ativo em primeiro plano
wait -n
