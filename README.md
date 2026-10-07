# 🌙 Luna REST API (OpenResty + Lua)

API RESTful de altíssima performance construída com **Lua** e **OpenResty**, seguindo uma arquitetura limpa e desacoplada em camadas (Controller, Service e Utils).

---

## 📁 Estrutura do Projeto

```text
luna-rest-api/
├── .vscode/          # Configurações do ambiente de desenvolvimento
├── conf/
│   └── nginx.conf    # Configuração de borda e rotas do OpenResty
├── db/
│   └── usuarios.json # Armazenamento de dados local
├── logs/             # Logs de execução e erros
├── lua/
│   ├── controllers/  # Manipulação de requisições e respostas HTTP
│   ├── services/     # Lógica de negócio e gestão de dados
│   └── utils/        # Helpers reutilizáveis (respostas JSON, etc.)
├── .gitignore
└── README.md
```

---

## 🚀 Como Executar no GitHub Codespaces

Se estiver configurando o ambiente manualmente sem a automação do `.devcontainer`:

### 1. Instalar Dependências (Apenas na 1ª vez)

```bash
# Adiciona o repositório oficial do OpenResty
wget -qO - [https://openresty.org/package/pubkey.gpg](https://openresty.org/package/pubkey.gpg) | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/openresty.gpg
echo "deb [http://openresty.org/package/ubuntu](http://openresty.org/package/ubuntu) jammy main" | sudo tee /etc/apt/sources.list.d/openresty.list

# Atualiza e instala os pacotes
sudo apt-get update && sudo apt-get install -y openresty mysql-server
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

| Método | Rota | Descrição |
| :--- | :--- | :--- |
| **GET** | `/usuarios` | Lista todos os usuários cadastrados |
| **POST** | `/usuarios` | Cadastra um novo usuário |
| **PUT** | `/usuarios/:id` | Atualiza os dados de um usuário pelo ID |
| **DELETE** | `/usuarios/:id` | Remove um usuário pelo ID |

---

## 💻 Exemplos de Requisições (`curl`)

**1. Listar Usuários:**
```bash
curl http://localhost:8080/usuarios
```

**2. Criar Usuário:**
```bash
curl -X POST http://localhost:8080/usuarios \
  -H "Content-Type: application/json" \
  -d '{"nome": "Victor", "dev": true}'
```

**3. Atualizar Usuário:**
```bash
curl -X PUT http://localhost:8080/usuarios/1 \
  -H "Content-Type: application/json" \
  -d '{"nome": "Victor M."}'
```

**4. Apagar Usuário:**
```bash
curl -X DELETE http://localhost:8080/usuarios/1
```