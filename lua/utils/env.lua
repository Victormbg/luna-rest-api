-- lua/utils/env.lua
local env = {}
local cache_env = nil

function env.get(chave, valor_padrao)
    if not cache_env then
        cache_env = {}
        local f = io.open(".env", "r")
        if f then
            for linha in f:lines() do
                local k, v = linha:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")
                if k and v then
                    cache_env[k] = v
                end
            end
            f:close()
        end
    end

    return cache_env[chave] or os.getenv(chave) or valor_padrao
end

return env