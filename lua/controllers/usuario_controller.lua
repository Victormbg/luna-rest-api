-- lua/controllers/usuario_controller.lua
local cjson = require("cjson")
local usuario_service = require("services.usuario_service")

local metodo = ngx.req.get_method()

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

-- Caso o cliente envie PUT, DELETE ou outros métodos não tratados
ngx.status = 405
ngx.say(cjson.encode({ sucesso = false, erro = "Método HTTP não suportado nesta rota" }))