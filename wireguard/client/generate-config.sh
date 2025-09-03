#!/bin/bash

# Função para carregar variáveis do .env
load_env() {
  local env_file=".env"
  
  if [[ ! -f "$env_file" ]]; then
    echo "❌ Erro: Arquivo .env não encontrado na pasta atual" >&2
    echo "📋 Crie um arquivo .env com as seguintes variáveis:" >&2
    echo "WG_SERVER_PUBLIC_KEY=" >&2
    echo "WG_INTERFACE_ADDRESS=" >&2
    echo "WG_SERVER_ENDPOINT=" >&2
    echo "FOLDER_PREFIX=" >&2
    exit 1
  fi
  
  # Carrega variáveis do .env ignorando comentários e linhas vazias
  export $(grep -v '^#' "$env_file" | grep -v '^$' | xargs)
  
  # Validação das variáveis obrigatórias
  if [[ -z "$WG_SERVER_PUBLIC_KEY" || -z "$WG_INTERFACE_ADDRESS" || -z "$WG_SERVER_ENDPOINT" || -z "$FOLDER_PREFIX" ]]; then
    echo "❌ Erro: Variáveis obrigatórias não definidas no .env" >&2
    echo "📋 Certifique-se de que todas as variáveis estão preenchidas:" >&2
    echo "WG_SERVER_PUBLIC_KEY, WG_INTERFACE_ADDRESS, WG_SERVER_ENDPOINT, FOLDER_PREFIX" >&2
    exit 1
  fi
}

# Função para obter endereço do usuário
get_user_address() {
  local address
  
  echo "🔧 Configure o endereço do túnel WireGuard" >&2
  echo -e "\n" >&2
  
  while true; do
    read -p "📍 Digite o endereço IP do túnel (ex: 10.0.0.2/24): " address
    
    # Validação básica do formato IP
    if [[ "$address" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$ ]]; then
      echo "✅ Endereço válido: $address" >&2
      echo "$address"
      return 0
    else
      echo "❌ Formato inválido! Use o formato IP/CIDR (ex: 10.0.0.2/24)" >&2
      echo -e "\n" >&2
    fi
  done
}

# Função para extrair último octeto do IP
extract_last_octet() {
  local ip="$1"
  echo "$ip" | cut -d'.' -f4 | cut -d'/' -f1
}

# Função para criar pasta baseada no endereço
create_folder() {
  local address="$1"
  local last_octet=$(extract_last_octet "$address")
  local folder_name="${FOLDER_PREFIX}-${last_octet}"
  
  if [[ ! -d "$folder_name" ]]; then
    mkdir -p "$folder_name"
    echo "📁 Pasta criada: $folder_name" >&2
  else
    echo "📁 Usando pasta existente: $folder_name" >&2
  fi
  
  echo "$folder_name"
}

# Função para gerar nova chave privada
generate_private_key() {
  wg genkey
}

# Função para gerar chave pública a partir da privada
generate_public_key() {
  local private_key="$1"
  echo "$private_key" | wg pubkey
}

# Função para gerar nova configuração WireGuard
generate_new_config() {
  local user_address="$1"
  local new_private_key
  local new_public_key
  local folder_name
  local config_file
  local private_key_file
  local public_key_file
  
  echo "🚀 Gerando nova configuração WireGuard..."
  echo -e "\n\n" >&2
  
  # Cria pasta baseada no endereço
  folder_name=$(create_folder "$user_address")
  config_file="${folder_name}/wg-client.conf"
  private_key_file="${folder_name}/privatekey.conf"
  public_key_file="${folder_name}/publickey.conf"
  
  # Gera novas chaves
  new_private_key=$(generate_private_key)
  new_public_key=$(generate_public_key "$new_private_key")
  
  # Salva chave privada
  echo "$new_private_key" > "$private_key_file"
  
  # Salva chave pública
  echo "$new_public_key" > "$public_key_file"
  
  # Monta nova configuração usando variáveis do .env
  cat << EOF > "$config_file"
[Interface]
PrivateKey = $new_private_key
Address = $user_address

[Peer]
PublicKey = $WG_SERVER_PUBLIC_KEY
Endpoint = $WG_SERVER_ENDPOINT
AllowedIPs = $WG_INTERFACE_ADDRESS
PersistentKeepalive = 25
EOF
  
  echo "✅ Nova configuração salva em: $config_file" >&2
  echo "🔑 Chave privada salva em: $private_key_file" >&2
  echo "🔑 Chave pública salva em: $public_key_file" >&2
  echo -e "\n\n" >&2
}



# Função principal
main() {
  if ! command -v wg &> /dev/null; then
    echo "❌ Erro: WireGuard não está instalado" >&2
    exit 1
  fi
  
  # Carrega variáveis do .env
  load_env
  
  local user_address
  user_address=$(get_user_address)
  generate_new_config "$user_address"
}


# Executa função principal se script for chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
