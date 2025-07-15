#!/bin/bash

# Import de todas as funções core
CORE_DIR="$(dirname "${BASH_SOURCE[0]}")"

source "$CORE_DIR/docker.sh"
source "$CORE_DIR/health.sh"
source "$CORE_DIR/info.sh"
