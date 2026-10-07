-- lua/middlewares/auth_middleware.lua
local res = require("utils.response")
local env = require("config.env")
local auth_service = require("services.auth_service")

local _M = {}

-- Middleware de validação para rotas protegidas (ex: /usuarios)
function _M.validar_requisicao()
    local headers = ngx.req.get_headers()
    local api_key = headers["x-api-key"]
    local auth_header = headers["authorization"]

    if not api_key or api_key == "" or not auth_header or auth_header == "" then
        res.erro(401, "Acesso negado. É obrigatório enviar AMBOS os cabeçalhos: 'x-api-key' E 'Authorization: Bearer <token>'")
        return false
    end

    local api_key_env = env.get("API_KEY", "bHVuYV9hcGlfdjFfc2VjcmV0X2FjY2Vzc19rZXlfMjAyNg==")
    local api_key_decoded = ngx.decode_base64(api_key_env) or ""

    if api_key ~= api_key_env and api_key ~= api_key_decoded then
        res.erro(401, "API Key inválida")
        return false
    end

    local token = auth_header:match("^Bearer%s+(.+)$")
    if not token then
        res.erro(401, "Formato do header Authorization deve ser 'Bearer <token>'")
        return false
    end

    local payload, err = auth_service.validar_jwt(token)
    if not payload then
        res.erro(401, err or "Bearer Token inválido")
        return false
    end

    ngx.ctx.user = payload
    return true
end

return _M