#!/bin/bash

# Script de entrypoint para MinIO
# Este script configura e inicializa o servidor MinIO

set -e

# Importa funções de log centralizadas
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils/log.sh"

# Variáveis globais
DATA_DIR="/data"
MINIO_PID=""

# Função para preparar diretório de dados
prepare_data_directory() {
    if [ ! -d "$DATA_DIR" ]; then
        log "Criando diretório de dados: $DATA_DIR"
        mkdir -p "$DATA_DIR"
    fi

    if [ ! -w "$DATA_DIR" ]; then
        error "Diretório de dados não tem permissão de escrita: $DATA_DIR"
        exit 1
    fi
}

# Função para verificar se MinIO está disponível
check_minio_binary() {
    if ! command -v minio &> /dev/null; then
        error "MinIO não está instalado ou não está no PATH"
        exit 1
    fi
}

# Função para exibir configurações
show_configuration() {
    info "Configurações do MinIO:"
    info "  Root User: $MINIO_ROOT_USER"
    info "  Root Password: [PROTEGIDO]"
    info "  Região: $MINIO_REGION"
    info "  Server URL: $MINIO_SERVER_URL"
    info "  Browser Redirect URL: $MINIO_BROWSER_REDIRECT_URL"
    info "  Diretório de dados: $DATA_DIR"
}

# Função para configurar tratamento de sinais
setup_signal_handlers() {
    cleanup() {
        log "Recebido sinal de parada. Finalizando MinIO..."
        if [ ! -z "$MINIO_PID" ]; then
            kill -TERM "$MINIO_PID" 2>/dev/null || true
            wait "$MINIO_PID" 2>/dev/null || true
        fi
        log "MinIO finalizado"
        exit 0
    }

    trap cleanup SIGTERM SIGINT SIGQUIT
}

# Função para iniciar o servidor MinIO
start_minio_server() {
    log "Iniciando servidor MinIO..."
    
    minio server \
        --console-address ":9001" \
        --address ":9002" \
        "$DATA_DIR" &
    
    MINIO_PID=$!
    log "MinIO iniciado com PID: $MINIO_PID"
    info "Console Web disponível em: $MINIO_BROWSER_REDIRECT_URL"
    info "API S3 disponível em: $MINIO_SERVER_URL"
}

# Função para aguardar o processo e gerenciar saída
wait_for_minio() {
    wait "$MINIO_PID"
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        log "MinIO finalizado normalmente"
    else
        error "MinIO finalizado com código de erro: $exit_code"
    fi

    exit $exit_code
}

# Execução principal
main() {
    log "Iniciando MinIO Object Store..."
    
    prepare_data_directory
    check_minio_binary
    show_configuration
    setup_signal_handlers
    start_minio_server
    wait_for_minio
}

# Executar função principal
main "$@"
