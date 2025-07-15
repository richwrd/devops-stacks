#!/bin/bash

# Funções para configurações internas do MinIO
# Responsável por: configurações de API, browser e outras configurações internas

# Mostrar configurações internas do MinIO
show_minio_config() {
    is_running
    
    log "Mostrando configurações internas do MinIO..."
    $DOCKER_COMPOSE exec -T $SERVICE_NAME /bin/sh -c "
        echo '============================================='
        echo '⚙️  CONFIGURAÇÕES INTERNAS DO MINIO        '
        echo '============================================='
        echo ''
        
        echo '🔧 Configurações de API:'
        echo '─────────────────────────────────────────────────'
        mc admin config get local/ api 2>/dev/null || echo '⚠ Erro ao obter configurações de API'
        echo ''
        
        echo '🌐 Configurações de Browser:'
        echo '─────────────────────────────────────────────────'
        mc admin config get local/ browser 2>/dev/null || echo '⚠ Erro ao obter configurações de Browser'
        echo ''
        
        echo '📋 Todas as configurações disponíveis:'
        echo '─────────────────────────────────────────────────'
        mc admin config get local/ 2>/dev/null || echo '⚠ Erro ao obter todas as configurações'
        echo ''
        
        echo '============================================='
        echo '✅  CONFIGURAÇÕES EXIBIDAS COM SUCESSO!    '
        echo '============================================='
    "
}

show_api_config() {
    is_running
    
    log "Mostrando configurações de API do MinIO..."
    $DOCKER_COMPOSE exec -T $SERVICE_NAME /bin/sh -c "
        echo '============================================='
        echo '🔧  CONFIGURAÇÕES DE API DO MINIO          '
        echo '============================================='
        echo ''
        
        echo '📋 Configurações de API:'
        echo '─────────────────────────────────────────────────'
        mc admin config get local/ api 2>/dev/null || echo '⚠ Erro ao obter configurações de API'
        echo ''
        
        echo '============================================='
        echo '✅  CONFIGURAÇÕES DE API EXIBIDAS!         '
        echo '============================================='
    "
}

show_browser_config() {
    is_running
    
    log "Mostrando configurações de Browser do MinIO..."
    $DOCKER_COMPOSE exec -T $SERVICE_NAME /bin/sh -c "
        echo '============================================='
        echo '🌐  CONFIGURAÇÕES DE BROWSER DO MINIO      '
        echo '============================================='
        echo ''
        
        echo '📋 Configurações de Browser:'
        echo '─────────────────────────────────────────────────'
        mc admin config get local/ browser 2>/dev/null || echo '⚠ Erro ao obter configurações de Browser'
        echo ''
        
        echo '============================================='
        echo '✅  CONFIGURAÇÕES DE BROWSER EXIBIDAS!     '
        echo '============================================='
    "
}

list_all_config() {
    is_running
    
    log "Listando todas as configurações disponíveis do MinIO..."
    $DOCKER_COMPOSE exec -T $SERVICE_NAME /bin/sh -c "
        echo '============================================='
        echo '📋  TODAS AS CONFIGURAÇÕES DO MINIO        '
        echo '============================================='
        echo ''
        
        echo '📝 Listando todas as configurações:'
        echo '─────────────────────────────────────────────────'
        mc admin config get local/ 2>/dev/null || echo '⚠ Erro ao obter todas as configurações'
        echo ''
        
        echo '============================================='
        echo '✅  LISTAGEM COMPLETA EXIBIDA!             '
        echo '============================================='
    "
}
