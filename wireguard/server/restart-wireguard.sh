#!/bin/bash

# Carrega variáveis do arquivo .env
if [ -f ".env" ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "❌ Arquivo .env não encontrado!"
  exit 1
fi

# Define o nome da interface WireGuard (usa variável do .env ou padrão)
WG_INTERFACE="${WG_INTERFACE:-wg0}"

log_message() {
  echo "🕐 [$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log_info() {
  echo "ℹ️  [$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log_success() {
  echo "✅ [$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log_error() {
  echo "❌ [$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

echo "🔄 ═══════════════════════════════════════════════════════════════════"
log_info "Reiniciando túnel WireGuard: $WG_INTERFACE"
echo "🔄 ═══════════════════════════════════════════════════════════════════"

# Para o serviço WireGuard
log_message "Parando o serviço wg-quick@$WG_INTERFACE..."
sudo systemctl stop wg-quick@$WG_INTERFACE

# Aguarda um momento
log_message "Aguardando 2 segundos..."
sleep 2

# Inicia o serviço WireGuard
log_message "Iniciando o serviço wg-quick@$WG_INTERFACE..."
sudo systemctl start wg-quick@$WG_INTERFACE

echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "📊 Status do serviço:"
echo ""

# Verifica o status
if sudo systemctl is-active --quiet wg-quick@$WG_INTERFACE; then
  log_success "WireGuard reiniciado com sucesso!"
  echo ""
  sudo systemctl status wg-quick@$WG_INTERFACE --no-pager -l
else
  log_error "Erro ao reiniciar o WireGuard!"
  echo ""
  sudo systemctl status wg-quick@$WG_INTERFACE --no-pager -l
  exit 1
fi

echo ""
echo "🎉 Operação concluída!"