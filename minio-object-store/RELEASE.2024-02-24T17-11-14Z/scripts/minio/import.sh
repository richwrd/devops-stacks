#!/bin/bash

# Import de todas as funções MinIO
MINIO_DIR="$(dirname "${BASH_SOURCE[0]}")"

source "$MINIO_DIR/setup.sh"
source "$MINIO_DIR/info.sh"
