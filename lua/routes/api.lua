-- lua/routes/api.lua
local res = require("utils.response")

local uri = ngx.var.uri
local prefix = ngx.config.prefix() .. "lua/"

-- Rota de Token de Autenticação (/token)
if uri == "/token" then
    return dofile(prefix .. "controllers/auth_controller.lua")
end

-- Rota de Usuários (/usuarios e /usuarios/:id)
if uri:match("^/usuarios") then
    return dofile(prefix .. "controllers/usuario_controller.lua")
end

-- Caso nenhuma rota corresponda
return res.erro(404, "Rota não encontrada")