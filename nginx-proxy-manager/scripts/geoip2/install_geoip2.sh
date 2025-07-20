#!/bin/bash

# Script para instalar e configurar GeoIP2
# Lê as configurações do arquivo .env

set -e  # Sair se algum comando falhar

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funções para logging
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar se o script está sendo executado como root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Este script deve ser executado como root (use sudo)"
        exit 1
    fi
}

# Procurar arquivo .env
find_env_file() {
    local env_file=""
    if [ -f ".env" ]; then
        env_file=".env"
    elif [ -f "../.env" ]; then
        env_file="../.env"
    elif [ -f "../../.env" ]; then
        env_file="../../.env"
    else
        log_error "Arquivo .env não encontrado. Certifique-se de que existe um arquivo .env com as variáveis GEOIP_ACCOUNT_ID e GEOIP_LICENSE_KEY"
        exit 1
    fi
    echo "$env_file"
}

# Carregar variáveis do .env
load_env_variables() {
    source "$1"
    if [ -z "$GEOIP_ACCOUNT_ID" ] || [ -z "$GEOIP_LICENSE_KEY" ] || [ -z "$GEOIP_DATA_DIR" ]; then
        log_error "As variáveis GEOIP_ACCOUNT_ID, GEOIP_LICENSE_KEY e GEOIP_DATA_DIR devem estar definidas no arquivo .env"
        log_error "Exemplo:"
        log_error "GEOIP_ACCOUNT_ID=123456"
        log_error "GEOIP_LICENSE_KEY=sua_chave_completa_aqui"
        log_error "GEOIP_DATA_DIR=/caminho/para/dados/geoip"
        exit 1
    fi
    
    # Validar formato das credenciais
    if ! [[ "$GEOIP_ACCOUNT_ID" =~ ^[0-9]+$ ]]; then
        log_error "GEOIP_ACCOUNT_ID deve conter apenas números"
        exit 1
    fi
    
    if [[ ${#GEOIP_LICENSE_KEY} -lt 10 ]]; then
        log_error "GEOIP_LICENSE_KEY parece muito curta (deve ter pelo menos 10 caracteres)"
        exit 1
    fi
    
    log_info "✅ Credenciais carregadas: Account ID = $GEOIP_ACCOUNT_ID"
    log_info "✅ License Key carregada (${#GEOIP_LICENSE_KEY} caracteres)"
    log_info "✅ Diretório de dados: $GEOIP_DATA_DIR"
}

# Instalar pacotes necessários
install_packages() {
    log_info "Atualizando lista de pacotes..."
    apt update
    log_info "Instalando geoipupdate..."
    apt install -y geoipupdate
}

# Configurar diretório e arquivo de configuração
configure_geoip() {
    log_info "Criando diretório $GEOIP_DATA_DIR..."
    mkdir -p "$GEOIP_DATA_DIR"

    if [ -f "/etc/GeoIP.conf" ]; then
        log_info "Fazendo backup do arquivo /etc/GeoIP.conf..."
        cp /etc/GeoIP.conf /etc/GeoIP.conf.backup
    fi

    log_info "Configurando /etc/GeoIP.conf..."
    cat > /etc/GeoIP.conf << "EOF"
# GeoIP.conf file for geoipupdate
# Copyright (C) 2018 MaxMind, Inc.

# AccountID is from your MaxMind account.
AccountID ACCOUNT_ID_PLACEHOLDER

# LicenseKey is from your MaxMind account
LicenseKey LICENSE_KEY_PLACEHOLDER

# EditionIDs is from your MaxMind account.
EditionIDs GeoLite2-Country GeoLite2-City

# The directory to store the database files.
DatabaseDirectory DATA_DIR_PLACEHOLDER
EOF

    # Substituir os placeholders pelas variáveis reais
    sed -i "s/ACCOUNT_ID_PLACEHOLDER/$GEOIP_ACCOUNT_ID/g" /etc/GeoIP.conf
    sed -i "s/LICENSE_KEY_PLACEHOLDER/$GEOIP_LICENSE_KEY/g" /etc/GeoIP.conf
    sed -i "s|DATA_DIR_PLACEHOLDER|$GEOIP_DATA_DIR|g" /etc/GeoIP.conf
    
    # Verificar se as substituições foram feitas corretamente
    log_info "Verificando configuração gerada..."
    if grep -q "PLACEHOLDER" /etc/GeoIP.conf; then
        log_error "❌ Erro: Ainda existem placeholders não substituídos no arquivo de configuração!"
        grep "PLACEHOLDER" /etc/GeoIP.conf
        exit 1
    fi
    
    # Validar se as credenciais estão no arquivo (sem mostrar a chave completa por segurança)
    if grep -q "AccountID $GEOIP_ACCOUNT_ID" /etc/GeoIP.conf; then
        log_info "✅ AccountID configurado corretamente"
    else
        log_error "❌ Erro na configuração do AccountID"
        exit 1
    fi
    
    if grep -q "LicenseKey" /etc/GeoIP.conf && ! grep -q "LICENSE_KEY_PLACEHOLDER" /etc/GeoIP.conf; then
        log_info "✅ LicenseKey configurado"
    else
        log_error "❌ Erro na configuração da LicenseKey"
        exit 1
    fi
}

# Atualizar bancos de dados GeoIP
update_geoip_databases() {
    log_info "Executando primeira atualização dos bancos de dados GeoIP2..."
    log_info "Configuração sendo usada:"
    echo "--- Início do arquivo /etc/GeoIP.conf ---"
    cat /etc/GeoIP.conf
    echo "--- Fim do arquivo /etc/GeoIP.conf ---"

    log_info "Executando geoipupdate com verbose..."
    if geoipupdate -v \
        -f /etc/GeoIP.conf \
        -d "$GEOIP_DATA_DIR"; then
        log_info "✅ geoipupdate executado com sucesso"
    else
        log_error "❌ Erro ao executar geoipupdate"
        log_error "Verifique se suas credenciais estão corretas no MaxMind:"
        log_error "1. Account ID: $GEOIP_ACCOUNT_ID"
        log_error "2. Verifique se a License Key está correta e ativa"
        log_error "3. Verifique se sua conta tem acesso às edições GeoLite2-Country e GeoLite2-City"
        exit 1
    fi

    log_info "Verificando se os bancos de dados foram baixados..."
    if [ -f "$GEOIP_DATA_DIR/GeoLite2-Country.mmdb" ] && [ -f "$GEOIP_DATA_DIR/GeoLite2-City.mmdb" ]; then
        log_info "✅ Instalação e configuração do GeoIP2 concluída com sucesso!"
        log_info "Bancos de dados disponíveis em $GEOIP_DATA_DIR/"
        ls -la "$GEOIP_DATA_DIR/"
    else
        log_error "❌ Erro: Bancos de dados não foram baixados corretamente"
        log_error "Verificando o conteúdo do diretório $GEOIP_DATA_DIR/:"
        ls -la "$GEOIP_DATA_DIR/" || log_error "Diretório $GEOIP_DATA_DIR/ não existe"
        exit 1
    fi
}

# Exibir instruções para atualização automática
display_cron_instructions() {
    log_info "Para atualizar os bancos automaticamente, adicione uma entrada no crontab:"
    log_info "sudo crontab -e"
    log_info "# Adicione a linha: 0 2 * * 0 /usr/bin/geoipupdate"
}

# Configurar crontab automaticamente
setup_crontab() {
    log_info "Configurando atualização automática via crontab..."
    
    # Verificar se já existe uma entrada para geoipupdate
    if crontab -l 2>/dev/null | grep -q "geoipupdate"; then
        log_warn "Já existe uma entrada do geoipupdate no crontab. Pulando configuração..."
        log_info "Entrada atual encontrada:"
        crontab -l 2>/dev/null | grep "geoipupdate"
        return 0
    fi
    
    # Criar entrada do crontab (toda domingo às 2h da manhã)
    local cron_entry="0 2 * * 0 /usr/bin/geoipupdate -f /etc/GeoIP.conf -d $GEOIP_DATA_DIR"
    
    # Backup do crontab atual (se existir)
    if crontab -l 2>/dev/null > /tmp/crontab_backup; then
        log_info "Backup do crontab atual salvo em /tmp/crontab_backup"
    fi
    
    # Adicionar nova entrada ao crontab
    (crontab -l 2>/dev/null; echo "$cron_entry") | crontab -
    
    if [ $? -eq 0 ]; then
        log_info "✅ Crontab configurado com sucesso!"
        log_info "Os bancos de dados GeoIP2 serão atualizados automaticamente toda domingo às 2h da manhã"
        log_info "Entrada adicionada: $cron_entry"
        
        # Mostrar crontab atual
        log_info "Crontab atual:"
        crontab -l
    else
        log_error "❌ Erro ao configurar o crontab"
        log_error "Você pode configurar manualmente executando:"
        log_error "sudo crontab -e"
        log_error "E adicionando a linha: $cron_entry"
        return 1
    fi
}

# Fluxo principal
main() {
    check_root
    ENV_FILE=$(find_env_file)
    log_info "Carregando configurações do arquivo: $ENV_FILE"
    load_env_variables "$ENV_FILE"
    install_packages
    configure_geoip
    update_geoip_databases
    setup_crontab
}

main
