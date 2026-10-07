-- lua/controllers/auth_controller.lua
local cors = require("middlewares.cors")
local rate_limit = require("middlewares.rate_limit")
local res = require("utils.response")
local auth_service = require("services.auth_service")

local _M = {}

function _M.handle()
    if not cors.aplicar() then return end
    if not rate_limit.check() then return end

    local metodo = ngx.req.get_method()

    if metodo == "OPTIONS" then
        ngx.status = 200
        return ngx.exit(200)
    end

    if metodo == "POST" then
        ngx.req.read_body()
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

        if grant_type and grant_type ~= "client_credentials" then
            return res.erro(400, "O campo 'grant_type' precisa ser 'client_credentials'")
        end

        local token_data, erro = auth_service.autenticar_cliente(client_id, client_secret, scope)
        if erro then
            return res.erro(401, erro)
        end

        return res.json(200, token_data)
    end

    return res.erro(405, "Método HTTP não suportado nesta rota")
end

return _M