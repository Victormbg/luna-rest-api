-- lua/utils/auth.lua
local cjson = require("cjson")
local res = require("utils.response")
local env = require("utils.env")
local auth = {}

-- Codifica os dados em Base64URL, formato utilizado na estrutura do JWT.
local function base64url_encode(data)
    local b64 = ngx.encode_base64(data)
    if not b64 then return "" end
    return b64:gsub("+", "-"):gsub("/", "_"):gsub("=", "")
end

-- Decodifica dados Base64URL para recuperar o conteúdo original do JWT.
local function base64url_decode(data)
    local remainder = #data % 4
    if remainder > 0 then
        data = data .. string.rep("=", 4 - remainder)
    end
    data = data:gsub("-", "+"):gsub("_", "/")
    return ngx.decode_base64(data)
end

-- Cria o JWT com informações do cliente, escopo e tempo de expiração.
local function criar_jwt(client_id, scope, expires_in)
    local secret = env.get("TOKEN_SECRET_KEY", "9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f")
    local now = ngx.time()

    -- Define o cabeçalho padrão do token JWT.
    local header = { alg = "HS256", typ = "JWT" }
    local header_b64 = base64url_encode(cjson.encode(header))

    -- Define os claims utilizados para identificar e controlar o token.
    local payload = {
        iss = "luna-api",
        sub = client_id,
        iat = now,
        exp = now + expires_in,
        scope = scope or "read write",
        jti = ngx.encode_base64(tostring(now) .. tostring(math.random(100000, 999999)))
    }
    local payload_b64 = base64url_encode(cjson.encode(payload))

    -- Monta a parte do token que será utilizada para gerar a assinatura.
    local string_para_assinar = header_b64 .. "." .. payload_b64
    local assinatura_raw = ngx.hmac_sha1(secret, string_para_assinar)
    local assinatura_b64 = base64url_encode(assinatura_raw)

    -- Retorna o JWT completo no formato Header.Payload.Signature.
    return header_b64 .. "." .. payload_b64 .. "." .. assinatura_b64
end

-- Valida a estrutura, assinatura e expiração do JWT recebido.
local function validar_jwt(token)
    local secret = env.get("TOKEN_SECRET_KEY", "9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f")
    local header_b64, payload_b64, assinatura_fornecida = token:match("^([^%.]+)%.([^%.]+)%.([^%.]+)$")

    -- Garante que o token possua as três partes esperadas do JWT.
    if not header_b64 or not payload_b64 or not assinatura_fornecida then
        return nil, "Formato do token JWT inválido"
    end

    -- Recalcula a assinatura para verificar a integridade do token.
    local string_para_assinar = header_b64 .. "." .. payload_b64
    local assinatura_esperada = base64url_encode(ngx.hmac_sha1(secret, string_para_assinar))

    if assinatura_fornecida ~= assinatura_esperada then
        return nil, "Assinatura do token inválida (Token adulterado ou expirado)"
    end

    -- Decodifica o payload e converte o conteúdo JSON para uma estrutura Lua.
    local payload_json = base64url_decode(payload_b64)
    local ok, payload = pcall(cjson.decode, payload_json or "")

    if not ok or not payload then
        return nil, "Falha ao decodificar o payload do token"
    end

    -- Verifica se o token ainda está dentro do período de validade.
    if ngx.time() > (payload.exp or 0) then
        return nil, "Token expirado. Solicite um novo em /token"
    end

    return payload, nil
end

-- Gera um novo token após validar as credenciais do cliente.
function auth.gerar_token(client_id, client_secret, scope)
    local env_client_id = env.get("CLIENT_ID", "luna_cli_dev")
    local env_client_secret = env.get("CLIENT_SECRET", "7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e")

    -- Compara as credenciais recebidas com as configuradas no ambiente.
    if client_id ~= env_client_id or client_secret ~= env_client_secret then
        return nil, "Client ID ou Client Secret inválidos"
    end

    -- Define a validade do token e gera o JWT.
    local duracao_segundos = 3600
    local jwt_token = criar_jwt(client_id, scope, duracao_segundos)

    return {
        access_token = jwt_token,
        token_type = "Bearer",
        expires_in = duracao_segundos,
        scope = scope or "read write"
    }, nil
end

-- Middleware de validação: exige x-api-key e Authorization Bearer.
function auth.validar_requisicao()
    local headers = ngx.req.get_headers()
    local api_key = headers["x-api-key"]
    local auth_header = headers["authorization"]

    -- Verifica se os dois cabeçalhos obrigatórios foram enviados.
    if not api_key or api_key == "" or not auth_header or auth_header == "" then
        res.erro(401, "Acesso negado. É obrigatório enviar AMBOS os cabeçalhos: 'x-api-key' E 'Authorization: Bearer <token>'")
        return false
    end

    -- Valida a API Key configurada no ambiente.
    local api_key_env = env.get("API_KEY", "bHVuYV9hcGlfdjFfc2VjcmV0X2FjY2Vzc19rZXlfMjAyNg==")
    local api_key_decoded = ngx.decode_base64(api_key_env) or ""
    
    if api_key ~= api_key_env and api_key ~= api_key_decoded then
        res.erro(401, "API Key inválida")
        return false
    end

    -- Extrai o token do header Authorization no padrão Bearer.
    local token = auth_header:match("^Bearer%s+(.+)$")
    if not token then
        res.erro(401, "Formato do header Authorization deve ser 'Bearer <token>'")
        return false
    end

    -- Valida o JWT e seus respectivos claims.
    local payload, err = validar_jwt(token)
    if not payload then
        res.erro(401, err or "Bearer Token inválido")
        return false
    end

    -- Disponibiliza os dados autenticados durante o processamento da requisição.
    ngx.ctx.user = payload
    return true
end

return auth