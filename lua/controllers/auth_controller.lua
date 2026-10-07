-- lua/controllers/auth_controller.lua
local auth = require("utils.auth")
local res = require("utils.response")

-- Obtém o método HTTP utilizado na requisição.
local metodo = ngx.req.get_method()

-- POST /token
-- Processa a solicitação de geração de um novo token.
if metodo == "POST" then
    ngx.req.read_body()

    -- Captura os parâmetros enviados no formato application/x-www-form-urlencoded.
    local args, err = ngx.req.get_post_args()

    -- Retorna erro caso os parâmetros não possam ser lidos.
    if not args then
        return res.erro(400, "Falha ao ler os parâmetros form-urlencoded: " .. (err or ""))
    end

    -- Obtém as credenciais e os parâmetros da solicitação.
    local client_id = args["client_id"]
    local client_secret = args["client_secret"]
    local grant_type = args["grant_type"]
    local scope = args["scope"] or "read write"

    -- Valida a presença das credenciais obrigatórias.
    if not client_id or not client_secret then
        return res.erro(400, "Os campos 'client_id' e 'client_secret' são obrigatórios")
    end

    -- Valida o grant_type quando informado na requisição.
    if grant_type and grant_type ~= "client_credentials" then
        return res.erro(400, "O campo 'grant_type' precisa ser 'client_credentials'")
    end

    -- Valida as credenciais e gera o token de acesso.
    local token_data, erro = auth.gerar_token(client_id, client_secret, scope)
    if erro then
        return res.erro(401, erro)
    end

    -- Retorna os dados do token no formato esperado pelo fluxo OAuth2.
    return res.json(200, token_data)
end

-- Retorna 405 para métodos HTTP não suportados nesta rota.
return res.erro(405, "Método HTTP não suportado nesta rota")