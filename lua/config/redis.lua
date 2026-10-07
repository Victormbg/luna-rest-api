-- lua/config/redis.lua
local _M = {}

_M.host = os.getenv("REDIS_HOST") or "127.0.0.1"
_M.port = tonumber(os.getenv("REDIS_PORT")) or 6379
_M.timeout = tonumber(os.getenv("REDIS_TIMEOUT")) or 1000 -- 1s

-- Configurações de Connection Pooling
_M.keepalive_timeout = 10000 -- 10 segundos
_M.pool_size = 100            -- Máximo de conexões no pool

return _M