-- lua/controllers/usuario_controller.lua
local cjson = require("cjson")
local usuario_service = require("services.usuario_service")
local res = require("utils.response")

-- Importação dos Middlewares e Schemas
local cors = require("middlewares.cors")
local rate_limit = require("middlewares.rate_limit")
local auth = require("middlewares.auth_middleware")
local validator = require("middlewares.validator_middleware")
local usuario_schema = require("schemas.usuario_schema")

-- Execução dos Middlewares em ordem
if not cors.aplicar() then return end
if not rate_limit.check() then return end
if not auth.validar_requisicao() then return end

local metodo = ngx.req.get_method()

if metodo == "OPTIONS" then
    ngx.status = 200
    return ngx.exit(200)
end

local uri = ngx.var.uri
local id_param = uri:match("^/usuarios/([0-9]+)$") or ngx.var.arg_id

-- GET /usuarios
if metodo == "GET" then
    local usuarios = usuario_service.listar_todos()
    return res.json(200, {
        status = "sucesso",
        total = #usuarios,
        dados = usuarios
    })
end

-- POST /usuarios
if metodo == "POST" then
    -- Valida o JSON enviado contra as regras do usuario_schema
    local valido, payload = validator.validar(usuario_schema)
    if not valido then return end

    local usuario_criado = usuario_service.criar(payload)
    if not usuario_criado then
        return res.erro(500, "Erro ao salvar usuário no Redis")
    end

    return res.sucesso(201, "Usuário criado com sucesso!", usuario_criado)
end

-- PUT /usuarios/:id
if metodo == "PUT" then
    local id_num = tonumber(id_param)
    if not id_num then
        return res.erro(400, "É necessário informar um ID numérico válido (ex: /usuarios/1)")
    end

    -- Utiliza a mesma validação por Schema do POST
    local valido, payload = validator.validar(usuario_schema)
    if not valido then return end

    local usuario_atualizado = usuario_service.atualizar(id_num, payload)
    if not usuario_atualizado then
        return res.erro(404, "Usuário não encontrado")
    end

    return res.sucesso(200, "Usuário atualizado com sucesso!", usuario_atualizado)
end

-- DELETE /usuarios/:id
if metodo == "DELETE" then
    local id_num = tonumber(id_param)
    if not id_num then
        return res.erro(400, "É necessário informar um ID numérico válido (ex: /usuarios/1)")
    end

    local sucesso = usuario_service.deletar(id_num)
    if not sucesso then
        return res.erro(404, "Usuário não encontrado")
    end

    return res.sucesso(200, "Usuário removido com sucesso!")
end

return res.erro(405, "Método HTTP não suportado nesta rota")