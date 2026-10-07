-- lua/utils/response.lua
local cjson = require("cjson")
local response = {}

cjson.encode_empty_table_as_object(false)

-- Força o cjson a ordenar as chaves alfabeticamente no JSON final
-- Como "mensagem" vem depois de "status" ("m" < "s"), precisamos inverter ou usar codificação direta
function response.json(status_code, payload)
    ngx.status = status_code
    
    -- Montamos a string JSON diretamente para garantir estritamente a ordem "status" -> "mensagem" -> "dados"
    local json_str
    if type(payload) == "table" and payload.status then
        local parts = {}
        table.insert(parts, '"status":' .. cjson.encode(payload.status))
        
        if payload.mensagem ~= nil then
            table.insert(parts, '"mensagem":' .. cjson.encode(payload.mensagem))
        end
        
        if payload.dados ~= nil then
            table.insert(parts, '"dados":' .. cjson.encode(payload.dados))
        end
        
        -- Inclui outros campos extras se houver (ex: total)
        for k, v in pairs(payload) do
            if k ~= "status" and k ~= "mensagem" and k ~= "dados" then
                table.insert(parts, cjson.encode(k) .. ':' .. cjson.encode(v))
            end
        end
        
        json_str = "{" .. table.concat(parts, ",") .. "}"
    else
        json_str = cjson.encode(payload)
    end

    ngx.say(json_str)
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