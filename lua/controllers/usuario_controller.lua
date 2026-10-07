-- lua/controllers/usuario_controller.lua
local cjson = require("cjson")
local usuario_service = require("services.usuario_service")
local res = require("utils.response")
local auth = require("utils.auth")

-- Validação de Autenticação (x-api-key ou Bearer Token)
if not auth.validar_requisicao() then
    return
end

local metodo = ngx.req.get_method()
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
    ngx.req.read_body()
    local body_raw = ngx.req.get_body_data()

    if not body_raw or body_raw == "" then
        return res.erro(400, "O corpo da requisição não pode estar vazio")
    end

    local ok, payload = pcall(cjson.decode, body_raw)
    if not ok or not payload.nome then
        return res.erro(400, "Payload JSON inválido. O campo 'nome' é obrigatório")
    end

    local usuario_criado = usuario_service.criar(payload)
    return res.sucesso(201, "Usuário criado com sucesso!", usuario_criado)
end

-- PUT /usuarios/:id
if metodo == "PUT" then
    if not id_param then
        return res.erro(400, "É necessário informar o ID do usuário (ex: /usuarios/1)")
    end

    ngx.req.read_body()
    local body_raw = ngx.req.get_body_data()
    local ok, payload = pcall(cjson.decode, body_raw or "")
    if not ok then
        return res.erro(400, "JSON enviado é inválido")
    end

    local usuario_atualizado = usuario_service.atualizar(tonumber(id_param), payload)
    if not usuario_atualizado then
        return res.erro(404, "Usuário não encontrado")
    end

    return res.sucesso(200, "Usuário atualizado com sucesso!", usuario_atualizado)
end

-- DELETE /usuarios/:id
if metodo == "DELETE" then
    if not id_param then
        return res.erro(400, "É necessário informar o ID do usuário (ex: /usuarios/1)")
    end

    local sucesso = usuario_service.deletar(tonumber(id_param))
    if not sucesso then
        return res.erro(404, "Usuário não encontrado")
    end

    return res.sucesso(200, "Usuário removido com sucesso!")
end

return res.erro(405, "Método HTTP não suportado nesta rota")