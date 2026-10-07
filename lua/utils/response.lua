-- lua/utils/response.lua
local cjson = require("cjson")
local response = {}

cjson.encode_empty_table_as_object(false)

function response.json(status_code, payload)
    ngx.status = status_code
    ngx.say(cjson.encode(payload))
    return
end

-- Resposta Padronizada com status e mensagem
function response.sucesso(status_code, mensagem, dados)
    local payload = {
        status = "sucesso",
        mensagem = mensagem
    }
    if dados ~= nil then
        payload.dados = dados
    end
    return response.json(status_code, payload)
end

function response.erro(status_code, mensagem)
    return response.json(status_code, {
        status = "erro",
        mensagem = mensagem
    })
end

return response