#!/bin/bash

# Funções para informações do sistema
# Responsável por: info, show-config, test-env

# Mostrar informações do serviço
show_info() {
    check_docker_compose
    echo "Informações do MinIO:"
    echo "  Service: $SERVICE_NAME"
    echo "  Compose File: $COMPOSE_FILE"
    echo "  Console Web: http://$MINIO_BROWSER_REDIRECT_URL:9001"
    echo "  API S3: http://$MINIO_SERVER_URL:9002"
    echo "  Data Directory: ./data"
    if is_running; then
        echo "  Status: ✓ Rodando"
    else
        echo "  Status: ✗ Parado"
    fi
}

# Mostrar configurações do sistema/ambiente
show_config() {
    check_docker_compose
    
    echo "=== Configurações do Sistema ==="
    echo "Service Name: $SERVICE_NAME"
    echo "Compose File: $COMPOSE_FILE"
    echo "Console Web: http://$MINIOP_WEB_DOMAIN:9001"
    echo "API S3: http://$MINIO_API_DOMAIN:9002"
    echo "Data Directory: ./data"
    
    echo ""
    echo "=== Variáveis de Ambiente ==="
    echo "MINIO_ROOT_USER: ${MINIO_ROOT_USER:-[não definido]}"
    echo "MINIO_ROOT_PASSWORD: ${MINIO_ROOT_PASSWORD:+[definido - ${#MINIO_ROOT_PASSWORD} caracteres]}"
    echo "CUSTOM_USER: ${CUSTOM_USER:-[não definido]}"
    echo "CUSTOM_PASSWORD: ${CUSTOM_PASSWORD:+[definido - ${#CUSTOM_PASSWORD} caracteres]}"
    echo "MINIO_SERVER_URL: ${MINIO_SERVER_URL:-[não definido]}"
    echo "MINIO_BROWSER_REDIRECT_URL: ${MINIO_BROWSER_REDIRECT_URL:-[não definido]}"
    echo "MINIOP_WEB_DOMAIN: ${MINIOP_WEB_DOMAIN:-[não definido]}"
    echo "MINIO_API_DOMAIN: ${MINIO_API_DOMAIN:-[não definido]}"
    echo "MINIO_WEB_PORT: ${MINIO_WEB_PORT:-[não definido]}"
    echo "MINIO_API_PORT: ${MINIO_API_PORT:-[não definido]}"
    echo ""


    if is_running; then
        echo ""
        echo "Status: ✓ Rodando"
        info "Para configurações internas do MinIO, use: './scripts/manage.sh minio-config'"
    else
        echo ""
        echo "Status: ✗ Parado"
        info "Inicie o serviço para acessar configurações internas"
    fi
}
