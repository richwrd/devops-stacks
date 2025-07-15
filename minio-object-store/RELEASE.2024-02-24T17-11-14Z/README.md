# MinIO Object Store

Stack completa do MinIO para armazenamento de objetos S3-compatível, configurada com Docker Compose e scripts avançados de gestão e automação.

## 🌟 Características

- ✅ **Setup Automatizado**: Scripts inteligentes para configuração inicial
- ✅ **Arquitetura Modular**: Código organizado em módulos especializados
- ✅ **Gestão Simplificada**: Comandos únicos para operações complexas
- ✅ **Produção Ready**: Configurações otimizadas para ambiente produtivo
- ✅ **Healthcheck Avançado**: Monitoramento automático de saúde do serviço
- ✅ **Logs Centralizados**: Sistema de logging colorido e estruturado
- ✅ **Integração Nginx**: Pronto para reverse proxy com SSL
- ✅ **Configuração Flexível**: Variáveis de ambiente para customização

## 📁 Estrutura do Projeto

```
├── 📄 docker-compose.yaml       # Configuração principal do Docker Compose
├── 📄 .env.example             # Template de variáveis de ambiente
├── 📁 docs/                    # Documentação técnica
│   ├── config_nginx.txt        # Configuração para Nginx Proxy Manager
├── 📁 scripts/                 # Scripts de automação
│   ├── 📄 entrypoint.sh        # Script de inicialização do container
│   ├── 📄 manage.sh            # Script principal de gestão
│   ├── 📄 import.sh            # Sistema de importação de módulos
│   ├── 📁 core/                # Módulos principais
│   │   ├── docker.sh           # Operações Docker
│   │   ├── info.sh             # Informações do sistema
│   │   └── import.sh           # Importador de módulos core
│   ├── 📁 minio/               # Módulos específicos do MinIO
│   │   ├── info.sh             # Informações do MinIO
│   │   ├── setup.sh            # Configuração inicial
│   │   └── import.sh           # Importador de módulos MinIO
│   ├── 📁 utils/               # Utilitários
│   │   ├── log.sh              # Sistema de logging
│   │   └── import.sh           # Importador de utilitários
│   └── 📁 config/              # Configurações específicas
└── 📁 data/                    # Dados persistentes do MinIO (auto-criado)
```

## ⚙️ Configuração

### 🔑 Variáveis de Ambiente

Copie e configure o arquivo de variáveis:

```bash
cp .env.example .env
```

#### Variáveis Principais

```bash
#==========================
# CONFIGURAÇÕES DE CREDENCIAIS
#==========================

# Credenciais do administrador root
MINIO_ROOT_USER=minio_admin
MINIO_ROOT_PASSWORD=sua_senha_super_segura_aqui

#==========================
# CONFIGURAÇÕES DE REDE
#==========================

# Domínios (para produção)
MINIO_WEB_DOMAIN=minio.seudominio.com
MINIO_API_DOMAIN=s3.seudominio.com

# Portas de acesso
MINIO_WEB_PORT=9001                                    # Console Web
MINIO_API_PORT=9002                                    # API S3

# URLs completas (importante para reverse proxy)
MINIO_SERVER_URL=https://s3.seudominio.com
MINIO_BROWSER_REDIRECT_URL=https://minio.seudominio.com

#==========================
# CONFIGURAÇÕES REGIONAIS E PERFORMANCE
#==========================

MINIO_REGION=sa-east-1                                 # Região AWS-compatível
MINIO_AGPL_LICENSE_ACCEPTED=1                          # Aceitar licença AGPL

# Configurações de performance
MINIO_API_REQUESTS_MAX=2000                            # Máximo de requests simultâneos
MINIO_API_CORS_ALLOW_ORIGIN=*                          # CORS para desenvolvimento
```

> 🔒 **Segurança**: Em produção, sempre altere as senhas padrão e configure CORS adequadamente!

## � Pré-requisitos

### Sistema Operacional
- ✅ Linux (Ubuntu 20.04+ recomendado)
- ✅ Docker 20.10+
- ✅ Docker Compose v2.0+

### Recursos Mínimos
- **RAM**: 4GB disponível
- **CPU**: 2 cores
- **Armazenamento**: 10GB+ para dados
- **Rede**: Portas 9001 e 9002 disponíveis

### Dependências
```bash
# Instalar Docker (se necessário)
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Instalar Docker Compose (se necessário)
sudo apt install docker-compose-plugin

# Criar rede para reverse proxy
docker network create nginx_proxy
```

### Verificação de Pré-requisitos
```bash
# Verificar versões
docker --version                    # Docker 20.10+
docker compose version             # v2.0+

# Verificar portas disponíveis
sudo netstat -tlnp | grep -E ':(9001|9002)'

# Verificar espaço em disco
df -h /mnt/sdb1/
```

## �🚀 Quick Start

### Inicialização Rápida (Recomendado)

```bash
# 1. Clonar e configurar
git clone <repo-url>
cd minio-object-store
cp .env.example .env

# 2. Editar variáveis (especialmente senhas!)
nano .env

# 3. Iniciar com setup automático
./scripts/manage.sh start-setup

# 4. Verificar status
./scripts/manage.sh status

```

### Acesso aos Serviços

- **🌐 Console Web**: http://localhost:9001
- **🔗 API S3**: http://localhost:9002
- **📊 Health Check**: http://localhost:9002/minio/health/live

### Credenciais de Acesso

- **Usuário**: Conforme `MINIO_ROOT_USER` (padrão: `minio_admin`)
- **Senha**: Conforme `MINIO_ROOT_PASSWORD` (padrão: `minio_admin`)

## 🛠️ Scripts de Gestão

### `manage.sh` - Script Principal

O script `manage.sh` é a interface principal para todas as operações:

#### 📦 Comandos de Container
```bash
./scripts/manage.sh start           # Iniciar serviço
./scripts/manage.sh start-setup     # Iniciar + configuração inicial
./scripts/manage.sh stop            # Parar serviço
./scripts/manage.sh restart         # Reiniciar serviço
./scripts/manage.sh status          # Status atual
./scripts/manage.sh logs            # Ver logs em tempo real
./scripts/manage.sh shell           # Acessar shell do container
```

#### 🔧 Comandos de Configuração
```bash
./scripts/manage.sh setup           # Executar configuração inicial
./scripts/manage.sh config          # Mostrar configuração atual
./scripts/manage.sh info            # Informações detalhadas
```

#### 🧪 Outros comandos 
```bash
./scripts/manage.sh show-config     # Mostrar configurações MinIO
./scripts/manage.sh validate-env    # Validar configuração .env
```

### `entrypoint.sh` - Inicialização Inteligente

O script de entrypoint fornece:

- ✅ **Verificação de Dependências**: Valida binários e configurações
- ✅ **Logging Avançado**: Sistema de logs colorido com timestamps
- ✅ **Tratamento de Sinais**: Parada limpa com SIGTERM/SIGINT
- ✅ **Preparação Automática**: Criação e validação de diretórios
- ✅ **Configuração Dinâmica**: Carregamento de variáveis de ambiente
- ✅ **Monitoramento de Processo**: Acompanhamento do estado do MinIO

## 🏗️ Arquitetura Modular

### Sistema de Módulos

A stack utiliza uma arquitetura modular para facilitar manutenção e extensibilidade:

#### 📁 `scripts/core/` - Módulos Principais
- **`docker.sh`**: Operações de container e Docker Compose
- **`info.sh`**: Coleta e exibição de informações do sistema

#### 📁 `scripts/minio/` - Módulos MinIO
- **`setup.sh`**: Configuração inicial automatizada do MinIO
- **`info.sh`**: Informações específicas do MinIO (versão, configuração)

#### 📁 `scripts/utils/` - Utilitários
- **`log.sh`**: Sistema de logging colorido e estruturado

#### 📁 `scripts/config/` - Configurações
- Configurações específicas e templates de configuração

### Sistema de Importação

Cada diretório possui um `import.sh` que facilita o carregamento de módulos:

```bash
# Importação automática de todos os módulos
source "${SCRIPT_DIR}/import.sh"
```

## 🐳 Configuração Docker

### Características do Container

```yaml
services:
  minio-object-store:
    image: minio/minio:latest
    container_name: minio-object-store
    restart: unless-stopped
    
    # Recursos otimizados
    mem_limit: 4g
    cpus: 1.5
    
    # Healthcheck integrado
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9002/minio/health/live"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s
    
    # Rede externa para reverse proxy
    networks:
      - nginx_proxy
```

### Volume Persistente

```yaml
volumes:
  minio-object-store:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /minio-object-store/data
```

> 📝 **Nota**: O volume é mapeado para um diretório específico do host para garantir persistência dos dados.

## 🌐 Integração com Reverse Proxy

### Nginx Proxy Manager

A stack está preparada para integração com Nginx Proxy Manager:

1. **Rede Externa**: Utiliza a rede `nginx_proxy`
2. **Configuração SSL**: Suporte completo para HTTPS/WSS
3. **WebSocket**: Configuração otimizada para websockets

### Configuração Recomendada

Consulte `docs/config_nginx.txt` para configuração detalhada do Nginx Proxy Manager.

#### Headers Essenciais para WebSocket:
```nginx
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
```

#### CSP Otimizado:
```nginx
Content-Security-Policy: "default-src 'self'; connect-src 'self' https: ws: wss: data:;"
```

## 🔧 Troubleshooting

### Comandos de Diagnóstico

#### Verificação Rápida
```bash
# Status geral do serviço
./scripts/manage.sh status

# Verificar saúde do MinIO
./scripts/manage.sh health

# Ver logs em tempo real
./scripts/manage.sh logs
```

#### Diagnóstico Avançado
```bash
# Informações detalhadas do sistema
./scripts/manage.sh info

# Validar configuração .env
./scripts/manage.sh validate-env

# Mostrar configuração atual do MinIO
./scripts/manage.sh show-config
```

#### 🚨 Container não inicia
```bash
# Verificar rede nginx_proxy
docker network create nginx_proxy

# Verificar permissões de volume
sudo chown -R 1000:1000 /mnt/sdb1/stacks/minio-object-store/data
```

#### 🚨 Performance lenta
```bash
# Aumentar limites de recursos no docker-compose.yaml
mem_limit: 8g
cpus: 2.0

# Ajustar configurações de API
MINIO_API_REQUESTS_MAX=3000
```

### Comandos de Recuperação

#### Reinicialização Completa
```bash
# Parar serviço
./scripts/manage.sh stop

# Limpar containers órfãos
docker system prune -f

# Reiniciar com setup
./scripts/manage.sh start-setup
```

#### Reset de Configuração
```bash
# ⚠️ CUIDADO: Remove todas as configurações
# Backup dos dados antes de executar
cp .env .env.backup

# Recriar configuração do zero
./scripts/manage.sh stop
rm .env
cp .env.example .env
# Editar .env conforme necessário
./scripts/manage.sh start-setup
```

## 📚 Documentação Adicional

### Arquivos de Referência

- **`docs/config_nginx.txt`**: Configuração detalhada para Nginx Proxy Manager
- **`.env.example`**: Template completo de variáveis de ambiente

### Recursos Úteis

- [Documentação Oficial MinIO](https://docs.min.io/)
- [MinIO Client (mc) Guide](https://docs.min.io/docs/minio-client-complete-guide.html)
- [S3 API Compatibility](https://docs.min.io/docs/minio-server-with-s3-api.html)

## 🤝 Contribuição

### Estrutura para Novos Módulos

Para adicionar novos módulos:

1. Criar arquivo em `scripts/[categoria]/`
2. Adicionar importação em `scripts/[categoria]/import.sh`
3. Seguir padrões de logging do `utils/log.sh`
4. Documentar no README

### Padrões de Código

- **Bash strict mode**: `set -e`
- **Logging estruturado**: Usar funções do `log.sh`
- **Validação de entrada**: Sempre validar parâmetros
- **Documentação**: Comentários claros e descritivos

---

## 📄 Licença

Este projeto segue os termos da licença AGPL v3 do MinIO.

---

**Desenvolvido com ❤️ para facilitar o deploy e gestão do MinIO em ambientes Docker**
