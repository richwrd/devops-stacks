#!/bin/bash

# Configurações e variáveis do projeto
# Responsável por: configurações globais, validações, defaults

# Configurações globais
COMPOSE_FILE="docker-compose.yaml"
SERVICE_NAME="minio-object-store"

# Carregar variáveis do arquivo .env
load_env_vars() {
  if [ -f ".env" ]; then
    set -a  # Exporta automaticamente todas as variáveis
    . ./.env
    set +a  # Desabilita a exportação automática
    log "Variáveis do .env carregadas"
  elif [ -f "../.env" ]; then
    set -a
    . ../.env
    set +a
    log "Variáveis do .env carregadas"
  elif [ -f "../../.env" ]; then
    set -a
    . ../../.env
    set +a
    log "Variáveis do .env carregadas"
  else
    echo "Erro: Arquivo .env não encontrado. Por favor, disponibilize o arquivo .env na raiz do projeto."
    exit 1
  fi
}
