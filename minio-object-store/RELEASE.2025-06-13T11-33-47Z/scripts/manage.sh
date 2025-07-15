#!/bin/bash

# Script de gestão do MinIO - Versão Modular
# Facilita operações comuns com o container MinIO

set -e

# Importa todos os módulos do projeto
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/import.sh"

# Carrega configurações e variáveis
load_env_vars

# Valida variáveis obrigatórias
validate_environment

# Função para mostrar uso
show_usage() {
    echo "Uso: $0 [COMANDO]"
    echo ""
    
    echo "📦 Comandos de Container:"
    echo "  start         - Iniciar o serviço MinIO"
    echo "  start-setup   - Iniciar o serviço e executar setup inicial"
    echo "  stop          - Parar o serviço MinIO"
    echo "  restart       - Reiniciar o serviço MinIO"
    echo "  status        - Mostrar status do serviço"
    echo "  logs          - Mostrar logs do serviço"
    echo "  shell         - Abrir shell no container"
    echo "  build         - Rebuild do container"
    echo "  build-start   - Build e iniciar em sequência"
    echo "  clean         - Parar e remover containers e volumes"
    echo ""
    
    echo "🔧 Comandos de Configuração:"
    echo "  setup         - Executar configuração inicial do MinIO"
    echo "  show-config   - Mostrar configurações do sistema/ambiente"
    echo "  minio-config  - Mostrar configurações internas do MinIO"
    echo "  api-config    - Mostrar configurações de API do MinIO"
    echo "  browser-config- Mostrar configurações de Browser do MinIO"
    echo "  validate-env  - Validar variáveis obrigatórias"
    echo ""
    
    echo "🩺 Comandos de Saúde:"
    echo "  health        - Verificar saúde do serviço"
    echo ""
    
    echo "ℹ️  Comandos de Informação:"
    echo "  info          - Mostrar informações do serviço"
    echo "  help          - Mostrar esta ajuda"
    echo ""
}

# Roteamento de comandos
case "${1:-help}" in
  start)
    start_service
    ;;
  
  start-setup)
    start_service
    run_minio_setup
    ;;
  
  stop)
    stop_service
    ;;
  
  restart)
    restart_service
    ;;
  
  status)
    show_status
    ;;
  
  logs)
    show_logs
    ;;
  
  shell)
    open_shell
    ;;
  
  build)
    build_service
    ;;
  
  build-start)
    build_and_start
    ;;
  
  clean)
    clean_service
    ;;
  
  health)
    check_health
    check_domain_health
    ;;
  
  setup)
    run_minio_setup
    ;;
  
  show-config)
    show_config
    ;;
  
  minio-config)
    show_minio_config
    ;;
  
  api-config)
    show_api_config
    ;;
  
  browser-config)
    show_browser_config
    ;;
  
  validate-env)
    validate_environment
    ;;

  info)
    show_info
    ;;
  
  help|--help|-h)
    show_usage
    ;;
  
  *)
    error "Comando desconhecido: $1"
    show_usage
    exit 1
    ;;
esac
