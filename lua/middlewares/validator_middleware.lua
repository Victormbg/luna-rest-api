-- lua/middlewares/validator_middleware.lua
local cjson = require("cjson")
local res = require("utils.response")

local _M = {}

-- Valida um payload de acordo com um schema fornecido
function _M.validar(schema)
    ngx.req.read_body()
    local body_raw = ngx.req.get_body_data()

    if not body_raw or body_raw == "" then
        res.erro(400, "O corpo da requisição não pode estar vazio")
        return false, nil
    end

    local ok, payload = pcall(cjson.decode, body_raw)
    if not ok or type(payload) ~= "table" then
        res.erro(400, "JSON enviado é inválido ou malformatado")
        return false, nil
    end

    -- Percorre as regras definidas no Schema
    for campo, regra in pairs(schema) do
        local valor = payload[campo]

        -- 1. Checa se é obrigatório
        if regra.required and valor == nil then
            res.erro(400, string.format("O campo '%s' é obrigatório", campo))
            return false, nil
        end

        -- 2. Checa o tipo de dado (se o valor foi enviado)
        if valor ~= nil then
            if type(valor) ~= regra.type then
                res.erro(400, string.format("O campo '%s' deve ser do tipo '%s'", campo, regra.type))
                return false, nil
            end

            -- 3. Executa função de validação customizada (se existir no schema)
            if regra.custom then
                local erro_custom = regra.custom(valor)
                if erro_custom then
                    res.erro(400, erro_custom)
                    return false, nil
                end
            end
        end
    end

    return true, payload
end

return _M