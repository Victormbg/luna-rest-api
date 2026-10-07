-- lua/middlewares/rate_limit.lua
local res = require("utils.response")
local rate_limit = {}

-- Memória local do worker para contagem de IP
local requisicoes_ip = {}

-- Configurações padrão: Máximo 60 requisições por minuto por IP
local MAX_REQUISICOES = 60
local JANELA_TEMPO = 60 

function rate_limit.check()
    local client_ip = ngx.var.remote_addr or "127.0.0.1"
    local now = ngx.time()

    local registro = requisicoes_ip[client_ip]

    if not registro or (now - registro.inicio) > JANELA_TEMPO then
        -- Reinicia a janela de tempo do IP
        requisicoes_ip[client_ip] = {
            inicio = now,
            contador = 1
        }
        return true
    end

    if registro.contador >= MAX_REQUISICOES then
        res.erro(429, "Muitas requisições (Rate Limit atingido). Aguarde um instante.")
        return false
    end

    registro.contador = registro.contador + 1
    return true
end

return rate_limit