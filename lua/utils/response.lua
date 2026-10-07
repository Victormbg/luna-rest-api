-- lua/utils/response.lua
local cjson = require("cjson")
local response = {}

-- Configura o cjson para representar tabelas vazias como arrays JSON.
cjson.encode_empty_table_as_object(false)

-- Monta e envia uma resposta JSON padronizada.
-- A ordem dos campos principais é mantida como: status -> mensagem -> dados.
function response.json(status_code, payload)
    -- Define o status HTTP da resposta.
    ngx.status = status_code
    
    local json_str

    -- Trata payloads que possuem o campo "status" para manter a ordem dos campos.
    if type(payload) == "table" and payload.status then
        local parts = {}

        -- Adiciona o status como primeiro campo da resposta.
        table.insert(parts, '"status":' .. cjson.encode(payload.status))
        
        -- Adiciona a mensagem quando informada.
        if payload.mensagem ~= nil then
            table.insert(parts, '"mensagem":' .. cjson.encode(payload.mensagem))
        end
        
        -- Adiciona os dados quando disponíveis.
        if payload.dados ~= nil then
            table.insert(parts, '"dados":' .. cjson.encode(payload.dados))
        end
        
        -- Adiciona campos adicionais, como "total", que não fazem parte da estrutura principal.
        for k, v in pairs(payload) do
            if k ~= "status" and k ~= "mensagem" and k ~= "dados" then
                table.insert(parts, cjson.encode(k) .. ':' .. cjson.encode(v))
            end
        end
        
        -- Monta o JSON final a partir dos campos previamente organizados.
        json_str = "{" .. table.concat(parts, ",") .. "}"
    else
        -- Para payloads sem a estrutura padronizada, utiliza a codificação padrão do cjson.
        json_str = cjson.encode(payload)
    end

    -- Envia o JSON como corpo da resposta HTTP.
    ngx.say(json_str)
    return
end

-- Gera uma resposta de sucesso com status, mensagem e dados opcionais.
function response.sucesso(status_code, mensagem, dados)
    local payload = {
        status = "sucesso",
        mensagem = mensagem
    }

    -- Inclui os dados somente quando informados.
    if dados ~= nil then
        payload.dados = dados
    end

    return response.json(status_code, payload)
end

-- Gera uma resposta de erro padronizada com status e mensagem.
function response.erro(status_code, mensagem)
    return response.json(status_code, {
        status = "erro",
        mensagem = mensagem
    })
end

return response