-- lua/middlewares/cors.lua
local cors = {}

-- Aplica as configurações de CORS para permitir requisições de diferentes origens.
function cors.aplicar()
    -- Permite requisições provenientes de qualquer origem.
    ngx.header["Access-Control-Allow-Origin"] = "*"
    
    -- Define os métodos HTTP permitidos pela API.
    ngx.header["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS"
    
    -- Define os cabeçalhos que podem ser enviados nas requisições.
    ngx.header["Access-Control-Allow-Headers"] = "Content-Type, Authorization, x-api-key"

    -- Trata requisições OPTIONS utilizadas pelo navegador no processo de Preflight.
    if ngx.req.get_method() == "OPTIONS" then
        -- Retorna 204 (No Content), indicando que a requisição está autorizada.
        ngx.status = 204
        ngx.exit(204)
        return false
    end

    -- Permite que a requisição continue para o processamento da API.
    return true
end

return cors