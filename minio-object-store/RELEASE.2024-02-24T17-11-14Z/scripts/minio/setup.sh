#!/bin/bash

run_minio_setup() {
    is_running

    log "Executando configuração inicial do MinIO..."

    $DOCKER_COMPOSE exec -T $SERVICE_NAME /bin/sh -c "
        $(print_setup_banner)
        $(print_config_check)
        $(verify_mc_client)
        $(configure_alias)
        $(configure_security_policies)
        $(create_buckets)
        $(configure_cors)
        $(set_api_limits)
        $(restart_minio_service)
        $(print_setup_summary)
    "

    if [ $? -eq 0 ]; then
        log "✓ Configuração do MinIO concluída com sucesso!"
        info "Aguarde alguns segundos para o serviço reiniciar"
        sleep 5
    else
        error "✗ Falha na configuração do MinIO"
        exit 1
    fi
}

# 🧩 Funções de responsabilidade única:

print_setup_banner() {
cat <<'EOF'
echo '============================================='
echo '🚀  INICIANDO CONFIGURAÇÃO COMPLETA MINIO  '
echo '============================================='
EOF
}

print_config_check() {
cat <<EOF
echo '📋 [ETAPA 1/8] Verificando configurações...'
echo "  MINIO_ROOT_USER: ${MINIO_ROOT_USER}"
echo '✓ Configurações verificadas'
EOF
}

verify_mc_client() {
cat <<'EOF'
echo '🔍 [ETAPA 2/8] Verificando cliente mc...'
if ! command -v mc >/dev/null 2>&1; then
    echo '❌ Cliente mc não encontrado no container'
    exit 1
fi
echo '✓ Cliente mc disponível'
EOF
}

configure_alias() {
cat <<EOF
echo '🔗 [ETAPA 3/8] Configurando alias do MinIO...'
mc alias set local http://localhost:${MINIO_API_PORT} ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD}
echo '✓ Alias configurado'
EOF
}

configure_security_policies() {
cat <<'EOF'
echo '🛡️ [ETAPA 4/8] Configurando políticas de segurança...'
mc admin config set local/ browser csp_policy="default-src 'self' 'unsafe-inline' data:; font-src 'self' 'unsafe-inline' data: https://use.typekit.net https://fonts.googleapis.com https://fonts.gstatic.com; connect-src 'self' https://dl.min.io https://unpkg.com wss:; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; script-src 'self' 'unsafe-inline' 'unsafe-eval';"
echo '✓ Políticas configuradas'
EOF
}

create_buckets() {
cat <<'EOF'
echo '📦 [ETAPA 5/8] Criando buckets...'
mc mb local/public 2>/dev/null && echo '✓ Bucket público criado' || echo 'ℹ Bucket já existe'
EOF
}

configure_cors() {
cat <<EOF
echo '🌐 [ETAPA 6/8] Configurando CORS...'
mc admin config set local/ api cors_allow_origin="${MINIO_API_CORS_ALLOW_ORIGIN}"
echo '✓ CORS habilitado'
EOF
}

set_api_limits() {
cat <<EOF
echo '⚡ [ETAPA 7/8] Configurando limite de API...'
mc admin config set local/ api requests_max=${MINIO_API_REQUESTS_MAX}
echo '✓ Limite de requisições configurado'
EOF
}

restart_minio_service() {
cat <<'EOF'
echo '🔄 [ETAPA 8/8] Reiniciando serviço...'
if mc admin service restart local --json >/dev/null 2>&1; then
    echo '✓ Serviço reiniciado'
else
    echo '⚠ Falha ao reiniciar serviço automaticamente'
fi
EOF
}

print_setup_summary() {
cat <<EOF
echo '============================================='
echo '✅  CONFIGURAÇÃO COMPLETA FINALIZADA!'
echo '============================================='
echo "📋 Resumo:"
echo "  • Root User: ${MINIO_ROOT_USER}"
echo "  • Bucket: local/public"
echo "  • CORS: ${MINIO_API_CORS_ALLOW_ORIGIN}"
echo "  • CSP: OK"
echo "  • Max Requests: ${MINIO_API_REQUESTS_MAX}"
EOF
}
