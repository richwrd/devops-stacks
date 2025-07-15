#!/bin/bash

# Funções para verificações de saúde do MinIO
# Responsável por: health checks, connectivity tests

# Verificar saúde do MinIO
check_health() {
    check_docker_compose
    if is_running; then
        log "Verificando saúde do MinIO..."
        if curl -f http://localhost:9002/minio/health/live &>/dev/null; then
            log "✓ MinIO está saudável"
        else
            error "✗ MinIO não está respondendo"
            exit 1
        fi
    else
        error "MinIO não está rodando"
        exit 1
    fi
}

check_domain_health() {
  is_running
  
  # Verifica se os domínios estão acessíveis
  if [ -z "$MINIO_WEB_DOMAIN" ] || [ -z "$MINIO_API_DOMAIN" ]; then
      error "Domínios não configurados. Verifique o arquivo .env"
      exit 1
  fi
  
  log "Verificando saúde dos domínios MinIO..."
  
  # Verificar domínio web
  if curl -f http://$MINIO_WEB_DOMAIN &>/dev/null; then
    log "✓ O domínio web $MINIO_WEB_DOMAIN está acessível"
  else
    error "✗ O domínio web $MINIO_API_DOMAIN não está acessível"
    exit 1
  fi
  
  # Verificar domínio API
  if curl -f http://$MINIO_API_DOMAIN &>/dev/null; then
    log "✓ O domínio API $MINIO_API_DOMAIN está acessível"
  else
    error "✗ O domínio API $MINIO_API_DOMAIN não está acessível"
    exit 1
  fi
}


# Aguardar MinIO ficar pronto
wait_for_minio() {
    local max_attempts=${1:-30}
    local attempt=1
    
    log "Aguardando MinIO ficar pronto..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s http://localhost:9002/minio/health/live > /dev/null 2>&1; then
            log "MinIO está pronto!"
            return 0
        fi
        
        if [ $attempt -eq $max_attempts ]; then
            error "Timeout aguardando MinIO ficar pronto"
            return 1
        fi
        
        info "Tentativa $attempt/$max_attempts - Aguardando MinIO..."
        sleep 3
        attempt=$((attempt + 1))
    done
}
