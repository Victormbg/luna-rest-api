# 🌙 Luna REST API (OpenResty + Lua)

API RESTful de altíssima performance e ultra-baixa latência construída com **Lua** e **OpenResty** (Nginx + LuaJIT), projetada para lidar com um volume massivo de requisições por segundo utilizando processamento não-bloqueante baseado em coroutines e **armazenamento de baixa latência no Redis**.

> ⚡ **Benchmark Local:** Em testes executados via **Docker Desktop (Alpine)**, a API atingiu um tempo de resposta de apenas **2 ms** no endpoint de busca de usuários, demonstrando a eficiência extrema da combinação LuaJIT + Redis em memória.

---

## 🎯 Destaques do Projeto

* 🚀 **Ultra Performance (2 ms):** Roteamento em C/Nginx com regras compiladas (PCRE2) e execução assíncrona transparente via coroutines no LuaJIT.
* ⚡ **Persistência em Memória (Redis):** Integrado via `resty.redis` (módulo não-bloqueante nativo do OpenResty) utilizando *connection pooling* e operações atômicas (`INCR`).
* 🛡️ **Segurança em Camadas (Zero Trust):** Exige autenticação dupla simultânea por **`x-api-key`** (Base64) e **`Bearer Token`** para máxima proteção dos recursos.
* 🔑 **Padrão OAuth 2.0 & JWT:** Rota `/token` nativa para emissão de JSON Web Tokens (RFC 7519) assinados em `HMAC-SHA256` com tempo de expiração (`exp`, `iat`, `jti`).
* 📋 **Validação por Schemas:** Middleware desacoplado que valida tipos de dados, obrigatoriedade e regras customizadas em payloads JSON antes de processar a requisição.
* 🧩 **Arquitetura Limpa em Camadas:** Separação estrita de responsabilidades (`Config`, `Controllers`, `Middlewares`, `Routes`, `Schemas`, `Services` e `Utils`).
* ⏱️ **Rate Limiting Nativo (Proteção Anti-DDoS):** Middleware em memória RAM controlando o limite de requisições por IP com resposta automática `HTTP 429 Too Many Requests`.
* 🌐 **CORS & Preflight Dinâmico:** Gerenciamento centralizado de políticas de origem (`Cross-Origin`) e requisições `OPTIONS` processadas direto na camada de middleware.
* 🐳 **Containerização Minimalista:** Ambiente de desenvolvimento automatizado via `.devcontainer` e imagem Docker Alpine otimizada.
---

## 📸 Evidências de Testes & Performance

<table>
  <tr>
    <td width="50%">
      <img src="docs/assets/image.png" alt="Evidência 1" width="100%"/>
    </td>
    <td width="50%">
      <img src="docs/assets/image-1.png" alt="Evidência 2" width="100%"/>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <img src="docs/assets/image-2.png" alt="Evidência 3" width="100%"/>
    </td>
    <td width="50%">
      <img src="docs/assets/image-3.png" alt="Evidência 4" width="100%"/>
    </td>
  </tr>
</table>

---

## 📁 Estrutura do Projeto

```text
luna-rest-api/
├── .devcontainer/
│   └── devcontainer.json    # Configurações do ambiente de desenvolvimento automatizado
├── .vscode/
│   └── settings.json        # Ajustes de workspace do VS Code
├── conf/
│   └── nginx.conf           # Configuração de borda e servidor OpenResty
├── docker/                  # Scripts e arquivos de construção da imagem Docker
├── docs/
│   └── assets/              # Evidências, prints de testes e documentação visual
├── logs/                    # Arquivos de log do servidor Nginx/OpenResty
├── lua/
│   ├── config/              # Parâmetros globais de ambiente e conexão
│   │   ├── env.lua          # Leitura centralizada de variáveis do arquivo .env
│   │   └── redis.lua        # Configurações de timeout e pool do Redis
│   ├── controllers/         # Manipuladores de requisição e orquestração de resposta
│   │   ├── auth_controller.lua     # Endpoint do fluxo OAuth 2.0 /token
│   │   └── usuario_controller.lua  # Endpoints do CRUD de usuários
│   ├── middlewares/         # Interceptadores de segurança e validação
│   │   ├── auth_middleware.lua     # Validação estrita de x-api-key e Bearer JWT
│   │   ├── cors.lua                # Gerenciamento de cabeçalhos e preflight OPTIONS
│   │   ├── rate_limit.lua          # Controle de tráfego e limite por IP
│   │   └── validator_middleware.lua # Validador dinâmico baseado em Schemas
│   ├── routes/              # Roteamento centralizado da API
│   │   └── api.lua          # Mapeamento de URIs para os controllers
│   ├── schemas/             # Schemas e regras estruturais do payload JSON
│   │   └── usuario_schema.lua      # Contrato dos campos de dados do usuário
│   ├── services/            # Camada de regras de negócio e acesso aos dados
│   │   ├── auth_service.lua        # Geração, assinação e validação do JWT
│   │   └── usuario_service.lua     # Operações atômicas e persistência no Redis
│   └── utils/               # Helpers e utilitários da aplicação
│       ├── redis.lua        # Cliente e gerenciador do ciclo de vida do resty.redis
│       └── response.lua     # Padronizador de respostas JSON
├── .dockerignore            # Arquivos ignorados no contexto de build do Docker
├── .env                     # Variáveis de ambiente e chaves secretas
├── .gitignore               # Arquivos e pastas ignorados pelo Git
└── README.md                # Documentação oficial do projeto
```

---

### 🗄️ Comandos do Redis

```bash
# Listar todas as chaves cadastradas no banco
redis-cli KEYS "*"

# Visualizar a lista de usuários armazenada
redis-cli GET "usuarios:lista"

# Consultar o valor do contador atual de IDs
redis-cli GET "usuarios:id_counter"

# Limpar todas as chaves do banco (resetar dados)
redis-cli FLUSHALL
```

---

## 🐳 Executando com Docker

Se preferir rodar a aplicação em um ambiente isolado na sua máquina utilizando Docker Desktop:

### 1. Gerar a Imagem Docker
```bash
docker build -f docker/Dockerfile -t luna-api:latest .
```

### 2. Iniciar o Container
```bash
docker run -d --name luna-app -p 8080:8080 -p 6379:6379 luna-api:latest
```

### 3. Testar a API Localmente
```bash
curl http://localhost:8080/usuarios
```

### 4. Parar e Remover o Container
```bash
docker stop luna-app && docker rm luna-app
```

---

## 🛠️ Gerenciando o Servidor

### Iniciar o servidor
```bash
openresty -p . -c conf/nginx.conf
```

### Recarregar alterações (Hot-Reload)
Sempre que alterar arquivos `.lua` ou `.conf`, use para aplicar sem derrubar o servidor:
```bash
openresty -p . -c conf/nginx.conf -s reload
```

### Parar o servidor
```bash
openresty -p . -c conf/nginx.conf -s stop
```

### Forçar encerramento (se a porta 8080 estiver ocupada)
```bash
sudo killall nginx openresty
```

---

## 🧪 Endpoints da API

| Método | Rota | Autenticação | Descrição |
| :--- | :--- | :--- | :--- |
| **POST** | `/token` | Pública | Gera o Bearer Token JWT (Padrão OAuth 2.0) |
| **GET** | `/usuarios` | `x-api-key` + `Bearer Token` | Lista todos os usuários cadastrados |
| **POST** | `/usuarios` | `x-api-key` + `Bearer Token` | Cadastra um novo usuário |
| **PUT** | `/usuarios/:id` | `x-api-key` + `Bearer Token` | Atualiza os dados de um usuário pelo ID |
| **DELETE** | `/usuarios/:id` | `x-api-key` + `Bearer Token` | Remove um usuário pelo ID |

---

## 💻 Exemplos de Requisições (`curl`)

**1. Gerar Bearer Token (OAuth 2.0):**
```bash
curl -X POST http://localhost:8080/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=luna_cli_dev&client_secret=7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e&grant_type=client_credentials&scope=read write"
```

**2. Listar Usuários:**
```bash
curl http://localhost:8080/usuarios \
  -H "x-api-key: bHVuYV9hcGlfdjFfc2VjcmV0X2FjY2Vzc19rZXlfMjAyNg==" \
  -H "Authorization: Bearer <SEU_TOKEN_JWT>"
```

**3. Criar Usuário:**
```bash
curl -X POST http://localhost:8080/usuarios \
  -H "x-api-key: bHVuYV9hcGlfdjFfc2VjcmV0X2FjY2Vzc19rZXlfMjAyNg==" \
  -H "Authorization: Bearer <SEU_TOKEN_JWT>" \
  -H "Content-Type: application/json" \
  -d '{"nome": "Victor", "dev": true}'
```

**4. Atualizar Usuário:**
```bash
curl -X PUT http://localhost:8080/usuarios/1 \
  -H "x-api-key: bHVuYV9hcGlfdjFfc2VjcmV0X2FjY2Vzc19rZXlfMjAyNg==" \
  -H "Authorization: Bearer <SEU_TOKEN_JWT>" \
  -H "Content-Type: application/json" \
  -d '{"nome": "Victor M."}'
```

**5. Apagar Usuário:**
```bash
curl -X DELETE http://localhost:8080/usuarios/1 \
  -H "x-api-key: bHVuYV9hcGlfdjFfc2VjcmV0X2FjY2Vzc19rZXlfMjAyNg==" \
  -H "Authorization: Bearer <SEU_TOKEN_JWT>"
```