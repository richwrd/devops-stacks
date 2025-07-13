#!/bin/sh

cat > setup-minio.sh << 'EOF'
#!/bin/sh
set -e

# Aguarda o MinIO ficar pronto
until curl -s http://localhost:9002/minio/health/live > /dev/null; do
  sleep 1
done

# Configura o alias e políticas
mc alias set local http://localhost:9002 ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD}
mc admin config set local/ browser csp_policy="default-src 'self' 'unsafe-inline' 'unsafe-eval'; connect-src 'self' https://dl.min.io https://unpkg.com wss:;"

# Reinicia para aplicar as configurações
mc admin service restart local/

# Mantém o container rodando
tail -f /dev/null
EOF

chmod +x setup-minio.sh