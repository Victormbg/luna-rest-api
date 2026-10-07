-- lua/controllers/auth_controller.lua
local auth = require("utils.auth")
local res = require("utils.response")

local metodo = ngx.req.get_method()

if metodo == "POST" then
    ngx.req.read_body()
    -- Captura os parâmetros do formato form-urlencoded
    local args, err = ngx.req.get_post_args()

    if not args then
        return res.erro(400, "Falha ao ler os parâmetros form-urlencoded: " .. (err or ""))
    end

    local client_id = args["client_id"]
    local client_secret = args["client_secret"]
    local grant_type = args["grant_type"]
    local scope = args["scope"] or "read write"

    if not client_id or not client_secret then
        return res.erro(400, "Os campos 'client_id' e 'client_secret' são obrigatórios")
    end

    -- Valida o grant_type se necessário (padrão OAuth 2.0 usa client_credentials)
    if grant_type and grant_type ~= "client_credentials" then
        return res.erro(400, "O campo 'grant_type' precisa ser 'client_credentials'")
    end

    local token_data, erro = auth.gerar_token(client_id, client_secret, scope)
    if erro then
        return res.erro(401, erro)
    end

    -- Retorna diretamente os dados do Token no formato padrão OAuth2
    return res.json(200, token_data)
end

return res.erro(405, "Método HTTP não suportado nesta rota")