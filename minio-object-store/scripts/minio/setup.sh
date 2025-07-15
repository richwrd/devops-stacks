#!/bin/bash

run_minio_setup() {
    is_running

    if ! wait_for_minio; then
        error "Timeout aguardando MinIO ficar pronto"
        exit 1
    fi

    log "Executando configuração inicial do MinIO..."

    $DOCKER_COMPOSE exec -T $SERVICE_NAME /bin/sh -c "
        $(print_setup_banner)
        $(print_config_check)
        $(check_minio_ready)
        $(verify_mc_client)
        $(configure_alias)
        $(configure_security_policies)
        $(create_custom_user)
        $(attach_admin_policy)
        $(create_buckets)
        $(configure_cors)
        $(set_api_limits)
        $(set_session_timeout)
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
echo '📋 [ETAPA 1/12] Verificando configurações...'
echo "  MINIO_ROOT_USER: ${MINIO_ROOT_USER}"
echo "  CUSTOM_USER: ${CUSTOM_USER}"
echo '✓ Configurações verificadas'
EOF
}

check_minio_ready() {
cat <<EOF
echo '⏳ [ETAPA 2/12] Aguardando MinIO ficar pronto...'
until curl -s http://localhost:${MINIO_API_PORT}/minio/health/live > /dev/null; do
    sleep 1
done
echo '✓ MinIO está pronto'
EOF
}

verify_mc_client() {
cat <<'EOF'
echo '🔍 [ETAPA 3/12] Verificando cliente mc...'
if ! command -v mc >/dev/null 2>&1; then
    echo '❌ Cliente mc não encontrado no container'
    exit 1
fi
echo '✓ Cliente mc disponível'
EOF
}

configure_alias() {
cat <<EOF
echo '🔗 [ETAPA 5/12] Configurando alias do MinIO...'
mc alias set local http://localhost:${MINIO_API_PORT} ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD}
echo '✓ Alias configurado'
EOF
}

configure_security_policies() {
cat <<'EOF'
echo '🛡️ [ETAPA 6/12] Configurando políticas de segurança...'
mc admin config set local/ browser csp_policy="default-src 'self' 'unsafe-inline' data:; font-src 'self' 'unsafe-inline' data: https://use.typekit.net https://fonts.googleapis.com https://fonts.gstatic.com; connect-src 'self' https://dl.min.io https://unpkg.com wss:; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; script-src 'self' 'unsafe-inline' 'unsafe-eval';"
echo '✓ Políticas configuradas'
EOF
}

create_custom_user() {
cat <<EOF
echo '👤 [ETAPA 7/12] Adicionando usuário ${CUSTOM_USER}...'
if mc admin user add local "${CUSTOM_USER}" "${CUSTOM_PASSWORD}"; then
    echo "✓ Usuário ${CUSTOM_USER} criado"
elif mc admin user info local "${CUSTOM_USER}" >/dev/null 2>&1; then
    echo "ℹ Usuário ${CUSTOM_USER} já existe"
else
    echo "❌ Falha ao criar usuário ${CUSTOM_USER}"
    exit 1
fi
EOF
}

attach_admin_policy() {
cat <<EOF
echo '🔑 [ETAPA 8/12] Aplicando política consoleAdmin...'
if mc admin policy attach local consoleAdmin --user "${CUSTOM_USER}"; then
    echo "✓ Política aplicada para ${CUSTOM_USER}"
else
    echo "❌ Falha ao aplicar política"
    exit 1
fi
EOF
}

create_buckets() {
cat <<'EOF'
echo '📦 [ETAPA 9/12] Criando buckets...'
mc mb local/public 2>/dev/null && echo '✓ Bucket público criado' || echo 'ℹ Bucket já existe'
EOF
}

configure_cors() {
cat <<'EOF'
echo '🌐 [ETAPA 10/12] Configurando CORS...'
mc admin config set local/ api cors_allow_origin="*"
echo '✓ CORS habilitado'
EOF
}

set_api_limits() {
cat <<'EOF'
echo '⚡ [ETAPA 11/12] Configurando limite de API...'
mc admin config set local/ api requests_max=2000
echo '✓ Limite de requisições configurado'
EOF
}

restart_minio_service() {
cat <<'EOF'
echo '🔄 [ETAPA 12/12] Reiniciando serviço...'
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
echo "  • Custom User: ${CUSTOM_USER}"
echo "  • Bucket: local/public"
echo "  • CORS: *"
echo "  • CSP: OK"
echo "  • Sessão: 24h"
echo "  • Max Requests: 2000"
EOF
}
