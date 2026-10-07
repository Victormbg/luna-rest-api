-- lua/utils/env.lua
local env = {}

-- Mantém as variáveis do arquivo .env em memória após a primeira leitura.
local cache_env = nil

-- Obtém uma variável de configuração priorizando .env, variável do sistema
-- e, por último, o valor padrão informado.
function env.get(chave, valor_padrao)
    -- Carrega o arquivo .env somente na primeira consulta.
    if not cache_env then
        cache_env = {}

        local f = io.open(".env", "r")

        if f then
            -- Percorre cada linha do arquivo para identificar chave e valor.
            for linha in f:lines() do
                local k, v = linha:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")

                if k and v then
                    cache_env[k] = v
                end
            end

            f:close()
        end
    end

    -- Prioriza o valor do .env, depois a variável do sistema e o valor padrão.
    return cache_env[chave] or os.getenv(chave) or valor_padrao
end

return env