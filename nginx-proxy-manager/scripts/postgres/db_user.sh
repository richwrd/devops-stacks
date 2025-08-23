#!/bin/bash
#by: richwrd

# Variáveis de configuração do PostgreSQL
PG_ROOT_USER="${PG_ROOT_USER:-postgres}"
PG_ROOT_PASS="${PG_ROOT_PASS:-}"

# Função para verificar a existência do arquivo .env
check_env_file() {
  local env_file="../../.env"
  if [[ ! -f "$env_file" ]]; then
    echo "Erro: Arquivo .env não encontrado em $env_file"
    exit 1
  fi
  echo "Arquivo .env encontrado: $env_file"
}

# Função para carregar variáveis do .env
load_env_vars() {
  local env_file="../../.env"
  # Carrega as variáveis do .env, ignorando comentários e linhas vazias
  export $(grep -v '^#' "$env_file" | grep -v '^$' | xargs)
}

# Função para criar usuário e banco de dados completo
create_user_and_database() {
  local db_user="$1"
  local db_pass="$2"
  local db_name="$3"
  
  echo "Criando usuário $db_user..."
  psql -U "$PG_ROOT_USER" -h "$DB_POSTGRES_HOST" -p "$DB_POSTGRES_PORT" -c "CREATE USER $db_user WITH PASSWORD '$db_pass';"
  
  echo "Criando banco de dados $db_name..."
  psql -U "$PG_ROOT_USER" -h "$DB_POSTGRES_HOST" -p "$DB_POSTGRES_PORT" -c "CREATE DATABASE $db_name OWNER $db_user;"
  
  echo "Concedendo privilégios..."
  psql -U "$PG_ROOT_USER" -h "$DB_POSTGRES_HOST" -p "$DB_POSTGRES_PORT" -c "GRANT ALL PRIVILEGES ON DATABASE $db_name TO $db_user;"
  
  echo "Alterando proprietário do schema public..."
  psql -U "$PG_ROOT_USER" -h "$DB_POSTGRES_HOST" -p "$DB_POSTGRES_PORT" -d "$db_name" -c "ALTER SCHEMA public OWNER TO $db_user;"
  
  echo "Configurando privilégios padrão..."
  psql -U "$PG_ROOT_USER" -h "$DB_POSTGRES_HOST" -p "$DB_POSTGRES_PORT" -d "$db_name" -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $db_user;"
  psql -U "$PG_ROOT_USER" -h "$DB_POSTGRES_HOST" -p "$DB_POSTGRES_PORT" -d "$db_name" -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO $db_user;"
  
  echo "Configuração completa para usuário $db_user e banco $db_name."
}

# Verifica e carrega o arquivo .env
check_env_file
load_env_vars

# Define variáveis padrão se não estiverem no .env
PG_ROOT_USER="${PG_ROOT_USER:-postgres}"
DB_POSTGRES_HOST="${DB_POSTGRES_HOST:-localhost}"
DB_POSTGRES_PORT="${DB_POSTGRES_PORT:-5432}"

export PGPASSWORD="$PG_ROOT_PASS"

# Usa as variáveis do .env se disponíveis, senão solicita input
if [[ -n "$DB_POSTGRES_USER" && -n "$DB_POSTGRES_PASSWORD" && -n "$DB_POSTGRES_NAME" ]]; then
  DB_USER="$DB_POSTGRES_USER"
  DB_PASS="$DB_POSTGRES_PASSWORD"
  DB_NAME="$DB_POSTGRES_NAME"
  echo "Usando variáveis do .env: usuário=$DB_USER, banco=$DB_NAME"
else
  read -p "Novo usuário do banco: " DB_USER
  read -s -p "Senha do novo usuário: " DB_PASS
  echo
  DB_NAME="$DB_USER"
fi

create_user "$DB_USER" "$DB_PASS"
create_database "$DB_NAME" "$DB_USER"
grant_privileges "$DB_NAME" "$DB_USER"
alter_schema_owner "$DB_NAME" "$DB_USER"
alter_default_privileges "$DB_NAME" "$DB_USER"
