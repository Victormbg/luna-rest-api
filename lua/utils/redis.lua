local redis = require("resty.redis")

local _M = {}

-- Cria e configura uma conexão com o Redis.
function _M.get_client()
    local red = redis:new()

    -- Define timeout de 1 segundo para conexão, envio e leitura.
    red:set_timeouts(1000, 1000, 1000)

    -- Estabelece conexão com o Redis local na porta padrão.
    local ok, err = red:connect("127.0.0.1", 6379)

    -- Registra o erro e interrompe o processamento caso a conexão falhe.
    if not ok then
        ngx.log(ngx.ERR, "Falha ao conectar no Redis: ", err)
        return nil, err
    end

    return red, nil
end

-- Libera a conexão com o Redis após o uso.
function _M.close(red)
    -- Não executa nenhuma operação quando não existe conexão.
    if not red then return end

    -- Mantém a conexão no pool para permitir seu reaproveitamento.
    local ok, err = red:set_keepalive(10000, 100)

    -- Fecha a conexão caso ela não possa ser devolvida ao pool.
    if not ok then
        red:close()
    end
end

return _M