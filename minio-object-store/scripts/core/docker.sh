#!/bin/bash

# Funções para operações Docker/Compose do MinIO
# Responsável por: start, stop, restart, build, clean, status, logs, shell

# Verificar se docker-compose está disponível
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null; then
        if ! command -v docker &> /dev/null || ! docker compose version &> /dev/null; then
            error "docker-compose ou 'docker compose' não encontrado"
            exit 1
        fi
        DOCKER_COMPOSE="docker compose"
    else
        DOCKER_COMPOSE="docker-compose"
    fi
}

# Função para verificar se o serviço está rodando
is_running() {
    check_docker_compose
    local container_id=$($DOCKER_COMPOSE ps -q "$SERVICE_NAME" 2>/dev/null)
    if [ -n "$container_id" ]; then
        return 0
    else
        warning "MinIO não está rodando. Execute './scripts/manage.sh start' primeiro"
        return 1
    fi
}

# Iniciar o serviço MinIO
start_service() {
    check_docker_compose
    log "Iniciando MinIO..."
    $DOCKER_COMPOSE up -d $SERVICE_NAME
    sleep 5
    if is_running; then
        log "MinIO iniciado com sucesso!"
        info "Console Web: https://$MINIOP_WEB_DOMAIN"
        info "API S3: https://$MINIO_API_DOMAIN"
    else
        error "Falha ao iniciar MinIO"
        exit 1
    fi
}

# Parar o serviço MinIO
stop_service() {
    check_docker_compose
    log "Parando MinIO..."
    $DOCKER_COMPOSE stop $SERVICE_NAME
    log "MinIO parado"
}

# Reiniciar o serviço MinIO
restart_service() {
    check_docker_compose
    log "Reiniciando MinIO..."
    $DOCKER_COMPOSE restart $SERVICE_NAME
    sleep 5
    if is_running; then
        log "MinIO reiniciado com sucesso!"
    else
        error "Falha ao reiniciar MinIO"
        exit 1
    fi
}

# Mostrar status do serviço
show_status() {
    check_docker_compose
    echo "Status do MinIO:"
    $DOCKER_COMPOSE ps $SERVICE_NAME
}

# Mostrar logs do serviço
show_logs() {
    check_docker_compose
    log "Mostrando logs do MinIO..."
    $DOCKER_COMPOSE logs -f $SERVICE_NAME
}

# Abrir shell no container
open_shell() {
    check_docker_compose
    if is_running; then
        log "Abrindo shell no container MinIO..."
        $DOCKER_COMPOSE exec $SERVICE_NAME /bin/bash
    else
        error "MinIO não está rodando"
        exit 1
    fi
}

# Rebuild do container
build_service() {
    check_docker_compose
    log "Rebuilding MinIO..."
    $DOCKER_COMPOSE build --no-cache $SERVICE_NAME
    log "Build concluído"
}

# Build e start
build_and_start() {
    check_docker_compose
    log "Rebuilding e iniciando MinIO..."
    $DOCKER_COMPOSE build --no-cache $SERVICE_NAME
    $DOCKER_COMPOSE up -d $SERVICE_NAME
    sleep 5
    if is_running; then
        log "MinIO buildado e iniciado com sucesso!"
        info "Console Web: $MINIO_BROWSER_REDIRECT_URL"
        info "API S3: $MINIO_SERVER_URL"
    else
        error "Falha ao buildar e iniciar MinIO"
        exit 1
    fi
}

# Limpeza completa
clean_service() {
    check_docker_compose
    warning "Isso irá parar e remover o container e volumes do MinIO"
    read -p "Tem certeza? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "Limpando MinIO..."
        $DOCKER_COMPOSE down -v
        log "Limpeza concluída"
    else
        log "Operação cancelada"
    fi
}
