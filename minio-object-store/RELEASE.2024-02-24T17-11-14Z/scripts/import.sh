#!/bin/bash
# Import centralizado para todo o projeto

source "$(dirname "${BASH_SOURCE[0]}")/config/import.sh"
source "$(dirname "${BASH_SOURCE[0]}")/core/import.sh"
source "$(dirname "${BASH_SOURCE[0]}")/minio/import.sh"
source "$(dirname "${BASH_SOURCE[0]}")/utils/import.sh"
