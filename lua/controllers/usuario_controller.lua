-- lua/controllers/usuario_controller.lua
local cjson = require("cjson")
local usuario_service = require("services.usuario_service")
local res = require("utils.response")
local auth = require("utils.auth")

-- Valida a autenticação antes de permitir o processamento da requisição.
if not auth.validar_requisicao() then
    return
end

-- Obtém o método HTTP, URI e ID informado na rota ou como parâmetro de query.
local metodo = ngx.req.get_method()
local uri = ngx.var.uri
local id_param = uri:match("^/usuarios/([0-9]+)$") or ngx.var.arg_id

-- GET /usuarios
-- Retorna a lista de usuários cadastrados.
if metodo == "GET" then
    local usuarios = usuario_service.listar_todos()

    return res.json(200, {
        status = "sucesso",
        total = #usuarios,
        dados = usuarios
    })
end

-- POST /usuarios
-- Cria um novo usuário a partir do payload enviado na requisição.
if metodo == "POST" then
    ngx.req.read_body()
    local body_raw = ngx.req.get_body_data()

    -- Valida se a requisição possui um corpo.
    if not body_raw or body_raw == "" then
        return res.erro(400, "O corpo da requisição não pode estar vazio")
    end

    -- Valida e converte o payload JSON para uma tabela Lua.
    local ok, payload = pcall(cjson.decode, body_raw)
    if not ok or not payload.nome then
        return res.erro(400, "Payload JSON inválido. O campo 'nome' é obrigatório")
    end

    -- Persiste o novo usuário e retorna o registro criado.
    local usuario_criado = usuario_service.criar(payload)
    return res.sucesso(201, "Usuário criado com sucesso!", usuario_criado)
end

-- PUT /usuarios/:id
-- Atualiza os dados de um usuário existente.
if metodo == "PUT" then
    -- O ID é obrigatório para identificar o usuário.
    if not id_param then
        return res.erro(400, "É necessário informar o ID do usuário (ex: /usuarios/1)")
    end

    ngx.req.read_body()
    local body_raw = ngx.req.get_body_data()

    -- Valida o JSON recebido no corpo da requisição.
    local ok, payload = pcall(cjson.decode, body_raw or "")
    if not ok then
        return res.erro(400, "JSON enviado é inválido")
    end

    -- Atualiza o usuário e trata o cenário em que o ID não existe.
    local usuario_atualizado = usuario_service.atualizar(tonumber(id_param), payload)
    if not usuario_atualizado then
        return res.erro(404, "Usuário não encontrado")
    end

    return res.sucesso(200, "Usuário atualizado com sucesso!", usuario_atualizado)
end

-- DELETE /usuarios/:id
-- Remove um usuário pelo ID informado na rota.
if metodo == "DELETE" then
    -- O ID é obrigatório para realizar a exclusão.
    if not id_param then
        return res.erro(400, "É necessário informar o ID do usuário (ex: /usuarios/1)")
    end

    -- Executa a remoção e valida se o usuário existia.
    local sucesso = usuario_service.deletar(tonumber(id_param))
    if not sucesso then
        return res.erro(404, "Usuário não encontrado")
    end

    return res.sucesso(200, "Usuário removido com sucesso!")
end

-- Retorna 405 para métodos HTTP que não possuem tratamento nesta rota.
return res.erro(405, "Método HTTP não suportado nesta rota")