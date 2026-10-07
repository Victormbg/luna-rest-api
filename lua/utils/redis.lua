-- lua/utils/redis.lua
local redis = require("resty.redis")
local config = require("config.redis")

local _M = {}

-- Cria e configura uma conexão com o Redis usando as configurações centralizadas.
function _M.get_client()
    local red = redis:new()

    -- Define os timeouts configurados
    red:set_timeouts(config.timeout, config.timeout, config.timeout)

    -- Conecta no Redis com Host e Porta das configurações
    local ok, err = red:connect(config.host, config.port)

    if not ok then
        ngx.log(ngx.ERR, "Falha ao conectar no Redis (", config.host, ":", config.port, "): ", err)
        return nil, err
    end

    return red, nil
end

-- Libera a conexão enviando para o pool de conexões (Keepalive).
function _M.close(red)
    if not red then return end

    local ok, err = red:set_keepalive(config.keepalive_timeout, config.pool_size)

    if not ok then
        ngx.log(ngx.ERR, "Falha ao definir keepalive no Redis: ", err)
        red:close()
    end
end

return _M