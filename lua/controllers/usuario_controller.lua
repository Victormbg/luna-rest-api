-- lua/controllers/usuario_controller.lua
local cjson = require("cjson")
local usuario_service = require("services.usuario_service")

local metodo = ngx.req.get_method()
-- Captura o ID diretamente da URI (ex: /usuarios/1 -> extrai "1")
local uri = ngx.var.uri
local id_param = uri:match("^/usuarios/([0-9]+)$") or ngx.var.arg_id

-- GET /usuarios -> Listar todos
if metodo == "GET" then
    local usuarios = usuario_service.listar_todos()

    ngx.status = 200
    ngx.say(cjson.encode({
        sucesso = true,
        total = #usuarios,
        dados = usuarios
    }))
    return
end

-- POST /usuarios -> Criar um novo usuário
if metodo == "POST" then
    ngx.req.read_body()
    local body_raw = ngx.req.get_body_data()

    if not body_raw or body_raw == "" then
        ngx.status = 400
        ngx.say(cjson.encode({ sucesso = false, erro = "O corpo da requisição não pode estar vazio" }))
        return
    end

    local ok, payload = pcall(cjson.decode, body_raw)
    if not ok or not payload.nome then
        ngx.status = 400
        ngx.say(cjson.encode({ sucesso = false, erro = "Payload JSON inválido. O campo 'nome' é obrigatório" }))
        return
    end

    local usuario_criado = usuario_service.criar(payload)

    ngx.status = 201
    ngx.say(cjson.encode({
        sucesso = true,
        mensagem = "Usuário criado com sucesso!",
        dados = usuario_criado
    }))
    return
end

-- DELETE /usuarios/:id -> Excluir usuário pelo ID
if metodo == "DELETE" then
    -- Extrai o ID da URL (ex: /usuarios/1) ou de query param (?id=1)
    local uri = ngx.var.uri
    local id_param = uri:match("^/usuarios/([0-9]+)$") or ngx.var.arg_id

    if not id_param then
        ngx.status = 400
        ngx.say(cjson.encode({ sucesso = false, erro = "É necessário informar o ID do usuário (ex: /usuarios/1)" }))
        return
    end

    local id_numero = tonumber(id_param)
    if not id_numero then
        ngx.status = 400
        ngx.say(cjson.encode({ sucesso = false, erro = "O ID precisa ser um número válido" }))
        return
    end

    local sucesso = usuario_service.deletar(id_numero)

    if not sucesso then
        ngx.status = 404
        ngx.say(cjson.encode({ sucesso = false, erro = "Usuário não encontrado" }))
        return
    end

    ngx.status = 200
    ngx.say(cjson.encode({
        sucesso = true,
        mensagem = "Usuário de ID " .. id_numero .. " removido com sucesso!"
    }))
    return
end

-- Caso o cliente envie PUT ou outros métodos não tratados
ngx.status = 405
ngx.say(cjson.encode({ sucesso = false, erro = "Método HTTP não suportado nesta rota" }))