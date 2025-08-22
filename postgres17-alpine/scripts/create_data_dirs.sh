#!/bin/bash
# Script to create data directories for PostgreSQL Alpine
# by: richwrd

set -e

load_env_file() {
  echo "🔍 Looking for environment file..."
  if [ -f "../.env" ]; then
    source "../.env"
    echo "✅ Environment file loaded successfully"
  else
    echo "❌ Error: .env file not found in parent directory."
    exit 1
  fi
  echo
  echo "══════════════════════════════════════════════════"
  echo
}

validate_env_vars() {
  echo "🔎 Validating environment variables..."
  if [ -z "${POSTGRES_DATA_DIR}" ]; then
    echo "❌ Error: POSTGRES_DATA_DIR is not defined in .env file."
    exit 1
  fi
  echo "✅ Environment variables validated successfully"
  echo
  echo "══════════════════════════════════════════════════"
  echo
}

create_data_directory() {
  echo "📁 Creating data directory for PostgreSQL Alpine..."
  echo
  if [ -d "$POSTGRES_DATA_DIR" ]; then
    echo "ℹ️  Data directory already exists: $POSTGRES_DATA_DIR"
  else
    mkdir -p "$POSTGRES_DATA_DIR"
    echo "✅ Created data directory: $POSTGRES_DATA_DIR"
  fi
  echo
  echo "══════════════════════════════════════════════════"
  echo
}

set_directory_permissions() {
  echo "🔒 Setting secure permissions (700) for data directory..."
  chmod 700 "$POSTGRES_DATA_DIR"
  echo "✅ Permissions set successfully"
  echo
  echo "══════════════════════════════════════════════════"
  echo
}

display_summary() {
  echo "🎉 Data directory created successfully:"
  echo
  echo "📂 PostgreSQL: $POSTGRES_DATA_DIR"
  echo
  echo "══════════════════════════════════════════════════"
}

main() {
  echo
  echo "🚀 Starting PostgreSQL data directory setup"
  echo "══════════════════════════════════════════════════"
  echo
  
  load_env_file
  validate_env_vars
  create_data_directory
  set_directory_permissions
  display_summary
}

main

exit 0
