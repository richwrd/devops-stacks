# 🚀 MariaDB com Docker Compose

Este guia fornece instruções para configurar e executar um serviço MariaDB usando Docker Compose. O ambiente é projetado para ser seguro e persistente.

## ✅ Pré-requisitos

  - [Docker](https://docs.docker.com/get-docker/)
  - [Docker Compose](https://docs.docker.com/compose/install/)

## ⚙️ Passo a passo para execução

### 1\. Prepare o arquivo de ambiente

Todas as configurações sensíveis e específicas do ambiente são gerenciadas através de um arquivo `.env`. Comece copiando o arquivo de exemplo, caso ainda não o tenha feito.

```bash
# Renomeie o arquivo de exemplo para .env
cp .env.example .env
```

### 2\. Revise o arquivo `.env`

Abra o arquivo `.env` para confirmar que os valores correspondem ao seu ambiente. O exemplo abaixo reflete a sua configuração atual.

```bash
# ⚠️ Atenção: Os valores de senha padrão ("root", "mariadb") são inseguros.
# É ALTAMENTE RECOMENDADO alterá-los para senhas fortes antes de usar em produção.

# Caminho no seu computador (host) onde os dados do MariaDB serão salvos
MARIADB_DATA_DIR="/mnt/data"

# Senha para o superusuário 'root'.
MYSQL_ROOT_PASSWORD="root" # <-- Mude esta senha!

# Usuário e banco de dados padrão para aplicações
MYSQL_DATABASE="mariadb"
MYSQL_USER="mariadb"
MYSQL_PASSWORD="mariadb" # <-- Mude esta senha!

# Outras configurações
NETWORK_NAME="mariadb_network"
MARIADB_CONTAINER_NAME="mariadb"
TZ="America/Sao_Paulo"
```

### 3\. Crie o diretório de dados

O Docker precisa que o diretório no host exista antes de montar o volume. Crie-o com o mesmo caminho que você definiu em `MARIADB_DATA_DIR`.

```bash
# Use o mesmo caminho definido no seu arquivo .env
mkdir -p /mnt/data
```

### 4\. Inicie o serviço

Com tudo configurado, suba o container usando Docker Compose.

```bash
sudo docker compose up -d
```

Para verificar se o serviço está em execução e saudável:

```bash
sudo docker compose ps
```

## 🔒 Segurança: Acesso do Usuário `root`

Por padrão, a configuração inicial pode deixar o usuário `root` acessível de qualquer lugar, o que é uma grande falha de segurança. Para garantir a proteção do seu banco de dados, é **essencial** restringir o acesso do `root` a um IP confiável.

➡️ **Consulte o guia detalhado que criamos para isso: [ACESSO\_ROOT.md](https://github.com/richwrd/devops-stacks/blob/main/mariadb/ACESSO_ROOT.MD)**

## 🎛️ Gerenciamento do serviço

Para parar os containers e a rede:

```bash
sudo docker compose down
```

Para visualizar os logs do MariaDB em tempo real (use o nome do container definido no seu `.env`):

```bash
sudo docker compose logs -f mariadb
```

## 📚 Informações adicionais

Para mais detalhes sobre configurações, otimizações e uso do MariaDB, consulte a [documentação oficial do MariaDB](https://mariadb.com/kb/en/documentation/).


<p align="center">═══════════ ◈ ═══════════</p>
<p align="center">
  👨‍💻 Desenvolvido por <strong>richwrd</strong> 
</p>
<p align="center">⚜️ Maringá - PR ⚜️</p>
<p align="center">═══════════ ◈ ═══════════</p>