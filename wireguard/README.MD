# 🔐 WireGuard - Configuração Completa

Este repositório contém uma configuração completa para servidor e clientes WireGuard, incluindo scripts automatizados para geração de configurações e gerenciamento do serviço.

## 📁 Estrutura do Projeto

```
wireguard/
├── README.MD                    # Este arquivo
├── client/                     # Configurações e ferramentas para clientes
│   ├── generate-config.sh      # Script para gerar configurações de cliente
│   └── example/               # Exemplos de configuração por plataforma
│       ├── client-linux.conf   # Configuração exemplo para Linux
│       ├── client-mac.conf     # Configuração exemplo para macOS
│       └── client-windows.conf # Configuração exemplo para Windows
└── server/                     # Configurações e ferramentas para servidor
    ├── restart-wireguard.sh    # Script para reiniciar o serviço WireGuard
    └── example/               # Exemplos de configuração do servidor
        └── server.conf         # Configuração exemplo do servidor
```

## 🖥️ Pasta `client/`

A pasta `client` contém todas as ferramentas e configurações relacionadas aos clientes WireGuard.

### 📄 `generate-config.sh`

Script automatizado que gera configurações completas para novos clientes WireGuard.

#### ✨ Funcionalidades:
- **Geração automática de chaves**: Cria automaticamente chaves privadas e públicas para cada cliente
- **Configuração personalizada**: Permite definir endereços IP específicos para cada cliente
- **Organização automática**: Cria pastas organizadas baseadas no IP do cliente
- **Validação**: Verifica formatos de IP e dependências do sistema
- **Configuração via .env**: Utiliza arquivo de ambiente para configurações do servidor

#### 🚀 Como usar:

1. **Criar arquivo `.env`** na pasta raiz com as seguintes variáveis:
   ```bash
   WG_SERVER_PUBLIC_KEY=sua_chave_publica_do_servidor
   WG_INTERFACE_ADDRESS=10.10.10.1/24
   WG_SERVER_ENDPOINT=seu.servidor.com:51820
   FOLDER_PREFIX=cliente
   ```

2. **Executar o script**:
   ```bash
   cd client/
   chmod +x generate-config.sh
   ./generate-config.sh
   ```

3. **Informar o IP do túnel** quando solicitado (ex: `10.10.10.5/32`)

#### 📤 Saída do script:
- `cliente-X/wg-client.conf`: Configuração completa do cliente
- `cliente-X/privatekey.conf`: Chave privada do cliente
- `cliente-X/publickey.conf`: Chave pública do cliente (para adicionar no servidor)

### 📂 `example/`

Contém exemplos de configuração para diferentes plataformas:

- **`client-linux.conf`**: Configuração otimizada para sistemas Linux
- **`client-mac.conf`**: Configuração para macOS
- **`client-windows.conf`**: Configuração para Windows

Cada exemplo demonstra:
- Configuração da interface do cliente
- Endereçamento IP específico
- Configuração do peer (servidor)
- Keep-alive para manter conexão estável

## 🖧 Pasta `server/`

A pasta `server` contém ferramentas e configurações para o servidor WireGuard.

### 🔄 `restart-wireguard.sh`

Script para reiniciar o serviço WireGuard de forma controlada e monitorada.

#### ✨ Funcionalidades:
- **Reinício seguro**: Para e inicia o serviço de forma controlada
- **Logs informativos**: Fornece feedback detalhado sobre o processo
- **Verificação de status**: Confirma se o serviço foi reiniciado com sucesso
- **Configuração via .env**: Permite personalizar a interface WireGuard

#### 🚀 Como usar:

1. **Configurar arquivo `.env`** (opcional):
   ```bash
   WG_INTERFACE=wg0
   ```

2. **Executar o script**:
   ```bash
   cd server/
   chmod +x restart-wireguard.sh
   ./restart-wireguard.sh
   ```

#### 📊 O script mostra:
- Status atual do serviço
- Processo de parada e inicialização
- Confirmação de sucesso
- Logs detalhados em caso de erro

### 📂 `example/`

- **`server.conf`**: Exemplo completo de configuração do servidor WireGuard

#### Características da configuração do servidor:
- **Interface do servidor**: `10.10.10.1/24`
- **Porta de escuta**: `51820`
- **Múltiplos peers**: Suporte para Linux, Windows e macOS
- **Organização clara**: Comentários explicativos para cada seção

## ⚙️ Configuração Inicial

### 1. Preparar o Ambiente

```bash
# Instalar WireGuard (Ubuntu/Debian)
sudo apt update
sudo apt install wireguard

# Ou no CentOS/RHEL
sudo yum install epel-release
sudo yum install wireguard-tools
```

### 2. Configurar Servidor

1. Copiar `server/example/server.conf` para `/etc/wireguard/wg0.conf`
2. Gerar chaves do servidor:
   ```bash
   wg genkey | tee server_private.key | wg pubkey > server_public.key
   ```
3. Editar configuração substituindo as chaves
4. Iniciar o serviço:
   ```bash
   sudo systemctl enable wg-quick@wg0
   sudo systemctl start wg-quick@wg0
   ```

### 3. Gerar Clientes

1. Criar arquivo `.env` na raiz do projeto
2. Usar o script `client/generate-config.sh` para cada novo cliente
3. Adicionar a chave pública do cliente na configuração do servidor
4. Reiniciar o servidor usando `server/restart-wireguard.sh`

## 🔧 Exemplo de Fluxo Completo

```bash
# 1. Gerar configuração para novo cliente
cd client/
./generate-config.sh
# IP informado: 10.10.10.5/32

# 2. Adicionar cliente no servidor
sudo nano /etc/wireguard/wg0.conf
# Adicionar seção [Peer] com a chave pública gerada

# 3. Reiniciar servidor
cd ../server/
sudo ./restart-wireguard.sh

# 4. Enviar arquivo cliente-5/wg-client.conf para o cliente
```

## 📋 Variáveis de Ambiente (.env)

```bash
# Chave pública do servidor WireGuard
WG_SERVER_PUBLIC_KEY=ChavePublicaDoServidor=

# Endereço da interface/rede do túnel
WG_INTERFACE_ADDRESS=10.10.10.0/24

# Endpoint do servidor (IP:Porta)
WG_SERVER_ENDPOINT=meu.servidor.com:51820

# Prefixo para pastas dos clientes
FOLDER_PREFIX=cliente

# Interface WireGuard (opcional, padrão: wg0)
WG_INTERFACE=wg0
```

## 🛡️ Segurança

- **Chaves únicas**: Cada cliente possui chaves criptográficas únicas
- **IPs isolados**: Cada cliente tem seu próprio endereço IP no túnel
- **Keep-alive**: Mantém conexões estáveis através de NAT/Firewall
- **Validação**: Scripts validam formatos e dependências

## 🐛 Solução de Problemas

### Cliente não conecta
1. Verificar se as chaves estão corretas
2. Confirmar se o cliente foi adicionado na configuração do servidor
3. Reiniciar o serviço do servidor

### Servidor não inicia
1. Verificar configuração em `/etc/wireguard/wg0.conf`
2. Confirmar se a porta está disponível: `sudo netstat -tulpn | grep 51820`
3. Verificar logs: `sudo journalctl -u wg-quick@wg0`

---

📚 **Documentação oficial**: [WireGuard](https://www.wireguard.com/)