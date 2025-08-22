# PostgreSQL 17 with Docker Compose

Este guia fornece instruções para configurar e executar um serviço PostgreSQL 17 usando Docker Compose.

## Pré-requisitos

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Passo a passo para execução

### 1. Configuração do ambiente

Clone o repositório e prepare o arquivo de configuração:

```bash
# Renomeie o arquivo de exemplo para .env
cp .env.example .env
```

### 2. Edite o arquivo .env

Abra o arquivo `.env` e modifique a pasta de dados do PostgreSQL conforme necessário:

```bash
# Exemplo de configuração
POSTGRES_DATA_DIR=/caminho/para/seus/dados
```

### 3. Crie os diretórios de dados

Execute o script para criar os diretórios necessários:

```bash
./create_data_dirs.sh
```

### 4. Inicie o serviço

Suba o container usando Docker Compose:

```bash
sudo docker compose up -d
```

Para verificar se o serviço está em execução:

```bash
sudo docker compose ps
```

## Gerenciamento do serviço

Para parar o serviço:

```bash
sudo docker compose down
```

Para visualizar logs:

```bash
sudo docker compose logs -f
```

## Informações adicionais

Para mais detalhes sobre configurações e uso do PostgreSQL 17, consulte a [documentação oficial](https://www.postgresql.org/docs/17/).