#!/bin/bash

# Lista de variáveis obrigatórias para o MinIO
required_vars=(
"MINIO_ROOT_USER" 
"MINIO_ROOT_PASSWORD"
"MINIO_SERVER_URL"
"MINIO_BROWSER_REDIRECT_URL"
"MINIO_REGION"
"MINIO_AGPL_LICENSE_ACCEPTED"
"MINIO_API_CORS_ALLOW_ORIGIN"
"MINIO_API_REQUESTS_MAX"
)

# Function to validate required environment variables recursively
validate_required_variables_recursive() {
  local missing_vars=("$@") # List of required variables

  # Base case: if the list is empty, return
  if [[ ${#missing_vars[@]} -eq 0 ]]; then
    return 0
  fi

  # Check the first variable in the list
  local var_name="${missing_vars[0]}"
  if [[ -z "${!var_name}" ]]; then
    error "Variável obrigatória não definida: $var_name"
    return 1
  fi

  # Recursive call with the rest of the list
  validate_required_variables_recursive "${missing_vars[@]:1}"
}

# Função principal para validar todas as variáveis obrigatórias
validate_environment() {
    log "Validando variáveis de ambiente..."
    
    if validate_required_variables_recursive "${required_vars[@]}"; then
        log "✓ Todas as variáveis obrigatórias estão definidas"
        return 0
    else
        error "✗ Validação de ambiente falhou"
        info "Verifique se todas as variáveis estão definidas no arquivo .env"
        return 1
    fi
}