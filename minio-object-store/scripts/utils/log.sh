#!/bin/bash

# Script de logging centralizado
# Fornece funções de log coloridas e padronizadas para todos os scripts do projeto

# Evita redefinição das funções se o script já foi carregado
if [ "${LOG_FUNCTIONS_LOADED:-}" = "true" ]; then
    return 0 2>/dev/null || exit 0
fi

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Função para logging de sucesso/info geral
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

# Função para logging de erros
error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}" >&2
}

# Função para logging de avisos
warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

# Função para logging de informações
info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

# Função para logging de debug (apenas se DEBUG=true)
debug() {
    if [ "${DEBUG:-}" = "true" ]; then
        echo -e "\033[0;35m[$(date +'%Y-%m-%d %H:%M:%S')] DEBUG: $1\033[0m"
    fi
}

# Função para logging de status/progresso
status() {
    echo -e "\033[1;37m[$(date +'%Y-%m-%d %H:%M:%S')] STATUS: $1\033[0m"
}

# Função para separadores visuais
separator() {
    echo -e "${BLUE}============================================${NC}"
}

# Função para cabeçalhos de seção
section() {
    echo
    separator
    echo -e "${BLUE}  $1${NC}"
    separator
    echo
}

# Marca que as funções foram carregadas
export LOG_FUNCTIONS_LOADED=true
