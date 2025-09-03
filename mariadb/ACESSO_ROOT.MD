### 🛡️ A Fortaleza Digital: Por que Limitar o Acesso `root` ao seu IP?

Pense no seu usuário `root` como a **chave mestra** do seu castelo de dados. Permitir que ele se conecte de qualquer lugar (`'root'@'%'`) é como deixar a chave mestra pendurada no portão principal, visível para qualquer um que passar na rua.

Limitar o acesso a um único IP específico, como o da sua VPN WireGuard, transforma sua segurança da água para o vinho. Veja por quê:

💥 **Redução Drástica da Superfície de Ataque**
Com acesso liberado para o mundo (`%`), qualquer pessoa na internet pode tentar adivinhar sua senha. Ao restringir a um único IP, o atacante primeiro precisaria invadir a sua máquina ou a sua rede VPN para ter a *chance* de tentar fazer login. A porta de entrada para o mundo foi fechada.

🤖 **Proteção Contra Robôs e Ataques de Força Bruta**
Existem milhares de robôs (bots) varrendo a internet 24/7 em busca de bancos de dados com a porta 3306 aberta. Se encontram, eles começam a testar milhões de senhas comuns (`root`, `admin`, `123456`, etc.). Ao limitar o IP, seu banco de dados se torna invisível para esses robôs. Eles podem bater na porta, mas ninguém vai atender.

🔍 **Auditoria e Responsabilidade Claras**
Se alguma alteração crítica for feita pelo usuário `root`, e esse usuário só pode se conectar a partir de um único IP, você sabe exatamente de onde veio a ação. Isso simplifica a investigação de problemas e a responsabilização por mudanças.

🚪 **Prevenção de Acessos Indevidos**
A ameaça nem sempre é externa. Limitar o `root` impede que outras aplicações ou servidores na sua própria infraestrutura, que não deveriam ter esse nível de acesso, se conectem acidentalmente (ou maliciosamente) com privilégios máximos.

-----

### 🛠️ Passo a Passo: Trancando o `root` com seu IP do WireGuard

Vamos assumir que o IP fixo que sua VPN WireGuard fornece a você é `10.10.10.2`. O processo é simples e rápido.

#### 1\. 🖥️ Conecte-se ao seu Banco de Dados

Primeiro, acesse seu servidor (geralmente via SSH) e faça login no MariaDB/MySQL com privilégios de `root`.

```bash
# Conecte-se ao banco de dados
mariadb -u root -p
```

#### 2\. 🕵️‍♀️ Verifique a Configuração Atual

Antes de mudar, vamos ver como o `root` está configurado. É muito provável que você tenha uma entrada com o Host `%` ou `localhost`.

```sql
SELECT User, Host FROM mysql.user WHERE User = 'root';
```

A saída pode ser algo como:

```
+------+-----------+
| User | Host      |
+------+-----------+
| root | %         |
| root | localhost |
+------+-----------+
```

Nosso alvo é mudar a linha que contém `%`.

#### 3\. 🔒 Execute o Comando de Alteração

Agora, vamos usar o comando `RENAME USER` para alterar o host de `%` para o IP específico da sua VPN.

```sql
RENAME USER 'root'@'%' TO 'root'@'10.10.10.2';
```

  * **`RENAME USER 'root'@'%'`**: Identifica o usuário que queremos alterar (o `root` que pode se conectar de qualquer lugar).
  * **`TO 'root'@'10.10.10.2'`**: Define a nova configuração, permitindo acesso apenas do seu IP.

> ✨ **Dica:** Se você quisesse liberar para *qualquer dispositivo* na sua rede VPN, você usaria `... TO 'root'@'10.10.10.%';`. A versão com o IP específico é mais segura\!

#### 4\. ✅ Confirme a Mudança

Execute o comando de verificação novamente para garantir que a alteração foi aplicada com sucesso.

```sql
SELECT User, Host FROM mysql.user WHERE User = 'root';
```

A nova saída deve ser:

```
+------+--------------+
| User | Host         |
+------+--------------+
| root | 10.10.10.2   |
| root | localhost    |
+------+--------------+
```

Perfeito\! O acesso externo do `root` agora está restrito ao seu IP.

#### 5\. 🌐 Teste a Conexão

A melhor forma de ter certeza é testar\!

  * **Desconecte** do banco de dados (`exit;`).
  * **Com a VPN ativa**, tente se conectar remotamente. O acesso deve funcionar\!
  * **(Opcional) Desative a VPN** e tente se conectar remotamente de novo. O acesso deve ser **negado**.

Pronto\! Com um único comando, você aumentou drasticamente a segurança do seu banco de dados. 👍

---

by: richwrd <3