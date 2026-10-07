-- lua/services/auth_service.lua
local cjson = require("cjson")
local env = require("config.env")

local _M = {}

local function base64url_encode(data)
    local b64 = ngx.encode_base64(data)
    if not b64 then return "" end
    return b64:gsub("+", "-"):gsub("/", "_"):gsub("=", "")
end

local function base64url_decode(data)
    local remainder = #data % 4
    if remainder > 0 then
        data = data .. string.rep("=", 4 - remainder)
    end
    data = data:gsub("-", "+"):gsub("_", "/")
    return ngx.decode_base64(data)
end

-- Gera o JWT com base no client_id e scope
local function criar_jwt(client_id, scope, expires_in)
    local secret = env.get("TOKEN_SECRET_KEY", "9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f")
    local now = ngx.time()

    local header = { alg = "HS256", typ = "JWT" }
    local header_b64 = base64url_encode(cjson.encode(header))

    local payload = {
        iss = "luna-api",
        sub = client_id,
        iat = now,
        exp = now + expires_in,
        scope = scope or "read write",
        jti = ngx.encode_base64(tostring(now) .. tostring(math.random(100000, 999999)))
    }
    local payload_b64 = base64url_encode(cjson.encode(payload))

    local string_para_assinar = header_b64 .. "." .. payload_b64
    local assinatura_raw = ngx.hmac_sha1(secret, string_para_assinar)
    local assinatura_b64 = base64url_encode(assinatura_raw)

    return header_b64 .. "." .. payload_b64 .. "." .. assinatura_b64
end

-- Autentica as credenciais do cliente e retorna o payload do token
function _M.autenticar_cliente(client_id, client_secret, scope)
    local env_client_id = env.get("CLIENT_ID", "luna_cli_dev")
    local env_client_secret = env.get("CLIENT_SECRET", "7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e")

    if client_id ~= env_client_id or client_secret ~= env_client_secret then
        return nil, "Client ID ou Client Secret inválidos"
    end

    local duracao_segundos = 3600
    local jwt_token = criar_jwt(client_id, scope, duracao_segundos)

    return {
        access_token = jwt_token,
        token_type = "Bearer",
        expires_in = duracao_segundos,
        scope = scope or "read write"
    }, nil
end

-- Decodifica e valida a assinatura/expiração do JWT
function _M.validar_jwt(token)
    local secret = env.get("TOKEN_SECRET_KEY", "9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f")
    local header_b64, payload_b64, assinatura_fornecida = token:match("^([^%.]+)%.([^%.]+)%.([^%.]+)$")

    if not header_b64 or not payload_b64 or not assinatura_fornecida then
        return nil, "Formato do token JWT inválido"
    end

    local string_para_assinar = header_b64 .. "." .. payload_b64
    local assinatura_esperada = base64url_encode(ngx.hmac_sha1(secret, string_para_assinar))

    if assinatura_fornecida ~= assinatura_esperada then
        return nil, "Assinatura do token inválida (Token adulterado ou expirado)"
    end

    local payload_json = base64url_decode(payload_b64)
    local ok, payload = pcall(cjson.decode, payload_json or "")

    if not ok or not payload then
        return nil, "Falha ao decodificar o payload do token"
    end

    if ngx.time() > (payload.exp or 0) then
        return nil, "Token expirado. Solicite um novo em /token"
    end

    return payload, nil
end

return _M