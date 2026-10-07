# 🌙 Luna REST API (OpenResty + Lua)

API de altíssima performance construída com Lua e OpenResty.

## 🚀 Como Executar no GitHub Codespaces

Se você estiver abrindo o ambiente manualmente sem a automação do devcontainer, execute no terminal:

### 1. Instalar as dependências (Apenas na 1ª vez)
```bash
sudo apt-get update && sudo apt-get install -y openresty mysql-server

### 2. Iniciar openresty
```bash
openresty -p . -c conf/nginx.conf

### 3. Parar openresty
```bash
openresty -p . -c conf/nginx.conf -s stop